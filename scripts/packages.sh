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
	"zsh-autosuggestion"
	"zsh-syntax-highlighting"
	"tmux" "htop"
	"openssh" "wget" "curl"
	"zip" "unzip" "p7zip"
	"git" "neovim" "vim"
	"python-pywal"
	"keychain" "brightnessctl"
)

gui_packages=(
	"xorg" "xdg-user-dirs" "picom"
	"lightdm" "lightdm-gtk-greeter"
	"i3-gaps" "polybar" "rofi"
	"nautilus" "feh"
	"kitty" "alacritty"
	"firefox" "chromium"
	"discord" "vlc"
	"network-manager-applet"
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

pacman -Syy
pacman --noconfirm -S archlinux-keyring
pacman --noconfirm -S ${all_packages[@]}

gaming_packages=(
	"steam" "blender"
	"gamemode"
)

if [ $GAMING = true ]; then
	pacman --noconfirm -S ${gaming_packages[@]}
fi

exit 0
