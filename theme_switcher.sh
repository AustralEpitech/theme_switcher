#!/usr/bin/bash
set -e
shopt -s failglob

NORMAL='\e[0m'
RED='\e[31m'
GREEN='\e[32m'

if [ "$EUID" == 0 ]; then
    echo -e "${RED}ERROR: This script cannot be run as root${NORMAL}"
    exit 1
fi

GTK2_FILE="$HOME/.gtkrc-2.0"
[ -n "$XDG_CONFIG_HOME" ] &&
    GTK3_FILE="$XDG_CONFIG_HOME/gtk-3.0/settings.ini" ||
    GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"

QT4_FILE="$HOME/.config/Trolltech.conf"

PS3="Choose a theme: "
select THEME in $(ls /usr/share/themes); do
    break
done
[ -z "$THEME" ] && exit

PS3="Choose an icon pack: "
select ICON in $(ls /usr/share/icons); do
    break
done
[ -z "$ICON" ] && exit

echo
echo -e "Selected theme: ${GREEN}${THEME}${NORMAL}"
echo -e "Selected icon pack: ${GREEN}${ICON}${NORMAL}"
echo

read -rp "Continue? (Ctrl-C to cancel)"

# GTK3/4 Wayland
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.wm.preferences theme "$ICON"

# GTK3
mkdir -p "$(dirname "$GTK3_FILE")"
cat << EOF > "$GTK3_FILE"
[Settings]
gtk-theme-name = $THEME
gtk-icon-theme-name = $ICON
EOF

# GTK2
cat << EOF > "$GTK2_FILE"
gtk-theme-name = "$THEME"
gtk-icon-theme-name = "$ICON"
EOF

# QT5
sudo -s -- << EOF
touch /etc/environment
sed -i '/XDG_CURRENT_DESKTOP=/d; /QT_STYLE_OVERRIDE=/d' /etc/environment
cat << FOF >> /etc/environment
XDG_CURRENT_DESKTOP=Unity
QT_STYLE_OVERRIDE=$THEME
FOF
EOF

# QT4
cat << EOF > "$QT4_FILE"
[Qt]
style=$THEME
EOF

echo -e "${GREEN}DONE. log out and in for the changes to take effect.${NORMAL}"
