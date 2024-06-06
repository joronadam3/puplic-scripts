#!/bin/bash

# Check if script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Create the blacklist file for USB storage
echo "blacklist usb-storage" > /etc/modprobe.d/usb-storage.conf

# Update the initramfs to apply the changes
update-initramfs -u

# Unload the usb-storage module if

