<nav role='navigation' id="biocollectNav">
    <ul id='main'>
        <g:set var="path" value="${request.getServletPath()}"/>
        <li>
            <a href="${grailsApplication.config.biocollect.homepageUrl}" class="do-not-mark-external"><span class="fa fa-home"></span>Biocollect</a>
        </li>
        <li class="${(path ==~ /.*project\/citizenScience.*/) ? 'active' : ''}">
            <a href="#" class="btnSearch"><span class="fa fa-search"></span>Search</a>
        </li>
        <li class="${(path ==~ /.*bioActivity\/allRecords.*/) ? 'active' : ''}">
            <a href="#" class="btnAllData"><span class="fa fa-database"></span>All Records</a>
        </li>
        <li class="${(path ==~ /.*project\/create.*/) ? 'active' : ''}">
            <a href="#" class="btnNewProject"><span class="fa fa-plus"></span>New Project</a>
        </li>
        <li class="${(path ==~ /.*site\/.*/) ? 'active' : ''}">
            <a href="#" class="btnSite"><span class="fa fa-map-marker"></span>Sites</a>
        </li>
        <li class="${(path ==~ /.*project\/myProjects.*/) ? 'active' : ''}">
            <a href="#" class="btnMyProjects"><span class="fa fa-folder"></span>My Projects</a>
        </li>
        <li class="${(path ==~ /.*bioActivity\/list.*/) ? 'active' : ''}">
            <a href="#" class="btnMyData"><span class="fa fa-database"></span>My Data</a>
        </li>
        <g:if test="${fc.userIsSiteAdmin()}">
            <li class="${(path ==~ /.*admin\/index.*/) ? 'active' : ''}">
                <a href="#" class="btnAdministration"><span class="fa fa-lock"></span>Admin</a>
            </li>
        </g:if>
        <g:if test="${fc.currentUserDisplayName()}">
            <li class="${(path ==~ /.*user\/index.*/) ? 'active' : ''}">
                <a href="#" class="btnProfile"><span class="fa fa-user"></span><fc:currentUserDisplayName/></a>
            </li>
        </g:if>
        <li><fc:loginLogoutButton logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"
                                  iconLogin="fa fa-sign-in" iconLogout="fa fa-sign-out" cssClass="nothing"/></li>
        <li class="more" data-width="80" style="display: none">
            <a href="#"><span class="fa fa-ellipsis-h"></span>More</a>
            <ul></ul>
        </li>
        <li class="pull-right"><a href="http://www.ala.org.au" class="ala-link do-not-mark-external"><span
                class="ala-icon">&nbsp;</span>Atlas of Living Australia</a></li>
    </ul>
</nav>
