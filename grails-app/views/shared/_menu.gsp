<div class="row-fluid" style="background-color: black">
    <div class="dropdown">
        <button class="btn btn-link btn-primary dropdown-toggle" type="button" data-toggle="dropdown"><i class="fa fa-list"></i> BioCollect
            <span class="caret"></span></button>
        <ul class="dropdown-menu">
            <li><a href="#" class="btnSearch"><span class="fa fa-search"></span> Search</a></li>
            <li><a href="#" class="btnAllData"><span class="fa fa-database"></span> All Records</a></li>
            <li><a href="#" class="btnSite"><span class="fa fa-map-marker"></span> Sites</a></li>
            <li><a href="#" class="btnNewProject"><span class="fa fa-plus"></span> New Project</a></li>
            <g:if test="${fc.userIsSiteAdmin()}">
                <li><a href="#" class="btnMyDashboard"><span class="fa fa-dashboard"></span> My Dashboard</a></li>
                <li><a href="#" class="btnMyData"><span class="fa fa-database"></span> My Data</a></li>
                <li><a href="#" class="btnMyProjects"><span class="fa fa-folder"></span> My Projects</a></li>
                <li><a href="#" class="btnMyOrganisation"><span class="fa fa-building"></span> My Organisation</a></li>
                <li><a href="#" class="btnMyFavouriteSites"><span class="fa fa-map-marker"></span> My Favourite Sites</a></li>
            </g:if>
            <g:if test="${fc.userIsSiteAdmin()}">
                <li><a href="#" class="btnAdministration"><span class="fa fa-lock"></span> Admin</a></li>
            </g:if>
        </ul>
    </div>

</div>
