#!/usr/bin/env bash

# Check if correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <output_file> <text> <size> <profile>"
    echo "Size must be 'large', 'normal', or 'small'"
    exit 1
fi

OUTPUT_FILE="$1"
TEXT="$2"
SIZE="$3"
TEMP_PREFIX="${OUTPUT_FILE%.*}"

# Load font profile
PROFILE_NAME="$4"
PROFILE_FILE="profiles/${PROFILE_NAME}.sh"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "Error: Profile file $PROFILE_FILE not found"
    exit 1
fi

# Source the profile and get parameters
source "$PROFILE_FILE"
eval "$(profile "$SIZE")"

# Configuration variables (loaded from profile + fixed)
BG_COLOR="black"        # Background color
TEXT_COLOR="white"      # Text color
CORNER_RADIUS=10        # Radius for rounded corners of background (in pixels)
BLUR_RADIUS=1           # Blur radius for background (in pixels)
FINAL_CORNER_RADIUS=10  # Radius for rounded corners of final image (in pixels)
CANVAS_PAD=10           # Extra pixels for final canvas (total width/height increase)
SOFT_EDGE_BLUR=3        # Blur radius for soft edge effect (in pixels)
SOFT_EDGE_LEVEL="70%,100%" # Level adjustment for soft edge alpha channel

# Create text image
convert -background transparent -font "$FONT_NAME" -pointsize $FONT_SIZE -fill "$TEXT_COLOR" label:"$TEXT" "${TEMP_PREFIX}-text.png"

# Get text image dimensions
line1_width=$(identify -format "%w" "${TEMP_PREFIX}-text.png")
line1_height=$(identify -format "%h" "${TEMP_PREFIX}-text.png")

# Calculate background dimensions with padding
bg_width=$((line1_width + BG_PAD_WIDTH))
bg_height=$((line1_height + BG_PAD_HEIGHT))

# Create background rectangle
convert -size ${bg_width}x${bg_height} xc:"$BG_COLOR" -draw "rectangle 0,0,$((bg_width-1)),$((bg_height-1))" "${TEMP_PREFIX}-bg.png"

# Composite text and background
convert -size ${bg_width}x${bg_height} xc:transparent \
  \( "${TEMP_PREFIX}-bg.png" -geometry +0+0 \) -composite \
  \( "${TEMP_PREFIX}-text.png" -geometry +$((BG_PAD_WIDTH/2 + BG_OFFSET_X))+$((BG_PAD_HEIGHT/2 + BG_OFFSET_Y)) \) -composite \
  "${TEMP_PREFIX}-temp.png"

# Create rounded corner mask for background (white background, black rounded rectangle)
convert -size ${bg_width}x${bg_height} xc:white -fill black \
  -draw "roundrectangle 0,0,$((bg_width-1)),$((bg_height-1)),$CORNER_RADIUS,$CORNER_RADIUS" "${TEMP_PREFIX}-mask.png"

# Apply mask to merged image
convert "${TEMP_PREFIX}-temp.png" "${TEMP_PREFIX}-mask.png" -alpha Off -compose DstIn -composite "${TEMP_PREFIX}-temp_masked.png"

# Apply blur to masked image
convert "${TEMP_PREFIX}-temp_masked.png" -gaussian-blur 0x${BLUR_RADIUS} "${TEMP_PREFIX}-temp_blurred.png"

# Create rounded corner mask for final image
convert -size ${bg_width}x${bg_height} xc:white -fill black \
  -draw "roundrectangle 0,0,$((bg_width-1)),$((bg_height-1)),$FINAL_CORNER_RADIUS,$FINAL_CORNER_RADIUS" "${TEMP_PREFIX}-final_mask.png"

# Apply final mask to blurred image
convert "${TEMP_PREFIX}-temp_blurred.png" "${TEMP_PREFIX}-final_mask.png" -alpha Off -compose DstIn -composite "${TEMP_PREFIX}-final.png"

# Apply soft edge effect
convert "${TEMP_PREFIX}-final.png" -alpha set -virtual-pixel transparent \
  -channel A -blur 0x${SOFT_EDGE_BLUR} -level ${SOFT_EDGE_LEVEL} +channel "${TEMP_PREFIX}-soft_edge.png"

# Calculate final canvas dimensions
canvas_width=$((bg_width + CANVAS_PAD))
canvas_height=$((bg_height + CANVAS_PAD))

# Place final image on larger canvas, centered
convert -size ${canvas_width}x${canvas_height} xc:transparent \
  \( "${TEMP_PREFIX}-soft_edge.png" -geometry +$((CANVAS_PAD/2))+$((CANVAS_PAD/2)) \) -composite "$OUTPUT_FILE"

# Clean up temporary files
rm "${TEMP_PREFIX}-text.png" "${TEMP_PREFIX}-bg.png" "${TEMP_PREFIX}-temp.png" "${TEMP_PREFIX}-mask.png" "${TEMP_PREFIX}-temp_masked.png" "${TEMP_PREFIX}-temp_blurred.png" "${TEMP_PREFIX}-final_mask.png" "${TEMP_PREFIX}-final.png" "${TEMP_PREFIX}-soft_edge.png"
