#!/usr/bin/env bash
# Tool Logo Generator
# Copyright (c) 2025 Ivan Kostrubin

profile() {
    local size=$1
    case $size in
        "large")
            echo "FONT_NAME='EurostileLTStd-BoldEx2'"
            echo "FONT_SIZE=64"
            echo "BG_PAD_WIDTH=19" # Border 
            echo "BG_PAD_HEIGHT=2" 
            echo "BG_OFFSET_X=0" # Move text on the text-background
            echo "BG_OFFSET_Y=8"
            ;;
        "normal")
            echo "FONT_NAME='EurostileLTStd-BoldEx2'"
            echo "FONT_SIZE=38"
            echo "BG_PAD_WIDTH=15"
            echo "BG_PAD_HEIGHT=7"
            echo "BG_OFFSET_X=0"
            echo "BG_OFFSET_Y=6"
            ;;
        "small")
            echo "FONT_NAME='EurostileLTStd-BoldEx2'"
            echo "FONT_SIZE=22"
            echo "BG_PAD_WIDTH=12"
            echo "BG_PAD_HEIGHT=7"
            echo "BG_OFFSET_X=0"
            echo "BG_OFFSET_Y=4"
            ;;
        *)
            echo "Error: Invalid size '$size'. Use 'large', 'normal', or 'small'." >&2
            exit 1
            ;;
    esac
}
