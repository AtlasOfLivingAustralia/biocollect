<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="au.org.ala.biocollect.merit.SettingPageType" %>
<!DOCTYPE html>
<html>
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
   <meta name="app.version" content="${g.meta(name:'app.version')}"/>
   <meta name="app.build" content="${g.meta(name:'app.build')}"/>
    <meta name="description" content="Atlas of Living Australia Field Capture"/>
    <meta name="author" content="Atlas of Living Australia">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" rel="shortcut icon"  type="image/x-icon"/>

   <title><g:layoutTitle /></title>
   <r:require modules="ala2Skin, jquery_cookie" />
    <r:layoutResources/>
    <g:layoutHead />
</head>
<body class="${pageProperty(name:'body.class')?:'nav-getinvolved'}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}" style="padding-top:50px;">
<g:set var="introText"><fc:getSettingContent settingType="${SettingPageType.INTRO}"/></g:set>
<g:set var="userLoggedIn"><fc:userIsLoggedIn/></g:set>
<div id="body-wrapper">
    <hf:banner logoutUrl="${g.createLink(controller:"logout", action:"logout", absolute: true)}"/>

    <g:if test="${fc.announcementContent()}">
        <div id="announcement">
            ${fc.announcementContent()}
        </div>
    </g:if>
    <div id="nav-site" class="clearfix">

        <div class="navbar navbar-inner container-fluid ">
            %{--<a href="${g.createLink(uri:"/")}" class="brand">MERI data capture prototype</a>--}%
            <ul class="nav">
                <li><a href="/fieldcapture/" class="active hidden-desktop"><i class="icon-home">&nbsp;</i>&nbsp;Home</a></li>
            </ul>
            <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </a>
            <div class="nav-collapse collapse">
                <ul class="nav">
                    <fc:navbar active="${pageProperty(name: 'page.topLevelNav')}"/>
                </ul>
                <div class="navbar-form pull-right nav-collapse collapse">
                    <span id="buttonBar">
                        <g:if test="${fc.currentUserDisplayName()}">
                            <div class="btn-group">
                                <button class="btn btn-small btn-fc btnProfile" title="profile page">
                                    <i class="icon-user"></i><span class="">&nbsp;<fc:currentUserDisplayName /></span>
                                </button>
                                <a class="btn btn-small btn-fc dropdown-toggle" data-toggle="dropdown">
                                    More&nbsp;&nbsp;<span class="caret"></span>
                                </a>
                                <ul class="dropdown-menu pull-right">
                                    <li><a class="btnNewProject" href="#"><i class="icon-plus"></i> New project</a></li>
                                    <li><a class="btnMyProjects" href="#"><i class="icon-folder-open"></i> My projects</a></li>
                                    <li><a class="btnMyData" href="#"><i class="icon-folder-open"></i> My data</a></li>
                                </ul>
                            </div>
                            <g:if test="${fc.userIsSiteAdmin()}">
                                <div class="btn-group">
                                    <button class="btn btn-warning btn-small btnAdministration"><i class="icon-cog icon-white"></i><span class="">&nbsp;Administration</span></button>
                                </div>
                            </g:if>
                        </g:if>
                        <g:pageProperty name="page.buttonBar"/>
                    </span>
                </div>
            </div>
        </div><!-- /.navbar-inner -->
    </div>

    <div class="container" id="main-content">
        <g:layoutBody />
    </div><!--/.container-->

    <div class="container hidden-desktop">
        <%-- Borrowed from http://marcusasplund.com/optout/ --%>
        <a class="btn btn-small toggleResponsive"><i class="icon-resize-full"></i> <span>Desktop</span> version</a>
        %{--<a class="btn btn-small toggleResponsive"><i class="icon-resize-full"></i> Desktop version</a>--}%
    </div>

    <hf:footer/>

    <div id="footer">
        <div id="footer-wrapper">
            <div class="container-fluid">
                <fc:footerContent />
            </div>
            <div class="container-fluid">
                <div class="large-space-before">
                    <button class="btn btn-mini" id="toggleFluid">toggle fixed/fluid width</button>
                    <g:if test="${userLoggedIn && introText}">
                        <button class="btn btn-mini" type="button" data-toggle="modal" data-target="#introPopup">display user intro</button>
                    </g:if>
                </div>
            </div>
        </div>
    </div>
