#! /bin/zsh

# Configure pacman
sed -i '/^\[options\]/a Color\nParallelDownloads = 5' /etc/pacman.conf

# Enable multilib
if [ $GAMING = true ]; then
	MULTILIB_LINE=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -d : -f1 )
	LINEEND=$(($MULTILIB_LINE+1))
	sed -i "${MULTILIB_LINE},${LINEEND} s/#*//" /etc/pacman.conf
fi

pkgs=(
	"zsh" "zsh-completions"
	"zsh-autosuggestions"
	"zsh-syntax-highlighting"
	"tmux" "htop" "neofetch"
	"openssh" "wget" "curl"
	"zip" "unzip" "p7zip"
	"git" "neovim" "vim"
	"python-pywal"
	"keychain" "brightnessctl"
	"xorg" "xdg-user-dirs" "picom"
	"lightdm" "lightdm-gtk-greeter"
	"bspwm" "sxhkd" "rofi"
	"nautilus" "feh"
	"kitty" "rxvt-unicode" "mupdf"
	"firefox" "chromium"
	"discord" "vlc"
	"network-manager-applet"
	"pipewire"
	"pipewire-pulse"
	"bluez" "blueman"
	"bluez-utils"
	"pavucontrol"
	"flameshot"
	"gcc" "cmake" "clang" "gdb"
	"python" "python-pip"
	"ttc-iosevka"
	"ttf-font-awesome"
	"noto-fonts-emoji"
	"noto-fonts-cjk"
)

pacman -Syy
pacman --noconfirm -S archlinux-keyring
pacman --noconfirm -S ${pkgs[@]}

gaming_pkgs=(
	"steam" "blender"
	"gamemode"
)

if [ $GAMING = true ]; then
	pacman --noconfirm -S ${gaming_pkgs[@]}
fi

exit 0
