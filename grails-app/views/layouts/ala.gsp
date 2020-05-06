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
    <link href="${grailsApplication.config.skin.favicon}"  rel="icon"/>

    <title><g:layoutTitle /></title>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap-responsive.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/ala-styles.css"/>
    <asset:stylesheet src="base.css"/>
    <asset:stylesheet src="ala2.css"/>
    <asset:javascript src="base.js"/>
    <g:layoutHead/>
</head>
<body class="${pageProperty(name:'body.class')?:'nav-getinvolved'}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}" style="padding-top:50px;">
<g:set var="introText"><fc:getSettingContent settingType="${SettingPageType.INTRO}"/></g:set>
<g:set var="userLoggedIn"><fc:userIsLoggedIn/></g:set>
<div id="body-wrapper">
    <hf:banner logoutUrl="${g.createLink(controller:"logout", action:"logout", absolute: true)}"/>
    <g:render template="/shared/menu" model="${[fc:fc]}"/>
    <g:if test="${fc.announcementContent()}">
        <div id="announcement">
            ${fc.announcementContent()}
        </div>
    </g:if>
    <!-- ALA Skin supported only for sightings hib -->
    <g:if test="${showCitizenScienceBanner}">
        <g:render template="/shared/bannerCitizenScience"/>
    </g:if>

    <div class="container-fluid" id="main-content">
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
<asset:script type="text/javascript">
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
            window.location = "${createLink(controller: 'project', action:'create', params: [citizenScience:true])}"
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

</asset:script>
<g:if test="${userLoggedIn}">
    <asset:script type="text/javascript">
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
    </asset:script>
</g:if>

<script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<asset:script type="text/javascript">
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
    <g:if test="${!hubConfig.defaultFacetQuery.contains('isWorks:true')}">
        window.location = "${createLink(controller: 'project', action:'create', params: [citizenScience:true])}"
    </g:if>
    <g:if test="${hubConfig.defaultFacetQuery.contains('isWorks:true')}">
        window.location = "${createLink(controller: 'project', action:'create', params: [works:true])}"
    </g:if>
    <g:if test="${hubConfig.defaultFacetQuery.contains('isEcoScience:true')}">
        window.location = "${createLink(controller: 'project', action:'create', params: [ecoScience:true])}"
    </g:if>
    });

    $(".btnProfile").click(function (e) {
        window.location = "${createLink(controller: 'myProfile')}";
        });

        $(".btnAllData").click(function (e) {
            window.location = "${createLink(controller: 'bioActivity', action: 'allRecords')}";
        });

        $(".btnMyDashboard").click(function (e) {
            window.location = "${createLink(controller: 'user', action: 'index')}";
        });

        $(".btnMyData").click(function (e) {
            window.location = "${createLink(controller: 'bioActivity', action: 'list')}";
        });

        $(".btnMyProjects").click(function (e) {
            window.location = "${createLink(controller: 'project', action: 'myProjects')}";
        });

        $(".btnMyOrganisation").click(function (e) {
            window.location = "${createLink(controller: 'organisation', action: 'myOrganisations')}";
        });

        $(".btnMyFavouriteSites").click(function (e) {
            window.location = "${createLink(controller: 'site', action: 'myFavourites')}";
        });


        $(".btnSearch").click(function(e){
            window.location = "${createLink(controller: 'home', action: 'index')}";
        })

    $(".btnSite").click(function(e){
         window.location = "${createLink(controller: 'site', action: 'list')}";
        })

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

</asset:script>
<g:if test="${userLoggedIn}">
    <asset:script type="text/javascript">
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
    </asset:script>
</g:if>
<g:if test="${grailsApplication.config.bugherd.integration}">
    <asset:script type="text/javascript">
        (function (d, t) {
            var bh = d.createElement(t), s = d.getElementsByTagName(t)[0];
            bh.type = 'text/javascript';
            bh.src = '//www.bugherd.com/sidebarv2.js?apikey=2wgeczqfyixard6e9xxfnq';
            s.parentNode.insertBefore(bh, s);
        })(document, 'script');
    </asset:script>
</g:if>

<script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<asset:script type="text/javascript">
        var pageTracker = _gat._getTracker('${grailsApplication.config.googleAnalyticsID}');
        pageTracker._initData();
        pageTracker._trackPageview();
        // show warning if using IE6
        if ($.browser.msie && $.browser.version.slice(0,1) == '6') {
            $('#header').prepend($('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
' Many functions will still work but layout and image transparency will be disrupted.</div>'));
        }
</asset:script>
<asset:script type="text/javascript">
    function calcWidth() {
        var navwidth = 0;
        var morewidth = $('#main .more').outerWidth(true);
        $('#main > li:not(.more)').each(function() {
            navwidth += $(this).outerWidth( true );
        });
        var availablespace = $('nav').outerWidth(true) - morewidth;

        if (navwidth > availablespace) {
            var lastItem = $('#main > li:not(.more)').last();
            lastItem.attr('data-width', lastItem.outerWidth(true));
            lastItem.prependTo($('#main .more ul.more-ul'));
            calcWidth();
        } else {
            var firstMoreElement = $('#main li.more li').first();
            while ((navwidth = navwidth + firstMoreElement.data('width')) < availablespace) {
                firstMoreElement.insertBefore($('#main .more'));
                firstMoreElement = $('#main li.more li').first();
            }
        }

        if ($('.more li').length > 0) {
            $('.more').css('display','inline-block');
        } else {
            $('.more').css('display','none');
        }
    }
    $(window).on('resize',function(){
        calcWidth();
    });
    $('#biocollectNav').show();
    calcWidth();
</asset:script>
<!-- JS resources-->
<asset:deferredScripts/>
</body>
</html>>