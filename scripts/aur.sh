#! /bin/zsh

# Install yay package manager
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si PKGBUILD
cd .. && rm -r yay

aur_packages=(
	"spotify" "nvm"
	"ttf-ms-win10-auto"
	"ttf-fixedsys-excelsior-linux"
	"apple_cursor"
	"tela-circle-icon-theme-git"
	"graphite-gtk-theme-rimless-git"
)

yay --noconfirm -S ${aur_packages[@]}

exit 0
