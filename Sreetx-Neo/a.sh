#!/bin/bash

# 1. Eksekusi perubahan volume berdasarkan argumen script
case "$1" in
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

# 2. Ambil nilai volume murni dan paksa jadi Integer (pakai int() biar desimalnya ilang)
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')

# 3. Kirim angka bulatnya ke Quickshell via IPC
quickshell message mainRoot updateVolume "$VOLUME"
