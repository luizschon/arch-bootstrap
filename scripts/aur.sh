#! /usr/bin/env zsh

install_pkg() {
	local pkg=$1
	[ $VERBOSE = true ] && echo "Installing ${pkg}"
	git clone "https://aur.archlinux.org/${pkg}.git" && cd $pkg && makepkg -si --noconfirm PKGBUILD
	cd .. && rm -rf $pkg
}

aur_pkgs=(
	"yay"
	"spotify" "nvm"
	"ttf-ms-win10-auto"
)

[ $VERBOSE = true ] && echo "Installing AUR packages."

for pkg in $aur_pkgs; do
	install_pkg $pkg
done

exit 0
