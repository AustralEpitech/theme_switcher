#!/usr/bin/bash
set -e
shopt -s failglob

GREEN='\e[32m'
NORMAL='\e[0m'

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

if [ -n "$WAYLAND_DISPLAY" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
    gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
else
    echo "gtk-theme-name=$THEME"      > "$HOME/.gtkrc-2.0"
    echo "gtk-icon-theme-name=$ICON" >> "$HOME/.gtkrc-2.0"

    mkdir -p "$HOME/.config/gtk-3.0"
    echo "[Settings]"                 > "$HOME/.config/gtk-3.0/settings.ini"
    echo "gtk-theme-name=$THEME"     >> "$HOME/.config/gtk-3.0/settings.ini"
    echo "gtk-icon-theme-name=$ICON" >> "$HOME/.config/gtk-3.0/settings.ini"

    echo "QT_STYLE_OVERRIDE=$THEME" | sudo tee -a /etc/environment
fi
