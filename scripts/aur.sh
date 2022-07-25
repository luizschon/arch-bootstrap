#! /bin/zsh

# Install yay package manager
git clone https://aur.archlinux.org/yay.git && makepkg -si ./yay/PKGBUILD
rm -r ./yay

aur_packages=(
	"spotify" "nvm"
	"ttf-ms-win10-auto"
	"ttf-fixedsys-excelsior-linux"
)

yay --noconfirm -S ${aur_packages[@]}

exit 0
