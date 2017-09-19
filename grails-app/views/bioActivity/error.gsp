<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${mobile ? 'mobile' : hubConfig.skin}"/>
    <title>${error}</title>
</head>

<body>
<div class="container-fluid">
    <div class="row-fluid">
        <h3 class="text-center text-error"><strong>ERROR</strong></h3>
        <h4 class="text-center text-error">${error}</h4>
    </div>
</div>
</body>
</html>