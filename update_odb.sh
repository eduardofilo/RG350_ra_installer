#!/bin/sh

VERSION=`cat v`

# Screen determination
if grep -q "640x480" /sys/devices/platform/jz-lcd.0/graphics/fb0/modes; then
  MODEL="RG350M"
else
  MODEL="RG350P"
fi

export DIALOGOPTS="--colors --backtitle \"RetroArch installer v${VERSION}\""
echo "screen_color = (RED,RED,ON)" > /tmp/dialog_err.rc

TEXTO="\Zb\Z3NOTE\Zn

RetroArch installer for RG350/RG280.

Select \Zb\Z3Yes\Zn, then press \Zb\Z3Start\Zn to proceed."

dialog --defaultno --yes-label 'Yes' --no-label 'Cancel' --yesno "$TEXTO" 15 48
if [ $? -eq 1 ] ; then
    exit 1
fi
clear

echo "Installing, please wait (about 2 minutes)..."
sleep 5


# Copying retroarch icon to all GMenu2X skins
for filename in /media/data/local/home/.gmenu2x/skins/*/; do
    mkdir -p "${filename}sections"
    cp -f files/retroarch.png "${filename}sections"
done
if [ -d /media/data/local/home/.gmenu2x/skins/Pixel ] ; then
    mkdir -p /media/data/local/home/.gmenu2x/skins/Pixel/sections
    cp -f files/retroarch_pixel.png /media/data/local/home/.gmenu2x/skins/Pixel/sections/retroarch.png
fi
# Installing OPK and executable
cp -f files/retroarch_rg350_odbeta.opk /media/data/apps
cp -f files/retroarch /media/data/local/bin
# Installing OPK wrappers for cores
tar -xzf files/apps_ra.tgz -C /media/data/apps
chown -R root:root /media/data/apps
# Installing home files
mkdir -p /media/data/local/home/.retroarch
tar -xzf files/retroarch.tgz -C /media/data/local/home/.retroarch
chown -R root:root /media/data/local/home/.retroarch
# Installing GMenu2X links
mkdir -p /media/data/local/home/.gmenu2x/sections/retroarch
tar -xzf files/links.tgz -C /media/data/local/home/.gmenu2x/sections/retroarch
chown -R root:root /media/data/local/home/.gmenu2x/sections/retroarch
# Installing configs
if [[ "$MODEL" == "RG350P" ]] ; then
    tar -xzf files/configs_P.tgz -C /media/data/local/home/.retroarch
fi
if [[ "$MODEL" == "RG350M" ]] ; then
    tar -xzf files/configs_M.tgz -C /media/data/local/home/.retroarch
fi
# Installing BIOS?
if [ -f bios.tgz ] ; then
    tar -xzf bios.tgz -C /media/data/local/home/.retroarch/system
    chown -R root:root /media/data/local/home/.retroarch
fi
sync
echo "  DONE"

sleep 3

dialog --msgbox "Installation completed!\n\nNow we are going to reboot. After pressing \Zb\Z3OK\Zn, let the console reboot itself, don't force it manually." 16 0
reboot
