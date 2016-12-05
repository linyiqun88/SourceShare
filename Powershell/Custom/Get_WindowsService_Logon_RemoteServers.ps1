#Script version: 1.0
#Script to be run on different servers to retrieve the service and there logons
#Status: Development
#Output: Logging for services retrieved from multiple servers are saved in the host server which is running the script

#Servers to be defined
$servers = "servername"
#Service account to filter
#$serviceFilter = "local"
#p3ris@P3dev.mindef.gov.sg
#Path of the log files
$logfile = "C:\test.txt"

$out = foreach($server in $servers){
    invoke-command -cn $server -scriptblock {
        Param($server,$serviceFilter)
        $serviceFilter = "Local"
        "{0} :Begin windows service checking for {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$server       
        #Get-WMIObject Win32_Service | Where-Object{$serviceFilter.Contains($_.StartName)} | Format-Table name, startname, startmode, state
        $list = Get-WMIObject Win32_Service | Where-Object{$serviceFilter.Contains($_.StartName)} | select name, startname, startmode, state #Format-List name, startname, startmode, state
        foreach($item in $list)
        {
             "{0} ,Window service name {1}, Logon: {2}, Startmode: {3}, State: {4}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$item.name, $item.startname, $item.startmode, $item.state
        }
    } -ArgumentList $server
}

$out | Out-File $logfile