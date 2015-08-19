

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <script>
        // Set up a timer that will periodically poll the server to keep the session alive
        var intervalSeconds = 300;

        setInterval(function() {
            document.getElementsByName('keepAliveForm')[0].submit();
        }, intervalSeconds * 1000);
    </script>
</head>
<body>

<g:form name="keepAliveForm" controller="ajax" action="keepSessionAlive" method="GET">
    <input type="hidden" name="keepalive" value="unused">
</g:form>
</body>
</html>