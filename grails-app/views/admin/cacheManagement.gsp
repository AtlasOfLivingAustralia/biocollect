<!doctype html>
<html>
<head>
    <meta name="layout" content="adminLayout"/>
    <title>Cache Management | Admin | Data capture | Atlas of Living Australia</title>
    <asset:stylesheet src="base-bs4.css"/>
</head>

<body>
<content tag="pageTitle">Caches</content>
<h3>Caches Management</h3>
<div class="row">
    <ul>
        <g:each in="${cacheRegions}" var="cache">
            <li class="nav mb-2"><form action="clearCache"><button type="submit" class="btn btn-sm btn-danger" id="${cache}"><i class="fa fa-times"></i> Clear</button> ${cache} <input type="hidden" name="cache" value="${cache}"></form></li>
        </g:each>

    </ul>

</div>
<asset:javascript src="base-bs4.js"/>
</body>
</html>
