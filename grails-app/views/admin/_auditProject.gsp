<%@ page import="au.org.ala.biocollect.DateUtils" %>

<g:set var="searchTerm" value="${params.searchTerm}"/>

<div class="row">
    <h3>Project Audit - ${project.name}</h3>
</div>

<g:if test="${!hideBackButton}">
    <div class="row">
        <div class="span12 text-right">
            <a href="${createLink(action:'auditProjectSearch',params:[searchTerm: searchTerm])}" class="btn btn-default btn-small"><i class="icon-backward"></i> Back</a>
        </div>
    </div>
</g:if>

<div class="row well well-small" id="project-audit-list">
        <table style="width: 95%;" class="table table-striped table-bordered table-hover" id="project-list">
            <thead>
            <th>Date</th>
            <th>Action</th>
            <th>Type</th>
            <th>Name</th>
            <th>User</th>
            <th>Details</th>
            </thead>
            <tbody>
            </tbody>
        </table>
</div>

<button id="loadAuditRecords" class="btn btn-primary btn-large">Load ${project.name} audit records</button>

<asset:script type="text/javascript">
    $(document).ready(function() {
        $("#project-audit-list").hide();

        $("#loadAuditRecords").click(function() {
            $("#loadAuditRecords").hide();
            $("#project-audit-list").show();
            loadAuditData();
        });

        function loadAuditData(){
            $('#project-list').DataTable({
            "order": [[ 0, "desc" ]],
            "aoColumnDefs": [{ "sType": "date-uk", "aTargets": [0] }],
            "oLanguage": {
                "sSearch": "Search: "
            },
            "processing": true,
            "serverSide": true,
            "ajax":{
               url: "${createLink(controller: 'project', action: 'getAuditMessagesForProject')}/${project.projectId}",
               data: function(options){
                    var col, order
                    for(var i in options.order){
                        order = options.order[i];
                        col = options.columns[order.column];
                        break;
                    }
                    options.sort = col.data;
                    options.orderBy = order.dir
                    options.q = (options.search && options.search.value) || ''
               }
            },
            "columns": [{
                data: 'date',
                name: 'date'
            },{
                data: 'eventType',
                name: 'eventType'
            },{
                data: 'entityType',
                render: function(data, type, row){
                    return data && data.substr(data.lastIndexOf('.') + 1)
                }
            },{
                data:'entity.name',
                render: function(data, type, row){
                    var name = (row.entity && row.entity.name) || '',
                     type = (row.entity && row.entity.type) || '',
                     id = row.entityId;
                    return name + ' ' + type + ' <small>(' + id + ')</small>'
                },
                bSortable : false
            },{
                data: 'userName',
                bSortable : false
            },{
                render: function(data, type , row){
                    return '<a class="btn btn-small" href="'+ fcConfig.auditMessageUrl +'&id=' + row.id+'&searchTerm=${searchTerm}"><i class="icon-search"></i></a>';

                },
                bSortable : false
            }]
        });
        $('.dataTables_filter input').attr("placeholder", "Action, Type, Name");
        }

    });
</asset:script>
