#!/bin/sh

ask_if_sure(){
	while true; do
		read -p "reinstall & ERASE ALL DATA? [y/n] " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

blk_wait(){
	local dev="${1?}"

	while ! [ -b "${dev}" ]; do
		sleep 0.1
	done
}

blk_info_partuuid(){
	local dev="${1?}"

	printf '/dev/disk/by-partuuid/%s' "$(blkid -o value -s PARTUUID "${dev}")"
}

blk_info_uuid(){
	local dev="${1?}"

	printf '/dev/disk/by-uuid/%s' "$(blkid -o value -s UUID "${dev}")"
}

# Write into /tmp/password your password (without a trailing newline!)
# So you won't get asked for a password during installation
#
# If you want to get asked for every password, just remove this function
cryptsetup(){
	command cryptsetup $* --key-file /tmp/passwd -q
}

install_os(){
	local folder="${1?}"
	nixos-install --cores 0 --max-jobs auto --root "${folder}"
}

luks_close(){
	local drive="${1?}"

	if cryptsetup status "${drive}" &>/dev/null; then
		cryptsetup close "${drive}"
	fi
}

lvm_remove_lv(){
	local lv="${1?}"

	if lvs "${lv}"; then
		lvremove -f "${lv}"
	fi
}

lvm_remove_vg(){
	local vg="${1?}"

	if vgs "${vg}"; then
		vgremove "${vg}"
	fi
}

lvm_remove_pv(){
	local pv="${1?}"

	if pvs "${pv}"; then
		pvremove "${pv}"
	fi
}

macro_replace(){
	local macro="${1?}"
	local value="${2?}"
	local file="${3?}"

	sed -i "s%${macro}%${value}%g" "${file}"
}

mp_mount(){
	local src="${1?}"
	local dst="${2?}"
	local fstype="${3:-}"

	mkdir -p "${CHROOT_BASE?}${dst}"
	mount ${fstype:+-t} ${fstype:+"${fstype}"} "${src}" "${CHROOT_BASE?}${dst}"
}

mp_umount(){
	local mountpoint="${1?}"

	if mountpoint "${CHROOT_BASE}${mountpoint}" &>/dev/null; then
		umount -R "${CHROOT_BASE}${mountpoint}"
	fi

	if [ -d "${CHROOT_BASE}${mountpoint}" ]; then
		rmdir "${CHROOT_BASE}${mountpoint}"
	fi
	! [ -e "${CHROOT_BASE}${mountpoint}" ]
}

parttable_clear(){
	local drive="${1?}"

	while ! sgdisk -Z "${drive}" &>/dev/null; do
		sleep 0.1
	done
}

zero_blockdev(){
	local dev="${1?}"

	blkdiscard "${dev}"
}

zero_overwrite(){
	local fsdev="${1?}"
	local MBs="${2:-10}"

	dd if=/dev/zero of="${fsdev}" bs=1M count="${MBs}" conv=sync
}

# Helper.sh
zfs_pool_destroy(){
	local pool="${1?}"
	if zpool status "${pool}" &>/dev/null; then
		zpool destroy "${pool}"
	fi
}
