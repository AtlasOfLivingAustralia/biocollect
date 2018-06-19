<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Homepage</title>
    <style>
    %{-- Added to this page only to make image slider full page width --}%
    #main-content, #bannerHubContainer{
        padding-right: 0px;
        padding-left: 0px;
    }
    </style>
</head>
<body>
<g:if test="${hubConfig.title}">
    <div class="container-fluid" id="headerBannerSpace">
        <h1 class="title">${hubConfig.title}</h1>
    </div>
</g:if>

<g:render template="/shared/bannerHub"/>

<div class="${fluidLayout?'container-fluid':'container'}" id="hubHomepageContent">
    <g:if test="${hubConfig.templateConfiguration?.homePage?.buttonsConfig?.buttons}">
        <g:set var="layout" value="${Integer.parseInt(hubConfig.templateConfiguration?.homePage?.buttonsConfig?.numberOfColumns)}"></g:set>
        <div>
            <g:each in="${hubConfig.templateConfiguration?.homePage?.buttonsConfig?.buttons}" var="link" status="index">
                <g:if test="${(index) % layout == 0}">
                    </div>
                    <div class="row">
                </g:if>

                <config:createAButton config="${link}" layout="${layout}"></config:createAButton>
            </g:each>
        </div>
    </g:if>
</div>

</body>
</html>