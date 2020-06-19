#!/bin/bash

# little bottom applet that is able to kill the installation

killinstallation() {
    if sudo ps aux | grep '^root' | grep 'ask.sh' || [ "$1" = "force" ]; then
        sudo ps aux | grep '^root' | grep -Ei '(ask\.sh|instantosinstaller|sudo|install)' |
            grep -o 'root[^a-z0-9]*[0-9][0-9][0-9][0-9]' | grep -o '[0-9]*' >/tmp/installpid

        while read p; do
            echo "$p"
            sudo kill "$p"
        done </tmp/installpid
    fi
}

while :; do

    echo "cancel installation" | instantmenu -b -y 32 -x 0 -w 400 -G
    if echo "yes
no" | instantmenu -c -G -l 2 -w 500 -p "do you want to cancel the installation" |
        grep -q yes; then
        killinstallation
        exit
    fi

done
