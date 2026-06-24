<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title><g:layoutTitle/></title>
    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <link href="${g.createLink(controller: 'hub', action: 'generateStylesheet')}?ver=${hubConfig.lastUpdated}" rel="stylesheet"/>
    <script src="https://cdn.usefathom.com/script.js" data-site="${grailsApplication.config.getProperty('fathom.pwa-site-id') ?: grailsApplication.config.getProperty('fathom.site-id')}" defer></script>
    <g:layoutHead/>
</head>

<body>
    <div class="site" id="content">
        <g:layoutBody/>
    </div>
    <asset:deferredScripts/>
</body>
</html>