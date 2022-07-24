print_help() {
	echo "Usage: $0 [OPTIONS]"
}

# Parse short and long opts
TEMP=$(getopt --options vghd --longoptions verbose,gaming,aur,grub,help,dotfiles -- "$@")

# Terminates program if getopt reports an error
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

VERBOSE=false
GAMING=false
AUR=false
GRUB=false
DOTFILES=false

# Set variables
while true; do
	case "$1" in
		-h | --help		) print_help; exit 0 ;;
		-v | --verbose	) VERBOSE=true; shift ;;
		--gaming		) GAMING=true; shift ;;
		--aur		    ) AUR=true; shift ;;
		-g | --grub	    ) GRUB=true; shift ;;
		-d | --dotfiles ) DOTFILES=true; shift ;;
		--				) shift ; break ;;
		*				) break ;;
	esac
done

. "./partitions.conf"

if [ $VERBOSE = true ]; then
	# Variables from the partitions.conf file
	echo '----------------------------'
	echo "ROOT: ${root_partition}" 
	echo "EFI: ${efi_partition}" 
	echo "SWAP: ${swap_partition}" 
	echo "HOME: ${home_partition}" 
	echo "VAR: ${var_partition}" 
	echo '----------------------------'
fi

# Mount the partition especified in partitions.conf
# TODO: maybe accept partitions as a opt
mount $root_partition /mnt
[[ -n $swap_partition ]] && swapon $swap_partition
[[ -n $home_partition ]] && mount --mkdir $home_partition /mnt/home
[[ -n $var_partition ]] && mount --mkdir $var_partition /mnt/var
[[ -n $efi_partition ]] && mount --mkdir $efi_partition /mnt/boot

timedatectl set-ntp true

essential_packages=(
	"base" "base-devel"
	"linux" "linux-firmware"
)

basic_packages=(
	"man-db" "man-pages" "texinfo"
	"networkmanager" 
	"sudo" "zsh"
)

first_packages=(
	${essential_packages[@]}
	${basic_packages[@]}
)

pacstrap /mnt ${first_packages[@]}

genfstab -U /mnt >> /mnt/etc/fstab

SCRIPT_DIR=/mnt/scripts
mkdir -p $SCRIPT_DIR
mv /arch-bootstrap $SCRIPT_DIR

arch-chroot /mnt /bin/zsh -c "VERBOSE=${VERBOSE}; GAMING=${GAMING}; AUR=${AUR}; GRUB=${GRUB}; DOTFILES=${DOTFILES}" /scripts/chroot.sh $root_partition

rm -r $SCRIPT_DIR

umount -R /mnt
reboot
