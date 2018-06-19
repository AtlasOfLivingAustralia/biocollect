<!doctype html>
<html>
	<head>
		<meta name="layout" content="adminLayout"/>
		<title>Admin - Audit | Data capture | Atlas of Living Australia</title>
		<style type="text/css" media="screen">
		</style>
	</head>
	<body>
        <asset:stylesheet src="datatables-manifest.css"/>
        <asset:javascript src="datatables-manifest.js"/>
    <h3>Audit</h3>
        <form class="form-inline">
            Search for a project:
            <g:textField id="searchTerm" name="searchTerm" placeholder="Search for projects..." value="${searchTerm}"></g:textField>
            <button class="btn" id="btnProjectSearch"><i class="icon-search"></i></button>
        </form>
        <g:if test="${results}">
        <g:set var="searchTerm" value="${params.searchTerm}"/>
        <div class="well well-small">
            <table style="width: 95%;" class="table table-striped table-bordered table-hover" id="project-list">
                <thead>
                    <th>Name</th>
                    <th>Description</th>
                </thead>
                <tbody>
                    <g:each in="${results.hits?.hits}" var="hit">
                        <tr>
                            <td>
                                <a href="${createLink(action:'auditProject', params:[id:hit._source?.projectId, searchTerm:searchTerm])}">${hit._source?.name}</a>
                            </td>
                            <td>${hit._source?.description}</td>
                        </tr>
                    </g:each>
                </tbody>
            </table>

        </div>
        </g:if>
    </body>
</html>

<asset:script type="text/javascript">

    $(document).ready(function() {

        $('#project-list').DataTable({
            "bSort": false,
            "oLanguage": {
             "sSearch": "Search: "
            }
        });
        $('.dataTables_filter input').attr("placeholder", "Name or Description");

        $("#btnProjectSearch").click(function(e) {
            e.preventDefault();
            doAuditProjectSearch()
        });
    });

    function doAuditProjectSearch() {
        var searchTerm = $("#searchTerm").val();
        if (searchTerm) {
            window.location = "${createLink(controller:'admin', action:'auditProjectSearch')}?searchTerm=" + searchTerm;
        }
    }


</asset:script>

