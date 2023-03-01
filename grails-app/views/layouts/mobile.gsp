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
    <div class="wrapper" id="catalogue">
        <main class="site-main">
            <article class="page">
                <g:if test="${pageProperty(name: 'meta.bannerURL')}">
                <div id="banner" class="page-banner" style="background-image: url('${bannerURL}');">
                    <g:pageProperty name="page.banner"/>
                </div>
                </g:if>
                <div id="content">
                    <g:layoutBody/>
                </div>
            </article>
        </main>
    </div>
</div>
<script type="text/javascript">
    $.ajaxSetup({
        cache: false,
        xhrFields: {
            withCredentials: true
        },
        beforeSend: function (xhr) {
            <g:if test="${authorization}">
                xhr.setRequestHeader('Authorization', "${authorization}");
            </g:if>
            <g:elseif test="${grailsApplication.config.getProperty("mobile.authKeyEnabled", Boolean) && authKey && userName}">
                xhr.setRequestHeader('authKey', "${authKey}");
                xhr.setRequestHeader('userName', "${userName}");
            </g:elseif>
            window.incrementAsyncCounter && window.incrementAsyncCounter();
        },
        complete: function () {
            window.decreaseAsyncCounter && window.decreaseAsyncCounter();
        }
    });
</script>
<asset:deferredScripts/>
</body>
</html>
