#!/bin/bash

# little bottom applet that is able to kill the installatio

while :; do

    echo "cancel installation" | instantmenu -b -y 32 -x 0 -w 400 -G
    if echo "yes
no" | instantmenu -c -G -l 2 -w 500 -p "do you want to cancel the installation" |
        grep -q yes; then
        sudo pkill instantosinstaller
        exit
    fi

done
