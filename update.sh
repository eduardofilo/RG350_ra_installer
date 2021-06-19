#!/bin/sh

VERSION=`cat v`
INSTALL_CONF=false
INSTALL_UNOFF=false

# Screen determination
if grep -q "640x480" /sys/devices/platform/jz-lcd.0/graphics/fb0/modes; then
  MODEL="RG350M"
else
  MODEL="RG350P"
fi

export DIALOGOPTS="--colors --backtitle \"RetroArch installer v${VERSION}\""
echo "screen_color = (RED,RED,ON)" > /tmp/dialog_err.rc

TEXTO="
Choose if you want to install preset configurations of cores (if you have an old installation and made changes, they will be overwritten) and if you want to install unofficial cores.

Use \Zb\Z3X\Zn to check options and \Zb\Z3OK\Zn to proceed with installation."

# Ask options
result=$(dialog --stdout --title "RA Installer config" --checklist "$TEXTO" 0 0 0 1 "Install config" off 2 "Install unofficial cores" off)
if [ $? -eq 1 ] ; then
    exit 1
fi
if echo $result|grep -q "1"; then
    INSTALL_CONF=true
fi
if echo $result|grep -q "2"; then
    INSTALL_UNOFF=true
fi
clear

echo "Installing cores, please wait (about 2 minutes)..."
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
cp -f files/retroarch_rg350.opk /media/data/apps
if [ -f /media/data/local/bin/retroarch ] ; then
    rm /media/data/local/bin/retroarch
fi
cp -f files/retroarch_rg350 /media/data/local/bin
# Installing OPK wrappers for cores
tar -xzf files/apps_ra.tgz -C /media/data/apps
# Installing home files
mkdir -p /media/data/local/home/.retroarch
tar -xzf files/retroarch.tgz -C /media/data/local/home/.retroarch
# Installing GMenu2X links
mkdir -p /media/data/local/home/.gmenu2x/sections/retroarch
tar -xzf files/links.tgz -C /media/data/local/home/.gmenu2x/sections/retroarch
# Installing BIOS?
if [ -f bios.tgz ] ; then
    tar -xzf bios.tgz -C /media/data/local/home/.retroarch/system
fi
sync
echo "  DONE"

if [ ${INSTALL_CONF} = true ] ; then
    echo "Installing configs, please wait..."
    sleep 5

    # Installing configs
    if [[ "$MODEL" == "RG350P" ]] ; then
        tar -xzf files/configs_P.tgz -C /media/data/local/home/.retroarch
    fi
    if [[ "$MODEL" == "RG350M" ]] ; then
        tar -xzf files/configs_M.tgz -C /media/data/local/home/.retroarch
    fi
    sync
    echo "  DONE"
fi

if [ ${INSTALL_UNOFF} = true ] ; then
    echo "Installing unofficial cores, please wait..."
    sleep 5

    tar -xzf files/opendingux_ra_cores_unofficial.tgz -C /media/data/local/home/.retroarch/cores
    tar -xzf files/configs_unoff.tgz -C /media/data/local/home/.retroarch/config
    tar -xzf files/apps_unoff.tgz -C /media/data/apps
    tar -xzf files/links_unoff.tgz -C /media/data/local/home/.gmenu2x/sections/retroarch
    sync
    echo "  DONE"
fi

chown -R root:root /media/data/local/home/.retroarch
chown -R root:root /media/data/apps
chown -R root:root /media/data/local/home/.gmenu2x/sections/retroarch
sync

sleep 3

dialog --msgbox "Installation completed!\n\nRemember that following cores need BIOS files to run (LYNX, PC ENGINE CD, SEGA CD, VIDEOPAC, CHANNELF, ATARIST, AMIGA) or data files (OUTRUN, CAVESTORY, FLASHBACK).\n\nNow we are going to reboot. After pressing \Zb\Z3OK\Zn, let the console reboot itself, don't force it manually." 16 0
reboot
