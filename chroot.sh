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

# Enable required
systemctl enable fstrim.timer
systemctl enable NetworkManager
systemctl enable lightdm.service
systemctl enable bluetooth.service

# Install Intel Microcode
cpu_vendor=$(lscpu | grep Vendor | awk '{print $3}')
if [[ $cpu_vendor = "GenuineIntel" ]]; then
	# ------- GenuineIntel processor detected -------
	pacman -S intel-ucode
fi

# Install graphical drivers
zsh /scripts/drivers.sh

# Generate GRUB configuration
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Create wheel user
useradd -mG wheel,storage,power,video,audio $USER
echo "$USER:$PASSWORD" | chpasswd
sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers

zsh /scripts/xorg.sh

# disable root login
passwd -l root

exit
