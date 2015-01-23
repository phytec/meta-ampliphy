#!/bin/sh

### turn of the blinking cursor of the framebuffer console
echo 0 > /sys/class/graphics/fbcon/cursor_blink

### QT Environment Variables ###
export QT_QPA_GENERIC_PLUGINS=Auto
export QT_QPA_PLATFORM=eglfs
