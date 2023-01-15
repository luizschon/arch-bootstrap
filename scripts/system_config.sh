#! /bin/zsh

. "/scripts/system.conf"
. "/scripts/user.conf"

# Creates user directories
xdg-user-dirs-update

# Input methods configuration
cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
        Identifier "Keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "${kblayout}"
        Option "XkbVariant" "${kbvariant}"
EndSection
EOF

cat > /etc/X11/xorg.conf.d/30-touchpad.conf << EOF
Section "InputClass"
    Identifier "Touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "NaturalScrolling" "true"
    Option "Tapping" "on"
EndSection
EOF

# Bluetooth configuration
# Enables auto power-on after boot/resume
sed -i 's/#\(AutoEnable=\).*/\1true/' /etc/bluetooth/main.conf

exit
