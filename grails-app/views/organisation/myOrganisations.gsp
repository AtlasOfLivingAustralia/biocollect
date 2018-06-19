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
 * Created by Temi on 8/02/16.
 */
-->
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>My Organisations | Biocollect</title>
    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            createOrganisationUrl: "${createLink(controller: 'organisation', action: 'create')}",
            viewOrganisationUrl: "${createLink(controller: 'organisation', action: 'index')}",
            organisationSearchUrl: "${createLink(controller: 'organisation', action: 'searchMyOrg')}",
            noLogoImageUrl: "${asset.assetPath(src: 'no-image-2.png')}"
            };
    </asset:script>
    <asset:stylesheet src="organisation.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="organisation.js"/>
</head>

<body>
<g:render template="organisationListing"></g:render>

</body>

</html>