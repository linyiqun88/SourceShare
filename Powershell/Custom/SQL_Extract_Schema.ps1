# I'm wrapping everything into a function, it's just easier to reuse
function GenerateSPsScript([string]$serverName, [string]$dbname, [string]$scriptpath, [string]$condition,[string]$dropcreate,[string]$ExtractType)
{
  # Lets load the SMO assembly first (this is basically a collection of SQL Server related objects)
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
   
  # Lets initiate a SQL server object
  $srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $serverName
   
  # Lets prepare a Database object and connect to it
  $db = New-Object "Microsoft.SqlServer.Management.SMO.Database"
  $db = $srv.Databases[$dbname] 
   
  # And finally lets create a Scripter object
  $scr = New-Object "Microsoft.SqlServer.Management.SMO.Scripter"
  $scr.Server = $srv
   
  # Now we can prepare the options for the Scripter object. Check this web site for the details:
  # https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.scriptingoptions.aspx
  $options = New-Object "Microsoft.SqlServer.Management.SMO.ScriptingOptions"
  $options.AllowSystemObjects = $false
  $options.IncludeDatabaseContext = $false
  $options.IncludeIfNotExists = $false
  $options.Default = $true
  $options.IncludeHeaders = $false #This is hide the headers like data time when generating the script
  $options.ToFileOnly = $true
  $options.AppendToFile = $true
  if($dropcreate -eq "Drop"){$options.ScriptDrops = $true}

   
  # Lets set the option of the target file name and create a text file where the SPs code will be exported
  #$options.FileName = $scriptpath + "\$($dbname)_modified_stored_procs_$(get-date -f yyyy-MM-dd).sql"
  #New-Item $options.FileName -type file -force | Out-Null
   
  # now apply the above options to the SMO.Scripter object
  $scr.Options = $options
  
  if($ExtractType -eq "Both" -or $ExtractType -eq "Stored Procedure")
  {
    # OK, connection and settings are ready. Now we can start working with the database objects
  # We want to work with the Stored Procedures, so lets grab all the non-system SPs
  $StoredProcedures = $db.StoredProcedures | where {$_.IsSystemObject -eq $false}
  $CountStoredProcedures = $StoredProcedures.Count
  $CounterStoredProcedures = 1
   
  # Say you need to export only the SPs that were modified during the last 7 days
  $cd = Get-Date
  $d = $cd.AddDays(-0)
  $d = "2018-10-25"

  #
  #Retrieve the list of scripts that is being affected
   
  # Now for every SP we will execute the Script method
  Foreach ($StoredProcedure in $StoredProcedures)
  {
    #Write-Host "Checking:  $StoredProcedure, Last modified: $($StoredProcedure.DateLastModified) , Exported upper: $d" -ForegroundColor Yellow
    $temp = $StoredProcedure.ToString()
    $temp2 = $temp.split('.')[1]
    $result1= $temp2 -replace '[[]',''
    $result2 = $result1 -replace '[]]',''
   
    #Include progress bar
    $percentComplete = ($CounterStoredProcedures / $CountStoredProcedures) * 100

    #if ($StoredProcedures -ne $null -and $StoredProcedure.DateLastModified -ge $d -and $StoredProcedure -like '*SXAMAG*')
    if ($StoredProcedures -ne $null -and $StoredProcedure -like "*$condition*")
    #if ($StoredProcedures -ne $null -and $PublisherScripts.Contains("$StoredProcedure") -or $SubscriberScripts.Contains("$StoredProcedure"))
    {   
      # Script the Stored Procedure
      Write-Progress -Activity 'Processing $StoredProcedures' -Status "Processing $CounterStoredProcedures out of $CountStoredProcedures" -PercentComplete $percentComplete
        $options.FileName = $scriptpath + "\$result2.sql"
        New-Item $options.FileName -type file -force | Out-Null
        Write-Host "Exporting:  $StoredProcedure" -ForegroundColor Green
      $scr.Script($StoredProcedure)
    }
    $CounterStoredProcedures = $CounterStoredProcedures + 1
  }
  }

  if($ExtractType -eq "Both" -or $ExtractType -eq "User Defined Functions")
  {
  #Extract for functions
  $UserDefinedFunctions = $db.UserDefinedFunctions | where {$_.IsSystemObject -eq $false}
  $CountUserDefinedFunctions = $UserDefinedFunctions.Count
  $CounterUserDefinedFunctions = 1

  Foreach ($UserDefinedFunction in $UserDefinedFunctions)
  {
    #Write-Host "Checking:  $StoredProcedure, Last modified: $($StoredProcedure.DateLastModified) , Exported upper: $d" -ForegroundColor Yellow
    $temp = $UserDefinedFunction.ToString()
    $temp2 = $temp.split('.')[1]
    $result1= $temp2 -replace '[[]',''
    $result2 = $result1 -replace '[]]',''
   
    #Include progress bar
    $percentComplete = ($CounterUserDefinedFunctions / $CountUserDefinedFunctions ) * 100

    #if ($StoredProcedures -ne $null -and $StoredProcedure.DateLastModified -ge $d -and $StoredProcedure -like '*SXAMAG*')
    if ($UserDefinedFunction -ne $null -and $UserDefinedFunction -like "*$condition*")
    #if ($StoredProcedures -ne $null -and $PublisherScripts.Contains("$StoredProcedure") -or $SubscriberScripts.Contains("$StoredProcedure"))
    {   
      # Script the Stored Procedure
      Write-Progress -Activity "Processing $UserDefinedFunction" -Status "Processing $CounterUserDefinedFunctions out of $CountUserDefinedFunctions" -PercentComplete $percentComplete
        $options.FileName = $scriptpath + "\$result2.sql"
        New-Item $options.FileName -type file -force | Out-Null
        Write-Host "Exporting user defined functions:  $UserDefinedFunction" -ForegroundColor Green
      $scr.Script($UserDefinedFunction)
    }
    $CounterUserDefinedFunctions = $CounterUserDefinedFunctions + 1
  }


  }
  



} 
# Function is completed
 
# Finally we call the above function by putting our environment details
# If you have a default instance then just put the server name
GenerateSPsScript "DatabaseInstance" "Database Name" "D:\temp\Drop" "" "Drop" "User Defined Functions"
#GenerateSPsScript "DatabaseInstance" "Database Name" "D:\temp\Create" "" "Create" "User Defined Functions"