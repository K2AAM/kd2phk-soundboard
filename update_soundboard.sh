#!/bin/bash

# Paths (relative to the script's location)
REPO_DIR="$(pwd)"  # Current directory (kd2phk-soundboard)
SOURCE_AUDIO_DIR="/home/patriot3g/soundboard-repo/audio"
AUDIO_DIR="$REPO_DIR/audio"

# Copy new .mp3 files from source to repo's audio directory
rsync -av --include="*.mp3" --exclude="*" "$SOURCE_AUDIO_DIR/" "$AUDIO_DIR/"

# Regenerate index.html using the PHP template
php -f index.php > index.html

# Check for changes
git add .
if git diff-index --quiet HEAD; then
    echo "No new changes to commit."
else
    # Commit and push
    git commit -m "Update soundboard with new audio files - $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    echo "Soundboard updated and pushed to GitHub!"
fi
