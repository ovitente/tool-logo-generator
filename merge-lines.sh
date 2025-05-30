#!/usr/bin/env bash
# Tool Logo Generator
# Copyright (c) 2025 Ivan Kostrubin

# Default configuration variables
OFFSET_X_1=0    # X offset for first image
OFFSET_Y_1=0    # Y offset for first image
OFFSET_X_2=0    # X offset for second image
OFFSET_Y_2=-19  # Y offset for second image
OFFSET_X_3=0   # X offset for third image
OFFSET_Y_3=-37  # Y offset for third image
DEFAULT_PROFILE_SIZE="large" # Default profile size
DEFAULT_ALIGN="center,center,center" # Default alignments

# Arrays to store texts, profile sizes, and alignments
texts=()
profile_sizes=()
alignments=()
PROFILE_NAME=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --text)
            texts+=("$2")
            shift 2
            ;;
        --font-size)
            IFS=',' read -ra fs <<< "$2"
            profile_sizes=("${fs[@]}")
            shift 2
            ;;
        --align)
            IFS=',' read -ra al <<< "$2"
            alignments=("${al[@]}")
            shift 2
            ;;
        --profile)
            PROFILE_NAME="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1"
            echo "Usage: $0 [--text <text>] [--font-size <large,normal,small>] [--align <left,center,right>] [--profile <profile_name>]"
            exit 1
            ;;
    esac
done

# Check if any texts are provided
if [ ${#texts[@]} -eq 0 ]; then
    echo "Error: No texts provided. Use --text to specify at least one text."
    exit 1
fi

# Check if profile is provided
if [ -z "$PROFILE_NAME" ]; then
    echo "Error: Profile name not provided. Use --profile to specify a profile."
    exit 1
fi

# Limit to maximum 3 texts
if [ ${#texts[@]} -gt 3 ]; then
    echo "Warning: Only the first 3 texts will be used."
    texts=("${texts[@]:0:3}")
fi

# Set profile sizes (default to large if not specified)
for i in {0..2}; do
    if [ -z "${profile_sizes[$i]}" ]; then
        profile_sizes[$i]=$DEFAULT_PROFILE_SIZE
    fi
    # Validate profile size
    case ${profile_sizes[$i]} in
        large|normal|small) ;;
        *) echo "Error: Invalid profile size '${profile_sizes[$i]}'. Use 'large', 'normal', or 'small'."; exit 1 ;;
    esac
done

# Set alignments (default to right,center,center if not specified)
IFS=',' read -ra default_al <<< "$DEFAULT_ALIGN"
for i in {0..2}; do
    if [ -z "${alignments[$i]}" ]; then
        alignments[$i]=${default_al[$i]:-center}
    fi
    # Validate alignment
    case ${alignments[$i]} in
        left|center|right) ;;
        *) echo "Error: Invalid alignment '${alignments[$i]}'. Use 'left', 'center', or 'right'."; exit 1 ;;
    esac
done

# Generate images using generate-line.sh
output_files=()
for i in {0..2}; do
    if [ -n "${texts[$i]}" ]; then
        output_file="output$((i+1)).png"
        text="${texts[$i]}"
        profile_size="${profile_sizes[$i]}"
        ./generate-line.sh "$output_file" "$text" "$profile_size" "$PROFILE_NAME"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to generate $output_file"
            # Skip failed generation and continue
            continue
        fi
        output_files+=("$output_file")
    fi
done

# Check if any images were generated
if [ ${#output_files[@]} -eq 0 ]; then
    echo "Error: No images were generated."
    exit 1
fi

# Calculate total height and max width
total_height=0
max_width=0
for file in "${output_files[@]}"; do
    # Get dimensions of each image
    width=$(identify -format "%w" "$file" 2>/dev/null || echo 0)
    height=$(identify -format "%h" "$file" 2>/dev/null || echo 0)
    total_height=$((total_height + height))
    if [ "$width" -gt "$max_width" ]; then
        max_width=$width
    fi
done

# Create a transparent canvas with calculated dimensions
convert -size "${max_width}x${total_height}" xc:transparent canvas.png

# Composite images onto the canvas with specified alignment
current_y=0
index=0
for file in "${output_files[@]}"; do
    width=$(identify -format "%w" "$file" 2>/dev/null || echo 0)
    height=$(identify -format "%h" "$file" 2>/dev/null || echo 0)
    # Get alignment and offsets based on index
    align=${alignments[$index]}
    case $index in
        0) offset_x=$OFFSET_X_1; offset_y=$((current_y + OFFSET_Y_1)) ;;
        1) offset_x=$OFFSET_X_2; offset_y=$((current_y + OFFSET_Y_2)) ;;
        2) offset_x=$OFFSET_X_3; offset_y=$((current_y + OFFSET_Y_3)) ;;
    esac
    # Calculate X offset based on alignment
    case $align in
        "right") offset_x=$((max_width - width + offset_x)) ;;
        "left") offset_x=$((0 + offset_x)) ;;
        "center") offset_x=$(((max_width - width) / 2 + offset_x)) ;;
        *) echo "Error: Invalid alignment '$align' for image $file"; exit 1 ;;
    esac
    composite -geometry "+${offset_x}+${offset_y}" "$file" canvas.png canvas.png
    current_y=$((current_y + height))
    index=$((index + 1))
done

# Rename final output and clean up
mv canvas.png output.png
for file in "${output_files[@]}"; do
    rm -f "$file"
done
