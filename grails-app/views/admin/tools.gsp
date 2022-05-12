<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="adminLayout"/>
        <title>Tools | Admin | Data capture | Atlas of Living Australia</title>
    </head>

    <body>
        <script type="text/javascript">

            $(document).ready(function() {

                $("#btnReloadConfig").on('click',function(e) {
                    e.preventDefault();
                    $.ajax("${createLink(controller: 'admin', action:'reloadConfig')}").done(function(result) {
                        document.location.reload();
                    });
                });

                $("#btnClearMetadataCache").on('click',function(e) {
                    e.preventDefault();
                    var clearEcodataCache = $('#clearEcodataCache').is(':checked'),
                        url = "${createLink(controller: 'admin', action:'clearMetadataCache')}" +
                            (clearEcodataCache ? "?clearEcodataCache=true" : "");
                    $.ajax(url).done(function(result) {
                        document.location.reload();
                    }).fail(function (result) {
                        alert(result);
                    });
                });

                $("#btnLoadProjectData").on('click',function(e) {
                    e.preventDefault();

                    // HTML 5 only...
                    %{--var data = new FormData();--}%
                    %{--data.append('projectData', $('#fileSelector')[0].files[0]);--}%

                    %{--$.ajax({--}%
                    %{--url: "${createLink(controller: 'project', action:'loadProjectData')}",--}%
                    %{--done: function(result) {--}%
                    %{--document.location.reload();--}%
                    %{--},--}%
                    %{--error: function (result) {--}%
                    %{--var error = JSON.parse(result.responseText)--}%
                    %{--alert(error.error);--}%
                    %{--},--}%
                    %{--type:"POST",--}%
                    %{--processData: false,--}%
                    %{--contentType: false,--}%
                    %{--cache: false,--}%
                    %{--data: data--}%
                    %{--});--}%
                    $('form.loadProjectData').submit();
                });

                $("#projectData").on('change',function() {
                    if ($("#projectData").val()) {
                        $("#btnLoadProjectData").removeAttr("disabled");
                    }
                    else {
                        $("#btnLoadProjectData").attr("disabled", "disabled");
                    }

                }).trigger('change');

                $("#btnLoadPlanData").on('click',function(e) {
                    e.preventDefault();
                    $('form.loadPlanData').submit();
                });

                $("#planData").on('change',function() {
                    if ($("#planData").val()) {
                        $("#btnLoadPlanData").removeAttr("disabled");
                    }
                    else {
                        $("#btnLoadPlanData").attr("disabled", "disabled");
                    }

                }).trigger('change');

                $("#btnReindexAll").on('click',function(e) {
                    e.preventDefault();
                    var url = "${createLink(controller: 'admin', action:'reIndexAll')}";
                    $.ajax(url).done(function(result) {
                        document.location.reload();
                    }).fail(function (result) {
                                alert(result);
                            });
                });


                $("#btnSyncCollectoryOrgs").on('click',function(e) {
                    e.preventDefault();
                    $.ajax("${createLink(controller: 'admin', action:'syncCollectoryOrgs')}"
                    ).done(function(result) {
                        alert("Ecodata organisations synchronized with Collectory!")
                        document.location.reload();
                    }).fail(function (result) {
                        alert(result.statusText);
                    });
                });

                $("#btnSyncSciStarter").on('click',function(e) {
                    e.preventDefault();
                    $.ajax("${createLink(controller: 'admin', action:'syncSciStarter')}",
                            {
                                method:"POST"
                            }
                    ).done(function(result) {
                        alert("Successfully imported " + result.count + " SciStarter projects!");
                        document.location.reload();
                    }).fail(function (result) {
                        alert(result.statusText);
                    });
                });

                $("#btnSyncRematchSpeciesId").on('click',function(e) {
                    e.preventDefault();
                    $.ajax("${createLink(controller: 'admin', action:'syncSpeciesWithBie')}",
                            {
                                method:"GET"
                            }
                    ).done(function(result) {
                        alert(result.message);
                        document.location.reload();
                    }).fail(function (result) {
                        alert(result.statusText);
                    });
                });
            });

        </script>
        <content tag="pageTitle">Tools</content>
        <table class="table table-bordered table-striped table-hover">
            <thead>
                <tr>
                    <th>Tool</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <button id="btnReloadConfig" class="btn btn-warning"><i class="fas fa-sync"></i> Reload&nbsp;External&nbsp;Config</button>
                    </td>
                    <td>
                        Reads any defined config files and merges new config with old. Usually used after a change is
                        made to external config files. Note that this cannot remove a config item as the result is a
                        union of the old and new config.
                    </td>
                </tr>
                <tr>
                    <td>
                        <button id="btnClearMetadataCache" class="btn btn-danger"><i class="far fa-trash-alt"></i> Clear&nbsp;Metadata&nbsp;Cache</button>
                        <div class="form-group form-check">
                            <input type="checkbox" id="clearEcodataCache" checked="checked">
                            <label class="form-check-label" for="clearEcodataCache">Also clear ecodata cache</label>
                        </div>
                    </td>
                    <td>
                        Removes all cached values for metadata requests and causes the metadata to be requested
                        from the source at the next attempt to use the metadata.
                    </td>
                </tr>
                <tr>
                    <td><button disabled id="btnLoadProjectData" class="btn btn-info" title="Load project data"><i class="fas fa-file-upload"></i> Load Projects from CSV</button>
                    </td>
                    <td>
                        Loads (or reloads) project information from a csv file.
                        <p>
                            <g:uploadForm class="loadProjectData" controller="admin" action="importProjectData">
                                <input id="projectData" type="file" accept="text/csv" name="projectData"/>
                                <div class="form-group form-check">
                                    <input type="checkbox" name="importWithErrors" id="importWithErrors">
                                    <label class="form-check-label" for="importWithErrors">Force import (even with validation errors)</label>
                                </div>
                            </g:uploadForm>
                        </p>
                    </td>
                </tr>
                <tr>
                    <td><button disabled id="btnLoadPlanData" class="btn btn-info" title="Load project data"><i class="fas fa-file-upload"></i> Load Plans from CSV</button>
                    </td>
                    <td>
                        Loads (or reloads) project plan information from a csv file.
                        <p>
                            <g:uploadForm class="loadPlanData" controller="admin" action="importPlanData">
                                <input id="planData" type="file" accept="text/csv" name="planData"/>
                                <div class="form-group form-check">
                                    <input type="checkbox" name="overwriteActivities" id="overwriteActivities">
                                    <label class="form-check-label" for="overwriteActivities">Replace existing activities</label>
                                </div>
                            </g:uploadForm>
                        </p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <a style="color:white" class="btn btn-info" href="${createLink(controller:'admin', action:'bulkLoadUserPermissions')}"><i class="fas fa-upload"></i> Bulk Load Permissions</a>
                    </td>
                    <td>
                        Loads user project roles from a csv file
                    </td>
                </tr>
                <tr>
                    <td><button id="btnReindexAll" class="btn btn-danger" title="Re-index all data"><i class="fas fa-sync"></i> Re-index all</button>
                    </td>
                    <td>
                        Re-indexes all data in the search index.
                    </td>
                </tr>
                <tr>
                    <td><button id="btnSyncCollectoryOrgs" class="btn btn-warning" title="Sync collectory organisations"><i class="fas fa-sync"></i> Sync collectory orgs</button>
                    </td>
                    <td>
                        Ensures that all institutions in collectory have a corresponding organisation in ecodata.
                    </td>
                </tr>
                <tr>
                    <td>
                        <button id="btnSyncSciStarter" class="btn btn-info" title="Synchronise Biocollect with SciStarter"><i class="fas fa-file-import"></i> Import SciStarter Projects</button>
                    </td>
                    <td>
                        Import projects from SciStarter to Biocollect. Note: this might take a long time
                    </td>
                </tr>
                <tr>
                    <td>
                        <button id="btnSyncRematchSpeciesId" class="btn btn-warning" title="Synchronise Biocollect with SciStarter"><i class="fas fa-sync"></i> Rematch species guid</button>
                    </td>
                    <td>
                        Re-match species guid
                    </td>
                </tr>
                <tr>
                    <td><button disabled id="btnLoadSightingsData" class="btn btn-info" title="Load sightings data"><i class="fas fa-file-upload"></i> Load Sightings from JSON</button>
                    </td>
                    <td>
                        Loads sightings information from JSON file. To produce JSON file for import
                        <ul>
                            <li>Export BSON from sightings; mongoexport -d ecodata -c records</li>
                            <li>Convert BSON to JSON; bsondump records.bson > records.json</li>
                        </ul>
                        <p><g:uploadForm class="loadSightingsData" controller="admin" action="importSightingsData">
                            <input id="sightingsData" type="file" accept="application/json" name="sightingsData"/>
                            <br/><input type="text" name="pActivityId" id="pActivityId">Project Activity Id</g:uploadForm></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <a class="btn btn-info" href="/alaAdmin"><i class="fas fa-cog"></i> <g:message code="admin.alaAdmin"/></a>
                    </td>
                    <td>
                        <g:message code="admin.alaAdmin.helptext"/>
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
