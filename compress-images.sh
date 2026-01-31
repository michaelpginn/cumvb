#!/bin/bash

# Image compression script for CUMVB website
# Uses macOS built-in sips command

set -e

ASSETS_DIR="$(dirname "$0")/assets"
BACKUP_DIR="$(dirname "$0")/assets_backup"

echo "=== CUMVB Image Compression Script ==="
echo ""

# Create backup
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup of original images..."
    cp -r "$ASSETS_DIR" "$BACKUP_DIR"
    echo "Backup created at: $BACKUP_DIR"
else
    echo "Backup already exists at: $BACKUP_DIR"
fi

echo ""
echo "Compressing images..."
echo ""

# Function to get file size in human readable format
get_size() {
    du -h "$1" | cut -f1
}

# Compress gallery and team photos (resize to max 1600px width)
echo "--- Gallery & Team Photos (resizing to max 1600px width) ---"
for img in "$ASSETS_DIR"/team.jpg "$ASSETS_DIR"/team2.jpeg "$ASSETS_DIR"/gallery*.jp*g; do
    if [ -f "$img" ]; then
        before=$(get_size "$img")
        filename=$(basename "$img")

        # Get current width
        width=$(sips -g pixelWidth "$img" | tail -1 | awk '{print $2}')

        if [ "$width" -gt 1600 ]; then
            sips --resampleWidth 1600 "$img" --out "$img" > /dev/null 2>&1
            after=$(get_size "$img")
            echo "  $filename: $before -> $after"
        else
            echo "  $filename: $before (already ≤1600px wide, skipped)"
        fi
    fi
done

echo ""
echo "--- Roster Photos (resizing to max 300px width) ---"
for img in "$ASSETS_DIR"/roster/*.jp*g "$ASSETS_DIR"/roster/*.png; do
    if [ -f "$img" ]; then
        before=$(get_size "$img")
        filename=$(basename "$img")

        # Skip blank placeholder
        if [ "$filename" = "blank.jpg" ]; then
            echo "  $filename: $before (placeholder, skipped)"
            continue
        fi

        # Get current width
        width=$(sips -g pixelWidth "$img" | tail -1 | awk '{print $2}')

        if [ "$width" -gt 300 ]; then
            sips --resampleWidth 300 "$img" --out "$img" > /dev/null 2>&1
            after=$(get_size "$img")
            echo "  $filename: $before -> $after"
        else
            echo "  $filename: $before (already ≤300px wide, skipped)"
        fi
    fi
done

echo ""
echo "=== Compression complete! ==="
echo ""
echo "To restore originals: rm -rf assets && mv assets_backup assets"
