<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.biocollect.merit.SettingPageType" %>
<!DOCTYPE html>
<head>
    <title><g:layoutTitle/></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <link href="${g.createLink(controller: 'hub', action: 'generateStylesheet')}?ver=${hubConfig.lastUpdated}" rel="stylesheet"/>
    <asset:stylesheet src="base-bs4.css"/>
    <asset:javascript src="base-bs4.js"/>
    <g:layoutHead/>
    <style type="text/css">
    input[type=checkbox] {
        -webkit-transform: scale(1.5);
    }

    .checkbox-list label {
        min-height: 40px;
    }

    .speciesAutocompleteRow {
        min-height: 40px;
    }

    .datepicker td, .datepicker th {
        width: 40px;
        height: 40px;
        vertical-align: middle;
    }

    body {
        padding-top: 0px;
    }
    </style>
</head>

<body class="carousel">
<div class="site" id="page">
    <g:set var="bannerURL"
           value="${pageProperty(name: 'meta.bannerURL') ?: hubConfig.templateConfiguration.banner.images[0]?.url}"/>
    <g:if test="${pageProperty(name: 'meta.bannerURL')}">
        <div class="wrapper" id="catalogue">
            <main class="site-main">
                <article class="page">
                    <div id="banner" class="page-banner" style="background-image: url('${bannerURL}');">
                        <g:pageProperty name="page.banner"/>
                    </div>
                </article>
            </main>
        </div>
    </g:if>

    <div id="content" class="container-fluid mt-5">
        <g:layoutBody/>
    </div>
</div>
<script type="text/javascript">
    $.ajaxSetup({
        cache: false,
        xhrFields: {
            withCredentials: true
        },
        beforeSend: function (xhr) {
            xhr.setRequestHeader('authKey', "${authKey}");
            xhr.setRequestHeader('userName', "${userName}");
        }
    });
</script>
<asset:deferredScripts/>
</body>
</html>
