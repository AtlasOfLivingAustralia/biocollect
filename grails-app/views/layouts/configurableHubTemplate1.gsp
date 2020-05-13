<g:set var="orgNameLong" value="${grailsApplication.config.skin.orgNameLong}"/>
<g:set var="orgNameShort" value="${grailsApplication.config.skin.orgNameShort}"/>
<g:set var="settingService" bean="settingService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="app.version" content="${g.meta(name: 'info.app.version')}"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><g:layoutTitle/></title>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap-responsive.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/ala-styles.css"/>
    <asset:stylesheet src="base.css"/>
    <asset:stylesheet src="Common_fonts.css"/>
    <asset:javascript src="base.js"/>
    <g:set var="styles" value="${hubConfig.templateConfiguration?.styles}"></g:set>
    <asset:script type="text/javascript">
        // initialise plugins
        jQuery(function () {
            // autocomplete on navbar search input
            jQuery("#biesearch").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: 'https://bie.ala.org.au/ws/search/auto.jsonp',
                        dataType:'json',
                        data: {q:request.term},
                        success: function(data) {
                            var items = $.map(data.autoCompleteList, function(item) {
                                return {
                                    label:item.name,
                                    value: item.name,
                                    source: item
                                }
                            });
                            response(items);

                        },
                        error: function() {
                            items = [{label:"Error during species lookup", value:request.term, source: {listId:'error-unmatched', name: request.term}}];
                            response(items);
                        }
                    });
                },
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
    </asset:script>
    <g:layoutHead/>
    <link rel="stylesheet" type="text/css"
          href="${createLink(controller: 'hub', action: 'getStyleSheet')}?ver=${hubConfig.lastUpdated}">
    <link href="${grailsApplication.config.skin.favicon}"  rel="icon"/>
</head>

<body class="${pageProperty(name: 'body.class') ?: 'nav-collections'}" id="${pageProperty(name: 'body.id')}"
      onload="${pageProperty(name: 'body.onload')}" data-offset="${pageProperty(name: 'body.data-offset')}"
      data-target="${pageProperty(name: 'body.data-target')}" data-spy="${pageProperty(name: 'body.data-spy')}">
<g:set var="fluidLayout" value="${!hubConfig.content?.isContainer}"/>
<g:if test="${hubConfig.templateConfiguration.header.type == 'ala'}">
    <div id="ala-header-bootstrap2" class="do-not-mark-external hidden-print">
        <hf:banner logoutUrl="${g.createLink(controller: "logout", action: "logout", absolute: true)}"/>
    </div>
    <div id="content-starting-point"></div>
</g:if>
<g:elseif test="${hubConfig.templateConfiguration.header.type == 'biocollect'}">
    <div id="biocollect-header" class="hidden-print">
        <asset:stylesheet src="biocollect-banner.css"/>
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
    <div id="custom-header" class="do-not-mark-external hidden-print">
        <div class="navbar navbar-inverse navbar-static-top">
            <div class="navbar-inner contain-to-grid">
                <div class="${fluidLayout ? 'container-fluid' : 'container'}">
                    <div class="pull-right">
                        <!-- .btn-navbar is used as the toggle for collapsed navbar content -->
                        <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </a>

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
                            <config:getLinkFromConfig config="${item}" hubConfig="${hubConfig}"></config:getLinkFromConfig>
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
    <div id="ala-footer-bootstrap2 hidden-print">
        <hf:footer/>
    </div>
</g:if>
<g:elseif test="${hubConfig.templateConfiguration.footer.type == 'custom'}">
    <div id="custom-footer">
        <div class="${fluidLayout ? 'container-fluid' : 'container'} hidden-print">
            <div class="row-fluid  navbar-inverse">
                <div class="span4">
                    <ul class="nav">
                        <g:if test="${hubConfig.templateConfiguration?.footer?.links}">
                            <g:each in="${hubConfig.templateConfiguration?.footer?.links}" var="link">
                                <li>
                                    <config:getLinkFromConfig config="${link}" hubConfig="${hubConfig}"></config:getLinkFromConfig>
                                </li>
                            </g:each>
                        </g:if>
                    </ul>
                </div><!--/.spanX -->
                <div class="span8">
                    <div class="smlinks inline-block">
                        <div id="smlinks">
                            <g:if test="${hubConfig.templateConfiguration?.footer?.socials}">
                                <g:each in="${hubConfig.templateConfiguration?.footer?.socials}" var="social">
                                    <config:getSocialMediaLinkFromConfig
                                            config="${social}"></config:getSocialMediaLinkFromConfig>
                                </g:each>
                            </g:if>
                        </div>
                    </div><!--/.spanX -->
                    <div class="pull-right">
                        <div class="row-fluid text-right">
                            <div class="span12">
                                <g:each in="${hubConfig.templateConfiguration?.footer?.logos}" var="logo">
                                    <g:if test="${logo.href}">
                                        <a href="${logo.href}" title="Link to website" target="_blank" class="do-not-mark-external">
                                            <img class="footer-logo" src="${logo.url}" alt="Website logo"/>
                                        </a>
                                    </g:if>
                                    <g:else>
                                        <img class="footer-logo" src="${logo.url}" alt="Website logo"/>
                                    </g:else>
                                </g:each>
                                <a class="brand text-left" href="http://ala.org.au/" id="alaLink" title="ALA home page">
                                    <img src="${asset.assetPath(src:'mdba/ALA-logo-BW-124x109.png')}" alt="Powered by ALA logo"
                                         class="headerLogo"/>
                                    <div id="alaHeadingText"><div id="poweredBy">powered by</div>
                                        <div id="alaBy" class="visible-desktop">Atlas of Living Australia</div>
                                        <div class="hidden-desktop">ALA</div>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!--/.row -->
        </div><!--/.contaier -->
    </div><!--/#footer -->
    %{-- Adding GA script here since it is not included anywhere when custom footer is used. --}%
    %{-- Ala footer does not need it since it comes with GA script included. --}%
    <!-- Google Analytics -->
    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga('create', 'UA-4355440-1', 'auto');
        ga('send', 'pageview');
    </script>
    <!-- End Google Analytics -->
</g:elseif>
<asset:script type="text/javascript">
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
            $('#hideIntro').click(function () {
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

<!-- JS resources-->
<asset:deferredScripts />
</body>
</html>