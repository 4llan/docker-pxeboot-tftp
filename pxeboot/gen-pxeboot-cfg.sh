#!/bin/sh
#
# Generate Syslinux "pxeboot.cfg/default" menu file.
#
# Default entries:
# - Memtest86+
# - Clonezilla
# - GParted

BASEDIR=$(dirname $0)
TEMPDIR=$BASEDIR/tmp
CFGFILE=$TEMPDIR/pxeboot.cfg/default
CFGDIR=$(dirname $CFGFILE)

export PXE_IP_ADDR
export PXE_TITLE=${PXE_TITLE:-"pxeboot@docker"}
export PXE_PASSWD

if [ -z $PXE_IP_ADDR ];
then
    echo "Environment variable PXE_IP_ADDR is not set"
    exit 2
fi

source "$BASEDIR/pxeboot-cfg.sh"

find $TEMPDIR -type f -not -name '*.zip' -delete
find $TEMPDIR -mindepth 1 -type d -delete

[ ! -d $TEMPDIR ] && mkdir $TEMPDIR
[ ! -d $CFGDIR ] && mkdir $CFGDIR

############################################################
# Download and extract Syslinux necessary files to $TEMPDIR
# Arguments:
#   - [$1] Syslinux version, string
############################################################
syslinux() {
    local version=${1:-"6.03"}
    local label=syslinux-$version

    set -- "bios/com32/menu/menu.c32" \
           "bios/com32/elflink/ldlinux/ldlinux.c32" \
           "bios/com32/libutil/libutil.c32" \
           "bios/core/pxelinux.0"

    {
        [ ! -f $TEMPDIR/$label.zip ] &&
        wget -q https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/$label.zip -O $TEMPDIR/$label.zip

        unzip -q -o -j $TEMPDIR/$label "$@" -d $TEMPDIR
    } || return 255
}

############################################################
# Download, extract and echoes menu entry for Memtest86+
# Arguments:
#   - [$1] Password protected, int (1 == ON)
#   - [$2] Version, string
############################################################
memtest() {
    local passwd=${1:-0} && [ -z $PXE_PASSWD ] && passwd=0
    local version=${2:-"5.01"}
    local label=memtest86+-$version
    local kernel=/$label/$label

    {
        [ ! -d $TEMPDIR/$label ] &&
        mkdir $TEMPDIR/$label

        [ ! -f $TEMPDIR/$label.zip ] &&
        wget -q http://www.memtest.org/download/$version/$label.zip -O $TEMPDIR/$label.zip

        unzip -q -o $TEMPDIR/$label.zip -d $TEMPDIR/$label &&
        mv -f $TEMPDIR/$label/*.bin $TEMPDIR/$label/$label
    } || return 255

    label $label "Memtest86+ $version" $kernel "" $passwd
}

############################################################
# Download, extract and echoes menu entry for Clonezilla
# Arguments:
#   - [$1] Password protected, int (1 == ON)
#   - [$2] Version, string
#   - [$3] Architecture, string (amd64 | i686 | i686-pae)
############################################################
clonezilla() {
    local passwd=${1:-0} && [ -z $PXE_PASSWD ] && passwd=0
    local version=${2:-"2.5.6-22"}
    local arch=${3:-"amd64"}
    local label=clonezilla-live-$version-$arch
    local kernel=/$label/vmlinuz
    local append="initrd=$label/initrd.img boot=live username=user union=overlay config components quiet noswap edd=on nomodeset nodmraid locales= keyboard-layouts= ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" ocs_live_batch=no net.ifnames=0 nosplash noprompt vga=788 fetch=tftp://$PXE_IP_ADDR/$label/filesystem.squashfs"

    set -- "live/vmlinuz" \
           "live/initrd.img" \
           "live/filesystem.squashfs"

    {
        [ ! -d $TEMPDIR/$label ] &&
        mkdir $TEMPDIR/$label

        [ ! -f $TEMPDIR/$label.zip ] &&
        wget -q https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/$version/$label.zip/download -O $TEMPDIR/$label.zip

        unzip -q -o -j $TEMPDIR/$label.zip "$@" -d $TEMPDIR/$label
    } || return 255

    label $label "Clonezilla Live $version" $kernel "$append" $passwd
}

############################################################
# Download, extract and echoes menu entry for GParted
# Arguments:
#   - [$1] Password protected, int (1 == ON)
#   - [$2] Version, string
#   - [$3] Architecture, string (amd64 | i686 | i686-pae)
############################################################
gparted() {
    local passwd=${1:-0} && [ -z $PXE_PASSWD ] && passwd=0
    local version=${2:-"0.33.0-1"}
    local arch=${3:-"amd64"}
    local label=gparted-live-$version-$arch
    local kernel=/$label/vmlinuz
    local append="initrd=$label/initrd.img boot=live config components union=overlay username=user noswap noeject ip= vga=788 fetch=tftp://$PXE_IP_ADDR/$label/filesystem.squashfs"

    set -- "live/vmlinuz" \
           "live/initrd.img" \
           "live/filesystem.squashfs"

    {
        [ ! -d $TEMPDIR/$label ] &&
        mkdir $TEMPDIR/$label

        [ ! -f $TEMPDIR/$label.zip ] &&
        wget -q https://sourceforge.net/projects/gparted/files/gparted-live-stable/$version/$label.zip/download -O $TEMPDIR/$label.zip

        unzip -q -o -j $TEMPDIR/$label.zip "$@" -d $TEMPDIR/$label
    } || return 255

    label $label "Gparted Live $version" $kernel "$append" $passwd
}

main() {
    syslinux &&
    header "$PXE_TITLE" "$PXE_PASSWD" &&
    memtest 1 &&
    clonezilla 1 "2.6.6-15" "amd64" &&
    gparted 1 "1.1.0-1" "amd64"
}

main > $CFGFILE || {
    rm -rf $CFGDIR
    exit 1
}
