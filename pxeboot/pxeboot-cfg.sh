#!/bin/bash

if [[ $(basename "$0") = $(basename "$BASH_SOURCE") ]];
then
    echo "This script is meant to be sourced"
    exit 1
fi

function header {
    echo "DEFAULT menu.c32"
    echo "PROMPT 0"
    echo ""
    echo "MENU TITLE ${1:-"Default title"}"
    if [[ ! -z $2 ]];
    then
        echo "MENU MASTER PASSWD $2"
    fi
}

function label {
    if [[ $1 && $2 && $3 ]];
    then
        echo ""
        echo "LABEL $1"
        if [[ $5 -eq 1 ]];
        then
            echo "  MENU PASSWD"
        fi
        echo "  MENU LABEL $2"
        echo "  KERNEL $3"
        if [[ ! -z $4 ]];
        then
            echo "  APPEND $4"
        fi
    fi
}
