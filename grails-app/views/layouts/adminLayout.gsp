<g:applyLayout name="bs4">
    <head>
        <title><g:layoutTitle /></title>
    </head>
    <body>
    <asset:javascript src="fieldcapture-application.js"/>
    <div class="container-fluid">

        <nav aria-label="breadcrumb">
            <ul class="breadcrumb">
                <li class="breadcrumb-item">
                    <g:link controller="home">Home</g:link>
                </li>
                <li class="breadcrumb-item"><g:link class="discreet" action="index">Administration</g:link></li>
                <li class="breadcrumb-item active"><g:pageProperty name="page.pageTitle"/></li>
            </ul>
        </nav>
        <div class="row">
            <div class="col-md-3">
                <div class="nav flex-md-column nav-pills" role="tablist">
                    <fc:breadcrumbItem href="${createLink(controller: 'admin', action: 'users')}" title="Users" />
                    <fc:breadcrumbItem href="${createLink(controller: 'admin', action: 'audit')}" title="Audit" />
                    <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole)}">
                        <fc:breadcrumbItem href="${createLink(controller: 'admin', action: 'staticPages')}" title="Static pages" />
                    </g:if>
                    <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole)}">
                        <fc:breadcrumbItem href="${createLink(controller: 'admin', action: 'tools')}" title="Tools" />
                        <fc:breadcrumbItem href="${createLink(controller: 'admin', action: 'settings')}" title="Settings" />
                        <fc:breadcrumbItem href="${createLink(controller: 'admin', action:'manageHubs')}" title="Manage Hubs"/>
                        <fc:breadcrumbItem href="${createLink(controller: 'admin', action:'cacheManagement')}" title="Caches"/>
                    </g:if>
                </div>
                <div class="mt-5 text-align-center"><g:pageProperty name="page.adminButtonBar"/></div>
            </div>

            <div class="col-md-9">
                <g:if test="${flash.errorMessage}">
                    <div class="container-fluid">
                        <div class="alert alert-danger">
                            ${flash.errorMessage}
                        </div>
                    </div>
                </g:if>

                <g:if test="${flash.message}">
                    <div class="container-fluid">
                        <div class="alert alert-info">
                            ${flash.message}
                        </div>
                    </div>
                </g:if>

                <g:layoutBody/>

            </div>
        </div>
    </div>
    </body>
</g:applyLayout>