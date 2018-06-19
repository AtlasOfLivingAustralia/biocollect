<!DOCTYPE html>
<html>
<head>
    <title>An error has occurred</title>
    <meta name="layout" content="${hubConfig.skin}">
    <meta name="breadcrumb" content="Error"/>
    <link rel="stylesheet" href="${asset.assetPath(src: 'errors.css')}" type="text/css">
</head>

<body>
<div id="wrapper" class="container-fluid">
    <h1 style="margin:20px 0;">An error occurred</h1>
    <g:if test="${exception}">
        <g:renderException exception="${exception}"/>
    </g:if>
    <g:elseif test="${errorMessage}">
        <p>${errorMessage}</p>
    </g:elseif>
    <g:elseif test="${response.status == 404}">
        <p>404 - The requested page was not found</p>
    </g:elseif>
    <div class="space-before space-after">&nbsp</div>
</div>
</body>
</html>
