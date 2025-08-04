#!/bin/bash
# Paths (relative to the script's location)
REPO_DIR="$(pwd)" # Current directory (kd2phk-soundboard)
SOURCE_AUDIO_DIR="/home/patriot3g/soundboard-repo/audio"
AUDIO_DIR="$REPO_DIR/audio"

# Check if directories exist
if [ ! -d "$SOURCE_AUDIO_DIR" ]; then
    echo "Error: Source audio directory $SOURCE_AUDIO_DIR does not exist."
    exit 1
fi
if [ ! -d "$AUDIO_DIR" ]; then
    echo "Creating audio directory $AUDIO_DIR..."
    mkdir -p "$AUDIO_DIR"
fi

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
    <title>KD2PHK Drunken Raccoon Soundboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@400;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Quicksand', sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: url('https://images.unsplash.com/photo-1516841273335-e39b378f1885?auto=format&fit=crop&w=1200&q=10') no-repeat center center fixed;
            background-size: cover;
            background-color: #333333;
            color: #fff;
        }
        h1 {
            text-align: center;
            color: #fff;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
            margin-bottom: 10px;
        }
        .header-img {
            display: block;
            margin: 0 auto 20px;
            max-width: 150px;
        }
        .search-bar {
            margin-bottom: 20px;
            text-align: center;
        }
        .search-bar input {
            padding: 10px;
            width: 300px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
        }
        .audio-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            padding: 0;
        }
        .audio-card {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            transition: transform 0.2s;
            position: relative;
        }
        .audio-card:hover {
            transform: scale(1.05);
        }
        .audio-card.raccoon {
            border: 2px solid #8B4513;
            background: rgba(255, 245, 224, 0.9);
        }
        .audio-card.raccoon:hover {
            animation: wobble 0.5s ease-in-out;
        }
        .audio-card.raccoon::before {
            content: '🦝🍺';
            position: absolute;
            top: -15px;
            right: -15px;
            font-size: 24px;
        }
        .audio-card span {
            display: block;
            color: #333;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .audio-card button {
            padding: 8px 16px;
            background: #FF6347;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-family: 'Quicksand', sans-serif;
        }
        .audio-card button:hover {
            background: #D83C2F;
        }
        .audio-card a {
            color: #800080;
            text-decoration: none;
            margin-left: 10px;
        }
        .audio-card a:hover {
            text-decoration: underline;
        }
        footer {
            text-align: center;
            margin-top: 20px;
            color: #ccc;
            font-style: italic;
        }
        @keyframes wobble {
            0% { transform: rotate(0deg); }
            25% { transform: rotate(3deg); }
            75% { transform: rotate(-3deg); }
            100% { transform: rotate(0deg); }
        }
        @media (max-width: 600px) {
            .audio-grid {
                grid-template-columns: 1fr;
            }
            .search-bar input {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <img src="https://img.icons8.com/emoji/96/000000/raccoon.png" alt="Drunken Raccoon Logo" class="header-img">
    <h1>KD2PHK Drunken Raccoon Soundboard</h1>
    <div class="search-bar">
        <input type="text" id="search" placeholder="Search audio files..." aria-label="Search audio files">
    </div>
    <div class="audio-grid" id="audio-list"></div>
    <footer>Powered by drunken raccoon chaos 🦝🍺</footer>
    <script>
        const audioFiles = [
EOF

# Add audio files to JavaScript array
files_found=0
for file in "$AUDIO_DIR"/*.mp3; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "            \"$filename\"," >> index.html
        files_found=1
    fi
done

# Remove the last comma if files were found
if [ $files_found -eq 1 ]; then
    sed -i '$ s/,$//' index.html
else
    echo "Warning: No .mp3 files found in $AUDIO_DIR."
fi

# Close the JavaScript and HTML
cat >> index.html << EOF
        ];
        const audioList = document.getElementById('audio-list');
        const searchInput = document.getElementById('search');
        function renderAudioList(files) {
            audioList.innerHTML = '';
            files.forEach(file => {
                const div = document.createElement('div');
                div.className = \`audio-card \${file.includes('Raccoons') ? 'raccoon' : ''}\`;
                const fileName = file.replace(/\.mp3$/, '').replace(/_/g, ' ');
                div.innerHTML = \`
                    <span>\${fileName}</span>
                    <button onclick="new Audio('audio/\${file}').play()" aria-label="Play \${fileName}">Play</button>
                    <a href="audio/\${file}" target="_blank" aria-label="Download \${fileName}">Download</a>
                \`;
                audioList.appendChild(div);
            });
        }
        renderAudioList(audioFiles);
        searchInput.addEventListener('input', () => {
            const query = searchInput.value.toLowerCase();
            const filteredFiles = audioFiles.filter(file => file.toLowerCase().includes(query));
            renderAudioList(filteredFiles);
        });
    </script>
</body>
</html>
EOF

# Verify generated index.html
echo "Verifying index.html contents..."
if grep -q "Breface.mp3" index.html; then
    echo "Breface.mp3 found in index.html"
else
    echo "Error: Breface.mp3 not found in index.html"
    exit 1
fi

# Check for changes
echo "Checking for changes..."
git add .
git status

if git diff-index --quiet HEAD; then
    echo "No new changes to commit."
else
    # Commit and push
    git commit -m "Update soundboard with drunken raccoon theme - $(date '+%Y-%m-%d %H:%M:%S')"
    if git push origin main; then
        echo "Soundboard updated and pushed to GitHub!"
    else
        echo "Error: Failed to push to GitHub. Check authentication settings."
        exit 1
    fi
fi
