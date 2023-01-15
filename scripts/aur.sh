#! usr/bin/zsh

install_pkg() {
	local pkg=$1
	[ $VERBOSE = true ] && echo "Installing ${pkg}"
	git clone "https://aur.archlinux.org/${pkg}.git" && cd $pkg && makepkg -si --noconfirm PKGBUILD
	cd .. && rm -rf $pkg
}

aur_pkgs=(
	"yay" "eww"
	"spotify" "nvm"
	"ttf-ms-win10-auto"
	"ttf-fixedsys-excelsior-linux"
	"mcmojave-cursors"
	"mojave-gtk-theme"
)

[ $VERBOSE = true ] && echo "Installing AUR packages."

for pkg in $aur_pkgs; do
	install_pkg $pkg
done

exit 0
