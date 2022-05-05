$param0 = "LAPTOP-AG45SSRH\SQLEXPRESS"   #Server Instance
$param1 = "Development"   #Database Name but generated script has hardcoded database name
$param2 = "user1"   #User 
$param3 = "P@ssw0rd"   #Password
$param4 = "E:\Codes\VisualCode\SourceShare\SQL"   #Folder location
#[string]$param5 = "$($(Get-Location).Path)\DeploymentLogs_$(Get-Date -format yyyyMMdd).txt " #Logs location
[string]$param5 = "E:\Temp\DeploymentLogs_Table_TestCreate_$(Get-Date -format yyyyMMdd).txt " #Logs location
#D:\SQLBackup\RestoreFromBoxA


Start-Transcript -Path $param5 -Append

#sqlps
write-host "param0=$param0"
write-host "param1=$param1"
write-host "param2=$param2"
write-host "param3=$param3"
write-host "param4=$param4"
write-host "param5=$param5"

$CountFilesToProcess = $(Get-ChildItem -LiteralPath $param4 |?{$_.Extension -eq ".sql"}).Count
$counterFilesToProcess = 1

Get-ChildItem -LiteralPath $param4 |?{$_.Extension -eq ".sql"}|%{
    $percentComplete = ($counterFilesToProcess / $CountFilesToProcess) * 100
    Write-Progress -Activity "Processing $($_.Name)" -Status "Processing $counterFilesToProcess out of $CountFilesToProcess " -PercentComplete $percentComplete
try{
    Write-Host "Processing $($_.Name)"
    if($param2 -ne "" -and $param3 -ne ""){
        invoke-sqlcmd -serverinstance "$param0" -database $param1 -user $param2 -password $param3 -inputfile "$($_.Fullname)" -querytimeout 0 -ErrorAction Continue
        write-host "Deployment Completed: $($_.Name)"
    }
    else {
        invoke-sqlcmd -serverinstance "$param0" -database $param1 -inputfile "$($_.Fullname)" -querytimeout 0 -ErrorAction Continue
        write-host "Deployment Completed: $($_.Name)"
    }

} catch{
    #write-output "$error" | out-file $param5 -Append
    write-host "Error running $($_.Name) , Either the object already existed"
    Write-Host "$error"
    
}
$counterFilesToProcess = $counterFilesToProcess + 1
}

Stop-Transcript