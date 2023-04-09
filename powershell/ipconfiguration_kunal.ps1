#This obj will store the adaper detail which is enabled.
$obj= Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}

Write-Output "											~ IP Configuration Report ~"

# Initializing a counter variable and an array to hold the IP configuration information
$i = 0
$report = @()

	<# 
	This foreach loop i have created to extract the description, adapter index and other details for each of the adapter found in the system which is then stored in variable.
	#>
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
		"DHCP Server" = if($adapterobj.DHCPServer){$adapterobj.DHCPServer} else { "N/A"}
		

	}

        $report += $item
        $i++

}

$report | Format-Table -AutoSize 
