#!/bin/bash
echo "My fully qualified domain name is:"
hostname
echo "My host Information is:"
hostnamectl
echo "The IP address  of this server is:"
hostname -I
echo "The amount of space available in only the root system:"
df -h /
