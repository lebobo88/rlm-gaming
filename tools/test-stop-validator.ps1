[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$validator = Join-Path $PSScriptRoot '..\plugins\rlm-gaming\scripts\validate-stop.ps1'
$session = 'rlm-stop-validator-test-' + [guid]::NewGuid().ToString('N')
$powershell = (Get-Process -Id $PID).Path

function Invoke-Validator {
    param([string]$Agent, [string]$Message)
    $jsonInput = @{ session_id = $session; agent_type = $Agent; last_assistant_message = $Message; hook_event_name = 'SubagentStop'; stop_hook_active = $false } | ConvertTo-Json -Compress
    # Exercise the same stdin JSON channel Claude Code uses for command hooks.
    $raw = $jsonInput | & $powershell -NoProfile -File $validator
    $parsed = $raw | ConvertFrom-Json
    return $parsed
}

$valid = Invoke-Validator 'the-director' 'DECISION_RECORD: pillars and decomposition complete. Delegated all code as a PRD and DEV_TASK.'
if ($null -ne $valid.decision -or $null -ne $valid.continue) { throw 'Valid director response must be allowed.' }

$first = Invoke-Validator 'the-director' 'Pillars are complete.'
if ($first.decision -ne 'block' -or $first.reason -notmatch 'attempt 1 of 2') { throw 'First invalid response must request repair 1.' }
$second = Invoke-Validator 'the-director' 'Pillars are complete.'
if ($second.decision -ne 'block' -or $second.reason -notmatch 'attempt 2 of 2') { throw 'Second invalid response must request repair 2.' }
$final = Invoke-Validator 'the-director' 'Pillars are complete.'
if ($final.continue -ne $false -or $final.stopReason -notmatch 'after two repair attempts') { throw 'Third invalid response must terminate fail-closed.' }

$sentinel = Invoke-Validator 'the-sentinel' 'Checked game.client_authority, game.anticheat_absent, game.unsigned_genai_asset, game.pii_telemetry, and game.exploit_economy. Kan entry requires_human=true.'
if ($null -ne $sentinel.decision -or $null -ne $sentinel.continue) { throw 'Complete Sentinel evidence must be allowed.' }

Write-Output 'stop validator tests: passed'
