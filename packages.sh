#! /bin/zsh

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

all_packages=(
	${shell_packages[@]}
	${gui_packages[@]}
	${multimedia_packages[@]}
	${development_packages[@]}
)

pacman --noconfirm -S ${all_packages[@]}

exit
