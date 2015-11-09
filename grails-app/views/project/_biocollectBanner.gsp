<nav role='navigation' id="biocollectNav">
    <ul id='main'>
        <li><a href="${createLink(controller: 'project', action: 'citizenScience')}"><span class="fa fa-home"></span>Biocollect</a></li>
        <li><a href="#" class="btnSearch"><span class="fa fa-search"></span>Search</a></li>
        <li><a href="#" class="btnNewProject"><span class="fa fa-plus"></span>New Project</a></li>
        <li><a href="#" class="btnMyProjects"><span class="fa fa-folder"></span>My Projects</a></li>
        <li><a href="#" class="btnMyData"><span class="fa fa-database"></span>My Records</a></li>
        <g:if test="${fc.userIsSiteAdmin()}">
            <li><a href="#" class="btnAdministration"><span class="fa fa-lock"></span>Admin</a></li>
        </g:if>
        <g:if test="${fc.currentUserDisplayName()}">
            <li><a href="#" class="btnProfile"><span class="fa fa-user"></span><fc:currentUserDisplayName /></a></li>
        </g:if>
        <li><fc:loginLogoutButton logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout" iconLogin="fa fa-sign-in" iconLogout="fa fa-sign-out" cssClass="nothing"/></li>
        <li class="more hide" data-width="80">
            <a href="#"><span class="fa fa-ellipsis-h"></span>More</a>
            <ul></ul>
        </li>
        <li class="pull-right"><a href="http://www.ala.org.au" class="ala-link"><span class="ala-icon"></span>Atlas of Living Australia</a></li>
    </ul>
</nav>