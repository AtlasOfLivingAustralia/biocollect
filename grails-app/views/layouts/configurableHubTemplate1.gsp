<g:set var="orgNameLong" value="${grailsApplication.config.skin.orgNameLong}"/>
<g:set var="orgNameShort" value="${grailsApplication.config.skin.orgNameShort}"/>
<g:set var="settingService" bean="settingService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="app.version" content="${g.meta(name: 'app.version')}"/>
    <meta name="app.build" content="${g.meta(name: 'app.build')}"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><g:layoutTitle/></title>
    <r:require modules="configHubTemplate1"/>
    <g:set var="styles" value="${hubConfig.templateConfiguration?.styles}"></g:set>
    <r:script>
        // initialise plugins
        jQuery(function () {
            // autocomplete on navbar search input
            jQuery("#biesearch").autocomplete('https://bie.ala.org.au/ws/search/auto.jsonp', {
                extraParams: {limit: 100},
                dataType: 'jsonp',
                parse: function (data) {
                    var rows = new Array();
                    data = data.autoCompleteList;
                    for (var i = 0; i < data.length; i++) {
                        rows[i] = {
                            data: data[i],
                            value: data[i].matchedNames[0],
                            result: data[i].matchedNames[0]
                        };
                    }
                    return rows;
                },
                matchSubset: false,
                formatItem: function (row, i, n) {
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
            $(".toggleResponsive").click(function (e) {
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

            $('.helphover').popover({animation: true, trigger: 'hover'});
        });
    </r:script>
    <r:layoutResources/>
    <g:layoutHead/>
    <link rel="stylesheet" type="text/css"
          href="${createLink(controller: 'hub', action: 'getStyleSheet')}?hub=${hubConfig.urlPath}">
    <link href="https://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico" rel="shortcut icon"
          type="image/x-icon"/>
</head>

<body class="${pageProperty(name: 'body.class') ?: 'nav-collections'}" id="${pageProperty(name: 'body.id')}"
      onload="${pageProperty(name: 'body.onload')}" data-offset="${pageProperty(name: 'body.data-offset')}"
      data-target="${pageProperty(name: 'body.data-target')}" data-spy="${pageProperty(name: 'body.data-spy')}">
<g:set var="fluidLayout" value="${!hubConfig.content?.isContainer}"/>
<g:if test="${hubConfig.templateConfiguration.header.type == 'ala'}">
    <div id="ala-header-bootstrap2" class="do-not-mark-external">
        <hf:banner logoutUrl="${g.createLink(controller: "logout", action: "logout", absolute: true)}"/>
    </div>
    <div id="content-starting-point"></div>
</g:if>
<g:elseif test="${hubConfig.templateConfiguration.header.type == 'biocollect'}">
    <div id="biocollect-header">
        <g:render template="/project/biocollectBanner"></g:render>
        <g:if test="${isCitizenScience && !isUserPage}">
            <g:render template="/shared/bannerCitizenScience"/>
        </g:if>
        <g:if test="${isWorks && !isUserPage}">
            <g:render template="/shared/bannerWorks"/>
        </g:if>
        <g:if test="${isEcoScience && !isUserPage}">
            <g:render template="/shared/bannerEcoScience"/>
        </g:if>
    </div>
</g:elseif>
<g:elseif test="${hubConfig.templateConfiguration.header.type == 'custom'}">
    <div id="custom-header" class="do-not-mark-external">
        <div class="navbar navbar-inverse navbar-static-top">
            <div class="navbar-inner contain-to-grid">
                <div class="${fluidLayout ? 'container-fluid' : 'container'}">
                    <div class="pull-right">
                        <div class="nav-collapse collapse pull-right">
                            <ul class="nav">
                                <g:if test="${hubConfig.templateConfiguration?.header?.links}">
                                    <g:each in="${hubConfig.templateConfiguration?.header?.links}" var="link">
                                        <config:getLinkFromConfig config="${link}"
                                                                  hubConfig="${hubConfig}"></config:getLinkFromConfig>
                                    </g:each>
                                </g:if>
                            </ul>
                        </div><!--/.nav-collapse -->
                    </div>
                </div><!--/.container-fluid -->
            </div><!--/.navbar-inner -->
        </div><!--/.navbar -->
    </div>
</g:elseif>
<!-- Breadcrumb -->
<g:if test="${!printView && !mobile && !hubConfig.content?.hideBreadCrumbs}">
    <g:set var="cssClassName" value=""/>
    <g:set var="breadCrumbs"
           value="${settingService.getCustomBreadCrumbsSetForControllerAction(controllerName, actionName)}"/>
    <g:if test="${breadCrumbs}">
        <section id="breadcrumb" class="${cssClassName}">
            <div class="${fluidLayout ? 'container-fluid' : 'container'}">
                <div class="row">
                    <ul class="breadcrumb-list">
                        <g:each in="${breadCrumbs}" var="item" status="index">
                            <config:getLinkFromConfig config="${item}"></config:getLinkFromConfig>
                        </g:each>
                    </ul>
                </div>
            </div>
        </section>
    </g:if>
    <g:else>
        <g:set var="index" value="1"></g:set>
        <g:set var="metaName" value="${'meta.breadcrumbParent' + index}"/>
        <g:if test="${pageProperty(name: "meta.breadcrumb")}">
            <section id="breadcrumb" class="${cssClassName}">
                <div class="${fluidLayout ? 'container-fluid' : 'container'}">
                    <div class="row">
                        <ul class="breadcrumb-list">
                            <g:while test="${pageProperty(name: metaName)}">
                                <g:set value="${pageProperty(name: metaName).tokenize(',')}" var="parentArray"/>
                                <li><a href="${parentArray[0]}">${parentArray[1]}</a></li>
                                <% index++ %>
                                <g:set var="metaName" value="${'meta.breadcrumbParent' + index}"/>
                            </g:while>
                            <li class="active">${pageProperty(name: "meta.breadcrumb")}</li>
                        </ul>
                    </div>
                </div>
            </section>
        </g:if>
    </g:else>
</g:if>
<!-- End Breadcrumb -->

<g:pageProperty name="page.page-header"/> <%-- allows special content to be inserted --%>

<div id="main-content"
     class="${homepage ? 'homepage' : ''} ${fluidLayout ? 'container-fluid' : 'container'}">
    <g:if test="${flash.message}">
        <div class="container-fluid">
            <div class="alert alert-info">
                ${flash.message}
            </div>
        </div>
    </g:if>
    <g:layoutBody/>
</div>

<g:if test="${hubConfig.templateConfiguration.footer.type == 'ala'}">
    <div id="ala-footer-bootstrap2">
        <hf:footer/>
    </div>
</g:if>
<g:elseif test="${hubConfig.templateConfiguration.footer.type == 'custom'}">
    <div id="custom-footer">
        <div class="${fluidLayout ? 'container-fluid' : 'container'}">
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
                                <config:getSocialMediaLinkFromConfig
                                        config="${social}"></config:getSocialMediaLinkFromConfig>
                            </g:each>
                        </g:if>
                    </div>
                </div><!--/.spanX -->
                <div class="span3">
                    <a class="brand" href="http://ala.org.au/" id="alaLink" title="ALA home page">
                        <g:img dir="/images/mdba" file="ALA-logo-BW-124x109.png" alt="Powered by ALA logo"
                               class="headerLogo"/>
                        <div id="alaHeadingText"><div id="poweredBy">powered by</div>

                            <div id="alaBy" class="visible-desktop">Atlas of Living Australia</div>

                            <div class="hidden-desktop">ALA</div></div>
                    </a>
                </div>
            </div><!--/.row -->
        </div><!--/.contaier -->
    </div><!--/#footer -->
</g:elseif>
<r:script>
    // Prevent console.log() killing IE
    if (typeof console == "undefined") {
        this.console = {log: function() {}};
    }

    $(document).ready(function (e) {

        $.ajaxSetup({ cache: false });

        // Set up a timer that will periodically poll the server to keep the session alive
        var intervalSeconds = 5 * 60;

        setInterval(function() {
            $.ajax("${createLink(controller: 'ajax', action: 'keepSessionAlive')}").done(function(data) {});
        }, intervalSeconds * 1000);

        //make sure external link icon is not added to links in footer.
        $('#ala-footer-bootstrap2').find('a').addClass('do-not-mark-external')
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
            $('#hideIntro').click(function () {
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
            $('#header').prepend(
                $('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
' Many functions will still work but layout and image transparency will be disrupted.</div>')
            );
        }
</r:script>
<!-- JS resources-->
<r:layoutResources/>
</body>
</html>