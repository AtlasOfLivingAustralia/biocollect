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
    <link rel="icon" href="https://www.ala.org.au/app/uploads/2019/01/cropped-favicon-32x32.png" sizes="32x32" />
    <link rel="icon" href="https://www.ala.org.au/app/uploads/2019/01/cropped-favicon-192x192.png" sizes="192x192" />
    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <g:if test="${hubConfig.templateConfiguration?.header?.type == 'ala' || hubConfig.templateConfiguration?.footer?.type == 'ala'}">
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/ala-theme.css"/>
    </g:if>
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

    <g:if test="${hubConfig.templateConfiguration.header.type == 'ala'}">
        <hf:banner logoutUrl="${g.createLink(controller: "logout", action: "logout", absolute: true)}" fluidLayout="false"/>
    </g:if>
    <g:elseif test="${hubConfig.templateConfiguration.header.type == 'custom'}">
        <nav class="navbar navbar-expand-lg navbar-dark navbar-alt">
            <div class="container-fluid d-flex flex-nowrap align-items-center">
                <div class="align-self-lg-start">
                    <g:if test="${hubConfig.logoUrl}">
                    <!-- Your site title as branding in the menu -->
                    <a href="${g.createLink(uri: "/")}" class="custom-logo-link" rel="home" itemprop="url">
                        <img class="hub-logo col-6 col-md-4 col-lg-2" src="${hubConfig.logoUrl}" />
                    </a> <!-- end custom logo -->
                    </g:if>
                </div>

                <div class="outer-nav-wrapper align-self-lg-end">

                    <div class="main-nav-wrapper">
                        <a href="javascript:" class="navbar-toggler order-3 order-lg-2" type="button"
                           data-toggle="offcanvas" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown"
                           aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </a>


                        <!-- The Main Menu goes here -->
                        <div id="navbarNavDropdown" class="collapse navbar-collapse offcanvas-collapse">
                            <ul class="navbar-nav ml-auto flex-lg-wrap">
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
    </g:elseif>
    </div>
    %{--    navbar end--}%
    <div class="wrapper" id="catalogue">
        <main class="site-main">
            <article class="page">
                <g:set var="bannerURL" value="${pageProperty(name: 'meta.bannerURL') ?: hubConfig.templateConfiguration.banner.images?.getAt(0)?.url}"/>
                <g:set var="banner" value="${pageProperty(name: 'page.banner')}"/>
                <g:if test="${pageProperty(name: 'page.slider')}">
                    <g:pageProperty name="page.slider"></g:pageProperty>
                </g:if>
                <g:else>
                    <div id="banner" class="page-banner ${pageProperty(name: 'meta.bannerClass') ?: ''} ${pageProperty(name: 'page.projectLogo')}" style="${bannerURL ? "background-image: url('${bannerURL}');" : ""}">
                        <g:if test="${pageProperty(name: 'page.bannertitle')}">
                            <div class="banner-title">
                                <h1><g:pageProperty name="page.bannertitle"></g:pageProperty></h1>
                            </div>
                        </g:if>
                        ${raw(banner?:"")}
                    </div>
                </g:else>
                <g:set var="tabList" value="${pageProperty(name: 'page.tab')}"/>
                <g:if test="${tabList}">
                    <div class="nav-row">
                        <div class="container-fluid">
                            ${raw(tabList)}
                        </div>
                    </div>
                </g:if>
                <div id="titleBar">
                    <div class="container-fluid">
                        <div class="row d-flex title-row">
                            <div class="col col-lg-6 d-flex align-items-center justify-content-start">
                                <g:render template="/layouts/breadcrumb"/>
                            </div>
                            <g:if test="${pageProperty(name: 'page.pagefinderbuttons')}">
                                <div class="col col-lg-6 py-2 d-flex align-items-center justify-content-center justify-content-lg-end">
                                    <g:pageProperty name="page.pagefinderbuttons"/>
                                </div>
                            </g:if>
                        </div>
                    </div>
                </div>
                <div class="my-1 mx-1 mx-md-3" id="content">
                    <g:layoutBody/>
                </div>
            </article>
        </main>
    </div>
    <g:if test="${hubConfig.templateConfiguration.footer.type == 'ala'}">
        <hf:footer/>
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
        <g:if test="${grailsApplication.config.getProperty('fathom.enabled', Boolean, true)}">
        <!-- Fathom analytics -->
        <script src="https://cdn.usefathom.com/script.js" data-site="${grailsApplication.config.getProperty('fathom.site-id')}" defer></script>
        <!-- END Fathom analytics -->
        </g:if>
        <g:else>
        <!-- Google Analytics -->
        <script>
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

            ga('create', '${grailsApplication.config.googleAnalyticsID}', 'auto');
            ga('send', 'pageview');
        </script>
        <!-- End Google Analytics -->
        </g:else>

    </g:elseif>
</div>
<asset:deferredScripts />
<script>
    $(document).ready(function () {
        var delay = ${grailsApplication.config.pingDuration};
        /**
         * Mobile (off-canvas) menu
         */
        $('[data-toggle="offcanvas"]').on('click', function () {
            $('#page.site').toggleClass('offcanvas-open');
        });

        /**
         * Ping server every 5 minutes (default value)  to keep session active
         */
        setInterval(function () {
            $.get("/ajax/keepSessionAlive");
        }, delay);
    })
</script>
</body>
</html>
