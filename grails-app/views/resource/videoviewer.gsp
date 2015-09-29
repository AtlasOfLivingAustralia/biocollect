<!DOCTYPE html>
<html>
<head>
    <title>Video Player</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

    <!-- Chang URLs to wherever Video.js files will be hosted -->
    <link href="${g.resource(dir: 'vendor/video-js/4.12.11/', file: 'video-js.css')}" rel="stylesheet" type="text/css">
    <!-- video.js must be in the <head> for older IEs to work. -->
    <script src="${g.resource(dir: 'vendor/video-js/4.12.11/', file: 'video.js')}"></script>

    <!-- Unless using the CDN hosted version, update the URL to the Flash SWF -->
    <script>
        videojs.options.flash.swf = "${g.resource(dir: 'vendor/video-js/4.12.11/', file: 'video-js.swf')}";
    </script>

    <style>
    body {
        padding: 0;
        margin: 0;
        display: flex;
        align-items: center;
    }
    html, body {
        height: 100%;
    }

    .container {
        height: auto;
        margin: auto;
        width: 100%;
    }
    .video-js, .vjs-tech {
        position: relative !important;
        width: 100% !important;
        height: auto !important;
    }
    .vjs-poster {
        position: absolute !important;
        left: 0;
        right: 0;
        top: 0;
        bottom: 0;
    }
    </style>
</head>
<body>
<div class="container">
<video id="video" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="none"
       %{--poster="http://video-js.zencoder.com/oceans-clip.png"--}%
       data-setup="{}">
    <source src="${params.file}" type='${params.contentType}' />
    %{--TODO - Multiple video types--}%
    %{--<source src="http://video-js.zencoder.com/oceans-clip.webm" type='video/webm' />--}%
    %{--<source src="http://video-js.zencoder.com/oceans-clip.ogv" type='video/ogg' />--}%
    %{--<track kind="captions" src="demo.captions.vtt" srclang="en" label="English"></track><!-- Tracks need an ending tag thanks to IE9 -->--}%
    %{--<track kind="subtitles" src="demo.captions.vtt" srclang="en" label="English"></track><!-- Tracks need an ending tag thanks to IE9 -->--}%
    <p class="vjs-no-js">To view this video please enable JavaScript, and consider upgrading to a web browser that <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>
</video>
</div>
</body>
</html>
