[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Target,

    [ValidateRange(1,65535)]
    [int]$Port = 443,

    [ValidateRange(1,30)]
    [int]$TimeoutSeconds = 5
)

$dnsOk = $false
$addresses = @()
try {
    $addresses = [System.Net.Dns]::GetHostAddresses($Target) | ForEach-Object IPAddressToString
    $dnsOk = $addresses.Count -gt 0
} catch {
    $dnsError = $_.Exception.Message
}

$icmpOk = $false
try {
    $icmpOk = [bool](Test-Connection -TargetName $Target -Count 2 -Quiet -ErrorAction Stop)
} catch {
    $icmpError = $_.Exception.Message
}

$tcpOk = $false
$tcpError = $null
$tcp = [System.Net.Sockets.TcpClient]::new()
try {
    $task = $tcp.ConnectAsync($Target, $Port)
    if ($task.Wait([TimeSpan]::FromSeconds($TimeoutSeconds))) {
        $tcpOk = $tcp.Connected
    } else {
        $tcpError = "TCP connection timed out after $TimeoutSeconds seconds"
    }
} catch {
    $tcpError = $_.Exception.Message
} finally {
    $tcp.Dispose()
}

[pscustomobject]@{
    Target        = $Target
    Addresses     = ($addresses -join ', ')
    DNSResolved   = $dnsOk
    ICMPReachable = $icmpOk
    TCPPort       = $Port
    TCPReachable  = $tcpOk
    DNSError      = $dnsError
    ICMPError     = $icmpError
    TCPError      = $tcpError
}
