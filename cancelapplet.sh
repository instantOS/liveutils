#!/bin/bash

# little bottom applet that is able to kill the installation

killinstallation() {
    if sudo ps aux | grep '^root' | grep 'ask.sh' || [ "$1" = "force" ]; then
        sudo ps aux | grep '^root' | grep -Ei '(ask\.sh|instantosinstaller|sudo|install)' |
            grep -o 'root[^a-z0-9]*[0-9]*' | grep -o '[0-9]*' >/tmp/installpid
        sudo ps aux | grep -Ei 'instantosinstaller' |
            grep -o 'root[^a-z0-9]*[0-9]*' | grep -o '[0-9]*' >/tmp/userinstallpid

        while read p; do
            echo "$p"
            sudo kill "$p"
        done </tmp/installpid

        while read p; do
            echo "$p"
            sudo kill "$p"
        done </tmp/userinstallpid

        pkill instantmenu
        sudo pkill instantmenu
    fi
}

while :; do

    echo "cancel installation" | instantmenu -b -y 32 -x 0 -w 400 -G

    killinstallation
    exit

done
