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

# Enable required services
systemctl enable fstrim.timer
systemctl enable NetworkManager
systemctl enable lightdm.service
systemctl enable bluetooth.service

# Install packages
zsh /scripts/packages.sh

# Install graphical drivers
zsh /scripts/drivers.sh

# Install and configure systemd-boot
bootctl install

ROOT_PART=$1
PARTUUID=$(blkid -s PARTUUID -o value ${ROOT_PART})

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

# Install Intel Microcode
cpu_vendor=$(lscpu | grep Vendor | awk '{print $3}')
if [[ ${cpu_vendor} = "GenuineIntel" ]]; then
	# ------- GenuineIntel processor detected -------
	pacman --noconfirm -S intel-ucode
	sed -i -e '3i initrd	/intel-ucode.img' /boot/loader/entries/arch.conf
fi

# Uncomments first line where the '%wheel' pattern is found
# A.K.A.: %wheel ALL=(ALL:ALL) ALL
sed -i '0,/%wheel/s/^# //' /etc/sudoers

# Create wheel user
useradd -mG wheel,storage,power,video,audio $USER
echo "$USER:$PASSWORD" | chpasswd

zsh /scripts/xorg.sh

# disable root login
passwd -l root

exit
