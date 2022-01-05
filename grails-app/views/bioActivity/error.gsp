<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${mobile ? 'mobile' : 'bs4'}"/>
    <title>${error}</title>
</head>

<body>
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <h3 class="text-center text-danger"><strong>ERROR</strong></h3>
            <h4 class="text-center text-danger">${error}</h4>
        </div>
    </div>
</div>
</body>
</html>