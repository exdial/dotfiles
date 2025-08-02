#!/bin/sh

# X11 session environment
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export DESKTOP_SESSION=i3
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# X11 clipboard + features for VMware
vmware-user &

# Keyboard/DPMS/screen tweaks
xset s off            # disable screensaver
xset -dpms            # disable Display Power Manager Signaling
xset s noblank        # disable blank screen
xset r rate 200 100   # keyboard repeat rate

# Screen resolution
MODE="2880x1744_60.00"
OUTPUT=$(xrandr | grep " connected" | cut -d" " -f1)

if ! xrandr | grep -q "$MODE"; then
  xrandr --newmode "$MODE"  428.25  2880 3104 3416 3952  1744 1747 1757 1807 -hsync +vsync
  xrandr --addmode "$OUTPUT" "$MODE"
fi

xrdb -merge ~/.Xresources

exec i3
