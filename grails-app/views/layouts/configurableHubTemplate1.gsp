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
 * Created by Temi on 1/11/16.
 */
-->
<g:set var="orgNameLong" value="${grailsApplication.config.skin.orgNameLong}"/>
<g:set var="orgNameShort" value="${grailsApplication.config.skin.orgNameShort}"/>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="app.version" content="${g.meta(name:'app.version')}"/>
    <meta name="app.build" content="${g.meta(name:'app.build')}"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><g:layoutTitle /></title>
    <r:require modules="configHubTemplate1" />
    <g:set var="styles" value="${hubConfig.templateConfiguration?.styles}"></g:set>

    <r:script disposition='head'>
        // initialise plugins
        jQuery(function(){
            // autocomplete on navbar search input
            jQuery("form#search-form-2011 input#search-2011, form#search-inpage input#search, input#search-2013").autocomplete('http://bie.ala.org.au/search/auto.jsonp', {
                extraParams: {limit: 100},
                dataType: 'jsonp',
                parse: function(data) {
                    var rows = new Array();
                    data = data.autoCompleteList;
                    for(var i=0; i<data.length; i++) {
                        rows[i] = {
                            data:data[i],
                            value: data[i].matchedNames[0],
                            result: data[i].matchedNames[0]
                        };
                    }
                    return rows;
                },
                matchSubset: false,
                formatItem: function(row, i, n) {
                    return row.matchedNames[0];
                },
                cacheLength: 10,
                minChars: 3,
                scroll: false,
                max: 10,
                selectFirst: false
            });

            // Mobile/desktop toggle
            // TODO: set a cookie so user's choice is remembered across pages
            var responsiveCssFile = $("#responsiveCss").attr("href"); // remember set href
            $(".toggleResponsive").click(function(e) {
                e.preventDefault();
                $(this).find("i").toggleClass("icon-resize-small icon-resize-full");
                var currentHref = $("#responsiveCss").attr("href");
                if (currentHref) {
                    $("#responsiveCss").attr("href", ""); // set to desktop (fixed)
                    $(this).find("span").html("Mobile");
                } else {
                    $("#responsiveCss").attr("href", responsiveCssFile); // set to mobile (responsive)
                    $(this).find("span").html("Desktop");
                }
            });

            $('.helphover').popover({animation: true, trigger:'hover'});
        });
    </r:script>
    <r:layoutResources/>
    <g:layoutHead />
    <link rel="stylesheet" type="text/css" href="${createLink(controller:'hub', action: 'getStyleSheet')}?hub=${hubConfig.urlPath}">
</head>
<body class="${pageProperty(name:'body.class')?:'nav-collections'}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}"  data-offset="${pageProperty(name:'body.data-offset')}" data-target="${pageProperty(name:'body.data-target')}" data-spy="${pageProperty(name:'body.data-spy')}">
%{--<g:set var="fluidLayout" value="${grailsApplication.config.skin.fluidLayout?.toBoolean()}"/>--}%
<g:set var="fluidLayout" value="${true}"/>
<div class="navbar navbar-inverse navbar-static-top">
    <div class="navbar-inner contain-to-grid">
        <div class="${fluidLayout?'container-fluid':'container'}">
            <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            %{--<a class="brand do-not-mark-external" href="http://www.mdba.gov.au/" id="mdbaLink" title="MDBA home page">--}%
                %{--<g:img dir="/images/mdba" file="MDBA-logo.png" alt="MDBA logo" class="headerLogo"/>--}%
            %{--</a>--}%
            <div class="pull-right">
                <div class="nav-collapse collapse pull-right">
                    <ul class="nav">
                        <g:if test="${hubConfig.templateConfiguration?.header?.links}">
                            <g:each in="${hubConfig.templateConfiguration?.header?.links}" var="link">
                                    <config:getLinkFromConfig config="${link}" hubConfig="${hubConfig}"></config:getLinkFromConfig>
                            </g:each>
                        </g:if>
                    </ul>
                </div><!--/.nav-collapse -->
            </div>
        </div><!--/.container-fluid -->
    </div><!--/.navbar-inner -->
</div><!--/.navbar -->

<g:pageProperty name="page.page-header"/> <%-- allows special content to be inserted --%>

<div id="main-content" class="${homepage? 'homepage': ''}">
    <g:layoutBody />
</div>
<div id="footer">
    <div class="${fluidLayout?'container-fluid':'container'}">
        <div class="row-fluid  navbar-inverse">
            <div class="span5">
                <ul class="nav">
                    <g:if test="${hubConfig.templateConfiguration?.footer?.links}">
                        <g:each in="${hubConfig.templateConfiguration?.footer?.links}" var="link">
                            <li>
                                <config:getLinkFromConfig config="${link}"></config:getLinkFromConfig>
                            </li>
                        </g:each>
                    </g:if>
                </ul>
            </div><!--/.spanX -->
            <div class="span4 smlinks text-right">
                <div id="smlinks">
                    <g:if test="${hubConfig.templateConfiguration?.footer?.socials}">
                        <g:each in="${hubConfig.templateConfiguration?.footer?.socials}" var="social">
                            <config:getSocialMediaLinkFromConfig config="${social}"></config:getSocialMediaLinkFromConfig>
                        </g:each>
                    </g:if>
                </div>
        </div><!--/.spanX -->
            <div class="span3">
                <a class="brand" href="http://ala.org.au/" id="alaLink" title="ALA home page">
                    <g:img dir="/images/mdba" file="ALA-logo-BW-124x109.png" alt="Powered by ALA logo" class="headerLogo"/>
                    <div id="alaHeadingText"><div id="poweredBy">powered by</div><div id="alaBy" class="visible-desktop">Atlas of Living Australia</div>
                        <div class="hidden-desktop">ALA</div></div>
                </a>
            </div>
        </div><!--/.row -->
    </div><!--/.contaier -->
</div><!--/#footer -->

<!-- JS resources-->
<r:layoutResources/>
</body>
</html>