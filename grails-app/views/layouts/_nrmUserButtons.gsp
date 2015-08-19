<g:if test="${fc.currentUserDisplayName()}">
    <div class="btn-group">
        <button class="btn btn-small btn-fc btnProfile" title="profile page">
            <i class="icon-user icon-white"></i><span class="">&nbsp;<fc:currentUserDisplayName /></span>
        </button>
        <button class="btn btn-small btn-fc dropdown-toggle" data-toggle="dropdown">
            <!--<i class="icon-star icon-white"></i>--> My projects&nbsp;&nbsp;<span class="caret"></span>
        </button>
        <div class="dropdown-menu pull-right">
            <fc:userProjectList />
        </div>
        <button class="btn btn-small btn-fc btnNewProject" title="new project">
            <i class="icon-plus icon-white"></i><span class="">&nbsp; New Project</span>
        </button>
    </div>
    <g:if test="${fc.userIsSiteAdmin()}">
        <div class="btn-group">
            <button class="btn btn-warning btn-small btnAdministration"><i class="icon-cog icon-white"></i><span class="">&nbsp;Administration</span></button>
        </div>
    </g:if>
</g:if>
<div class="btn-group">
    <fc:loginLogoutButton logoutUrl="${createLink(controller:'logout', action:'logout')}" logoutReturnToUrl="${createLink(controller: "home", absolute: true)}" cssClass="${loginBtnCss}"/>
</div>