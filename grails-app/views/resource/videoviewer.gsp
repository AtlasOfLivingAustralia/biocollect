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
<%
    // application/ogg is a supported video type, but browsers skip playback when that
    // value is the source type. Do not assume mp4 when the type is missing or unknown.
    def declaredType = params.contentType?.toString()?.toLowerCase()?.trim()
    def sourceType = declaredType == 'application/ogg' ? 'video/ogg' : (declaredType?.startsWith('video/') ? declaredType : null)
%>
<video controls preload="metadata">
    <g:if test="${sourceType}">
        <source src="${params.file}" type="${sourceType}"/>
    </g:if>
    <g:else>
        <source src="${params.file}"/>
    </g:else>
</video>
</body>
</html>
