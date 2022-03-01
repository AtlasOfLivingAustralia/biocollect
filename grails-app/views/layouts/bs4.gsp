<!doctype html>
<%@ page contentType="text/html;charset=UTF-8" %>
<g:set bean="localeResolver" var="localeResolver"/>
<html lang="${localeResolver.resolveLocale(request).getLanguage()}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html;"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="app.version" content="${g.meta(name: 'info.app.version')}"/>
    <title><g:layoutTitle/></title>
    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <link href="${g.createLink(controller: 'hub', action: 'generateStylesheet')}?ver=${hubConfig.lastUpdated}" rel="stylesheet"/>
    <asset:stylesheet src="base-bs4.css"/>
    <asset:javascript src="base-bs4.js"/>
    <g:layoutHead/>
</head>

<body class="carousel">
<ala:systemMessage/>
<div class="site " id="page">
    %{--    navbar start--}%
    <div id="wrapper-navbar" itemscope="" itemtype="http://schema.org/WebSite">
        <a class="skip-link sr-only sr-only-focusable" href="#content">Skip to content</a>

        <nav class="navbar navbar-expand-lg navbar-dark navbar-alt">
            <div class="container-fluid flex-column flex-md-row align-items-center">

                <!-- Your site title as branding in the menu -->
                <a href="/" class="custom-logo-link navbar-brand" rel="home" itemprop="url">
                    ${hubConfig.title}
                </a> <!-- end custom logo -->

                <div class="outer-nav-wrapper">

                    <div class="main-nav-wrapper">
                        <a href="javascript:" class="navbar-toggler order-3 order-lg-2" type="button"
                           data-toggle="offcanvas" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown"
                           aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </a>


                        <!-- The Main Menu goes here -->
                        <div id="navbarNavDropdown" class="collapse navbar-collapse offcanvas-collapse">
                            <ul class="navbar-nav ml-auto">
                                <g:if test="${hubConfig.templateConfiguration?.header?.links}">
                                    <g:each in="${hubConfig.templateConfiguration?.header?.links}" var="link">
                                        <config:getLinkFromConfig config="${link}"
                                                                  hubConfig="${hubConfig}" bs4="true"></config:getLinkFromConfig>
                                    </g:each>
                                </g:if>
                                <g:else>
                                    <g:each in="${grailsApplication.config.headerAndFooter?.header}" var="link">
                                        <config:getLinkFromConfig config="${link}"
                                                                  hubConfig="${hubConfig}" bs4="true"></config:getLinkFromConfig>
                                    </g:each>
                                </g:else>
                            </ul>
                        </div>
                    </div>

                </div>
            </div><!-- .container -->

        </nav><!-- .site-navigation -->

    </div>
    %{--    navbar end--}%
    <div class="wrapper" id="catalogue">
        <main class="site-main">
            <article class="page">
                <g:set var="bannerURL" value="${pageProperty(name: 'meta.bannerURL') ?: hubConfig.templateConfiguration.banner.images[0]?.url}"/>
                <g:set var="banner" value="${pageProperty(name: 'page.banner')}"/>
                <g:if test="${pageProperty(name: 'page.slider')}">
                    <g:pageProperty name="page.slider"></g:pageProperty>
                </g:if>
                <g:elseif test="${bannerURL || banner}">
                    <div id="banner" class="page-banner ${pageProperty(name: 'meta.bannerClass') ?: ''} ${bannerURL? "": "no-image"} ${pageProperty(name: 'page.projectLogo')}">
                        <g:if test="${pageProperty(name: 'page.bannertitle')}">
                            <div class="banner-title">
                                <h1><g:pageProperty name="page.bannertitle"></g:pageProperty></h1>
                            </div>
                        </g:if>
                        ${raw(banner?:"")}
                    </div>
                </g:elseif>
                <g:else>
                    <div id="banner" class="no-image no-content"></div>
                </g:else>
                <g:set var="tabList" value="${pageProperty(name: 'page.tab')}"/>
                <g:if test="${tabList}">
                    <div class="nav-row">
                        <div class="container">
                            ${raw(tabList)}
                        </div>
                    </div>
                </g:if>
%{--                <g:else>--}%
%{--                    <div class="nav-row nav-row-height">--}%
%{--                        <div class="container">--}%
%{--                            <ul class="nav nav-tabs" id="tabs" data-tabs="tabs" role="tablist">--}%
%{--                            </ul>--}%
%{--                        </div>--}%
%{--                    </div>--}%
%{--                </g:else>--}%
                <div id="titleBar">
                    <div class="container-fluid">
                        <div class="row d-flex title-row">
