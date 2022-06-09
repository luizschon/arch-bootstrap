#! /bin/zsh

. "/scripts/user.conf"

# Variables loaded from the user.conf file
HOSTNAME=$hostname
USER=$username
PASSWORD=$password
TIMEZONE=$timezone
# This will be hardcoded until i find out a nice way to load arrays from a .conf file
LANGUAGES=(en_US pt_BR)
KEYMAP=$keymap

ROOT_PART=$1

echo '----------------------------'
echo "HOSTNAME: ${HOSTNAME}" 
echo "USER: ${USER}" 
echo "PASSWORD: ${PASSWORD}" 
echo "TIMEZONE: ${TIMEZONE}" 
echo "KEYMAP: ${KEYMAP}" 
echo '----------------------------'

# Generate localization for every language in the LANGUAGES array
for lang in ${LANGUAGES[@]}
do
	sed -i "s/^#\($lang\)\(\.UTF-8\)/\1\2/g" /etc/locale.gen
done
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
echo $HOSTNAME > /etc/hostname

# Timedate configuration
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# Enable required
systemctl enable fstrim.timer
systemctl enable NetworkManager
systemctl enable lightdm.service
systemctl enable bluetooth.service

# Install Intel Microcode
cpu_vendor=$(lscpu | grep Vendor | awk '{print $3}')
if [[ $cpu_vendor == "GenuineIntel" ]]; then
	# ------- GenuineIntel processor detected -------
	pacman -S intel-ucode
fi

# Install graphical drivers
zsh /scripts/drivers.sh

# Install and configure bootloader
bootctl install
cat > /etc/pacman.d/hooks/100-systemd-boot.hook << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOF

cat > /etc/pacman.d/hooks/99-secureboot.hook << EOF
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = systemd

[Action]
Description = Signing Kernel for SecureBoot
When = PostTransaction
Exec = /usr/bin/find /boot -type f ( -name vmlinuz-* -o -name systemd* ) -exec /usr/bin/sh -c 'if ! /usr/bin/sbverify --list {} 2>/dev/null | /usr/bin/grep -q "signature certificates"; then /usr/bin/sbsign --key db.key --cert db.crt --output "$1" "$1"; fi' _ {} ;
Depends = sbsigntools
Depends = findutils
Depends = grep
EOF

PARTUUID=$(blkid -s PARTUUID -o value ${ROOT_PART})

if pacman -Q linux; then
	conf_path="/boot/loader/entries/arch.conf"

	cat > $conf_path <<- EOF
		title	Arch Linux
		linux	/vmlinuz-linux
		initrd	/initramfs-linux.img
		options	root=PARTUUID=${PARTUUID} rw
	EOF

	if [[ $cpu_vendor == "GenuineIntel" ]]; then
		sed -i -e '3i initrd	/intel-ucode.img' $conf_path
	fi
fi

cat > /boot/loader/loader.conf << EOF
default	arch.conf
timeout	3
editor	0
EOF

# Create wheel user
useradd -mG wheel,storage,power,video,audio $USER
echo "$USER:$PASSWORD" | chpasswd
sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers

zsh /scripts/xorg.sh

# disable root login
passwd -l root

exit
