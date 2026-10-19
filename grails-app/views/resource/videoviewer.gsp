<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Video Player</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        html, body { height: 100%; margin: 0; background: #000; }
        body { display: flex; align-items: center; }
        video { width: 100%; max-height: 100%; }
    </style>
</head>
<body>
<video controls preload="metadata">
    <source src="${params.file}" type="${params.contentType ?: 'video/mp4'}"/>
</video>
</body>
</html>
