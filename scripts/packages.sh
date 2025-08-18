#! /usr/bin/env zsh

# Configure pacman
sed -i '/^\[options\]/a Color\nParallelDownloads = 5' /etc/pacman.conf

# Enable multilib
if [ $GAMING = true ]; then
	MULTILIB_LINE=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -d : -f1 )
	LINEEND=$(($MULTILIB_LINE+1))
	sed -i "${MULTILIB_LINE},${LINEEND} s/#*//" /etc/pacman.conf
fi

required_pkgs=(
	"xdg-user-dirs" "openssh" "gnupg"
	"lightdm" "lightdm-gtk-greeter"
	"pipewire-pulse" "pipewire"
	"bluez" "bluez-utils"
)

cli_pkgs=(
	"zsh" "zsh-completions"
	"zsh-autosuggestions"
	"fish" "starship"
	"htop" "fastfetch"
	"wget" "curl"
	"zip" "unzip" "p7zip"
	"git" "neovim" "vi"
	"keychain" "hexyl" "gcc"
	"clang" "gdb" "python"
)

gui_pkgs=(
	"wezterm" "chromium"
	"noto-fonts-emoji"
	"noto-fonts-cjk"
)

pacman -Sy
pacman --noconfirm -S archlinux-keyring
pacman --noconfirm -S ${required_pkgs[@]} ${cli_pkgs[@]} ${gui_pkgs[@]}

gaming_pkgs=(
	"steam" "mangohud" "gamemode"
)

if [ $GAMING = true ]; then
	pacman --noconfirm -S ${gaming_pkgs[@]}
fi

exit 0
