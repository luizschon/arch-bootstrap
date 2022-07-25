# Install Intel/AMD Microcode
cpu_vendor=$(lscpu | grep Vendor | awk '{print $3}')

if [[ ${cpu_vendor} = "GenuineIntel" ]]; then
	# ------- GenuineIntel processor detected -------
	pacman --noconfirm -S intel-ucode
elif [[ ${cpu_vendor} = "AuthenticAMD" ]]; then
	# ------- AuthenticAMD processor detected -------
	pacman --noconfirm -S amd-ucode
fi

$root_partition=$1

if [ $GRUB = true ]; then
	# Install and configure GRUB
	pacman --noconfirm -S grub efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

	# Adds NVIDIA modesetting kernel parameter to grub configuration file
	if [[ -n $IS_NVIDIA ]] && sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub

	grub-mkconfig -o /boot/grub/grub.cfg
	
else
	# Install and configure systemd-boot
	bootctl install

	PARTUUID=$(blkid -s PARTUUID -o value ${root_partition})

cat > /boot/loader/loader.conf << EOF
default  arch.conf
timeout  4
editor   no
EOF

cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux	/vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=${PARTUUID} rw
EOF

	if [[ ${cpu_vendor} = "GenuineIntel" ]]; then
		sed -i -e '3i initrd	/intel-ucode.img' /boot/loader/entries/arch.conf
	elif [[ ${cpu_vendor} = "AuthenticAMD" ]]; then
		sed -i -e '3i initrd	/amd-ucode.img' /boot/loader/entries/arch.conf
	fi

	# Adds NVIDIA modesetting kernel parameter to systemd-boot configuration file
	sed -i 's/\(^options.*\)/\1 nvidia-drm.modeset=1/' /boot/loader/entries/arch.conf
fi

exit 0
