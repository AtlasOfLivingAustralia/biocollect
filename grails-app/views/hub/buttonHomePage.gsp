<!--
/*
 * Copyright (C) 2016 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 4/11/16.
 */
-->
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Homepage</title>
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