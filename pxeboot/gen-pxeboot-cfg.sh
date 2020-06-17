#!/bin/sh

BASEDIR=$(dirname $0)
TEMPDIR=$BASEDIR/tmp
CFG_FILE=$TEMPDIR/pxeboot.cfg/default
CFG_DIR=$(dirname $CFG_FILE)

find $TEMPDIR -type f -not -name '*.zip' -delete
find $TEMPDIR -type d -mindepth 1 -delete

export PXE_IP_ADDR
export PXE_TITLE=${PXE_TITLE:-"pxeboot@docker"}
export PXE_PASSWD

if [ -z $PXE_IP_ADDR ];
then
    echo "You need to set PXE_IP_ADDR env var"
    exit 2
fi

source "$BASEDIR/pxeboot-cfg.sh"

if [[ ! -d $TEMPDIR ]];
then
    mkdir $TEMPDIR
fi
#cd $TEMPDIR

if [[ ! -d $CFG_DIR ]];
then
    mkdir $CFG_DIR
fi

syslinux() {
    local version=6.03
    local label=syslinux-$version

    set -- "bios/com32/menu/menu.c32" \
    "bios/com32/elflink/ldlinux/ldlinux.c32" \
    "bios/com32/libutil/libutil.c32" \
    "bios/core/pxelinux.0"

    {
        [ ! -f $TEMPDIR/$label.zip ] && wget -q https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/$label.zip -O $TEMPDIR/$label.zip
        unzip -q -o -j $TEMPDIR/$label "$@" -d $TEMPDIR
    } || return 255
}

memtest() {
    local passwd=${1:-0}
    local version=5.01
    local label=memtest86+-$version
    local kernel=/$label/$label
    if [ -z $PXE_PASSWD ];
    then
        passwd=0
    fi

    if [ ! -d $TEMPDIR/$label ];
    then
        mkdir $TEMPDIR/$label
    fi
    {
        [ ! -f $TEMPDIR/$label.zip ] && wget -q http://www.memtest.org/download/$version/$label.zip -O $TEMPDIR/$label.zip
        unzip -q -o $TEMPDIR/$label.zip -d $TEMPDIR/$label &&
        mv -f $TEMPDIR/$label/$label.bin $TEMPDIR/$label/$label
    } || return 255

    label $label "Memtest86+ $version" $kernel "" $passwd
}

clonezilla() {
    local passwd=${1:-0}
    local version=2.6.6-15 #2.5.6-22
    local arch=amd64
    local label=clonezilla-live-$version-$arch
    local kernel=/$label/vmlinuz
    local append="initrd=$label/initrd.img boot=live username=user union=overlay config components quiet noswap edd=on nomodeset nodmraid locales= keyboard-layouts= ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" ocs_live_batch=no net.ifnames=0 nosplash noprompt vga=788 fetch=tftp://$PXE_IP_ADDR/$label/filesystem.squashfs"
    if [ -z $PXE_PASSWD ];
    then
        passwd=0
    fi

    set -- "live/vmlinuz" \
    "live/initrd.img" \
    "live/filesystem.squashfs"

    if [ ! -d $TEMPDIR/$label ];
    then
        mkdir $TEMPDIR/$label
    fi
    {
        [ ! -f $TEMPDIR/$label.zip ] && wget -q https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/$version/$label.zip/download -O $TEMPDIR/$label.zip
        unzip -q -o -j $TEMPDIR/$label.zip "$@" -d $TEMPDIR/$label
    } || return 255

    label $label "Clonezilla Live $version" $kernel "$append" $passwd
}

gparted() {
    local passwd=${1:-0}
    local version=1.1.0-1 #0.33.0-1
    local arch=amd64
    local label=gparted-live-$version-$arch
    local kernel=/$label/vmlinuz
    local append="initrd=$label/initrd.img boot=live config components union=overlay username=user noswap noeject ip= vga=788 fetch=tftp://$PXE_IP_ADDR/$label/filesystem.squashfs"
    if [ -z $PXE_PASSWD ];
    then
        passwd=0
    fi

    set -- "live/vmlinuz" \
    "live/initrd.img" \
    "live/filesystem.squashfs"

    if [ ! -d $TEMPDIR/$label ];
    then
        mkdir $TEMPDIR/$label
    fi
    {
        [ ! -f $TEMPDIR/$label.zip ] && wget -q https://sourceforge.net/projects/gparted/files/gparted-live-stable/$version/$label.zip/download -O $TEMPDIR/$label.zip
        unzip -q -o -j $TEMPDIR/$label.zip "$@" -d $TEMPDIR/$label
    } || return 255

    label $label "Gparted Live $version" $kernel "$append" $passwd
}

main() {
    syslinux &&
    header "$PXE_TITLE" "$PXE_PASSWD" &&
    memtest 1 &&
    clonezilla 1 &&
    gparted 1
}

main > $CFG_FILE || {
    rm -rf $CFG_DIR
    exit 1
}
