#!/bin/bash

VERSION=`cat v`
BIOS=false
OPK_NAME=RA_Installer_v${VERSION}.opk
DIRECTORY=$(pwd)


# create default.gcw0.desktop
cat > ${DIRECTORY}/default.gcw0.desktop <<EOF
[Desktop Entry]
Type=Application
Name=RA Installer v${VERSION}
Comment=Installer for RetroArch v${VERSION}
Exec=update.sh
Icon=icon
Categories=applications;
Terminal=true
EOF

# create opk
FLIST="${DIRECTORY}/files"
if [ ${BIOS} = true ] ; then
    FLIST="${FLIST} ${DIRECTORY}/bios.tgz"
fi
FLIST="${FLIST} ${DIRECTORY}/icon.png"
FLIST="${FLIST} ${DIRECTORY}/update.sh"
FLIST="${FLIST} ${DIRECTORY}/v"
FLIST="${FLIST} ${DIRECTORY}/default.gcw0.desktop"

if [ -f ${DIRECTORY}/${OPK_NAME} ] ; then
    rm ${DIRECTORY}/${OPK_NAME}
fi

mksquashfs ${FLIST} ${DIRECTORY}/${OPK_NAME} -all-root -no-xattrs -noappend -no-exports
rm -f ${DIRECTORY}/default.gcw0.desktop

#scp ${DIRECTORY}/${OPK_NAME} rg350:/media/sdcard/apps/
