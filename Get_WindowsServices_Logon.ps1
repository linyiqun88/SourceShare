$serviceFilter = "LocalSystem"#, "NT AUTHORITY\NetworkService"
#Testing on local 
Get-WMIObject Win32_Service | Where-Object{$serviceFilter.Contains($_.StartName)} | Format-Table name, startname, startmode, state
#Run on different Servers
#Get-WMIObject Win32_Service -ComputerName comname | Where-Object{$serviceFilter.Contains($_.StartName)} | Format-Table name, startname, startmode, state
#

