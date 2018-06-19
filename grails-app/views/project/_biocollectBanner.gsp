<g:set var="settingService" bean="settingService"></g:set>
<nav role='navigation' id="biocollectNav"
    class="${hubConfig.defaultFacetQuery.contains('isEcoScience:true') ? 'ecoScienceNav' : ''}"
>
    <ul id='main'>
        <g:set var="path" value="${request.getServletPath()}"/>
        <li class="pull-left">
            <a id="biocollectlogo" class="white-background" href="${grailsApplication.config.biocollect.homepageUrl}"><img src="${asset.assetPath(src:"icons/BioCollect24.jpg")}" width="193"></a>
        </li>
        <li class="${(path ==~ /.*project\/projectFinder.*/) ? 'active' : ''}">
            <a href="${createLink(controller: 'home', action: 'index')}" class="btnSearch"><span class="fa fa-search"></span>Search</a>
        </li>
        <li class="${(path ==~ /.*bioActivity\/allRecords.*/) ? 'active' : ''}">
                <a href="${createLink(controller: 'bioActivity', action: 'allRecords')}" class="btnAllData"><span class="fa fa-database"></span>All Records</a>
        </li>
        <li class="${(path ==~ /.*site\/.*/) ? 'active' : ''}">
            <a href="${createLink(controller: 'site', action: 'list')}" class="btnSite"><span class="fa fa-map-marker"></span>Sites</a>
        </li>
        <li class="${(path ==~ /.*project\/create.*/) ? 'active' : ''}">
            <a href="<fc:getNewProjectLinkForHub hubConfig="${hubConfig}"/>" class="btnNewProject"><span class="fa fa-plus"></span>New Project</a>
        </li>
        <g:if test="${fc.userIsSiteAdmin()}">
            <li class="${(path ==~ /.*admin\/index.*/) ? 'active' : ''}">
                <a href="${createLink(controller: 'admin')}" class="btnAdministration"><span class="fa fa-lock"></span>Admin</a>
            </li>
        </g:if>
        <g:if test="${fc.currentUserDisplayName()}">
            <li class="${(path ==~ /.*user\/index.*/) || (path ==~ /.*bioActivity\/list.*/) || (path ==~ /.*project\/myProjects.*/) ? 'active' : ''} dropdown-submenu pull-left" role="menu">
                <a href="#" ><span class="fa fa-user"></span><fc:currentUserDisplayName/></a>
                <ul>
                    <!--
                    <li><a href="${createLink(controller: 'user', action: 'index')}" class="btnMyDashboard"><span class="fa fa-dashboard"></span>My Dashboard</a></li>
                    -->
                    <g:if test="${!settingService.isWorksHub()}">
                        <li><a href="${createLink(controller: 'bioActivity', action: 'list')}" class="btnMyData"><span class="fa fa-database"></span>My Data</a></li>
                    </g:if>
                    <li><a href="${createLink(controller: 'project', action: 'myProjects')}" class="btnMyProjects"><span class="fa fa-folder"></span>My Projects</a></li>
                    <li><a href="${createLink(controller: 'organisation', action: 'myOrganisations')}" class="btnMyOrganisation"><span class="fa fa-building"></span>My Organisation</a></li>
                    <li><a href="${createLink(controller: 'site', action: 'myFavourites')}" class="btnMyFavouriteSites"><span class="fa fa-map-marker"></span>My Favourite Sites</a></li>
                </ul>
            </li>
        </g:if>
        <li><fc:loginLogoutButton logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"
                                  iconLogin="fa fa-sign-in" iconLogout="fa fa-sign-out" cssClass="nothing"/></li>
        <li class="more" data-width="80" style="display: none">
            <a href="#"><span class="fa fa-ellipsis-h"></span>More</a>
            <ul class="more-ul"></ul>
        </li>
        <li class="pull-right"><a href="http://www.ala.org.au" class="ala-link do-not-mark-external"><span
                class="ala-icon">&nbsp;</span>Atlas of Living Australia</a></li>
        <g:if test="${hubConfig.defaultFacetQuery.contains('isCitizenScience:true')}">
            <li id="acsa-banner" class="pull-right"><a href="${grailsApplication.config.acsaUrl}" class="do-not-mark-external"><span
                class="acsa-image"></span> </a></li>
            <li id="acsa-text" class="pull-right"><a href="${grailsApplication.config.acsaUrl}" class="do-not-mark-external"><span
                    class="acsa-icon"></span> ACSA</a></li>
        </g:if>
    </ul>
</nav>
<asset:script>
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