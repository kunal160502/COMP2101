# this will check if the filename was passed as a command-line argument while running report file.
param(
  [String]$arg1
)

	<# 
	i have created this functions to extract the details forcthe system
	which is then stored in variable.
	#>

# Hardware system
function get-hardware{
$hardware = Get-WmiObject -Class Win32_ComputerSystem
$obj = [ordered]@{
"Hardware Manufacturer" = $hardware.Manufacturer
"Hardware Model" = $hardware.Model
"Total Physical Memory" = [math]::Round($hardware.TotalPhysicalMemory / 1GB, 2)
"Hardware Description" = $hardware.Description
"System Type" = $hardware.SystemType
}
return $obj | Format-List
}

# Operating system
Function get-os{
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $obj =[PSCustomObject]@{
   "System Name" = $os.Caption
  "Version Number" =  $os.Version

}
    return $obj
}

# processor information
function get-processor {
    $processor = Get-WmiObject -Class Win32_Processor
    $obj= [PSCustomObject] @{
    "Name" = $processor.Name
    "Number of Cores" = $processor.NumberOfCores
    "Speed" = $processor.MaxClockSpeed
    "L1 Cache Size" = if ($processor.L1CacheSize) { $($processor.L1CacheSize[0] / 1KB) } else { "N/A" }
    "L2 Cache Size" = if ($processor.L2CacheSize) { $($processor.L2CacheSize[0] / 1KB) } else { "N/A" }
    "L3 Cache Size" = if ($processor.L3CacheSize) { $($processor.L3CacheSize[0] / 1KB) } else { "N/A" }
    }
    return $obj | Format-List
}

# Ram memory information
Function get-memory {
   $memory = Get-WmiObject -Class Win32_PhysicalMemory
    $tolram = 0
       
    $obj = foreach ($RAMmemory in $memory) {
         [PSCustomObject] @{
            "Vendor" = $RAMmemory.Manufacturer
            "Description" = $RAMmemory.Description
            "Capacity" = "{0:N2} GB" -f ($RAMmemory.Capacity / 1GB)
            "Bank/Slot" = $RAMmemory.DeviceLocator
            "Memory Type" = $RAMmemory.MemoryType
            Speed = $RAMmemory.Speed
        }
          $tolram += $RAMmemory.Capacity
            
    }  $obj   | format-table -autosize
   
    Write-Output "Total of $(('{0:N2}' -f ($tolram / 1GB))) GB Ram Memory is installed in the system"
 }


# Disk drive information
function get-disk{
 $diskdrives = Get-CIMInstance CIM_diskdrive

  foreach ($disk in $diskdrives) {
      $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
      foreach ($partition in $partitions) {
            $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
	$freeSpace = [math]::Round(($logicaldisk.FreeSpace / $logicaldisk.Size) * 100, 2)
		$obj = [PSCustomObject]@{

			Manufacturer=$disk.Manufacturer
                                                          Model=$disk.Model     
			 Size = "{0:N2} GB" -f ($logicaldisk.Size / 1GB)
               			 "Free Space" = "{0:N2} GB" -f ($logicaldisk.FreeSpace / 1GB)
			"Free space in %" = "$freeSpace%"
                                                     }
		 $obj
           }
      }
  }

}

#network information
function get-network{
$obj= Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}
$i = 0
$report = @()
    while ($i -lt $obj.Count) {
        $adapterobj = $obj[$i]
        $item = [PSCustomObject]@{

            "Adapter Description" = if ($adapterobj.Description){$adapterobj.Description} else { "N/A"}
            "Index" = if($adapterobj.Index){$adapterobj.Index} else { "N/A"}
            "IP Address" = if($adapterobj.IPAddress){$adapterobj.IPAddress} else { "N/A"}
            "Subnet Mask" = if($adapterobj.IPSubnet){$adapterobj.IPSubnet} else { "N/A"}
            "DNS Domain Name" = if($adapterobj.DNSDomain){$adapterobj.DNSDomain} else { "N/A"}
            "DNS Server" = if($adapterobj.DNSServerSearchOrder){$adapterobj.IPSubnet} else { "N/A"}
            "Default Gateway" = if($adapterobj.DefaultIPGateway){$adapterobj.DefaultIPGateway} else { "N/A"}
            "MAC Address" = if($adapterobj.MACAddress){$adapterobj.MACAddress} else { "N/A"}

	}

        $report += $item
        $i++

}
$report | Format-Table -AutoSize 
}
                                                         
# video Controller information
function get-controller {
    $controller = Get-WmiObject -Class Win32_VideoController
    $obj= foreach ($video in $controller) {
        [PSCustomObject]@{
            Vendor = $video.VideoProcessor
            Description = $video.Description
            Resolution = "{0}x{1}" -f $video.CurrentHorizontalResolution, $video.CurrentVerticalResolution
        }
    }
    $obj
}


<#
I have this section for formating the displayed output in powershell screen
#>

if ($arg1 -eq "system") {
#this will display the ouput report
Write-Output "      "
Write-Output "     					---------------------- "
Write-Output "				      |  System Information |"
Write-Output "     					---------------------- "
Write-Output "				Hardware Information"
Write-Output "				---------------------"
get-hardware 
Write-Output "      "
Write-Output "      "

#operating system
Write-Output "				Operating Information"
Write-Output "				-----------------------"
get-os | Format-List
Write-Output "      "
Write-Output "      "

# processor
Write-Output "				Processor Information"
Write-Output "				------------------------"
get-processor
Write-Output "      "

#Memory
Write-Output "				RAM Information"
Write-Output "				-----------------"
get-memory 
Write-Output "      "
Write-Output "      "

# video controller
Write-Output "				Video Controller Information"
Write-Output "				--------------------------"
get-controller | Format-List
Write-Output "      "
}

elseif ($arg1 -eq "disks") {
#Disk
Write-Output "				-----------------"
Write-Output "				Disk Information"
Write-Output "				-----------------"
get-disk  | format-table -autosize
Write-Output "      "
Write-Output "      "
}

elseif ($arg1 -eq "network") {
#Network
Write-Output "				-----------------"
Write-Output "				Network Information"
Write-Output "				-------------------"
get-network
Write-Output "      "
}

else{

#this will display the ouput report
Write-Output "      "
Write-Output "     					--------------------------- "
Write-Output "				      |  System Information Report  |"
Write-Output "     					--------------------------- "
Write-Output "				Hardware Information"
Write-Output "				---------------------"
get-hardware 
Write-Output "      "
Write-Output "      "

#operating system
Write-Output "				Operating Information"
Write-Output "				-----------------------"
get-os | Format-List
Write-Output "      "
Write-Output "      "

# processor
Write-Output "				Processor Information"
Write-Output "				------------------------"
get-processor
Write-Output "      "

#Memory
Write-Output "				RAM Information"
Write-Output "				-----------------"
get-memory 
Write-Output "      "
Write-Output "      "

#Disk
Write-Output "				Disk Information"
Write-Output "				-----------------"
get-disk  | format-table -autosize
Write-Output "      "
Write-Output "      "


#Network
Write-Output "				Network Information"
Write-Output "				-------------------"
get-network
Write-Output "      "

# video controller
Write-Output "				Video Controller Information"
Write-Output "				--------------------------"
get-controller | Format-List
Write-Output "      "
}