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
 * Created by Temi on 29/01/16.
 */
-->
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>List of all sites</title>
    <meta name="layout" content="${hubConfig.skin}"/>
    <script>
        var fcConfig = {
            listSitesUrl: '${createLink(controller: 'site', action: 'search')}',
            viewSiteUrl: '${createLink(controller: 'site', action: 'index')}'
        }
    </script>
    <r:require modules="siteSearch"></r:require>
</head>

<body>
<div id="siteSearch" class="container">
    <g:render template="/site/listView"></g:render>
</div>
<script>
    $(document).ready(function(){
        var sites = new SitesListViewModel();
        ko.applyBindings(sites, document.getElementById('siteSearch'));
    })
</script>
</body>
</html>