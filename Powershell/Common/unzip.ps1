#Author: Clement
#Created date: 22 September 2016
#Description: This powershell script is provide upzipping 
##########################################################################################################################################
#Configuration Parameters
$Zipfile = $args[0]         #Zip location and filename       (Example: "D:\TEST\testzip\testzip1.zip" )
$extractDir = $args[1]      #Path to find files to unzip       (Example: "D:\TEST\testzip\testzip1")

$Zipfile = "C:\Users\yiquncl\Desktop\Personal\Powershell\Zip_unzip\DeploymentFiles_osnid2.zip"
$extractDir = "C:\Users\yiquncl\Desktop\Personal\Powershell\Zip_unzip\unzippedFiles"

Add-Type -AssemblyName System.IO.Compression.FileSystem

#$extractDir = 'D:\TEST\testzip\unzipped'

#$zip = [System.IO.Compression.ZipFile]::OpenRead('D:\TEST\testzip\testzip1.zip')

$zip = [System.IO.Compression.ZipFile]::OpenRead($Zipfile)

foreach ($item in $zip.Entries) {

    try {

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($item,(Join-Path -Path $extractDir -ChildPath $item.FullName),$false)

    } catch {

        $count = 0
        $extension = $item.FullName.Substring($item.FullName.LastIndexOf('.'))
        $fileName = $item.FullName.Substring(0,$item.FullName.LastIndexOf('.'))
        $found = $false

        do {
        
            if (!(Test-Path (Join-Path -Path $extractDir -ChildPath "$fileName ($count)$extension"))) {
            
                $found = $true
            
            } else {

                $count++

            }
        
        } until ($found -eq $true)

       $newFileName = "$fileName ($count)$extension"

       [System.IO.Compression.ZipFileExtensions]::ExtractToFile($item,(Join-Path -Path $extractDir -ChildPath $newFileName),$false)

    }

}
$zip.Dispose()
