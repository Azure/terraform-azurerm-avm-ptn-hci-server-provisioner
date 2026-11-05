Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

if ($env:GITHUB_ACTIONS -ne 'true' -or $env:GITHUB_JOB -ne 'pr-check') {
    return
}

$stageRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $env:AVM_HOME -ChildPath 'cache' -AdditionalChildPath 'policy-stage'))
$examplePath = [System.IO.Path]::GetFullPath($PSScriptRoot)
$comparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
if (-not $examplePath.StartsWith($stageRoot + [System.IO.Path]::DirectorySeparatorChar, $comparison)) {
    throw 'Policy inputs may only be created in the isolated policy staging directory.'
}

if ([string]::IsNullOrWhiteSpace($env:ARM_SUBSCRIPTION_ID)) {
    throw 'The selected CI subscription must be supplied in ARM_SUBSCRIPTION_ID.'
}

$inputs = @{
    local_admin_password     = 'policy-plan-only'
    local_admin_user         = 'policy-plan-only'
    location                 = 'eastus'
    resource_group_id        = "/subscriptions/$($env:ARM_SUBSCRIPTION_ID)/resourceGroups/rg-avm-policy-fixture"
    service_principal_id     = '00000000-0000-0000-0000-000000000001'
    service_principal_secret = 'policy-plan-only'
    virtual_host_ip          = '192.0.2.11'
}
$path = Join-Path $PSScriptRoot '.env'
$provided = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($key in [Environment]::GetEnvironmentVariables('Process').Keys) {
    $null = $provided.Add([string] $key)
}
$existing = if (Test-Path -LiteralPath $path) { [System.IO.File]::ReadAllText($path) } else { '' }
foreach ($line in ($existing -split "`n")) {
    $trimmed = $line.Trim()
    if ($trimmed.StartsWith('#')) { continue }
    if ($trimmed.StartsWith('export ')) { $trimmed = $trimmed.Substring(7).TrimStart() }
    $equals = $trimmed.IndexOf('=')
    if ($equals -gt 0) { $null = $provided.Add($trimmed.Substring(0, $equals).Trim()) }
}
$defaults = @(
    foreach ($entry in ($inputs.GetEnumerator() | Sort-Object Key)) {
        $key = "TF_VAR_$($entry.Key)"
        if (-not $provided.Contains($key)) { "$key=$($entry.Value)" }
    }
)
if ($defaults.Count -gt 0) {
    $separator = if ($existing.Length -gt 0 -and -not $existing.EndsWith("`n") -and -not $existing.EndsWith("`r")) { "`n" } else { '' }
    [System.IO.File]::AppendAllText($path, $separator + ($defaults -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
}
