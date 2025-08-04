#!/bin/bash
# Paths (relative to the script's location)
REPO_DIR="$(pwd)" # Current directory (kd2phk-soundboard)
SOURCE_AUDIO_DIR="/home/patriot3g/soundboard-repo/audio"
AUDIO_DIR="$REPO_DIR/audio"

# Copy new .mp3 files from source to repo's audio directory
echo "Copying .mp3 files from $SOURCE_AUDIO_DIR to $AUDIO_DIR..."
rsync -av --include="*.mp3" --exclude="*" "$SOURCE_AUDIO_DIR/" "$AUDIO_DIR/"

# Generate index.html
echo "Generating index.html..."
cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KD2PHK Soundboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        ul {
            list-style: none;
            padding: 0;
        }
        li {
            margin: 10px 0;
            padding: 10px;
            background: #fff;
            border-radius: 5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        button {
            padding: 5px 10px;
            background: #007bff;
            color: #fff;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        button:hover {
            background: #0056b3;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h1>KD2PHK Soundboard</h1>
    <ul id="audio-list"></ul>

    <script>
        // List of audio files
        const audioFiles = [
EOF

# Add audio files to JavaScript array
for file in "$AUDIO_DIR"/*.mp3; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "            \"$filename\"," >> index.html
    fi
done

# Remove the last comma if there are any files
if [ -n "$(ls -A "$AUDIO_DIR"/*.mp3 2>/dev/null)" ]; then
    sed -i '$ s/,$//' index.html
fi

# Close the JavaScript and HTML
cat >> index.html << EOF
        ];

        // Populate the audio list
        const audioList = document.getElementById('audio-list');
        audioFiles.forEach(file => {
            const li = document.createElement('li');
            const fileName = file.replace(/\.mp3$/, '').replace(/_/g, ' ');
            li.innerHTML = \`
                <a href="audio/\${file}" target="_blank">\${fileName}</a>
                <button onclick="new Audio('audio/\${file}').play()">Play</button>
            \`;
            audioList.appendChild(li);
        });
    </script>
</body>
</html>
EOF

# Verify generated index.html
echo "Verifying index.html contents..."
grep -c "Breface.mp3" index.html && echo "Breface.mp3 found in index.html" || echo "Breface.mp3 not found in index.html"

# Check for changes
echo "Checking for changes..."
git add .
git status

if git diff-index --quiet HEAD; then
    echo "No new changes to commit."
else
    # Commit and push
    git commit -m "Update soundboard with new audio files - $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    echo "Soundboard updated and pushed to GitHub!"
fi
