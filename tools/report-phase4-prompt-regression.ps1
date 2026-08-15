[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$agents = @('the-arbiter', 'the-custodian', 'the-director', 'the-forgemaster', 'the-producer', 'the-sentinel', 'the-warden')
$rows = foreach ($agent in $agents) {
    $relative = "plugins/rlm-gaming/agents/$agent.md"
    $current = Get-Content -Raw -LiteralPath (Join-Path $root $relative)
    $baseline = git -C $root show "HEAD:$relative"
    $currentFrontmatter = [regex]::Match($current, '(?s)^---\r?\n(.*?)\r?\n---').Groups[1].Value
    $baselineFrontmatter = [regex]::Match(($baseline -join "`n"), '(?s)^---\r?\n(.*?)\r?\n---').Groups[1].Value
    [pscustomobject]@{
        agent = $agent
        baseline_frontmatter_chars = $baselineFrontmatter.Length
        current_frontmatter_chars = $currentFrontmatter.Length
        delta_chars = $currentFrontmatter.Length - $baselineFrontmatter.Length
        estimated_delta_tokens = [math]::Round(($currentFrontmatter.Length - $baselineFrontmatter.Length) / 4.0, 1)
    }
}

$regressions = $rows | Where-Object { $_.delta_chars -gt 0 }
if ($regressions) {
    throw "Unexpected agent-frontmatter prompt growth: $($regressions.agent -join ', ')."
}

[pscustomobject]@{
    audit = 'phase-4-agent-frontmatter-prompt-regression'
    method = 'UTF-16 character delta; estimated tokens are characters divided by four and are informational only'
    rows = $rows
    total_delta_chars = ($rows | Measure-Object delta_chars -Sum).Sum
    total_estimated_delta_tokens = [math]::Round((($rows | Measure-Object estimated_delta_tokens -Sum).Sum), 1)
} | ConvertTo-Json -Depth 4
