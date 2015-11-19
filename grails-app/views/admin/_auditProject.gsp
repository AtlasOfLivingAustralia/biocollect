<%@ page import="au.org.ala.biocollect.DateUtils" %>
<r:require modules="jquery_bootstrap_datatable"/>
<g:set var="searchTerm" value="${params.searchTerm}"/>

<div class="row">
    <h3>Project Audit - ${project.name}</h3>
    <h4>Grant Id : ${project.grantId}</h4>
    <h4>External Id : ${project.externalId}</h4>
</div>

<g:if test="${!hideBackButton}">
    <div class="row">
        <div class="span12 text-right">
            <a href="${createLink(action:'auditProjectSearch',params:[searchTerm: searchTerm])}" class="btn btn-default btn-small"><i class="icon-backward"></i> Back</a>
        </div>
    </div>
</g:if>

<div class="row well well-small">
    <g:if test="${messages}">
        <table style="width: 95%;" class="table table-striped table-bordered table-hover" id="project-list">
            <thead>
            <th>Date</th>
            <th>Action</th>
            <th>Type</th>
            <th>Name</th>
            <th>User</th>
            <th></th>
            </thead>
            <tbody>
            <g:set var="project" value="${project}"/>
            <g:each in="${messages}" var="message">
                <tr>
                    <td><!-- ${DateUtils.displayFormatWithTimeNoSpace(message?.date)} --> ${DateUtils.displayFormatWithTime(message?.date)}</td>
                    <td>${message.eventType}</td>
                    <td>${message.entityType?.substring(message.entityType?.lastIndexOf('.')+1)}</td>
                    <td>${message.entity?.name} ${message.entity?.type} <small>(${message.entityId})</small></td>
                    <g:set var="displayName" value="${userMap[message.userId] ?: message.userId }" />
                    <td><g:encodeAs codec="HTML">${displayName}</g:encodeAs></td>
                    <td><a class="btn btn-small" href="${createLink( action:'auditMessageDetails', params:[projectId: project.projectId, id:message.id, compareId: message.entity.compareId, searchTerm: searchTerm])}">
                        <i class="icon-search"></i>
                    </a>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>

    </g:if>
    <g:else>
        <div>No messages found!</div>
    </g:else>
</div>

<r:script type="text/javascript">
    $(document).ready(function() {
        $('#project-list').DataTable({
            "order": [[ 0, "desc" ]],
            "aoColumnDefs": [{ "sType": "date-uk", "aTargets": [0] }],
            "oLanguage": {
                "sSearch": "Search: "
            },
            "ajax":"${createLink(controller: 'project', action: 'auditMessages')}/${project.projectId}",
            "columns": [{
                data: 'Date'
            },{
                data: 'Action'
            },{
                data: 'Type'
            },{
                data: 'Name'
            },{
                data: 'User'
            }]
        });
        $('.dataTables_filter input').attr("placeholder", "Date, Action, Type, Name, User");
    });
</r:script>
