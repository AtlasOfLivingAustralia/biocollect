%{--
  - Copyright (C) 2015 Atlas of Living Australia
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

<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 16/05/15
  Time: 4:43 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta name="app.version" content="${g.meta(name:'app.version')}"/>
  <meta name="app.build" content="${g.meta(name:'app.build')}"/>
  <meta name="description" content="Atlas of Living Australia"/>
  <meta name="author" content="Atlas of Living Australia">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" rel="shortcut icon"  type="image/x-icon"/>

  <title><g:layoutTitle /></title>

  <%-- Do not include JS & CSS files here - add them to your app's "application" module (in "Configuration/ApplicationResources.groovy") --%>
  <r:require modules="bootstrap"/>

  <r:layoutResources/>
  <g:layoutHead />
</head>
<body style="margin-top: -50px;">
  <g:layoutBody />
  <!-- JS resources-->
  <r:layoutResources/>
</body>