</div><!-- /#body-wrapper -->
<g:if test="${userLoggedIn && introText}">
%{-- User Intro Popup --}%
    <div id="introPopup" class="modal hide fade">
        <div class="modal-header hide">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h3>User Introduction</h3>
        </div>
        <div class="modal-body">
            ${introText}
        </div>
        <div class="modal-footer">
            <label for="hideIntro" class="pull-left">
                <g:checkBox name="hideIntro" style="margin:0;"/>&nbsp;
                Do not display this message again (current browser only)
            </label>
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            %{--<a href="#" class="btn btn-primary">Save changes</a>--}%
        </div>
    </div>
</g:if>
<r:script>
    // Prevent console.log() killing IE
    if (typeof console == "undefined") {
        this.console = {log: function() {}};
    }

    $(document).ready(function (e) {

        $.ajaxSetup({ cache: false });

        $(".btnAdministration").click(function (e) {
            window.location = "${createLink(controller: 'admin')}";
        });
        $('.btnNewProject').click(function(e) {
            window.location = "${createLink(controller: 'project', action:'create')}"
        });

        $(".btnProfile").click(function (e) {
            window.location = "${createLink(controller: 'myProfile')}";
        });

        $(".btnMyData").click(function (e) {
            window.location = "${createLink(controller: 'bioActivity', action: 'list')}";
        });

        $(".btnMyProjects").click(function (e) {
            window.location = "${createLink(controller: 'project', action: 'myProjects')}";
        });

        $("#toggleFluid").click(function(el){
            var fluidNo = $('div.container-fluid').length;
            var fixNo = $('div.container').length;
            //console.log("counts", fluidNo, fixNo);
            if (fluidNo > fixNo) {
                $('div.container-fluid').addClass('container').removeClass('container-fluid');
            } else {
                $('div.container').addClass('container-fluid').removeClass('container');
            }
        });

        // Set up a timer that will periodically poll the server to keep the session alive
        var intervalSeconds = 5 * 60;

        setInterval(function() {
            $.ajax("${createLink(controller: 'ajax', action:'keepSessionAlive')}").done(function(data) {});
        }, intervalSeconds * 1000);

    }); // end document ready

</r:script>
<g:if test="${userLoggedIn}">
    <r:script>
        $(document).ready(function (e) {
            // Show introduction popup (with cookie check)
            var cookieName = "hide-intro";
            var introCookie = $.cookie(cookieName);
            //  document.referrer is empty following login from AUTH
            if (!introCookie && !document.referrer) {
                $('#introPopup').modal('show');
            } else {
                $('#hideIntro').prop('checked', true);
            }
            // console.log("referrer", document.referrer);
            // don't show popup if user has clicked checkbox on popup
            $('#hideIntro').click(function() {
                if ($(this).is(':checked')) {
                    $.cookie(cookieName, 1);
                } else {
                    $.removeCookie(cookieName);
                }
            });
        }); // end document ready
    </r:script>
</g:if>
<g:if test="${java.lang.Boolean.parseBoolean(grailsApplication.config.bugherd.integration)}">
    <r:script>
        (function (d, t) {
            var bh = d.createElement(t), s = d.getElementsByTagName(t)[0];
            bh.type = 'text/javascript';
            bh.src = '//www.bugherd.com/sidebarv2.js?apikey=2wgeczqfyixard6e9xxfnq';
            s.parentNode.insertBefore(bh, s);
        })(document, 'script');
    </r:script>
</g:if>

    <script type="text/javascript">
        var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
        document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <r:script>
        var pageTracker = _gat._getTracker('${grailsApplication.config.googleAnalyticsID}');
        pageTracker._initData();
        pageTracker._trackPageview();
        // show warning if using IE6
        if ($.browser.msie && $.browser.version.slice(0,1) == '6') {
            $('#header').prepend($('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
                    ' Many functions will still work but layout and image transparency will be disrupted.</div>'));
        }
    </r:script>

    <!-- JS resources-->
    <r:layoutResources/>
</body>
</html>