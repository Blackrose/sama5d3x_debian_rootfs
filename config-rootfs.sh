#!/bin/sh
# see: http://www.acmesystems.it/emdebian_grip_armhf

#Target directory for the rootfs chroot image
TARGET_ROOTFS_DIR=$1

mkdir $TARGET_ROOTFS_DIR/dev/pts
mknod $TARGET_ROOTFS_DIR/dev/random c 1 8
mknod $TARGET_ROOTFS_DIR/dev/urandom c 1 9
mknod $TARGET_ROOTFS_DIR/dev/ptmx c 5 2
mknod $TARGET_ROOTFS_DIR/dev/null c 1 3

cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin
LC_ALL=C LANGUAGE=C LANG=C chroot $TARGET_ROOTFS_DIR dpkg --configure -a

#Directories used to mount some microSD partitions 
echo "Create mount directories"
mkdir $TARGET_ROOTFS_DIR/media/mmc_p1
mkdir $TARGET_ROOTFS_DIR/media/data

#Set the target board hostname
filename=$TARGET_ROOTFS_DIR/etc/hostname
echo Creating $filename
echo isrtc > $filename

#Set the defalt name server
filename=$TARGET_ROOTFS_DIR/etc/resolv.conf
echo Creating $filename
echo nameserver 114.114.114.114 > $filename
#echo nameserver 8.8.8.8 > $filename
#echo nameserver 8.8.4.4 >> $filename

#Set the default network interfaces
filename=$TARGET_ROOTFS_DIR/etc/network/interfaces
echo Updating $filename
echo allow-hotplug eth0 eth1 >> $filename
echo iface eth0 inet dhcp >> $filename
#echo hwaddress ether 00:04:25:12:34:56 >> $filename
#echo iface eth1 inet dhcp >> $filename
#echo hwaddress ether 00:04:25:23:45:67 >> $filename

#Set a terminal to the debug port
filename=$TARGET_ROOTFS_DIR/etc/inittab
echo Updating $filename
echo T0:2345:respawn:/sbin/getty -L ttyS0 115200 vt100 >> $filename

#Set how to mount the microSD partitions
filename=$TARGET_ROOTFS_DIR/etc/fstab
echo Creating $filename
#echo /dev/mmcblk0p1 /boot vfat noatime 0 1 > $filename
#echo /dev/mmcblk0p2 / ext4 noatime 0 1 >> $filename
#echo /dev/mmcblk0p3 /media/data ext4 noatime 0 1 >> $filename
echo proc /proc proc defaults 0 0 >> $filename

#Add Debian security repository
filename=$TARGET_ROOTFS_DIR/etc/apt/sources.list
echo Creating $filename
echo "deb http://security.debian.org/ jessie/updates main"  >> $filename

#Add the standard Debian non-free repositories useful to load
#closed source firmware (i.e. WiFi dongle firmware)
echo "deb http://debian.ustc.edu.cn/debian/ jessie main contrib non-free" >> $filename

