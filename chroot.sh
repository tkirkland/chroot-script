#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Function to print usage
print_usage() {
  echo "Usage: source chroot-setup.sh <target_partition> <mount_point>"
  echo "Example: source chroot-setup.sh /dev/sda1 /mnt"
}

# Check if target partition and mount point are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Target partition and/or mount point not specified."
  print_usage
  return 1
fi

TARGET_PARTITION=$1
MOUNT_POINT=$2

# Mount the target filesystem
echo "Mounting $TARGET_PARTITION to $MOUNT_POINT"
mount $TARGET_PARTITION $MOUNT_POINT || { echo "Failed to mount $TARGET_PARTITION"; return 1; }

# Mount necessary filesystems
echo "Mounting /proc, /sys, and /dev"
mount -t proc /proc $MOUNT_POINT/proc || { echo "Failed to mount /proc"; return 1; }
mount --rbind /sys $MOUNT_POINT/sys || { echo "Failed to mount /sys"; return 1; }
mount --rbind /dev $MOUNT_POINT/dev || { echo "Failed to mount /dev"; return 1; }

# Chroot into the target environment
echo "Chrooting into the target environment"
chroot $MOUNT_POINT /bin/bash || { echo "Failed to chroot"; return 1; }

echo "You are now in the chroot environment. Type 'exit' to leave."
return 0
