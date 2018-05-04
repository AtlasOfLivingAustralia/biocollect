<!doctype html>
<html>
	<head>
		<meta name="layout" content="adminLayout"/>
		<title>Admin - Audit Project | Data capture | Atlas of Living Australia</title>
		<style type="text/css" media="screen">
		</style>
	</head>
	<body>
	<asset:stylesheet src="datatables-manifest.css"/>
	<asset:javascript src="datatables-manifest.js"/>
	<asset:script type="text/javascript">
		var fcConfig = {
        	auditMessageUrl: "${createLink( controller: 'admin', action:'auditMessageDetails', params:[projectId: project.projectId])}"
		}
	</asset:script>
        <g:render template="auditProject"></g:render>
    </body>
</html>

