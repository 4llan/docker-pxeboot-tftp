#!/bin/sh
#
# Set functions to generate menu header and labels according to Syslinux Menu system.
# https://wiki.syslinux.org/wiki/index.php?title=Config
# https://wiki.syslinux.org/wiki/index.php?title=Menu
# https://wiki.syslinux.org/wiki/index.php?title=Comboot/menu.c32

if [ ${0##*/} = "pxeboot-cfg.sh" ];
then
    echo "This script is meant to be sourced"
    exit 1
fi

#######################################
# Echoes the Syslinux menu header.
# Arguments:
#   [$1] Menu title, string
#   [$2] Master password (plaintext or hash), string
#######################################
header() {
    echo "DEFAULT menu.c32"
    echo "PROMPT 0"
    echo ""
    echo "MENU TITLE ${1:-"Default title"}"
    if [ -n "$2" ];
    then
        echo "MENU MASTER PASSWD $2"
    fi
}

#######################################
# Echoes the Syslinux menu entry label.
# Arguments:
#   [$1] Label name, string
#   [$2] Label displayed, string
#   [$3] Kernel-like file image, string (relative path)
#   [$4] Append kernel options, string
#   [$5] Password protected, int (1 == ON)
#######################################
label() {
    if [ "$1" ] && [ "$2" ] && [ "$3" ];
    then
        echo ""
        echo "LABEL $1"
        if [ "$5" -eq 1 ];
        then
            echo "  MENU PASSWD"
        fi
        echo "  MENU LABEL $2"
        echo "  KERNEL $3"
        if [ -n "$4" ];
        then
            echo "  APPEND $4"
        fi
    fi
}
