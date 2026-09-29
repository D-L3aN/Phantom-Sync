$ErrorActionPreference = 'SilentlyContinue'
$drv  = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } | Select-Object -First 1).Root
$loot = Join-Path $drv 'loot'
if (!(Test-Path $loot)) { New-Item -ItemType Directory -Path $loot | Out-Null }
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$f  = Join-Path $loot ("{0}_{1}.txt" -f $env:COMPUTERNAME, $ts)

function Section($t) { Add-Content $f "`r`n===== $t =====" }

function Log-System {
    Section 'SYSTEM'
    Add-Content $f "Hostname : $env:COMPUTERNAME"
    Add-Content $f "User     : $env:USERNAME"
    Add-Content $f "OS       : $((Get-CimInstance Win32_OperatingSystem).Caption)"
    Add-Content $f "Build    : $((Get-CimInstance Win32_OperatingSystem).BuildNumber)"
    Add-Content $f "Boot     : $((Get-CimInstance Win32_OperatingSystem).LastBootUpTime)"
}

function Log-Network {
    Section 'ADAPTERS'
    Get-NetIPAddress | Select InterfaceAlias,IPAddress,PrefixLength,AddressFamily |
        Format-Table -Auto | Out-String | Add-Content $f
    Section 'ROUTES'
    Get-NetRoute | Select DestinationPrefix,NextHop,InterfaceAlias |
        Format-Table -Auto | Out-String | Add-Content $f
    Section 'DNS'
    Get-DnsClientServerAddress | Select InterfaceAlias,ServerAddresses |
        Format-Table -Auto | Out-String | Add-Content $f
    Section 'ARP'
    arp -a | Out-String | Add-Content $f
    Section 'ESTABLISHED'
    Get-NetTCPConnection -State Established |
        Select LocalAddress,LocalPort,RemoteAddress,RemotePort,OwningProcess |
        Format-Table -Auto | Out-String | Add-Content $f
}

function Log-Users {
    Section 'LOCAL USERS'
    Get-LocalUser | Select Name,Enabled,LastLogon |
        Format-Table -Auto | Out-String | Add-Content $f
    Section 'SESSIONS'
    quser 2>$null | Out-String | Add-Content $f
    Section 'ADMINS'
    Get-LocalGroupMember -Group 'Administrators' |
        Select Name,PrincipalSource | Format-Table -Auto | Out-String | Add-Content $f
}

function Log-Processes {
    Section 'TOP CPU'
    Get-Process | Sort CPU -Descending | Select -First 20 Name,Id,CPU,WS |
        Format-Table -Auto | Out-String | Add-Content $f
    Section 'RUNNING SERVICES'
    Get-Service | Where Status -eq 'Running' | Select Name,DisplayName |
        Format-Table -Auto | Out-String | Add-Content $f
    Section 'READY TASKS'
    Get-ScheduledTask | Where State -eq 'Ready' | Select TaskName,TaskPath |
        Format-Table -Auto | Out-String | Add-Content $f
}

Clear-Host
Write-Host '=== PHANTOMSYNC ===' -ForegroundColor Cyan
Write-Host '[1] Full profile'
Write-Host '[2] Network only'
Write-Host '[3] User audit'
Write-Host '[4] Process inventory'
Write-Host '[0] Exit'
$choice = Read-Host 'Select option'

switch ($choice) {
    '1' { Section 'FULL PROFILE'; Log-System; Log-Network; Log-Users; Log-Processes }
    '2' { Log-Network }
    '3' { Log-Users }
    '4' { Log-Processes }
    '0' { Add-Content $f 'Cancelled'; exit }
    default { Add-Content $f "Invalid: $choice"; exit }
}

Write-Host "`nDone: $f" -ForegroundColor Cyan
Start-Sleep -Seconds 2
exit