%{--                            <g:if test="${hubConfig.logoUrl}">--}%
%{--                                <div class="col-12 col-lg-auto flex-shrink-1 d-flex mb-4 mb-lg-0 justify-content-center justify-content-lg-end">--}%
%{--                                    <div class="main-image">--}%
%{--                                        <img src="${hubConfig.logoUrl}" alt="<g:message code="hub.logo.alttext"/> ${hubConfig.title}">--}%
%{--                                    </div>--}%
%{--                                </div>--}%
%{--                            </g:if>--}%

                            <g:if test="${pageProperty(name: 'page.pagefinderbuttons')}">
                                <div class="col d-flex align-items-center justify-content-center justify-content-lg-end">
                                    <g:pageProperty name="page.pagefinderbuttons"/>
                                </div>
                            </g:if>
                        </div>
                    </div>
                </div>
                <div class="my-5" id="content">
                    <g:layoutBody/>
                </div>
            </article>
        </main>
    </div>
    <g:if test="${hubConfig.templateConfiguration.footer.type == 'ala'}">
        <footer class="site-footer footer-alt" id="footer">
            <div class="footer-middle">
                <div class="container">
                    <div class="row">
                        <div class="col-md-4 col-lg-6">
                            <!-- Footer Menu goes here -->
                            <div class="footer-menu">
                                <ul class="menu menu-2-col">
                                    <li class="menu-item menu-item-has-children">
                                        <a title="Search &amp; Analyse" href="#">Search &amp; Analyse</a>
                                        <ul class="sub-menu">
                                            <li class="menu-item">
                                                <a title="Search Occurrence Records" href="#">Search Occurrence Records</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Search ALA Datasets" href="#">Search ALA Datasets</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Spatial Portal" href="#">Spatial Portal</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Download Data" href="#">Download Data</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Search Species" href="#">Search Species</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="ALA Dashboard" href="#">ALA Dashboard</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Explore Your Area" href="#">Explore Your Area</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Browse Natural History Collections"
                                                   href="#">Browse Natural History Collections</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Explore Regions" href="#">Explore Regions</a>
                                            </li>
                                        </ul>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <!--col end -->
                        <div class="col-md-4 col-lg-3">
                            <!-- Footer Menu goes here -->
                            <div class="footer-menu">
                                <ul class="menu">
                                    <li class="menu-item menu-item-has-children">
                                        <a title="Contribute" href="#">Contribute</a>
                                        <ul class="sub-menu">
                                            <li class="menu-item">
                                                <a title="Record a sighting in the ALA"
                                                   href="#">Record a sighting in the ALA</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Submit a dataset to the ALA"
                                                   href="#">Submit a dataset to the ALA</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Digitise a record in the DigiVol"
                                                   href="#">Digitise a record in the DigiVol</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Mobile Apps" href="#">Mobile Apps</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Join a Citizen Science Program"
                                                   href="#">Join a Citizen Science Program</a>
                                            </li>
                                        </ul>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <!--col end -->
                        <div class="col-md-4 col-lg-3">
                            <!-- Footer Menu goes here -->
                            <div class="footer-menu">
                                <ul class="menu">
                                    <li class="menu-item menu-item-has-children">
                                        <a title="About ALA" href="#">About ALA</a>
                                        <ul class="sub-menu">
                                            <li class="menu-item">
                                                <a title="Who We Are" href="#">Who We Are</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="How to Work With Data" href="#">How to Work With Data</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Indigenous Ecological Knowledge"
                                                   href="#">Indigenous Ecological Knowledge</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Contact Us" href="#">Contact Us</a>
                                            </li>
                                            <li class="menu-item">
                                                <a title="Feedback" href="#">Feedback</a>
                                            </li>
                                        </ul>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <!--col end -->
                        <div class="col-md-12">
                            <!-- Footer Menu goes here -->
                            <div class="footer-menu-horizontal">
                                <ul class="menu horizontal">
                                    <li class="menu-item">
                                        <a title="Search" href="#">Blog</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Help" href="#">Help</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Sites &amp; Services" href="#">Sites &amp; Services</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Developer Tools &amp; Documentation"
                                           href="#">Developer Tools &amp; Documentation</a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <!--col end -->
                    </div><!-- row end -->
                </div><!-- container end -->
            </div>

            <div class="footer-bottom">
                <div class="container">
                    <div class="row">
                        <div class="col-12 content-column text-center">
                            <h4>The ALA is made possible by contributions from its partners, is supported by NCRIS and hosted by CSIRO</h4>

                            <div class="partner-logos">
                                <img src="assets/img/logo1.png" alt="Logo1">
                                <img src="assets/img/logo2.png" alt="Logo2">
                                <img src="assets/img/logo3.png" alt="Logo3">
                                <img src="assets/img/logo1.png" alt="Logo1">
                                <img src="assets/img/logo2.png" alt="Logo2">
                                <img src="assets/img/logo3.png" alt="Logo3">
                                <img src="assets/img/logo1.png" alt="Logo1">
                                <img src="assets/img/logo2.png" alt="Logo2">
                                <img src="assets/img/logo3.png" alt="Logo3">
                            </div>
                        </div>
                        <!--col end -->
                    </div><!-- row end -->
                </div><!-- container end -->
            </div>

            <div class="footer-copyright">
                <div class="container">
                    <div class="row">
                        <div class="col-md-12 col-lg-7">
                            <p class="alert-text text-creativecommons">
                                This work is licensed under a <a
                                    href="https://creativecommons.org/licenses/by/3.0/au/">Creative
                                Commons Attribution 3.0 Australia License</a> <a rel="license"
                                                                                 href="http://creativecommons.org/licenses/by/3.0/au/"><img
                                        alt="Creative Commons License" style="border-width:0"
                                        src="https://www.ala.org.au/wp-content/themes/ala-wordpress-theme/img/cc-by.png">
                            </a>
                            </p>
                        </div>
                        <!--col end -->
                        <div class="col-md-12 col-lg-5 text-lg-right">
                            <ul class="menu horizontal">
                                <li><a title="copyright" href="/copyright">Copyright</a></li>
                                <li><a title="Terms of Use" href="/terms">Terms of Use</a></li>
                                <li><a title="System Status" href="/status">System Status</a></li>
                            </ul>
                        </div>
                        <!--col end -->
                    </div><!-- row end -->
                </div><!-- container end -->
            </div>

        </footer>
    </g:if>
    <g:elseif test="${hubConfig.templateConfiguration.footer.type == 'custom'}">
        <footer class="site-footer footer-alt" id="custom-footer">
            <div>
                <div class="${'container-fluid'} hidden-print">
                    <div class="row align-items-center">
                            <div class="col-12 col-md-4 align-center link-column d-flex flex-column flex-md-row justify-content-center justify-content-md-start align-items-center">
                                <ul class="nav">
                                    <g:if test="${hubConfig.templateConfiguration?.footer?.links}">
                                        <g:each in="${hubConfig.templateConfiguration?.footer?.links}" var="link">
                                            <config:getLinkFromConfig config="${link}" hubConfig="${hubConfig}"></config:getLinkFromConfig>
                                        </g:each>
                                    </g:if>
                                </ul>
                            </div>
                            <!--col end -->
                            <div class="col-12 col-md-8 menu-column text-center text-lg-right d-flex flex-column flex-md-row justify-content-center justify-content-md-between align-items-center">
                                <div class="account mt-3 mt-md-0">
                                    <ul class="social">
                                        <g:if test="${hubConfig.templateConfiguration?.footer?.socials}">
                                            <g:each in="${hubConfig.templateConfiguration?.footer?.socials}" var="social">
                                                <g:if test="${social.contentType == 'facebook'}">
                                                    <li><a href="${raw(social.href)}" target="_blank" title="Facebook"><i class="fab fa-facebook fa-2x"></i></a></li>
                                                </g:if>
                                                <g:if test="${social.contentType == 'twitter'}">
                                                    <li><a href="${raw(social.href)}" target="_blank" title="Twitter"><i class="fab fa-twitter fa-2x"></i></a></li>
                                                </g:if>
                                            </g:each>
                                        </g:if>
                                    </ul>
                                </div>
                                <div class="row">
                                    <div class="col-12 d-flex align-items-center flex-column flex-md-row justify-content-center">
                                        <g:each in="${hubConfig.templateConfiguration?.footer?.logos}" var="logo">
                                            <g:if test="${logo.href}">
                                                <a href="${logo.href}" title="Link to website" target="_blank" class="do-not-mark-external d-block d-md-inline-block">
                                                    <img class="footer-logo" src="${logo.url}" alt="Website logo"/>
                                                </a>
                                            </g:if>
                                            <g:else>
                                                <img class="footer-logo d-block d-md-inline-block" src="${logo.url}" alt="Website logo"/>
                                            </g:else>
                                        </g:each>
                                        <a class="brand text-center text-md-left d-block d-md-inline-block" href="http://ala.org.au/" id="alaLink" title="ALA home page">
                                            <img src="${asset.assetPath(src:'mdba/ALA-logo-BW-124x109.png')}" alt="Powered by ALA logo"
                                                 class="headerLogo"/>
                                            <div id="alaHeadingText"><div id="poweredBy">powered by</div>
                                                <div id="alaBy" class="d-none d-lg-block">Atlas of Living Australia</div>
                                                <div class="d-block d-lg-none text-left">ALA</div>
                                            </div>
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <!--col end -->
                    </div><!-- row end -->
                </div><!--/.container -->
            </div><!--/#footer -->
        </footer>
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
</div>
<asset:deferredScripts />
<script>
    $(document).ready(function () {
        /**
         * Mobile (off-canvas) menu
         */
        $('[data-toggle="offcanvas"]').on('click', function () {
            $('#page.site').toggleClass('offcanvas-open');
        });
    })
</script>
</body>
</html>