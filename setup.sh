usage() {
	echo "Lel"
}

# Fetch opts
while getopts "d" o; do
	case $o in
		"d") D_PACKAGES=1 ;;
		*)   usage ;;
	esac
done

. partitions.conf

# Variables from the partitions.conf file
ROOT_PART=$root_partition
SWAP_PART=$swap_partition
HOME_PART=$home_partition
VAR_PART=$var_partition
EFI_PART=$efi_partition

echo '----------------------------'
echo "ROOT: ${ROOT_PART}" 
echo "EFI: ${EFI_PART}" 
echo "SWAP: ${SWAP_PART}" 
echo "HOME: ${HOME_PART}" 
echo "VAR: ${VAR_PART}" 
echo '----------------------------'

mount $ROOT_PART /mnt
[[ -n $SWAP_PART ]] && swapon $SWAP_PART
[[ -n $HOME_PART ]] && mount --mkdir $HOME_PART /mnt/home
[[ -n $VAR_PART ]] && mount --mkdir $VAR_PART /mnt/var
[[ -n $EFI_PART ]] && mount --mkdir $EFI_PART /mnt/boot

timadatectl set-ntp true

essential_packages=(
	"base" "base-devel"
	"linux" "linux-firmware"
)

basic_packages=(
	"man-db" "man-pages"
	"networkmanager" 
	"grub" "efibootmgr"
	"sudo"
)

shell_packages=(
	"zsh" "zsh-completion"
	"tmux" "htop"
	"openssh" "wget" "curl" "json-pp"
	"zip" "unzip" "p7zip"
	"git" "neovim"
)

gui_packages=(
	"xorg" "xdg-user-dirs"
	"lightdm" "lightdm-gtk-greeter"
	"i3-gaps"
	"rofi"
	"nautilus"
	"kitty"
	"firefox" "chromium"
	"emacs"
	"discord"
	"vlc"
)

multimedia_packages=(
	"pipewire"
	"pipewire-pulse"
	"bluez"
	"bluez-utils"
	"pavucontrol"
)

development_packages=(
	"rust"
	"gcc" "cmake" "clang" "gdb"
	"python" "python-pip"
)

demanding_packages=(
	"steam" "lutris" "blender"
)

all_packages=(
	${essential_packages[@]}
	${basic_packages[@]}
	${shell_packages[@]}
	${gui_packages[@]}
	${multimedia_packages[@]}
	${development_packages[@]}
)

pacstrap /mnt ${all_packages[@]}

if [ -n ${D_PACKAGES} ]; then
	pacstrap /mnt ${demanding_packages[@]}
fi

genfstab -U /mnt >> /mnt/etc/fstab

zsh drivers.sh

SCRIPT_DIR=/mnt/scripts
mkdir -p $SCRIPT_DIR
mv chroot.sh xorg.sh user.conf $SCRIPT_DIR
arch-chroot /mnt zsh /scripts/chroot.sh

rm -r /mnt/scripts

umount -R /mnt
reboot
