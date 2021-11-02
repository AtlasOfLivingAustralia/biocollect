<%@ page import="au.org.ala.biocollect.DateUtils" %>

<g:set var="searchTerm" value="${params.searchTerm}"/>

<h4 class="mt-3 mt-lg-0">Project Audit - ${project.name}</h4>

<g:if test="${!hideBackButton}">
    <div class="row">
        <div class="col-12">
            <a href="${createLink(action:'auditProjectSearch',params:[searchTerm: searchTerm])}" class="btn btn-sm btn-dark">
                <i class="far fa-arrow-alt-circle-left"></i> Back
            </a>
        </div>
    </div>
</g:if>

<div class="row" id="project-audit-list">
    <div class="col-12">
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
</div>

<button id="loadAuditRecords" class="btn btn-primary-dark">Load ${project.name} audit records</button>

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
                    return '<a class="btn btn-sm btn-dark" href="'+ fcConfig.auditMessageUrl +'&id=' + row.id+'&searchTerm=${searchTerm}"><i class="fas fa-search"></i></a>';

                },
                bSortable : false
            }]
        });
        $('.dataTables_filter input').attr("placeholder", "Action, Type, Name");
        }

    });
</asset:script>
