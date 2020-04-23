<!doctype html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Welcome to ${grailsApplication.config.appName?.capitalize()}!</title>
</head>

<body>
<div class="row-fluid">
    <div class="span9" id="page-body" role="main">
        <bc:koLoading>

        </bc:koLoading>
        <h3>Welcome to ${grailsApplication.config.appName?.capitalize()}!</h3>
    </div>
</div>

</div>
</body>
</html>
