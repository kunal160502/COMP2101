#!/bin/bash
# this script displays system information

# TASK: This script produces a report. It does not communicate errors or deal with the user pressing ^C
#       Create the 4 functions described in the comments for
#         help display
#         error message display (2 of these)
#         temporary files cleanup to be used with interrupts
#       Create a trap command to attach your interrupt handling function to the signal that will be received if the user presses ^C while the script is running

# Start of section to be done for TASK
# This is where your changes will go for this TASK

# This function will send an error message to stderr
# Usage:
#   error-message ["some text to print to stderr"]
function error-message {
    #$1 will store the dynamic error message
    echo "Error: Unknown argument '$1'. See '$0 --help' for usage." >&2
}

# This function will send a message to stderr and exit with a failure status
# Usage:
#   error-exit ["some text to print to stderr" [exit-status]]
function error-exit {
#sending the dynamic message stored to std which will be added in commmand line 1
  error-message "$1"
  exit "${2:-1}" 

}
#This function displays help information if the user asks for it on the command line or gives us a bad command line
function displayhelp {
echo "  "
echo "-------------------------------------------"
echo "Usage: $0 [-h | -v]"
echo "Display system information"
echo "-------------------------------------------"
echo "      "
echo "  -h    display the help"
echo "  -v    display output version information"
echo "--------------------------------------------"
echo "     "
}

# This function will remove all the temp files created by the script
# The temp files are all named similarly, "/tmp/somethinginfo.$$"
# A trap command is used after the function definition to specify this function is to be run if we get a ^C while running

function cleanup {
  # Cleanups every the temporary files
  rm -f /tmp/*info.$$
  exit 1 
}

trap cleanup SIGINT

#using switch case to identify which function needs to be called.
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
        #Displaying help
      displayhelp
      exit 
      ;;
    -v|--version)
        #Displaying version
      echo "The version of $0 file name is version 1.0"
      exit 
      ;;
    *)
      error-exit "Invalid option: try -h or -v along with file e.g. name.sh -h"
      ;; 
  esac
   # I am deleting the first argument from the list of arguments using shift
  shift
done

# display the output
echo " "
echo "-------------------------------------------------"
echo "System Information:"
echo "-------------------------------------------------"
echo " " 
echo "  - Hostname: $(hostname)"
echo "  - System Uptime: $(uptime | awk '{print $3 " " $4}')"
echo "  - Memory Usage: $(free | awk '/Mem/{printf("used: %dMB (%.2f%%), ", ($2-$7)/1024, 100*($2-$7)/$2)} /buffers\/cache/{printf("buff/cache: %dMB (%.2f%%)\n", $4/1024, 100*$4/$2)}')"
echo "  - CPU Usage: $(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{printf("user: %.2f%%, system: %.2f%%, idle: %.2f%%\n", 100-$1, $1, $4)}')" 
echo "-------------------------------------------------"

# End of section to be done for TASK
# Remainder of script does not require any modification, but may need to be examined in order to create the functions for TASK

# DO NOT MODIFY ANYTHING BELOW THIS LINE
#This function produces the network configuration for our report
function getipinfo {
  # reuse our netid.sh script from lab 4
  netid.sh
}

# process command line options
partialreport=
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayhelp
      error-exit
      ;;
    --host)
      hostnamewanted=true
      partialreport=true
      ;;
    --domain)
      domainnamewanted=true
      partialreport=true
      ;;
    --ipconfig)
      ipinfowanted=true
      partialreport=true
      ;;
    --os)
      osinfowanted=true
      partialreport=true
      ;;
    --cpu)
      cpuinfowanted=true
      partialreport=true
      ;;
    --memory)
      memoryinfowanted=true
      partialreport=true
      ;;
    --disk)
      diskinfowanted=true
      partialreport=true
      ;;
    --printer)
      printerinfowanted=true
      partialreport=true
      ;;
    *)
      error-exit "$1 is invalid"
      ;;
  esac
  shift
done

# gather data into temporary files to reduce time spent running lshw
sudo lshw -class system >/tmp/sysinfo.$$ 2>/dev/null
sudo lshw -class memory >/tmp/memoryinfo.$$ 2>/dev/null
sudo lshw -class bus >/tmp/businfo.$$ 2>/dev/null
sudo lshw -class cpu >/tmp/cpuinfo.$$ 2>/dev/null

# extract the specific data items into variables
systemproduct=`sed -n '/product:/s/ *product: //p' /tmp/sysinfo.$$`
systemwidth=`sed -n '/width:/s/ *width: //p' /tmp/sysinfo.$$`
systemmotherboard=`sed -n '/product:/s/ *product: //p' /tmp/businfo.$$|head -1`
systembiosvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/memoryinfo.$$|head -1`
systembiosversion=`sed -n '/version:/s/ *version: //p' /tmp/memoryinfo.$$|head -1`
systemcpuvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/cpuinfo.$$|head -1`
systemcpuproduct=`sed -n '/product:/s/ *product: //p' /tmp/cpuinfo.$$|head -1`
systemcpuspeed=`sed -n '/size:/s/ *size: //p' /tmp/cpuinfo.$$|head -1`
systemcpucores=`sed -n '/configuration:/s/ *configuration:.*cores=//p' /tmp/cpuinfo.$$|head -1`

# gather the remaining data needed
sysname=`hostname`
domainname=`hostname -d`
osname=`sed -n -e '/^NAME=/s/^NAME="\(.*\)"$/\1/p' /etc/os-release`
osversion=`sed -n -e '/^VERSION=/s/^VERSION="\(.*\)"$/\1/p' /etc/os-release`
memoryinfo=`sudo lshw -class memory|sed -e 1,/bank/d -e '/cache/,$d' |egrep 'size|description'|grep -v empty`
ipinfo=`getipinfo`
diskusage=`df -h -t ext4`
printerlist="`lpstat -e`
Default printer: `lpstat -d|cut -d : -f 2`"

# create output

[[ (! "$partialreport" || "$hostnamewanted") && "$sysname" ]] &&
  echo "Hostname:     $sysname" >/tmp/sysreport.$$
[[ (! "$partialreport" || "$domainnamewanted") && "$domainname" ]] &&
  echo "Domainname:   $domainname" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$osinfowanted") && "$osname" && "$osversion" ]] &&
  echo "OS:           $osname $osversion" >>/tmp/sysreport.$$
[[ ! "$partialreport" || "$cpuinfowanted" ]] &&
  echo "System:       $systemproduct ($systemwidth)
Motherboard:  $systemmotherboard
BIOS:         $systembiosvendor $systembiosversion
CPU:          $systemcpuproduct from $systemcpuvendor
CPU config:   $systemcpuspeed with $systemcpucores core(s) enabled" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$memoryinfowanted") && "$memoryinfo" ]] &&
  echo "RAM installed:
$memoryinfo" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$diskinfowanted") && "$diskusage" ]] &&
  echo "Disk Usage:
$diskusage" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$printerinfowanted") && "$printerlist" ]] &&
  echo "Printer(s):
$printerlist" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$ipinfowanted") && "$ipinfo" ]] &&
  echo "IP Configuration:" >>/tmp/sysreport.$$ &&
  echo "$ipinfo" >> /tmp/sysreport.$$

cat /tmp/sysreport.$$

# cleanup temporary files
cleanup
