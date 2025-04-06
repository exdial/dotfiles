#!/bin/sh

xset s off            # disable screensaver
xset -dpms            # disable Display Power Manager Signaling
xset s noblank        # disable blank screen
xset r rate 200 100   # keyboard repeat rate

# set screen resolution
MODE="2880x1744_60.00"
OUTPUT=$(xrandr | grep " connected" | cut -d" " -f1)

if ! xrandr | grep -q "$MODE"; then
  xrandr --newmode "$MODE"  428.25  2880 3104 3416 3952  1744 1747 1757 1807 -hsync +vsync
  xrandr --addmode "$OUTPUT" "$MODE"
fi

exec i3
