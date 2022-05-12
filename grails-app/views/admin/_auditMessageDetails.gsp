<%@ page import="au.org.ala.biocollect.DateUtils" %>
<h4>Audit ${message?.entityType?.substring(message?.entityType?.lastIndexOf('.')+1)}: ${message?.entity?.name} ${message?.entity?.type} </h4>
<g:set var="projectId" value="${params.projectId}"/>
<g:set var="searchTerm" value="${params.searchTerm}"/>

<div class="row">
    <div class="col-6">
        <h4>Edited by: ${userDetails?.displayName} <g:encodeAs codec="HTML">${message?.userId ?: '<anon>'}</g:encodeAs> </h4>
        <h5><small>${message?.eventType} : ${DateUtils.displayFormatWithTime(message?.date)}</small></h5>
    </div>
    <div class="col-6 text-right">
        <button id="toggle-ids" type="button" class="btn btn-dark btn-sm"><i class="fas fa-chevron-down"></i> Show Ids</button>
        <div id="ids" class="col-12">
            <h6>
                <strong>Id: </Strong><small>${message?.id}</small>
            </h6>
            <h6>
                <Strong>Entity Id: </Strong>
                <small><g:encodeAs codec="HTML">${message?.entityId}</g:encodeAs></small>
            </h6>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-12 text-right">
        <g:if test="${backToProject}">
            <a href="${createLink(controller: 'project', action:'index')}/${projectId}" class="btn btn-dark btn-sm"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
        </g:if>
        <g:else>
            <a href="${createLink(action:'auditProject', params:[id: projectId,searchTerm:searchTerm])}" class="btn btn-dark btn-sm"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
        </g:else>
    </div>
</div>

<div class="bg-light mt-3">
    <div class="row float-right mr-1">
        <table>
            <tr>
                <td style="background: #c6ffc6;"></td><td>Inserted</td>
                <td style="background: #ffc6c6;"></td><td>Deleted</td>
            </tr>
        </table>
    </div>
    <div id="content">
        <ul id="tabSection" class="nav nav-tabs" data-tabs="tabs">
            <li class="nav-item active"><a class="nav-link active" href="#minimal" data-toggle="tab">Overview</a></li>
            <li class="nav-item"><a class="nav-link" href="#detailed" data-toggle="tab">Detailed</a></li>
        </ul>
        <div id="my-tab-content" class="tab-content">
            <div class="tab-pane active" id="minimal">
                <table id="formatedJSON" class="table table-bordered table-hover table-striped">
                    <thead class="bg-primary">
                    <tr>
                        <th><h4>Fields</h4></th>
                        <th><h4>What's changed?</h4></th>
                    </tr>
                    </thead>
                    <tbody>
                    <g:each var="obj" in="${message?.entity}">
                        <tr>
                            <td>${obj.key}</td>
                            <td wrap class="diff1"></td>
                            <td style="display:none" class="original"> ${(compare ? compare?.entity[obj.key] : "")}</td>
                            <td style="display:none" class="changed">${obj.value}</td>

                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="tab-pane" id="detailed">
                <table id="wrapper" class="table table-striped table-bordered table-hover">
                    <thead>
                    <tr class="bg-primary row ml-0 mr-0">
                        <th class="col-4"><h4>Before</h4></th>
                        <th class="col-4"><h4>After</h4></th>
                        <th class="col-4"><h4>What's changed? </h4>
                        </th>
                    </tr>
                    </thead>
                    <tbody>

                    <tr class="row ml-0 mr-0">
                        <td class="original col-4" style="overflow: scroll"><fc:renderJsonObject object="${compare?.entity}" /></td>
                        <td class="changed col-4" style="overflow: scroll"><fc:renderJsonObject object="${message?.entity}" /></td>
                        <td style="line-height:1;" class="diff1 col-4" style="overflow: scroll"></td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<asset:script type="text/javascript">
    $(document).ready(function() {
        $( "#ids").hide();
        $("#wrapper tr").prettyTextDiff({
            cleanup: true,
            diffContainer: ".diff1"
        });
        $("#formatedJSON tr").prettyTextDiff({
            cleanup: true,
            diffContainer: ".diff1"
        });

        $( "#toggle-ids" ).on('click',function() {
            $( "#ids" ).toggle();
        });


    });
</asset:script>