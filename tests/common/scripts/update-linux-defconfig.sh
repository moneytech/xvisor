#!/bin/bash

function usage()
{
	echo "Usage:"
	echo " $0 [options]"
	echo "Options:"
	echo "     -h                        Display help or usage (Optional)"
	echo "     -p <linux_defconfig_path> Path to Linux defconfig file"
	echo "     -f <extra_config_file>    Additional Linux config options from file (Optional)"
	echo "     -e <extra_options>        Additional Linux config options from command line (Optional)"
	echo "     -d                        Display options and do nothing (Optional)"
	exit 1;
}

# Command line options
LINUX_DEFCONFIG_PATH=`pwd`/defconfig
LINUX_EXTRA_CONFIG_FILE=""
LINUX_EXTRA_CONFIG_FILE_OPTIONS=""
LINUX_EXTRA_OPTIONS=""
DISPLAY_OPTIONS="0"

while getopts "de:f:hp:" o; do
	case "${o}" in
	d)
		DISPLAY_OPTIONS="1"
		;;
	e)
		LINUX_EXTRA_OPTIONS=${OPTARG}
		;;
	f)
		LINUX_EXTRA_CONFIG_FILE=${OPTARG}
		;;
	h)
		usage
		;;
	p)
		LINUX_DEFCONFIG_PATH=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND-1))

if [ -z "${LINUX_DEFCONFIG_PATH}" ]; then
	echo "Must specify Linux defconfig file"
	usage
fi

if [ ! -f ${LINUX_DEFCONFIG_PATH} ]; then
	echo "Linux defconfig file does not exist"
	usage
fi

if [ ! -z "${LINUX_EXTRA_CONFIG_FILE}" ]; then
	if [ ! -f ${LINUX_EXTRA_CONFIG_FILE} ]; then
		echo "Linux extra config file does not exist"
		usage
	fi
	LINUX_EXTRA_CONFIG_FILE_OPTIONS=`cat ${LINUX_EXTRA_CONFIG_FILE}`
fi

LINUX_OPTIONS=""

LINUX_OPTIONS+=" CONFIG_PRINTK=y"
LINUX_OPTIONS+=" CONFIG_PRINTK_TIME=y"

LINUX_OPTIONS+=" CONFIG_NET=y"
LINUX_OPTIONS+=" CONFIG_NET_9P=y"

LINUX_OPTIONS+=" CONFIG_BLOCK=y"

LINUX_OPTIONS+=" CONFIG_BLK_DEV_INITRD=y"

LINUX_OPTIONS+=" CONFIG_EXT4_FS=y"
LINUX_OPTIONS+=" CONFIG_EXT4_FS_POSIX_ACL=y"
LINUX_OPTIONS+=" CONFIG_EXT3_FS=y"
LINUX_OPTIONS+=" CONFIG_EXT3_FS_POSIX_ACL=y"
LINUX_OPTIONS+=" CONFIG_EXT2_FS=y"
LINUX_OPTIONS+=" CONFIG_EXT2_FS_XATTR=y"
LINUX_OPTIONS+=" CONFIG_EXT2_FS_POSIX_ACL=y"
LINUX_OPTIONS+=" CONFIG_MSDOS_FS=y"
LINUX_OPTIONS+=" CONFIG_VFAT_FS=y"

LINUX_OPTIONS+=" CONFIG_NETWORK_FILESYSTEMS=y"
LINUX_OPTIONS+=" CONFIG_9P_FS=y"

LINUX_OPTIONS+=" CONFIG_GOLDFISH=y"

LINUX_OPTIONS+=" CONFIG_DEVTMPFS=y"
LINUX_OPTIONS+=" CONFIG_DEVTMPFS_MOUNT=y"

LINUX_OPTIONS+=" CONFIG_VIRTIO_MENU=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_PCI=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_PCI_LEGACY=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_MMIO=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y"

LINUX_OPTIONS+=" CONFIG_VIRTIO_BALLOON=y"

LINUX_OPTIONS+=" CONFIG_INPUT=y"
LINUX_OPTIONS+=" CONFIG_INPUT_MOUSEDEV=y"
LINUX_OPTIONS+=" CONFIG_INPUT_KEYBOARD=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_INPUT=y"

LINUX_OPTIONS+=" CONFIG_TTY=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_CONSOLE=y"

LINUX_OPTIONS+=" CONFIG_HW_RANDOM=y"
LINUX_OPTIONS+=" CONFIG_HW_RANDOM_VIRTIO=y"

LINUX_OPTIONS+=" CONFIG_BLK_DEV=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_BLK=y"

LINUX_OPTIONS+=" CONFIG_NETDEVICES=y"
LINUX_OPTIONS+=" CONFIG_VIRTIO_NET=y"

LINUX_OPTIONS+=" CONFIG_FB=y"
LINUX_OPTIONS+=" CONFIG_FB_SIMPLE=y"
LINUX_OPTIONS+=" CONFIG_LOGO=y"
LINUX_OPTIONS+=" CONFIG_LOGO_LINUX_MONO=y"
LINUX_OPTIONS+=" CONFIG_LOGO_LINUX_VGA16=y"
LINUX_OPTIONS+=" CONFIG_LOGO_LINUX_CLUT224=y"

LINUX_OPTIONS+=" CONFIG_RTC_CLASS=y"
LINUX_OPTIONS+=" CONFIG_RTC_DRV_GOLDFISH=y"

LINUX_OPTIONS+=" CONFIG_RPMSG_CHAR=y"
LINUX_OPTIONS+=" CONFIG_RPMSG_VIRTIO=y"

LINUX_OPTIONS+=" CONFIG_DRM=y"
LINUX_OPTIONS+=" CONFIG_DRM_VIRTIO_GPU=y"

LINUX_OPTIONS+=" CONFIG_PROFILING=n"
LINUX_OPTIONS+=" CONFIG_OPROFILE=n"
LINUX_OPTIONS+=" CONFIG_MTD=n"
LINUX_OPTIONS+=" CONFIG_SOUND=n"

LINUX_OPTIONS+=" ${LINUX_EXTRA_CONFIG_FILE_OPTIONS}"

LINUX_OPTIONS+=" ${LINUX_EXTRA_OPTIONS}"

if [ "${DISPLAY_OPTIONS}" -eq "1" ]; then
	for OPTION in ${LINUX_OPTIONS}
	do
		echo ${OPTION}
	done
	exit 1
fi

for OPTION in ${LINUX_OPTIONS}
do
	LINUX_OPTION_COUNT=`grep -c ${OPTION} ${LINUX_DEFCONFIG_PATH}`
	if [ "${LINUX_OPTION_COUNT}" -ne "0" ]; then
		continue;
	fi

	echo "Appending ${OPTION}"
	echo ${OPTION} >> ${LINUX_DEFCONFIG_PATH}
done
