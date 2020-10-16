<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="app.version" content="${g.meta(name:'app.version')}"/>
    <meta name="app.build" content="${g.meta(name:'app.build')}"/>
    <meta name="description" content="Atlas of Living Australia"/>
    <meta name="author" content="Atlas of Living Australia">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title><g:layoutTitle /></title>

    <%-- Do not include JS & CSS files here - add them to your app's "application" module (in "Configuration/ApplicationResources.groovy") --%>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/bootstrap-responsive.min.css"/>
    <link rel="stylesheet" href="${grailsApplication.config.headerAndFooter.baseURL}/css/ala-styles.css"/>
    <asset:stylesheet src="base.css"/>
    <asset:stylesheet src="ala2.css"/>
    <asset:javascript src="base.js"/>
    <script type="text/javascript">
        i18nInitilisation("${g.createLink(controller: 'home', action: 'i18n')}");
    </script>

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
        });
    </asset:script>

    <g:layoutHead />
</head>
<body class="${pageProperty(name:'body.class')}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">
<ala:systemMessage/>

<hf:banner logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"/>

<hf:menu/>

<div class="container" id="main-content">
    <g:layoutBody />
</div><!--/.container-->

<div class="container hidden-desktop">
    <%-- Borrowed from http://marcusasplund.com/optout/ --%>
    <a class="btn btn-small toggleResponsive"><i class="icon-resize-full"></i> <span>Desktop</span> version</a>
    %{--<a class="btn btn-small toggleResponsive"><i class="icon-resize-full"></i> Desktop version</a>--}%
</div>

<hf:footer/>

<script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<asset:script type="text/javascript">
    var pageTracker = _gat._getTracker("UA-4355440-1");
    pageTracker._initData();
    pageTracker._trackPageview();

    // show warning if using IE6
    if ($.browser.msie && $.browser.version.slice(0,1) == '6') {
        $('#header').prepend($('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
                ' Many functions will still work but layout and image transparency will be disrupted.</div>'));
    }
</asset:script>

<!-- JS resources-->
<asset:deferredScripts/>

</body>
</html>