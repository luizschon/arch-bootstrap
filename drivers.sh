#! /bin/zsh

intel_drivers=(
	"xf86-video-intel"
	"mesa"
)

nvidia_drivers=(
	"nvidia"
	"nvidia-utils"
	"mesa"
)

prime_drivers=(
	"nvidia"
	"nvidia-utils"
	"nvidia-prime"
	"mesa"
)

universal_drivers=(
	"mesa"
)

IS_NVIDIA=$false
threed_controller=$(lspci | grep '3D' | sed 's/^.*: //' | awk '{print $1}')
vga_controller=$(lspci | grep 'VGA' | sed 's/^.*: //' | awk '{print $1}')

if [[ $threed_controller = "NVIDIA" ]]; then
	echo "---------- Detected NVIDIA 3D controller ----------"
	echo "---------- Installing NVIDIA and PRIME drivers ----------"
	IS_NVIDIA=$true
	pacman -S ${prime_drivers[@]}
fi

case $vga_controller in
	"Intel")
		echo "---------- Detected Intel VGA compatible controller ----------"
		echo "---------- Installing Intel Graphics drivers ----------"
		pacman -S ${intel_drivers[@]}
		;;
	"NVIDIA")
		echo "---------- Detected NVIDIA VGA compatible controller ----------"
		echo "---------- Installing NVIDIA drivers ----------"
		pacman -S ${nvidia_drivers[@]}
		IS_NVIDIA=$true
		;;
	*)
		if [ -n $vga_controller ]; then
			echo "---------- Installing universal drivers ----------"
			pacman -S ${universal_drivers[@]}
	lspci | grep '3D' | sed 's/^.*: //' | awk '{print $1}'	else
			echo "---------- No VGA compatible controller detected ----------"
		fi
		;;
esac

if [ $IS_NVIDIA ]; then
	echo "------- Creating NVIDIA pacman hook and kernel param -------"
	# Creates NVIDIA pacman hook
	cat > /etc/pacman.d/hooks/nvidia.hook << EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

	# Adds NVIDIA modesetting kernel parameter to grub configuration file
	sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
fi

exit
