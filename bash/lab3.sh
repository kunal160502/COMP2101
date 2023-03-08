#!/bin/bash
clear
printf ">> RUN THIS SCRIPT WITH SUDO"
echo ""
containername="COMP2101-S22"
lxd=$(which lxd)
if [ "$lxd" != "$null" ]; then
echo "lxd is installed"
else
echo "Installing lxd"
sudo snap install lxd
fi
interface=$(ifconfig lxdbr0)
if [ "$interface" != "$null" ]; then
echo "lxd interface found."
else
echo "No lxd interface found."
lxd init --auto
fi
if lxc launch ubuntu:20.04 COMP2101-S22; then
sleep 30
else
echo "$containername has problems."
exit 1
fi
containerhostname=$(lxc exec COMP2101-S22 -- hostname)
if [ "$containername" = "$containerhostname" ]; then
echo "Container $containername has right hostname: $containerhostname"
else
echo "Container $containername has wrong hostname: $containerhostname"
echo "Correcting it..."
lxc exec $containername -- env containerna="$containername" sh -c 'hostnamectl set-hostname $containerna' && echo "Hostname is corrected."
fi
containerip=$(lxc info $containername | grep -w inet | awk '{print $2}' | grep "/24" | cut -d/ -f1)
hostnameentry=$containername" "$containerip
hostnameentryget=$(lxc exec $containername  -- env containerna="$containername" sh -c 'cat /etc/hosts | grep "$containerna"')
if [[ $hostnameentryget ]]; then
echo "Container $containername has right hostname entry."
else
echo "Container $containername has wrong hostname entry."
echo "Correcting it..."
lxc exec $containername -- env hostnameen="$hostnameentry" sh -c 'echo $hostnameen >> /etc/hosts'
fi
lxc exec $containername  -- sh -c 'apt update && apt install apache2 -y && apt autoremove -y'
websitestatus=$(lxc exec $containername -- env containerna="$containername" sh -c 'curl -Is http://$containerna | grep -e "HTTP/1.1 200 OK"')
if [[ $websitestatus ]]; then
echo "Apache default website on $containername is in working condition."
else
echo "Apache default website on $containername is not working."
fi

