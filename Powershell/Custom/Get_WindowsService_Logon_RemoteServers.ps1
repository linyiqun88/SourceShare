#Script version: 1.0
#Script to be run on different servers to retrieve the service and there logons
#Status: Development
#Output: Logging for services retrieved from multiple servers are saved in the host server which is running the script

#Servers to be defined
$servers = "*h1","*h2", "DESKTOP-360HOOV"
#Service account to filter
$serviceFilter = "LocalSystem"
#Path of the log files
$logfile = "C:\test.txt"

$out = foreach($server in $servers){
    invoke-command -cn $server -scriptblock {
        Param($server,$serviceFilter)
        #"{0} :Begin DLL registration for {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$server
        Get-WMIObject Win32_Service | Where-Object{$serviceFilter.Contains($_.StartName)} | Format-Table name, startname, startmode, state
    } -ArgumentList $server
}

$out | Out-File $logfile