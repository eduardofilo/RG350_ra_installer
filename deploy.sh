#!/bin/bash

VERSION=`cat v`
BIOS=false
DIRECTORY=$(pwd)
OPK_NAME_ST=RA_Stock_Installer_v${VERSION}.opk
OPK_NAME_ODB=RA_ODBeta_Installer_v${VERSION}.opk
RA_DIST_DIR_ST=ra_dist_st
RA_DIST_DIR_ODB=ra_dist_odb
RA_DIST_FILE=${VERSION}_RetroArch.7z


# Stock
if [ -f ${RA_DIST_DIR_ST}/${RA_DIST_FILE} ] ; then
    echo "#### Building OPK for Stock distribution."
    ## Unpacking RA distribution
    if [ -d ${RA_DIST_DIR_ST}/retroarch ] ; then
        rm -rf ${RA_DIST_DIR_ST}/retroarch
    fi
    7z x -o${RA_DIST_DIR_ST} ${RA_DIST_DIR_ST}/${RA_DIST_FILE}
    unsquashfs -d ${RA_DIST_DIR_ST}/retroarch/fs ${RA_DIST_DIR_ST}/retroarch/retroarch_rg350.opk
    mv ${RA_DIST_DIR_ST}/retroarch/fs/retroarch files/
    mv ${RA_DIST_DIR_ST}/retroarch/retroarch_rg350.opk files/
    tar -czf files/retroarch.tgz -C ${DIRECTORY}/${RA_DIST_DIR_ST}/retroarch/.retroarch assets core_info cores database filters system
    rm -rf ${RA_DIST_DIR_ST}/retroarch

    ## create default.gcw0.desktop
    cat > ${DIRECTORY}/default.gcw0.desktop <<EOF
[Desktop Entry]
Type=Application
Name=RA Stock Installer v${VERSION}
Comment=Installer for RetroArch v${VERSION} on OD Stock
Exec=update.sh
Icon=icon
Categories=applications;
Terminal=true
EOF

    ## create opk
    FLIST="${DIRECTORY}/files"
    if [ ${BIOS} = true ] ; then
        FLIST="${FLIST} ${DIRECTORY}/bios.tgz"
    fi
    FLIST="${FLIST} ${DIRECTORY}/icon.png"
    FLIST="${FLIST} ${DIRECTORY}/update.sh"
    FLIST="${FLIST} ${DIRECTORY}/v"
    FLIST="${FLIST} ${DIRECTORY}/default.gcw0.desktop"

    if [ -f ${DIRECTORY}/releases/${OPK_NAME_ST} ] ; then
        rm ${DIRECTORY}/releases/${OPK_NAME_ST}
    fi

    mksquashfs ${FLIST} ${DIRECTORY}/releases/${OPK_NAME_ST} -all-root -no-xattrs -noappend -no-exports
    rm -f ${DIRECTORY}/default.gcw0.desktop

    #scp ${DIRECTORY}/releases/${OPK_NAME_ST} rg350:/media/sdcard/apps/
else
    echo "#### Stock distribution for ${VERSION} version not found, so not doing OPK."
fi

# OD Beta
if [ -f ${RA_DIST_DIR_ODB}/${RA_DIST_FILE} ] ; then
    echo "#### Building OPK for OD Beta distribution."
    ## Unpacking RA distribution
    if [ -d ${RA_DIST_DIR_ODB}/retroarch ] ; then
        rm -rf ${RA_DIST_DIR_ODB}/retroarch
    fi
    7z x -o${RA_DIST_DIR_ODB} ${RA_DIST_DIR_ODB}/${RA_DIST_FILE}
    unsquashfs -d ${RA_DIST_DIR_ODB}/retroarch/fs ${RA_DIST_DIR_ODB}/retroarch/retroarch_rg350_odbeta.opk
    mv ${RA_DIST_DIR_ODB}/retroarch/fs/retroarch files_odb/
    mv ${RA_DIST_DIR_ODB}/retroarch/retroarch_rg350_odbeta.opk files_odb/
    tar -czf files_odb/retroarch.tgz -C ${DIRECTORY}/${RA_DIST_DIR_ODB}/retroarch/.retroarch assets core_info cores database filters system
    rm -rf ${RA_DIST_DIR_ODB}/retroarch

    ## create default.gcw0.desktop
    cat > ${DIRECTORY}/default.gcw0.desktop <<EOF
[Desktop Entry]
Type=Application
Name=RA OD Beta Installer v${VERSION}
Comment=Installer for RetroArch v${VERSION} on OD Beta
Exec=update.sh
Icon=icon
Categories=applications;
Terminal=true
EOF

    ## create opk
    FLIST="${DIRECTORY}/files_odb"
    if [ ${BIOS} = true ] ; then
        FLIST="${FLIST} ${DIRECTORY}/bios.tgz"
    fi
    FLIST="${FLIST} ${DIRECTORY}/icon.png"
    FLIST="${FLIST} ${DIRECTORY}/update_odb.sh"
    FLIST="${FLIST} ${DIRECTORY}/v"
    FLIST="${FLIST} ${DIRECTORY}/default.gcw0.desktop"

    if [ -f ${DIRECTORY}/releases/${OPK_NAME_ODB} ] ; then
        rm ${DIRECTORY}/releases/${OPK_NAME_ODB}
    fi

    mksquashfs ${FLIST} ${DIRECTORY}/releases/${OPK_NAME_ODB} -all-root -no-xattrs -noappend -no-exports
    rm -f ${DIRECTORY}/default.gcw0.desktop

    #scp ${DIRECTORY}/releases/${OPK_NAME_ODB} rg350:/media/sdcard/apps/
else
    echo "#### OD Beta distribution for ${VERSION} version not found, so not doing OPK."
fi
