[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $root 'plugins\rlm-gaming\scripts\validate-stop.ps1'
$powershell = (Get-Process -Id $PID).Path

function Invoke-StopValidator {
    param([string]$Agent, [string]$Message, [string]$Session)
    $eventJson = @{
        session_id = $Session
        agent_type = $Agent
        last_assistant_message = $Message
        hook_event_name = 'SubagentStop'
        stop_hook_active = $false
    } | ConvertTo-Json -Compress
    $raw = $eventJson | & $powershell -NoProfile -File $validator
    return ($raw | ConvertFrom-Json)
}

$validScenarios = @{
    'the-arbiter' = 'Verdict: PASS. IARC answers are consistent; the platform CERT checklist is complete. Legal review: none.'
    'the-custodian' = 'Season event plan is inside the approval gate. All content work is routed as a PRD and DEV_TASK.'
    'the-director' = 'DECISION_RECORD: pillars and decomposition complete. Delegated all code as a PRD and DEV_TASK.'
    'the-forgemaster' = 'Unity engine selected with a per-platform performance budget. Engineering receives a PRD and DEV_TASK.'
    'the-producer' = 'Milestone backlog defines the critical path and a greenlight HITL. Delegated work uses a PRD and DEV_TASK.'
    'the-sentinel' = 'Checked game.client_authority, game.anticheat_absent, game.unsigned_genai_asset, game.pii_telemetry, and game.exploit_economy. Kan entry requires_human=true.'
    'the-warden' = 'Test strategy covers the accessibility floor; no test code was authored inline.'
}

foreach ($scenario in $validScenarios.GetEnumerator()) {
    $session = 'phase4-valid-' + $scenario.Key + '-' + [guid]::NewGuid().ToString('N')
    $result = Invoke-StopValidator -Agent $scenario.Key -Message $scenario.Value -Session $session
    if ($null -ne $result.decision -or $null -ne $result.continue -or $null -ne $result.stopReason) {
        throw "Expected valid scenario to be allowed for $($scenario.Key)."
    }
}

foreach ($agent in $validScenarios.Keys) {
    $session = 'phase4-invalid-' + $agent + '-' + [guid]::NewGuid().ToString('N')
    $result = Invoke-StopValidator -Agent $agent -Message 'Complete.' -Session $session
    if ($result.decision -ne 'block' -or $result.reason -notmatch 'Repair attempt 1 of 2') {
        throw "Expected missing-evidence scenario to block for $agent."
    }
}

Write-Output "phase 4 scenarios: passed ($($validScenarios.Count) valid and $($validScenarios.Count) missing-evidence cases)"
