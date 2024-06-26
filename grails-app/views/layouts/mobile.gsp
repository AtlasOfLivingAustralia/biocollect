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
            <g:if test="${Authorization}">
                xhr.setRequestHeader('Authorization', "${raw(Authorization)}");
            </g:if>
            <g:elseif test="${grailsApplication.config.getProperty("mobile.authKeyEnabled", Boolean) && authKey && userName}">
                xhr.setRequestHeader('authKey', "${raw(authKey)}");
                xhr.setRequestHeader('userName', "${raw(userName)}");
            </g:elseif>
        }
    });

    $(document).ajaxSend(window.incrementAsyncCounter);

    $(document).ajaxComplete(window.decreaseAsyncCounter);
</script>
<asset:deferredScripts/>
<g:if test="${grailsApplication.config.getProperty('fathom.enabled', Boolean, true)}">
    <!-- fathom analytics -->
    <script src="https://cdn.usefathom.com/script.js" data-site="${grailsApplication.config.getProperty('fathom.site-id')}" defer></script>
    <!-- END fathom analytics -->
</g:if>
<g:else>
    <!-- Google Analytics -->
    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga('create', '${grailsApplication.config.googleAnalyticsID}', 'auto');
        ga('send', 'pageview');
    </script>
    <!-- End Google Analytics -->
</g:else>
</body>
</html>
