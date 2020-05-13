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

# run actual installer
{
    curl -Ls git.io/instantarch | sudo bash 2>&1 | sudo tee -a /root/instantos.log
    touch /opt/finishinstall
    sudo cat /root/instantos.log >~/osinstall.log
} &

# status bar showing install progress
while :; do
    if [ -e /opt/finishinstall ]; then
        pkill instantmenu
        break
    fi

    if ! [ -e /opt/instantprogress ]; then
        sleep 1
        continue
    fi

    if [ -z "$INSTANTPROGRESS" ]; then
        INSTANTPROGRESS="$(cat /opt/instantprogress)"
    fi

    NEWINSTANTPROGRESS="$(cat /opt/instantprogress)"
    if ! [ "$INSTANTPROGRESS" = "$NEWINSTANTPROGRESS" ]; then
        INSTANTPROGRESS="$NEWINSTANTPROGRESS"
        pkill instantmenu
    fi
    sleep 2

done &

while :; do
    if [ -e /opt/finishinstall ]; then
        break
    fi

    if [ -n "$INSTANTPROGRESS" ]; then
        echo "> $INSTANTPROGRESS" | instantmenu -y 34 -l 1 -G
    fi
    sleep 1

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
