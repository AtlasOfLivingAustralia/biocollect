<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PDF</title>
    <style>
        html, body { margin: 0; height: 100%; background: #525659; }
        iframe { border: 0; width: 100%; height: 100%; }
    </style>
</head>
<body>
<g:if test="${params.file}">
    <iframe src="${params.file}" title="PDF document"></iframe>
</g:if>
</body>
</html>
