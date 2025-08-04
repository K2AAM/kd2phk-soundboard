<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>KD2PHK Soundboard</title>
</head>
<body>
    <h1>KD2PHK Soundboard</h1>
    <ul>
    <?php
        $audio_dir = 'audio/';
        $files = glob($audio_dir . '*.mp3');
        foreach ($files as $file) {
            $filename = basename($file);
            echo "<li><a href=\"$file\" target=\"_blank\">$filename</a> <button onclick=\"new Audio('$file').play()\">Play</button></li>\n";
        }
    ?>
    </ul>
</body>
</html>
