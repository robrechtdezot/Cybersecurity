#!/bin/bash
# sanitize.sh — Auto metadata & EXIF sanitizer

INPUT_DIR="$1"
RAND_NAMES=false  # set to true to rename files randomly
REMOVE_TIMESTAMPS=true

if [ -z "$INPUT_DIR" ]; then
    echo "Usage: $0 /path/to/files"
    exit 1
fi

echo "[*] Sanitizing files in: $INPUT_DIR"
cd "$INPUT_DIR" || exit 1

sanitize_image() {
    echo "  [IMG] Cleaning: $1"
    exiftool -overwrite_original -all= "$1"
}

sanitize_pdf_doc() {
    echo "  [DOC] Cleaning: $1"
    mat2 "$1" >/dev/null 2>&1
}

sanitize_audio_video() {
    echo "  [AV] Cleaning: $1"
    EXT="${1##*.}"
    ffmpeg -loglevel quiet -i "$1" -map 0 -c copy -map_metadata -1 "cleaned_$1"
    mv "cleaned_$1" "$1"
}

randomize_filename() {
    EXT="${1##*.}"
    NEWNAME="$(tr -dc a-z0-9 </dev/urandom | head -c 10).$EXT"
    echo "  [NAME] Renaming $1 -> $NEWNAME"
    mv "$1" "$NEWNAME"
}

for FILE in *; do
    [ -f "$FILE" ] || continue
    MIME=$(file --mime-type -b "$FILE")

    case "$MIME" in
        image/*) sanitize_image "$FILE" ;;
        application/pdf|application/msword|application/vnd*) sanitize_pdf_doc "$FILE" ;;
        video/*|audio/*) sanitize_audio_video "$FILE" ;;
        *) echo "  [SKIP] Unsupported type: $FILE" ;;
    esac

    if $RAND_NAMES; then
        randomize_filename "$FILE"
    fi

    if $REMOVE_TIMESTAMPS; then
        touch -d @0 "$FILE"
    fi
done

echo "[✔] Done sanitizing."