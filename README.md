<p align="center">
    <img src="logo.png" alt="Logo" width="200">
</p>

This project generates stylized text-based logos by combining multiple text lines into a single image. The `merge-lines.sh` script orchestrates the process, using `generate-line.sh` to create individual text images with customizable fonts, sizes, and alignments. Each text line is rendered with a black rounded background and white text, and the final image has a transparent background.

## Installation

1. Ensure you have [ImageMagick](https://imagemagick.org/) installed:
   ```bash
   sudo apt-get install imagemagick
   ```
2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd text-logo-gen
   ```
3. Make scripts executable:
   ```bash
   chmod +x merge-lines.sh generate-line.sh profiles/*.sh
   ```

## Usage

The main script is `merge-lines.sh`, which combines up to three text lines into a single image (`output.png`).

### Arguments

- `--text <text>`: Specifies the text for a line (up to 3 lines).
- `--font-size <large,normal,small>`: Sets the font size profile for each line, separated by commas (e.g., `large,normal,small`). Default: `large`.
- `--align <left,center,right>`: Sets the alignment for each line, separated by commas (e.g., `right,center,left`). Default: `center,center,center`.
- `--profile <profile_name>`: Specifies the font profile (e.g., `Eurostile`). Required.

### Examples

1. **Two lines with custom font sizes and alignments**:
   ```bash
   ./merge-lines.sh --text "LOGO" --text "GENERATOR" --font-size normal,small --align right,center --profile Eurostile
   ```
   - Generates `output.png` with "LOGO" (normal size, right-aligned) and "GENERATOR" (small size, center-aligned).

2. **Three lines with default alignments**:
   ```bash
   ./merge-lines.sh --text "LOGO" --text "GEN" --text "GITHUB" --font-size large,normal,small --profile Eurostile
   ```
   - Uses default alignments (`center,center,center`).

3. **Single line with custom alignment**:
   ```bash
   ./merge-lines.sh --text "LOGO" --font-size large --align left --profile Eurostile
   ```
   - Generates a single left-aligned line.

## Customization
### Profiles

Profiles is the way for setting up different fonts, sizes and positions.

### Creating a Custom Font Profile

Font profiles are stored in the `profiles/` directory as shell scripts. Each profile defines settings for three sizes (`large`, `normal`, `small`) to ensure proper text and background alignment.

#### Steps

1. Create a new file in `profiles/`, e.g., `profiles/MyFont.sh`.
2. Define a `profile` function that returns parameters for each size:
   - `FONT_NAME`: Name of the font (must be installed and recognized by ImageMagick).
   - `FONT_SIZE`: Point size for the text.
   - `BG_PAD_WIDTH`, `BG_PAD_HEIGHT`: Padding for the black background rectangle.
   - `BG_OFFSET_X`, `BG_OFFSET_Y`: Text offset relative to the background for centering.

#### Example Profile

```bash
#!/usr/bin/env bash

profile() {
    local size=$1
    case $size in
        "large")
            echo "FONT_NAME='EurostileLTStd-BoldEx2'"
            echo "FONT_SIZE=64"
            echo "BG_PAD_WIDTH=20"
            echo "BG_PAD_HEIGHT=6"
            echo "BG_OFFSET_X=0"
            echo "BG_OFFSET_Y=8"
            ;;
        "normal")
            echo "FONT_NAME='EurostileLTStd-BoldEx2'"
            echo "FONT_SIZE=48"
            echo "BG_PAD_WIDTH=16"
            echo "BG_PAD_HEIGHT=4"
            echo "BG_OFFSET_X=0"
            echo "BG_OFFSET_Y=6"
            ;;
        "small")
            echo "FONT_NAME='EurostileLTStd-BoldEx2'"
            echo "FONT_SIZE=32"
            echo "BG_PAD_WIDTH=12"
            echo "BG_PAD_HEIGHT=3"
            echo "BG_OFFSET_X=0"
            echo "BG_OFFSET_Y=4"
            ;;
        *)
            echo "Error: Invalid size '$size'. Use 'large', 'normal', or 'small'." >&2
            exit 1
            ;;
    esac
}
```

3. Make the profile executable:
   ```bash
   chmod +x profiles/MyFont.sh
   ```
4. Use the profile:
   ```bash
   ./merge-lines.sh --text "LOGO" --profile MyFont
   ```

#### Notes

- Ensure the font (`FONT_NAME`) is installed on your system. Check available fonts with:
  ```bash
  convert -list font
  ```
- Adjust `BG_PAD_WIDTH`, `BG_PAD_HEIGHT`, and `BG_OFFSET_Y` to center the text within the background for each size.

## Dependencies

- **Font**: Specified in the profile (e.g., `EurostileLTStd-BoldEx2`). I can't put it into the repository because it is proprietary. You can easely find it by yourself.
- **ImageMagick**: For image processing.

## Output

The final image is saved as `output.png` with a transparent background. Temporary files are automatically deleted.
