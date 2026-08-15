[CmdletBinding()]
param(
    [string]$HydraSchemaFixture = "contracts/hydra-envelope-contract.v1.json"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Add-Finding {
    param([string]$Severity, [string]$Rule, [string]$Path, [int]$Line, [string]$Message)
    [pscustomobject]@{ severity = $Severity; rule = $Rule; path = $Path; line = $Line; message = $Message }
}

$fixturePath = Join-Path $root $HydraSchemaFixture
if (-not (Test-Path -LiteralPath $fixturePath)) { throw "Missing Hydra schema fixture: $fixturePath" }
$contract = Get-Content -Raw -LiteralPath $fixturePath | ConvertFrom-Json
$findings = [System.Collections.Generic.List[object]]::new()

# Plugin manifest paths are executable configuration, so they are hard failures.
$manifest = Get-Content -Raw -LiteralPath ".claude-plugin/plugin.json" | ConvertFrom-Json
foreach ($relativePath in $manifest.agents) {
    $target = Join-Path $root $relativePath.TrimStart('.', '/')
    if (-not (Test-Path -LiteralPath $target)) {
        $findings.Add((Add-Finding "error" "manifest-path" ".claude-plugin/plugin.json" 0 "Missing agent path: $relativePath"))
    }
}
foreach ($relativePath in @($manifest.skills, $manifest.commands)) {
    $target = Join-Path $root $relativePath.TrimStart('.', '/')
    if (-not (Test-Path -LiteralPath $target)) {
        $findings.Add((Add-Finding "error" "manifest-path" ".claude-plugin/plugin.json" 0 "Missing plugin path: $relativePath"))
    }
}

$files = Get-ChildItem -Recurse -File plugins, README.md, RLM-GAMING.md | Where-Object { $_.Extension -eq ".md" -or $_.Name -eq "README.md" }
foreach ($file in $files) {
    $relative = Resolve-Path -Relative $file.FullName
    $lineNumber = 0
    foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
        $lineNumber++
        if ($line -match '\.claude/(agents|skills|commands)') {
            $findings.Add((Add-Finding "error" "legacy-local-path" $relative $lineNumber "References empty legacy .claude content; use plugins/rlm-gaming instead."))
        }
        foreach ($match in [regex]::Matches($line, '\]\(([^)#]+)(?:#[^)]*)?\)')) {
            $link = $match.Groups[1].Value
            if ($link -match '^(https?:|mailto:|/)') { continue }
            $target = Join-Path $file.DirectoryName ([uri]::UnescapeDataString($link))
            if (-not (Test-Path -LiteralPath $target)) {
                $findings.Add((Add-Finding "error" "local-markdown-link" $relative $lineNumber "Missing local Markdown target: $link"))
            }
        }
        if ($line -match 'payload/attachments|payload of a `(?:PRD|HANDOFF)`|as payload|as the payload|carrying .* as payload') {
            $findings.Add((Add-Finding "warning" "phantom-envelope-field" $relative $lineNumber "Prompt text conflicts with PRD/DevTask/Handoff contract: persist artifacts and reference them via context_refs or use the documented instruction field."))
        }
        if ($line -match '^\s*(payload|attachments|dcc_contract|style_ref):') {
            $findings.Add((Add-Finding "error" "deprecated-envelope-key" $relative $lineNumber "Use a persisted artifact in context_refs; this key is not part of the canonical RLM-Gaming delegation contract."))
        }
        if ($line -match 'model_type:\s*(mesh|rig)' -and $contract.asset_job.model_type -notcontains $Matches[1]) {
            $findings.Add((Add-Finding "warning" "unsupported-asset-model" $relative $lineNumber "Current Hydra AssetJob accepts: $($contract.asset_job.model_type -join ', ')."))
        }
    }
}

