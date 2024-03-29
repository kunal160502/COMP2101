$env:path += ";$home/Desktop\lab"
New-Alias np notepad.exe


function welcome{
# Lab 2 COMP2101 welcome script for profile
#

write-output "Welcome to planet $env:computername Overlord $env:username"
$now = get-date -format 'HH:MM tt on dddd'
write-output "It is $now."

}

function get-cpuinfo{
$cpu = ciminstance cim_processor 

	foreach ($c in $cpu){
	[PSCustomObject] @{	
		"CPU manufacturer" = $c.Manufacturer
		"CPU Model" = $c.name
		"Speed Current" = $c.currentclockspeed
		"Speed Max" = $c.maxclockspeed
		"Core processor" = $c.numberofcores
		
		}
	}

}

function get-mydisks{

$disk = Get-CimInstance -ClassName Win32_DiskDrive

	foreach ($d in $disk){
	[PSCustomObject] @{	
		"Disk Manufacturer" = $d.Manufacturer
		"Disk Model" =$d.Model
		"Serial Number" = $d.SerialNumber
		"FirmwareRevision" = $d.FirmwareRevision
		"Disk Size" = $d.Size
		
		}
	}

}
