#!/bin/sh

VERSION=`cat v`

# Screen determination
if grep -q "640x480" /sys/devices/platform/13050000.lcd-controller/graphics/fb0/modes; then
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
for filename in /media/data/local/home/.gmenu2x/skins/320x240/*/; do
    mkdir -p "${filename}sections"
    cp -f files_odb/retroarch.png "${filename}sections"
done
for filename in /media/data/local/home/.gmenu2x/skins/640x480/*/; do
    mkdir -p "${filename}sections"
    cp -f files_odb/retroarch.png "${filename}sections"
done
# Installing OPK and executable
cp -f files_odb/retroarch_rg350_odbeta.opk /media/data/apps
cp -f files_odb/retroarch /media/data/local/bin
# Installing OPK wrappers for cores
tar -xzf files_odb/apps_ra.tgz -C /media/data/apps
# Installing home files
mkdir -p /media/data/local/home/.retroarch
tar -xzf files_odb/retroarch.tgz -C /media/data/local/home/.retroarch
# Installing GMenu2X links
mkdir -p /media/data/local/home/.gmenu2x/sections/retroarch
tar -xzf files_odb/links.tgz -C /media/data/local/home/.gmenu2x/sections/retroarch
# Installing configs
if [[ "$MODEL" == "RG350P" ]] ; then
    tar -xzf files_odb/configs_P.tgz -C /media/data/local/home/.retroarch
fi
if [[ "$MODEL" == "RG350M" ]] ; then
    tar -xzf files_odb/configs_M.tgz -C /media/data/local/home/.retroarch
fi
# Installing BIOS?
if [ -f bios.tgz ] ; then
    tar -xzf bios.tgz -C /media/data/local/home/.retroarch/system
fi
sync
echo "  DONE"

sleep 3

dialog --msgbox "Installation completed!\n\nRemember that following cores need BIOS files to run: LYNX, PC ENGINE CD, SEGA CD, VIDEOPAC.\n\nNow we are going to reboot. After pressing \Zb\Z3OK\Zn, let the console reboot itself, don't force it manually." 16 0
reboot
