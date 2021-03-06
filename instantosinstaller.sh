#!/bin/bash
# instantOS installer wrapper

# warn user when installing without power source
if acpi | grep -i discharging; then
    echo "laptop without power source detected"
    if echo 'Warning: discharging battery detected
it is recommended to connect your device to a power
source or ensure it is fully charged
before beginning the installation
Begin installation?' | imenu -C; then
        echo "ignoring warning"
    else
        exit
    fi
fi

# connect user to the internet
if ! {
    checkinternet ||
        curl -s cht.sh ||
        curl -s http://packages.instantos.io &> /dev/null ||
        ping -c 1 archlinux.org ||
        ping -c github.com ||
        curl -s https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt
}; then
    sudo systemctl start NetworkManager &
    echo "please connect to the internet before starting the installation
ethernet is recommended
for wifi please use the applet in the top right
and then restart the installation" | imenu -M &
    pgrep nm-applet && pkill nm-applet
    sleep 0.5
    nm-appet &
    exit 1
fi

# allow disabling gui
if [ -n "$1" ] && [ "$1" = "-cli" ]; then
    curl -Ls git.io/instantarch | sudo bash
    exit
fi

pgrep conky && pkill conky

# open up a logging window on second tag
echo "beginning installation" | sudo tee /root/instantos.log
xdotool key super+2

while :; do
    st -e bash -c "sudo tail -f /root/instantos.log"
    sleep 10
done &

sleep 3
xdotool key super+1

# will be killed when the installer is running
echo ':b Preparing installation...' | instantmenu -l 3 -q "please wait..." -i -h -1 -w -1 -c -bw 8 &

# run actual installer
if grep -iq arch /etc/os-release; then
    curl -Ls git.io/instantarch | sudo bash 2>&1 | sudo tee -a /root/instantos.log
    sudo touch /opt/finishinstall
    sleep 2
    pkill instantmenu
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
        continue
    fi

    if [ -e /opt/instantprogress ]; then
        if [ -z "$INSTANTPROGRESS" ]; then
            INSTANTPROGRESS="$(cat /opt/instantprogress)"
        fi

        NEWINSTANTPROGRESS="$(cat /opt/instantprogress)"
        if ! [ "$INSTANTPROGRESS" = "$NEWINSTANTPROGRESS" ] || ! pgrep instantmenu; then
            INSTANTPROGRESS="$NEWINSTANTPROGRESS"
            pkill instantmenu
            echo "> $INSTANTPROGRESS" | instantmenu -b -l 1 -G
            export MENUPID="$?"
        fi
        sleep 2
    fi

done

# post install menu
if [ -e /opt/installsuccess ]; then
    REBOOTANSWER="$(echo 'yes
no' | instantmenu -c -bw 4 -p 'installation finished. reboot?')"
    if grep -q 'yes' <<<"$REBOOTANSWER"; then
        reboot
    fi
else
    echo "somethings appears to have gone wrong.
Refer to ~/osinstall.log for more information. 
Please open an issue with its
contents at https://github.com/instantOS/instantOS" | imenu -M
fi
