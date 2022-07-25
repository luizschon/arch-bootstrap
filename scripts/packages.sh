#! /bin/zsh

# Configure pacman
sed -i '/^\[options\]/a Color\nParallelDownloads = 5' /etc/pacman.conf

# Enable multilib
if [ $GAMING = true ]; then
	MULTILIB_LINE=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -d : -f1 )
	LINEEND=$(($MULTILIB_LINE+1))
	sed -i "${MULTILIB_LINE},${LINEEND} s/#*//" /etc/pacman.conf
fi

shell_packages=(
	"zsh" "zsh-completions"
	"tmux" "htop"
	"openssh" "wget" "curl"
	"zip" "unzip" "p7zip"
	"git" "neovim" "vim"
)

gui_packages=(
	"xorg" "xdg-user-dirs"
	"lightdm" "lightdm-gtk-greeter"
	"i3-gaps" "polybar" "rofi"
	"nautilus" "feh"
	"kitty" "alacritty"
	"firefox" "chromium"
	"discord" "vlc"
)

multimedia_packages=(
	"pipewire"
	"pipewire-pulse"
	"bluez" "blueman"
	"bluez-utils"
	"pavucontrol"
)

development_packages=(
	"rust" "go"
	"gcc" "cmake" "clang" "gdb"
	"python" "python-pip"
)

font_packages=(
	"ttf-cascadia-code"
	"ttf-font-awesome"
)

all_packages=(
	${shell_packages[@]}
	${gui_packages[@]}
	${multimedia_packages[@]}
	${development_packages[@]}
	${font_packages[@]}
)

pacman -Sy
pacman --noconfirm -S ${all_packages[@]}

gaming_packages=(
	"steam", "blender"
)

if [ $GAMING = true ]; then
	pacman --noconfirm -S ${gaming_packages[@]}
fi

if [ $AUR = true ]; then
	zsh /scripts/aur.sh
fi

exit 0
