#! /bin/zsh

install_pkg() {
	local pkg = $1
	[ $VERBOSE = true ] && echo "\tInstalling ${pkg}"
	git clone "https://aur.archlinux.org/${pkg}.git" && cd $pkg && makepkg -si PKGBUILD
	cd .. && rm -r $pkg
}

aur_pkgs=(
	"yay" "eww"
	"spotify" "nvm"
	"ttf-ms-win10-auto"
	"ttf-fixedsys-excelsior-linux"
	"mcmojave-cursors"
	"mojave-gtk-theme"
	"mcmojave-circle-icon-theme"
)

[ $VERBOSE = true ] && echo "Installing AUR packages."

install_pkg ${aur_pkgs[@]}

exit 0
