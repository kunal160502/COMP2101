#!/bin/bash

# Installing lxd if not there in the system or diplays message of already present
if ! command -v lxd > /dev/null; then
  echo "INSTALLING LXD....."
  sudo snap install lxd
  if [ $? -ne 0 ]; then // checks the output from previous command
    echo "LXD INSTALLATION UNSUCESSFULL..."
    exit 1
  fi
else
  echo "LXD IS ALREADY PRESENT PROCESSING WITH INITIALIZATION LXD COMMAND "
  echo " "
fi


# Initializing lxd
if ! lxc network list | grep -q lxdbr0; then 
  echo "INITIALIZING LXD"
  lxd init --auto
  if [ $? -ne 0 ]; then
    echo "UNSUCESSFULL TO INITIALIZATION LXD"
    exit 1
  fi
else
  echo "LXD IS ALREADY INITIALIZED"
  echo " "
fi

# container creation
if ! lxc list --format csv | grep -q COMP2101-S22; then
  echo "CREATING CONTAINER IN UBUNTU 20.04 SERVER AS COMP2101-S22"
  lxc launch ubuntu:20.04 COMP2101-S22
  if [ $? -ne 0 ]; then
    echo "UNSUCESSFULL TO CREATE CONTAINER"
    exit 1
  fi
else
  echo "CONTAINER ALREADY EXISTS"
fi


# Installing software in the container
echo "INSTALLING APACHE2 FOR COMP2101-S22"
lxc exec COMP2101-S22 -- apt update
lxc exec COMP2101-S22 -- apt install -y apache2
if [ $? -ne 0 ]; then
  echo "APACHE2 INSTALLATION UNSUCESSFULL"
  exit 1
fi

# Testing the default page
if which curl >/dev/null; then 

if [ "curl http://COMP2101-S22 >/dev/null 2>&1" ];then
      echo "the default web page is successfully retrieved"
else
      echo "error exists default web page is not able to retrieve"
fi 
 
else
if [ "curl http://COMP2101-S22 >/dev/null 2>&1" ];then
      echo "the default web page is successfully retrieved"
else
      echo "error exists default web page is not able to retrieve"
fi 


fi
