%{--
  - Copyright (C) 2013 Atlas of Living Australia
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
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title><g:layoutTitle /></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <asset:stylesheet src="base.css"/>
    <asset:stylesheet src="nrm-manifest.css"/>
    <asset:javascript src="base.js"/>
    <asset:stylesheet src="print.css"/>
    <g:layoutHead />
</head>
<body class="${pageProperty(name:'body.class')}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">
<div id="body-wrapper">
    <div id="header">
        <div class="container-fluid">
            <div class="row-fluid">
            </div>
        </div>
    </div><!-- /#header -->
    <div id="dcNav" class="clearfix">
        <div class="navbar container-fluid">
        </div><!-- /.nav -->
    </div>

    <div id="content" class="clearfix">
        <g:layoutBody />
    </div><!-- /#content -->

    <div id="footer">
        <div id="footer-wrapper">

            <div class="container-fluid">
            </div>
        </div>

    </div>
</div><!-- /#body-wrapper -->
<asset:script type="text/javascript">

    // Prevent console.log() killing IE
    if (typeof console == "undefined") {
        this.console = {log: function() {}};
    }

    $(document).ready(function (e) {

        $.ajaxSetup({ cache: false });

        $("#toggleFluid").click(function(el){
            var fluidNo = $('div.container-fluid').length;
            var fixNo = $('div.container').length;
            console.log("counts", fluidNo, fixNo);
            if (fluidNo > fixNo) {
                $('div.container-fluid').addClass('container').removeClass('container-fluid');
            } else {
                $('div.container').addClass('container-fluid').removeClass('container');
            }
        });
    });


</asset:script>

<asset:deferredScripts/>
</body>
</html>