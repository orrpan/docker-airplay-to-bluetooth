#!/bin/sh

hciconfig hci0 up

if [ -z "$BT_DEVICE" ]; then

  # list pairable devices
  hcitool scan
  echo "Re-run with '-e BT_DEVICE=<device id>' to pair with a device."

else

  # start up with a specific device

  rm -f /var/run/dbus.pid
  dbus-daemon --system --fork

  rm -f /var/run/avahi-daemon/pid
  avahi-daemon &

  /usr/lib/bluetooth/bluetoothd --plugin=a2dp -n &

  rm -f /tmp/pulse-* ~/.pulse/*-runtime
  pulseaudio --log-level=1 --log-target=stderr --disallow-exit=true --exit-idle-time=-1 &

  hciconfig hci0 sspmode 0
  hciconfig hci0 piscan
  sleep 2
  /app/bluetooth-connect.exp

  sleep 5

  shairport-sync -a "$AIRPLAY_NAME" -o pulse

fi
