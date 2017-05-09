function get-hostinfo    
{ 
    Begin { 
        Write-output "Starting inventory Collection" 
    } 
     
    Process { 
    #parsing out the result from computer LDAP name to computer netbios name 
    $x=$_.split(",") 
    $server=$x[0].Substring(3) 
    Write-Host $server 
     
    trap { 
        Write-Host -ForegroundColor Red "   <<<Spider Alert>>>  Error connecting to server : " $server ". Please make sure that the server is online and that WMI Queries are enabled." 
        continue 
        } 
     
    #Nullifying Wmi Queries results from previous objects , to fix the problem of assigning previous Wmi Query values to offline servers 
    $pingresult=0 
    $RamResult=0 
    $ModelResult=0 
    $CpuResult=0 
    $DiskResult=0 
         
         
    #Quering Wmi for certian properties to collect information for the computer 
    $pingresult = Get-WmiObject -Query "SELECT * FROM Win32_PingStatus WHERE Address = '$server'" -ErrorAction Stop 
    $RamResult = Get-WmiObject -Query "SELECT * from Win32_PhysicalMemory" -computername $server -ErrorAction Stop 
    $ModelResult = Get-WmiObject -Query "SELECT * from Win32_ComputerSystem" -computername $server -ErrorAction Stop 
    $CpuResult = Get-Wmiobject -Query "select * from Win32_Processor" -ComputerName $server -ErrorAction Stop 
    $DiskResult = Get-Wmiobject -Query "select * from Win32_DiskDrive" -ComputerName $server -ErrorAction Stop 
    $OSResult = Get-WmiObject -Query "select * from win32_operatingsystem" -ComputerName $server -ErrorAction stop 
    $appresult = Get-WmiObject -Query "select * from win32_Product" -ComputerName $server -ErrorAction stop 
     
    #creating a new object called computer 
    $Computer = New-Object psobject 
     
    #the following section Adds properties to the computer Object  
 
    #Adding properties from ping result 
    $Computer | Add-Member NoteProperty Name $server 
    $Computer | Add-Member NoteProperty ResponseTime ($pingresult.responsetime) 
    $Computer | Add-Member NoteProperty IPAddress ($pingresult.protocoladdress) 
     
    #Adding a property called Siteloation depending on te computer ipaddress 
    if ($pingresult.protocoladdress.StartsWith('10.1.1.')) 
        {$Computer | Add-Member NoteProperty Sitelocation ("Site1") 
        } 
    elseif ($pingresult.protocoladdress.StartsWith('10.1.2.')) 
        {$Computer | Add-Member NoteProperty Sitelocation ("Site2")     
        } 
    else { 
        $Computer | Add-Member NoteProperty Sitelocation ("UNKNOWN") 
    } 
     
    #Adding a property for Server Model 
    $Model = $ModelResult.Manufacturer + $ModelResult.Model 
    $Computer | Add-Member NoteProperty SrvModel ($Model) 
     
    #Adding a properties for processor including clock speed , Number of cores and Number of physical processsorts 
    #if the lenght of the object cpuresult is greater than 0 , then there are more than one instance of the Win32_processor class which means 
    #there are more than one physical processor on the server , since all physical cpuz on the same board are identical then getting the result 
    #from object[0] in the collection does the trick 
    if ($CpuResult.length ) 
        { 
        $Computer | Add-Member Noteproperty CpuMHZ ($cpuresult[0].maxclockspeed) 
        $Computer | Add-Member Noteproperty ProcessorCores ($CpuResult[0].NumberOfCores) 
        $Computer | Add-Member NoteProperty PhysicalProcessors ($CpuResult.length) 
         
    } 
    elseif ( -not $CpuResult.length)  
        {  
        $Computer | Add-Member Noteproperty CpuMHZ ($cpuresult.maxclockspeed) 
        $Computer | Add-Member Noteproperty ProcessorCores ($CpuResult.NumberOfCores) 
        $Computer | Add-Member NoteProperty PhysicalProcessors ('0') 
    } 
     
    #Adding a property for total number of Rams 
    #doing a ram counter and accumelating the capacity property of all the instances of Win32_PhysicalMemory Class 
    $ramcounter = 0 
    $RamResult | ForEach-Object { $ramcounter = $ramcounter + $_.Capacity } 
    $Computer | Add-Member NoteProperty RAMS ($ramcounter / 1048576) 
     
    #Adding property for total Disk space  
    $storagecounter = 0 
    $DiskResult | ForEach-Object { 
                            if ($_.mediatype -eq "Fixed hard disk media") 
                            {$storagecounter = $storagecounter + $_.size} 
    } 
    $Computer | Add-Member NoteProperty TotalStorageGB ([int]($storagecounter / 1gb )) 
     
    #Adding properties for OS type and Version number 
    $Computer | Add-Member NoteProperty OSType ($OSResult.caption) 
    $Computer | Add-Member NoteProperty Servicepack ($OSResult.csdversion) 
     
    #adding a property for the installed applications 
    $apparray = "" 
    $appresult | ForEach-Object { $apparray = ( $apparray + $_.name + "," ) } 
    $Computer | Add-Member Noteproperty AppList ( $apparray ) 
     
    Write-Output $Computer 
        } 
         
    End { 
    Write-host "end of Inventory Collection" 
    } 
     
} 
get-hostinfo