#!/usr/bin/env bash

# Array of 10 different texts
texts=(
    "7"
    "GITHUB"
    "TEXT"
    "LOGOGEN"
    "SAMPLE TEXT"
    "GROK AI"
    "IMAGE GEN"
    "TEXT STYLING"
    "BASH SCRIPT"
    "FINAL TEST"
)

# Generate 10 images using igen.sh
for i in {1..10}; do
    output_file="output${i}.png"
    text="${texts[$((i-1))]}"
    ./igen.sh "$output_file" "$text"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate $output_file"
        exit 1
    fi
done

# Collect all output files
output_files=()
for i in {1..10}; do
    output_files+=("output${i}.png")
done

# Calculate total height and max width
total_height=0
max_width=0
for file in "${output_files[@]}"; do
    # Get dimensions of each image
    width=$(identify -format "%w" "$file")
    height=$(identify -format "%h" "$file")
    total_height=$((total_height + height))
    if [ "$width" -gt "$max_width" ]; then
        max_width=$width
    fi
done

# Create a white canvas with calculated dimensions
convert -size "${max_width}x${total_height}" xc:white canvas.png

# Composite images onto the canvas
current_y=0
for file in "${output_files[@]}"; do
    height=$(identify -format "%h" "$file")
    composite -geometry +0+$current_y "$file" canvas.png canvas.png
    current_y=$((current_y + height))
done

# Rename final output and clean up
mv canvas.png merged_output.png
rm output{1..10}.png
