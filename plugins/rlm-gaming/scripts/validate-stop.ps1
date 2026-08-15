[CmdletBinding()]
param(
    [string]$InputJson
)

$ErrorActionPreference = 'Stop'

function Write-HookJson {
    param([hashtable]$Value)
    [Console]::Out.Write(($Value | ConvertTo-Json -Compress -Depth 5))
}

function Test-Markers {
    param(
        [string]$Text,
        [string[]]$Patterns
    )

    $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($pattern in $Patterns) {
        if ($Text -notmatch $pattern) {
            $missing.Add($pattern)
        }
    }
    return $missing
}

try {
    if ([string]::IsNullOrWhiteSpace($InputJson)) {
        $InputJson = [Console]::In.ReadToEnd()
    }
    $event = $InputJson | ConvertFrom-Json
    $agent = [string]$event.agent_type
    $message = [string]$event.last_assistant_message
    $requirements = @{
        'the-arbiter' = @('(?i)\b(verdict|decision)\b', '(?i)\bIARC\b', '(?i)\b(cert|certification|platform)\b', '(?i)\b(not applicable|none|HANDOFF|legal)\b')
        'the-custodian' = @('(?i)\b(season|event|hotfix|A/B)\b', '(?i)\b(approval|gate|greenlight)\b', '(?i)\b(PRD|DEV_TASK|CREATIVE_BRIEF|ASSET_JOB)\b')
        'the-director' = @('(?i)\b(DECISION_RECORD|pillar|decomposition)\b', '(?i)\b(PRD|DEV_TASK|CREATIVE_BRIEF|ASSET_JOB)\b')
        'the-forgemaster' = @('(?i)\b(engine|Unity|Unreal|Godot)\b', '(?i)\b(perf|performance|budget)\b', '(?i)\b(PRD|DEV_TASK)\b')
        'the-producer' = @('(?i)\b(task graph|backlog|milestone)\b', '(?i)\bcritical path\b', '(?i)\b(HITL|greenlight|content-lock|ship)\b', '(?i)\b(PRD|DEV_TASK|CREATIVE_BRIEF|ASSET_JOB)\b')
        'the-sentinel' = @('(?i)\bgame\.client_authority\b', '(?i)\bgame\.anticheat_absent\b', '(?i)\bgame\.unsigned_genai_asset\b', '(?i)\bgame\.pii_telemetry\b', '(?i)\bgame\.exploit_economy\b', '(?i)\b(Kan|requires_human)\b')
        'the-warden' = @('(?i)\b(strategy|test plan|balance)\b', '(?i)\b(accessibility|accessible)\b', '(?i)\b(PRD|DEV_TASK|no test code)\b')
    }

    if (-not $requirements.ContainsKey($agent)) {
        throw "Unexpected RLM Gaming agent type: $agent"
    }
    if ([string]::IsNullOrWhiteSpace($message)) {
        $missing = @('a non-empty final response')
    } else {
        $missing = Test-Markers -Text $message -Patterns $requirements[$agent]
    }

    $stateRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'rlm-gaming-stop-hooks'
    $safeKey = (([string]$event.session_id + '-' + $agent) -replace '[^A-Za-z0-9_.-]', '_')
    $statePath = Join-Path $stateRoot ($safeKey + '.json')

    if ($missing.Count -eq 0) {
        if (Test-Path -LiteralPath $statePath) {
            Remove-Item -LiteralPath $statePath -Force
        }
        Write-HookJson @{}
        exit 0
    }

    $attempts = 0
    if (Test-Path -LiteralPath $statePath) {
        try { $attempts = [int]((Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json).attempts) } catch { $attempts = 2 }
    }
    $details = ($missing | ForEach-Object { "missing /$_/" }) -join '; '

    if ($attempts -lt 2) {
        New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
        @{ attempts = $attempts + 1 } | ConvertTo-Json -Compress | Set-Content -LiteralPath $statePath -NoNewline
        Write-HookJson @{ decision = 'block'; reason = "RLM stop gate rejected [$agent]. Repair attempt $($attempts + 1) of 2: $details. Update the final deliverable with the required explicit evidence." }
        exit 0
    }

    if (Test-Path -LiteralPath $statePath) {
        Remove-Item -LiteralPath $statePath -Force
    }
    Write-HookJson @{ continue = $false; stopReason = "RLM stop gate rejected [$agent] after two repair attempts: $details. The run is terminated without an allow decision." }
    exit 0
} catch {
    Write-HookJson @{ continue = $false; stopReason = "RLM stop gate validator failed closed: $($_.Exception.Message)" }
    exit 0
}
