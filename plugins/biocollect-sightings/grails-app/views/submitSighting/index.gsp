%{--
  - Copyright (C) 2014 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%
<%@ page import="grails.converters.JSON" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin ?: 'main'}"/>
    <title>Report a sighting | Atlas of Living Australia</title>
    <g:render template="submitSightingResources"/>
</head>

<body class="nav-species">
<g:render template="/topMenu" model="[pageHeading: 'Report a Sighting']"/>

<div class="well">
    <form id="sightingForm" action="${g.createLink(controller: 'submitSighting', action: 'upload')}" method="POST">
        <g:render template="submitSighting"/>

        <div id="submitArea">
            <div id="termsOfUse">Please read the <a href="http://www.ala.org.au/about-the-atlas/terms-of-use/"
                                                    target="_blank">ALA
                terms of use</a> before submitting your sighting</div>

            <div id="submitWrapper"><input type="submit" id="formSubmit" class="btn btn-primary btn-lg"
                                           value="${actionName == 'edit' ? 'Update' : 'Submit'} Record"/></div>
        </div>


    </form>

</div>

</body>
</html>
