#! /bin/zsh

intel_drivers=(
	"xf86-video-intel"
	"vulkan-intel"
	"intel-media-driver"
	"mesa"
)

nvidia_drivers=(
	"nvidia"
	"nvidia-utils"
	"mesa"
)

amd_drivers=(
	"xf86-video-amdgpu"
	"vulkan-radeon"
	"libva-mesa-driver"
	"mesa"
)

prime_drivers=(
	"nvidia-prime"
)

lib32_nvidia_drivers=(
	"lib32-nvidia-utils"
)

lib32_amd_drivers=(
	"lib32-mesa"
	"lib32-vulkan-radeon"
)

lib32_intel_drivers=(
	"lib32-mesa"
)

universal_drivers=(
	"mesa"
)

is_nvidia=false
is_amd=false
vga_controller=$(lspci -d ::0300 | sed 's/^.*: //' | awk '{print $1}')
threed_controller=$(lspci -d ::0302 | sed 's/^.*: //' | awk '{print $1}')
display_controller=$(lspci -d ::0380 | sed 's/^.*: //' | awk '{print $1}')

if [[ $threed_controller = "NVIDIA" ]]; then
	echo "---------- Detected NVIDIA 3D controller ----------"
	echo "---------- Installing NVIDIA and PRIME drivers ----------"
	is_nvidia=true
	pacman --noconfirm -S ${nvidia_drivers[@]}
	pacman --noconfirm -S ${prime_drivers[@]}

	if [ $GAMING = true ]; then
		pacman --noconfirm -S ${lib32_amd_drivers}
	fi
fi

case $vga_controller in
	"Intel")
		echo "---------- Detected Intel VGA compatible controller ----------"
		echo "---------- Installing Intel Graphics drivers ----------"
		pacman --noconfirm -S ${intel_drivers[@]}
		if [ $GAMING = true ]; then
			pacman --noconfirm -S ${lib32_intel_drivers}
		fi
		;;
	"NVIDIA")
		echo "---------- Detected NVIDIA VGA compatible controller ----------"
		echo "---------- Installing NVIDIA drivers ----------"
		pacman --noconfirm -S ${nvidia_drivers[@]}
		is_nvidia=true
		if [ $GAMING = true ]; then
			pacman --noconfirm -S ${lib32_nvidia_drivers}
		fi
		;;
	"Advanced")
		echo "---------- Detected NVIDIA VGA compatible controller ----------"
		echo "---------- Installing NVIDIA drivers ----------"
		pacman --noconfirm -S ${amd_drivers[@]}
		is_amd=true
		if [ $GAMING = true ]; then
			pacman --noconfirm -S ${lib32_amd_drivers}
		fi
		;;
	* )
		echo "---------- Installing universal drivers ----------"
		pacman --noconfirm -S ${universal_drivers[@]}
		;;
esac

if [ $is_nvidia = true ]; then
	echo "------- Creating NVIDIA pacman hook and kernel param -------"

	# Creates NVIDIA pacman hook
	mkdir -p /etc/pacman.d/hooks
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
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
fi

export IS_NVIDIA=$is_nvidia
export IS_AMD=$is_amd

exit
