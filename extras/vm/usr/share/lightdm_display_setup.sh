#!/usr/bin/env sh

# set screen resolution
xrandr --newmode "2880x1744_60.00"  428.25  2880 3104 3416 3952  1744 1747 1757 1807 -hsync +vsync
xrandr --addmode Virtual-1 2880x1744_60.00
xrandr --output Virtual-1 --mode 2880x1744_60.00

# set keyboard repeat rate
xset r rate 200 100
