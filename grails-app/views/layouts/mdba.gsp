<g:set var="orgNameLong" value="${grailsApplication.config.skin.orgNameLong}"/>
<g:set var="orgNameShort" value="${grailsApplication.config.skin.orgNameShort}"/>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" type="image/x-icon" href="${grailsApplication.config.mdba.baseUrl}/images/favicons.ico/favicon.ico">
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap-responsive.min.css"/>
    <asset:stylesheet src="base.css"/>
    <asset:stylesheet src="Common_fonts.css"/>
    <asset:stylesheet src="mdba-styles.css"/>

    <title><g:layoutTitle /></title>
    <asset:javascript src="base.js"/>
    <asset:script type="text/javascript">
        // initialise plugins
        jQuery(function(){
            // autocomplete on navbar search input
            jQuery("form#search-form-2011 input#search-2011, form#search-inpage input#search, input#search-2013").autocomplete('https://bie.ala.org.au/search/auto.jsonp', {
                extraParams: {limit: 100},
                dataType: 'jsonp',
                parse: function(data) {
                    var rows = new Array();
                    data = data.autoCompleteList;
                    for(var i=0; i<data.length; i++) {
                        rows[i] = {
                            data:data[i],
                            value: data[i].matchedNames[0],
                            result: data[i].matchedNames[0]
                        };
                    }
                    return rows;
                },
                matchSubset: false,
                formatItem: function(row, i, n) {
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
            $(".toggleResponsive").click(function(e) {
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

            $('.helphover').popover({animation: true, trigger:'hover'});
        });
    </asset:script>
    <g:layoutHead />
</head>
<body class="${pageProperty(name:'body.class')?:'nav-collections'}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}"  data-offset="${pageProperty(name:'body.data-offset')}" data-target="${pageProperty(name:'body.data-target')}" data-spy="${pageProperty(name:'body.data-spy')}">
%{--<g:set var="fluidLayout" value="${grailsApplication.config.skin.fluidLayout?.toBoolean()}"/>--}%
<g:set var="fluidLayout" value="${true}"/>
<div class="navbar navbar-inverse navbar-static-top">
    <div class="navbar-inner contain-to-grid">
        <div class="${fluidLayout?'container-fluid':'container'}">
            <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="brand do-not-mark-external" href="https://www.mdba.gov.au/" id="mdbaLink" title="MDBA home page">
                <img src="${asset.assetPath(src:'mdba/MDBA-logo.png')}" alt="MDBA logo" class="headerLogo"/>
                <div id="mdbaHeadingText">MDBA</div>
            </a>
            <a class="brand" href="https://ala.org.au/" id="alaLink" title="ALA home page">
                <img src="${asset.assetPath(src:'mdba/ALA-logo-BW-124x109.png')}" alt="Powered by ALA logo" class="headerLogo"/>
                <div id="alaHeadingText"><div id="poweredBy">powered by</div><div id="alaBy" class="visible-desktop">Atlas of Living Australia</div>
                    <div class="hidden-desktop">ALA</div></div>
            </a>
            <div class="pull-right">
                <div class="nav-collapse collapse pull-right">
                    <ul class="nav">
                        <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/index">Home</a></li>
                        <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/${grailsApplication.config.mdba.searchUrl}">Search</a></li>
                        <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/about">About</a></li>
                        <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/help">Help</a></li>
                        <g:if test="${!fc.userIsLoggedIn()}">
                            <li>
                                <a href="${grailsApplication.config.security.cas.loginUrl}?service=${ grailsApplication.config.security.cas.appServerName}${request.forwardURI}">Login</a>
                            </li>
                        </g:if>
                        <g:if test="${fc.userIsLoggedIn()}">
                            <li>
                                <a href="${grailsApplication.config.grails.serverURL}/logout/logout?casUrl=${grailsApplication.config.casServerUrlPrefix}/logout&appUrl=${ grailsApplication.config.security.cas.appServerName}${request.forwardURI}">Logout</a>
                            </li>
                        </g:if>
                    </ul>
                </div><!--/.nav-collapse -->
            </div>
        </div><!--/.container-fluid -->
    </div><!--/.navbar-inner -->
</div><!--/.navbar -->

<g:pageProperty name="page.page-header"/> <%-- allows special content to be inserted --%>

<div class="${fluidLayout?'container-fluid':'container'}" id="main-content">
    <g:layoutBody />
</div><!--/.container-->

<div id="footer">
    <div class="${fluidLayout?'container-fluid':'container'}">
        <div class="row  navbar-inverse">
            <div class="span6">
                <ul class="nav">
                    <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/contact">Contact us </a></li>
                    <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/access">Accessibility </a></li>
                    <li><a class="do-not-mark-external" href="${grailsApplication.config.mdba.baseUrl}/disclaim">Disclaimer</a></li>
                </ul>
            </div><!--/.spanX -->
            <div class="span6 smlinks text-right">
                <div id="smlinks">
                    <a class="do-not-mark-external" href="https://twitter.com/MD_Basin_Auth">
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                            <i class="fa fa-twitter fa-stack-1x"></i>
                        </span>
                        %{--<g:img dir="/images" file="twitter-icon.png" alt="MDBA on Twitter"/>--}%
                    </a>
                    <a class="do-not-mark-external" href="https://www.youtube.com/user/mdbamedia">
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                            <i class="fa fa-youtube fa-stack-1x"></i>
                        </span>
                        %{--<g:img dir="/images" file="youtube-icon.png" alt="MDBA on Youtube"/>--}%
                    </a>
                    <a class="do-not-mark-external" href="https://www.facebook.com/MDBAuth">
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                            <i class="fa fa-facebook fa-stack-1x"></i>
                        </span>
                        %{--<g:img dir="/images" file="facebook-icon.png" alt="MDBA on Facebook"/>--}%
                    </a>
                </div>
            </div><!--/.spanX -->
        </div><!--/.row -->
    </div><!--/.contaier -->
</div><!--/#footer -->

<!-- JS resources-->
<asset:deferredScripts/>
</body>
</html>