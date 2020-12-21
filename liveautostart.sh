#!/bin/bash

# this script autostarts on an instantOS live session

echo "applying live session tweaks"
# increase tmpfs size depending on ram size
MEMSIZERAW="$(grep MemTotal /proc/meminfo | grep -o '[0-9]*' | head -1)"

if grep -Eq '.{8,}'; then
    GIGSIZE="$(sed 's/........{8,}$//g' <<<"$MEMSIZERAW")"
    echo "$GIGSIZE gigs of ram detected"
    if [ "$GIGSIZE" -gt 1 ]; then
        TMPSIZE="$((GIGSIZE / 2))"
    fi
    if [ "$TMPSIZE" -eq "$TMPSIZE" ] && [ "$TMPSIZE" -gt 0 ]; then
        echo "failed setting tmpfs size"
        exit
    fi
    echo "setting tmpfs size to $TMPSIZE"
    mount -o remount,size="${TMPSIZE}G" /run/archiso/cowspace

else
    mount -o remount,size=512M /run/archiso/cowspace
fi

echo "finished applying live session tweaks"
