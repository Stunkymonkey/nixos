#!/usr/bin/env bash

set -eux -o pipefail

BASE="$(dirname "$(readlink -f "$0")")"
. "${BASE}/helpers.sh"

export HOST=thinkman
export DRIVE_ROOT=/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0NB16097P

export NIXOS_FILES="${NIXOS_FILES?}"
export CHROOT_BASE="/mnt/newroot-${HOST}"

export DRIVE_ROOT_LUKS=/dev/mapper/luks-root
PARTSEP="-part"

ask_if_sure

mp_umount /

################################################################################################
echo "Starting Root SSD"

lvm_remove_lv /dev/vg_root/lv_root
lvm_remove_lv /dev/vg_root/lv_home
lvm_remove_vg vg_root
lvm_remove_pv "${DRIVE_ROOT_LUKS}"

luks_close "$(basename "${DRIVE_ROOT_LUKS}")"
zero_blockdev "${DRIVE_ROOT}"

parttable_clear "${DRIVE_ROOT}"

# ROOT SSD SETUP
sgdisk \
	-o "${DRIVE_ROOT}" \
	-n 1:2048:4095   -c 1:"BIOS Boot Partition"  -t 1:ef02 \
	-n 2:4096:823295 -c 2:"EFI System Partition" -t 2:ef00 \
	--largest-new=3  -c 3:"Crypt"                -t 3:8309 \
	-p

cryptsetup luksFormat "${DRIVE_ROOT}${PARTSEP}3"
cryptsetup luksOpen --allow-discards "${DRIVE_ROOT}${PARTSEP}3" "$(basename "${DRIVE_ROOT_LUKS}")"

pvcreate         "${DRIVE_ROOT_LUKS}"
vgcreate vg_root "${DRIVE_ROOT_LUKS}"

lvcreate -L 50GiB -n lv_root vg_root
mkfs.ext4 -L "${HOST}-root" /dev/vg_root/lv_root

lvcreate -L 100GiB -n lv_home vg_root
mkfs.ext4 -L "${HOST}-home" /dev/vg_root/lv_home

lvcreate -L 10GiB -n lv_swap vg_root
mkswap -L "${HOST}-swap" /dev/vg_root/lv_swap

zero_overwrite "${DRIVE_ROOT}${PARTSEP}2"
mkfs.vfat -n "${HOST}-boot" "${DRIVE_ROOT}${PARTSEP}2"

mp_mount /dev/vg_root/lv_root /
mp_mount /dev/vg_root/lv_home /home
mp_mount "${DRIVE_ROOT}${PARTSEP}2" /boot

mkdir -p ${CHROOT_BASE}/etc/secrets/initrd
ssh-keygen -t ed25519 -N "" -f "${CHROOT_BASE}/etc/secrets/initrd/ssh_host_ed25519_key"
ssh-keygen -t rsa     -N "" -f "${CHROOT_BASE}/etc/secrets/initrd/ssh_host_rsa_key"

mkdir -p "${CHROOT_BASE}/etc/nixos/"
rsync -avH "${NIXOS_FILES}/" "${CHROOT_BASE}/etc/nixos/"

cat >> "${CHROOT_BASE}/etc/nixos/vars-uuids.nix" <<END
{
	fs = {
		root = "$(blkid -o value -s UUID "/dev/vg_root/lv_root")";
		boot = "$(blkid -o value -s UUID "${DRIVE_ROOT}${PARTSEP}2")";
		home = "$(blkid -o value -s UUID "/dev/vg_root/lv_home")";
		swap = "$(blkid -o value -s UUID "/dev/vg_root/lv_swap")";
	};

	luks = {
		root = "$(blkid -o value -s PARTUUID "${DRIVE_ROOT}${PARTSEP}3")";
	};
}
END

install_os "${CHROOT_BASE}"
