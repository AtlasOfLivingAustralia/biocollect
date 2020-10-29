<div class="row-fluid bg-black-color">
    <div class="dropdown">
        <button class="btn btn-link btn-primary dropdown-toggle" type="button" data-toggle="dropdown"><i class="fa fa-list"></i> BioCollect
            <span class="caret"></span></button>
        <ul class="dropdown-menu">
            <li><a href="${createLink(controller: 'home', action: 'index')}" class="btnSearch"><span class="fa fa-search"></span> <g:message code='g.search'/></a></li>
            <li><a href="${createLink(controller: 'bioActivity', action: 'allRecords')}" class="btnAllData"><span class="fa fa-database"></span> <g:message code='g.allRecords'/></a></li>
            <li><a href="${createLink(controller: 'site', action: 'list')}" class="btnSite"><span class="fa fa-map-marker"></span> <g:message code='g.sites'/></a></li>
            <li><a href="<fc:getNewProjectLinkForHub hubConfig='${hubConfig}'/>" class="btnNewProject"><span class="fa fa-plus"></span> <g:message code='g.newProject'/></a></li>
            <g:if test="${fc.userIsSiteAdmin()}">
                <!--
                <li><a href="#" class="btnMyDashboard"><span class="fa fa-dashboard"></span> My Dashboard</a></li>
                -->
                <li><a href="${createLink(controller: 'bioActivity', action: 'list')}" class="btnMyData"><span class="fa fa-database"></span> <g:message code='myData'/></a></li>
                <li><a href="${createLink(controller: 'project', action: 'myProjects')}" class="btnMyProjects"><span class="fa fa-folder"></span> <g:message code='g.myProjects'/></a></li>
                <li><a href="${createLink(controller: 'organisation', action: 'myOrganisations')}" class="btnMyOrganisation"><span class="fa fa-building"></span> <g:message code='g.myOrganisation'/></a></li>
                <li><a href="${createLink(controller: 'site', action: 'myFavourites')}" class="btnMyFavouriteSites"><span class="fa fa-map-marker"></span> <g:message code='site.myFavouriteSites.heading'/></a></li>
            </g:if>
            <g:if test="${fc.userIsSiteAdmin()}">
                <li><a href="${createLink(controller: 'admin')}" class="btnAdministration"><span class="fa fa-lock"></span> <g:message code='g.admin'/></a></li>
            </g:if>
        </ul>
    </div>

</div>
