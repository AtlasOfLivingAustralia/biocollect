<!DOCTYPE html>
<html>
<head>
    <title><g:if env="development">Grails Runtime Exception</g:if><g:else>Error</g:else></title>
    <meta name="layout" content="${hubConfig.skin}">
    <meta name="breadcrumb" content="Error"/>
    <link rel="stylesheet" href="${asset.assetPath(src: 'errors.css')}" type="text/css">
</head>

<body>
<div id="wrapper" class="container-fluid">
    <g:if env="development">
        <g:renderException exception="${exception}"/>
    </g:if>
    <g:else>
        <ul class="errors">
            <li>An error has occurred</li>
        </ul>
    </g:else>
</div>
</body>
</html>

