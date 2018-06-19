<%--
  Created by IntelliJ IDEA.
  User: dos009
  Date: 5/07/13
  Time: 12:32 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>User Dashboard | Field Capture</title>
</head>
<body>
<div id="wrapper" class="container-fluid">
    <div class="row-fluid">
        <div class="span12" id="header">
            <h1 class="pull-left">User Dashboard - ${user?.displayName}</h1>
        </div>
    </div>
    <g:if test="${flash.error || error}">
        <g:set var="error" value="${flash.error?:user?.error}"/>
        <div class="row-fluid">
            <div class="alert alert-error large-space-before">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <span>Error: ${error}</span>
            </div>
        </div>
    </g:if>
    <g:else>
        <div class="row-fluid ">
            <div class="span8">
                <h4>Pages recently edited by you</h4>
                <g:if test="${recentEdits && !recentEdits.get('error')}">
                    <table class="table table-striped table-bordered table-condensed">
                        <thead>
                        <tr>
                            <th>Page</th>
                            <th>Name</th>
                            <th>Date</th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each var="p" in="${recentEdits}">
                            <tr>
                                <td><g:message code="label.${p.entityType}" default="${p.entityType}"/></td>
                                <td><g:link controller="${fc.getControllerNameFromEntityType(entityType: p.entityType)}" id="${p.entityId}">${p.entity?.name?:p.entity?.type?:p.entity?.key}</g:link></td>
                                <td><fc:formatDateString date="${p.date}" inputFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"/></td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </g:if>
                <g:else>
                    [ No edits found in audit log ]
                </g:else>
            </div>
            <div class="span4">
                <g:if test="${memberOrganisations}">
                    <h4>Your organisations</h4>
                    <ul>
                        <g:each var="p" in="${memberOrganisations}">
                            <li><g:link controller="organisation" id="${p.organisation?.organisationId}">${p.organisation?.name}</g:link></li>
                        </g:each>
                    </ul>
                </g:if>
                <h4>Active Projects</h4>
                <g:if test="${memberProjects}">
                    <ul>
                        <g:each var="p" in="${memberProjects}">
                            <li><g:link controller="project" id="${p.project?.projectId}">${p.project?.name}</g:link> (${p.accessLevel?.name})</li>
                        </g:each>
                    </ul>
                </g:if>
                <g:else>
                    [ You are not a member of any projects ]
                </g:else>
                <h4>Favourite Projects</h4>
                <g:if test="${starredProjects}">
                    <ul>
                        <g:each var="p" in="${starredProjects}">
                            <li><g:link controller="project" id="${p.projectId}">${p.name}</g:link></li>
                        </g:each>
                    </ul>
                </g:if>
                <g:else>
                    [ No favourites set ]
                </g:else>
            </div>
        </div>
    </g:else>

</div>
<asset:script type="text/javascript">
    $(window).load(function () {
        $('.tooltips').tooltip({placement: "right"});
    });
</asset:script>
</body>
</html>