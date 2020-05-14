#!/bin/bash
# instantOS installer wrapper

# allow disabling gui
if [ -n "$1" ] && [ "$1" = "-cli" ]; then
    curl -Ls git.io/instantarch | sudo bash
    exit
fi

pgrep conky && pkill conky

# open up a logging window on second tag
echo "beginning installation" | sudo tee /root/instantos.log
xdotool key super+2
urxvt -e bash -c "sudo tail -f /root/instantos.log" &
sleep 3
xdotool key super+1

# connect user to the internet
if ! ping -c 1 archlinux.org; then
    INTERNETCHOICE="$(echo 'connect to wifi
cancel installation
I am connected to ethernet' | instantmenu -p 'internet required' -c -l 4)"

    if grep -q 'cancel' <<<"$INTERNETCHOICE"; then
        exit
    fi

    if grep -q 'wifi' <<<"$INTERNETCHOICE"; then
        urxvt -e bash -c "sudo wifi-menu && sleep 5"
    fi
fi

# run actual installer
if grep -iq arch /etc/os-release; then
    curl -Ls git.io/instantarch | sudo bash 2>&1 | sudo tee -a /root/instantos.log
    sudo touch /opt/finishinstall
    sudo cat /root/instantos.log >~/osinstall.log
fi &

INSTANTPROGRESS="loading"

# status bar showing install progress
while :; do
    if [ -e /opt/finishinstall ]; then
        pkill instantmenu
        break
    fi

    if ! [ -e /opt/instantprogress ]; then
        sleep 1
        echo "waiting for progress"
        continue
    fi

    if [ -z "$INSTANTPROGRESS" ]; then
        INSTANTPROGRESS="$(cat /opt/instantprogress)"
    fi

    NEWINSTANTPROGRESS="$(cat /opt/instantprogress)"
    if ! [ "$INSTANTPROGRESS" = "$NEWINSTANTPROGRESS" ] || ! pgrep instantmenu; then
        INSTANTPROGRESS="$NEWINSTANTPROGRESS"
        pkill instantmenu
        echo "> $INSTANTPROGRESS" | instantmenu -y 34 -l 1 -G
    fi
    sleep 2

done

# post install menu
if [ -e /opt/installsuccess ]; then
    REBOOTANSWER="$(echo 'yes
no' | instantmenu -p 'installation finished. reboot?')"
    if grep -q 'yes' <<<"$REBOOTANSWER"; then
        reboot
    fi
else
    echo "somethings appears to have gone wrong.
Refer to ~/osinstall.log for more information. 
Please open an issue with its
contents at https://github.com/instantOS/instantOS" | imenu -M
fi
