<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title><g:layoutTitle/></title>
    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <link href="${g.createLink(controller: 'hub', action: 'generateStylesheet')}?ver=${hubConfig.lastUpdated}" rel="stylesheet"/>
    <g:layoutHead/>
</head>

<body>
    <div class="site" id="content">
        <g:layoutBody/>
    </div>
    <asset:deferredScripts/>
</body>
</html>