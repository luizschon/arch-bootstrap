#! /bin/zsh

. "/scripts/user.conf"

root_partition=$1

if [ $VERBOSE = true ]; then
	# Variables loaded from the user.conf file
	echo '----------------------------'
	echo "HOSTNAME: ${hostname}" 
	echo "USER: ${username}" 
	echo "TIMEZONE: ${timezone}" 
	echo "KEYMAP: ${keymap}" 
	echo "LANGUAGES: ${languages[@]}" 
	echo '----------------------------'
fi

# Generate localization for every language in the languages array
for lang in ${languages[@]}; do
	sed -i "s/^#\($lang\)\(\.UTF-8\)/\1\2/g" /etc/locale.gen
done

# Some applications like Steam require en_US localization
sed -i "s/^#\(en_US.UTF-8\)/\1/g" /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=${keymap}" > /etc/vconsole.conf
echo $hostname > /etc/hostname

# Timedate configuration
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# Install packages
zsh /scripts/packages.sh

# Install graphical drivers
zsh /scripts/drivers.sh

# Install bootloader
zsh /scripts/bootloader.sh $root_partition

# System configuration
zsh /scripts/system_config.sh

# Uncomments first line where the '%wheel' pattern is found
# A.K.A.: %wheel ALL=(ALL:ALL) ALL
sed -i '0,/%wheel/s/^# //' /etc/sudoers

# Create wheel user
useradd -mG wheel,storage,power,video,audio $username
echo "$username:$password" | chpasswd

# disable root login
passwd -l root

# Enable required services
systemctl enable fstrim.timer
systemctl enable NetworkManager
systemctl enable lightdm.service
systemctl enable bluetooth.service

# Change to user to set $HOME env and install aur packages
su $username
cd ~

# Move AUR script to home dir
if [ $AUR = true ]; then
	echo "entering aur.sh"
	zsh /scripts/aur.sh
fi


if [ $DOTFILES = false ]; then
	# Create a very very minimal bspwm config so the user that
	# doesn't use my dotfiles don't get softlocked :)
	mkdir -p $HOME/.config/bspwm
	cp /scripts/config-files/* $HOME/.config/bspwm

	chmod +x $HOME/.config/bspwm/bspwmrc
	chmod +x $HOME/.config/bspwm/help
	chown -R $username:$username $HOME/.config/bspwm
else
	# Install my dotfiles
	git clone https://github.com/luizschonarth/dotfiles.git $HOME/.dotfiles
	chown -R $username:$username $HOME/.dotfiles
	cd $HOME/.dotfiles
	./install.sh
fi

exit
