<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Audio Player</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        html, body { height: 100%; margin: 0; background: #fff; }
        body { display: flex; align-items: center; justify-content: center; }
        audio { width: 100%; max-width: 480px; }
    </style>
</head>
<body>
<%
    // Non-standard aliases make browsers skip a source they could otherwise play.
    // Leave the type off when it is missing or not a known audio type.
    def declaredType = params.contentType?.toString()?.toLowerCase()?.trim()
    def aliases = [
        'audio/mp3'     : 'audio/mpeg',
        'audio/wave'    : 'audio/wav',
        'audio/x-wav'   : 'audio/wav',
        'audio/x-pn-wav': 'audio/wav'
    ]
    def supported = ['audio/mpeg', 'audio/mp4', 'audio/ogg', 'audio/webm', 'audio/wav', 'audio/aac', 'audio/flac'] as Set
    def sourceType = aliases[declaredType] ?: (supported.contains(declaredType) ? declaredType : null)
%>
<audio controls preload="metadata">
    <g:if test="${sourceType}">
        <source src="${params.file}" type="${sourceType}"/>
    </g:if>
    <g:else>
        <source src="${params.file}"/>
    </g:else>
    Your browser does not support audio playback.
</audio>
</body>
</html>
