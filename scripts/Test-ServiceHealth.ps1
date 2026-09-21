[CmdletBinding()]
param(
    [string]$ConfigPath = "./config/services.json",
    [string]$ReportDirectory = "./reports",
    [switch]$NoExport
)

if (-not (Test-Path $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$services = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$results = foreach ($service in $services) {
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $status = 'DOWN'
    $httpStatus = $null
    $errorMessage = $null

    try {
        $response = Invoke-WebRequest -Uri $service.Url -Method Get -MaximumRedirection 5 -ErrorAction Stop
        $httpStatus = [int]$response.StatusCode
        if ($httpStatus -ge 200 -and $httpStatus -lt 400) {
            $status = 'UP'
        } else {
            $status = 'DEGRADED'
        }
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $httpStatus = [int]$_.Exception.Response.StatusCode
        }
        $errorMessage = $_.Exception.Message
    } finally {
        $timer.Stop()
    }

    [pscustomobject]@{
        Timestamp  = (Get-Date).ToString('s')
        Name       = $service.Name
        Url        = $service.Url
        Status     = $status
        HttpStatus = $httpStatus
        ResponseMs = $timer.ElapsedMilliseconds
        Error      = $errorMessage
    }
}

if (-not $NoExport) {
    New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $path = Join-Path $ReportDirectory "service-health-$stamp.csv"
    $results | Export-Csv -Path $path -NoTypeInformation
    Write-Verbose "Report written to $path"
}

$results
