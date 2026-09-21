[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    throw "CSV not found: $Path"
}

$users = Import-Csv -Path $Path
$findings = foreach ($user in $users) {
    $enabled = $user.Enabled -match '^(?i:true|yes|1)$'
    $groups = @()
    if (-not [string]::IsNullOrWhiteSpace($user.Groups)) {
        $groups = $user.Groups -split ';' | ForEach-Object { $_.Trim() }
    }

    if (-not $enabled) {
        [pscustomobject]@{
            Username   = $user.Username
            Department = $user.Department
            Severity   = 'Review'
            Finding    = 'Account is disabled; confirm whether access/groups should be removed.'
        }
    }

    if ($user.Department -eq 'Finance' -and $groups -notcontains 'Finance-Read') {
        [pscustomobject]@{
            Username   = $user.Username
            Department = $user.Department
            Severity   = 'Review'
            Finding    = 'Finance user is missing Finance-Read.'
        }
    }

    if ($user.Department -ne 'Finance' -and $groups -contains 'Finance-Read') {
        [pscustomobject]@{
            Username   = $user.Username
            Department = $user.Department
            Severity   = 'High'
            Finding    = 'Non-Finance user has Finance-Read; verify authorization.'
        }
    }

    if ($groups.Count -eq 0) {
        [pscustomobject]@{
            Username   = $user.Username
            Department = $user.Department
            Severity   = 'Review'
            Finding    = 'No groups recorded; verify expected baseline access.'
        }
    }
}

$findings