[string[]]$evidenceRequirements = @(
    "plugins/rlm-gaming/agents/the-arbiter.md|Evidence rule for time-sensitive claims",
    "plugins/rlm-gaming/skills/game-cert-and-compliance/SKILL.md|source-evidence record",
    "plugins/rlm-gaming/skills/game-economy-and-monetization/SKILL.md|verification artifact"
)
foreach ($requirement in $evidenceRequirements) {
    $parts = $requirement.Split('|', 2)
    $path = Join-Path $root $parts[0]
    if (-not (Test-Path -LiteralPath $path) -or -not ((Get-Content -Raw -LiteralPath $path).Contains($parts[1]))) {
        $findings.Add((Add-Finding "error" "time-sensitive-evidence-rule" $parts[0] 0 "Missing required evidence instruction: $($parts[1])"))
    }
}

# Plugin-provided agent frontmatter hooks are ignored by Claude Code. Stop guards must
# live in the plugin hook manifest and must be deterministic command hooks.
$guardedAgents = @('the-arbiter', 'the-custodian', 'the-director', 'the-forgemaster', 'the-producer', 'the-sentinel', 'the-warden')
$hookManifestPath = Join-Path $root 'plugins/rlm-gaming/hooks/hooks.json'
$validatorPath = Join-Path $root 'plugins/rlm-gaming/scripts/validate-stop.ps1'
if (-not (Test-Path -LiteralPath $hookManifestPath) -or -not (Test-Path -LiteralPath $validatorPath)) {
    $findings.Add((Add-Finding 'error' 'deterministic-stop-gate' 'plugins/rlm-gaming/hooks/hooks.json' 0 'Missing plugin-level deterministic stop hook or validator.'))
} else {
    try {
        $hookManifest = Get-Content -Raw -LiteralPath $hookManifestPath | ConvertFrom-Json
        $handler = $hookManifest.hooks.SubagentStop[0].hooks[0]
        if ($handler.type -ne 'command' -or $handler.command -notmatch 'validate-stop\.ps1') {
            $findings.Add((Add-Finding 'error' 'deterministic-stop-gate' 'plugins/rlm-gaming/hooks/hooks.json' 0 'Expected a SubagentStop command hook that invokes validate-stop.ps1.'))
        }
        foreach ($agent in $guardedAgents) {
            if ($hookManifest.hooks.SubagentStop[0].matcher -notmatch [regex]::Escape($agent)) {
                $findings.Add((Add-Finding 'error' 'deterministic-stop-gate' 'plugins/rlm-gaming/hooks/hooks.json' 0 "Missing SubagentStop matcher for $agent."))
            }
            $agentPath = Join-Path $root "plugins/rlm-gaming/agents/$agent.md"
            if ((Get-Content -Raw -LiteralPath $agentPath) -match '(?ms)^hooks:') {
                $findings.Add((Add-Finding 'error' 'ignored-plugin-agent-hook' "plugins/rlm-gaming/agents/$agent.md" 0 'Plugin agent frontmatter hooks are ignored; use hooks/hooks.json.'))
            }
        }
        $validator = Get-Content -Raw -LiteralPath $validatorPath
        if ($validator -notmatch 'attempts -lt 2' -or $validator -notmatch 'continue = \$false') {
            $findings.Add((Add-Finding 'error' 'bounded-fail-closed-stop-gate' 'plugins/rlm-gaming/scripts/validate-stop.ps1' 0 'Validator must provide two repairs then terminate fail-closed.'))
        }
    } catch {
        $findings.Add((Add-Finding 'error' 'deterministic-stop-gate' 'plugins/rlm-gaming/hooks/hooks.json' 0 "Invalid stop hook configuration: $($_.Exception.Message)"))
    }
}

$summary = $findings | Group-Object severity | ForEach-Object { [pscustomobject]@{ severity = $_.Name; count = $_.Count } }
[pscustomobject]@{
    audit = "rlm-gaming-phase-0"
    contract_fixture = $HydraSchemaFixture
    contract_version = $contract.contract_version
    findings = $findings
    summary = $summary
} | ConvertTo-Json -Depth 6

if (($findings | Where-Object severity -eq "error").Count -gt 0) { exit 1 }
