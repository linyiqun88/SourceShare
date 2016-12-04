#Script version: 1.0
#Script to be run on different servers to retrieve the service and there logons
#Status: Complete
#Output: Retrieving service account logon to the services

$serviceFilter = "LocalSystem"#, "NT AUTHORITY\NetworkService"
#Testing on local 
Get-WMIObject Win32_Service | Where-Object{$serviceFilter.Contains($_.StartName)} | Format-Table name, startname, startmode, state
#Run on different Servers.

