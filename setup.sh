usage() {
	echo "Lel"
}

D_PACKAGES=false

# Fetch opts
while getopts "d" o; do
	case $o in
		"d") D_PACKAGES=true ;;
		*)   usage ;;
	esac
done

. "./partitions.conf"

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

timedatectl set-ntp true

essential_packages=(
	"base" "base-devel"
	"linux" "linux-firmware"
)

basic_packages=(
	"man-db" "man-pages" "texinfo"
	"networkmanager" 
	"sudo"
)

all_packages=(
	${essential_packages[@]}
	${basic_packages[@]}
)

pacstrap /mnt ${all_packages[@]}

genfstab -U /mnt >> /mnt/etc/fstab

SCRIPT_DIR=/mnt/scripts
mkdir -p $SCRIPT_DIR
mv chroot.sh packages.sh drivers.sh xorg.sh user.conf $SCRIPT_DIR
arch-chroot /mnt zsh /scripts/chroot.sh $ROOT_PART

rm -r /mnt/scripts

umount -R /mnt
reboot
