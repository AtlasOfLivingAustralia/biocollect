<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name.encodeAsHTML()} | Project | Field Capture</title>
    <r:script disposition="head">
    var fcConfig = {
        imageLocation:"${resource(dir:'/images')}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        homePagePath: "${createLink(controller: 'home', action: 'index')}",
        projectUpdateUrl: "${createLink(action: 'ajaxUpdate', id: project.projectId)}",
        projectEditUrl:"${createLink(action:'edit', id:project.projectId)}",
        projectDeleteUrl:"${createLink(action:'delete', id:project.projectId)}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project.projectId)}"
        },
        here = window.location.href;

    </r:script>

    <style type="text/css">
    .well-title {
        border-bottom: 1px solid lightgrey;
        font-weight: bold;
        padding-bottom:5px;
        margin-bottom:10px;
        font-size:larger;
    }
    </style>

    <r:require modules="knockout,datepicker,amplify,jqueryValidationEngine, projects, attachDocuments, wmd, restoreTab, map"/>
</head>
<g:render template="banner"/>


<div class="row-fluid">
    <div class="clearfix">
        <div id="project-results-placeholder"></div>
        <g:if test="${flash.errorMessage || flash.message}">
            <div class="span5">
                <div class="alert alert-error">
                    <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                    ${flash.errorMessage?:flash.message}
                </div>
            </div>
        </g:if>

    </div>
</div>

<g:if test="${user?.isAdmin}">
    <div class="container-fluid">
        <div class="row-fluid">
            <!-- content  -->
            <ul id="ul-cs-external-project" class="nav nav-pills">
                <li>
                    <a href="#about" id="about-tab" data-toggle="tab">About</a>
                </li>
                <li>
                    <a href="#admin" id="admin-tab" data-toggle="tab">Admin</a>
                </li>
            </ul>
        </div>

        <div class="pill-content">
            <div class="pill-pane" id="about">
                <g:render template="aboutCitizenScienceProject" model="${projectContent.about}"/>
            </div>
            <div class="pill-pane" id="admin">
                <g:render template="externalCSAdmin"/>
            </div>
        </div>
    </div>
</g:if>
<g:else>
    <g:render template="aboutCitizenScienceProject" model="${projectContent.about}"/>
</g:else>

<r:script>
    $(function() {
        var organisations = <fc:modelAsJavascript model="${organisations?:[]}"/>;
        var project = <fc:modelAsJavascript model="${project}"/>;
        var projectViewModel = new ProjectViewModel(project, ${user?.isEditor?:false}, organisations);

        var ViewModel = function() {
            var self = this;
            $.extend(this, projectViewModel);
            self.transients = self.transients || {};
            self.transients.resultsHolder = 'project-results-placeholder';
        };
        var viewModel = new ViewModel();
        viewModel.loadPrograms(<fc:modelAsJavascript model="${programs}"/>);
        ko.applyBindings(viewModel);

        <g:if test="${user?.isAdmin || fc.userIsAlaOrFcAdmin()}">
            populatePermissionsTable();
            new RestoreTab('ul-cs-external-project', 'about-tab');
            initialiseExternalCSAdmin();
        </g:if>

});
</r:script>
</body>
</html>