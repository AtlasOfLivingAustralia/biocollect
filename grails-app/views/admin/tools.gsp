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

                $("#btnReloadConfig").click(function(e) {
                    e.preventDefault();
                    $.ajax("${createLink(controller: 'admin', action:'reloadConfig')}").done(function(result) {
                        document.location.reload();
                    });
                });

                $("#btnClearMetadataCache").click(function(e) {
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

                $("#btnLoadProjectData").click(function(e) {
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

                $("#projectData").change(function() {
                    if ($("#projectData").val()) {
                        $("#btnLoadProjectData").removeAttr("disabled");
                    }
                    else {
                        $("#btnLoadProjectData").attr("disabled", "disabled");
                    }

                }).trigger('change');

                $("#btnLoadPlanData").click(function(e) {
                    e.preventDefault();
                    $('form.loadPlanData').submit();
                });

                $("#planData").change(function() {
                    if ($("#planData").val()) {
                        $("#btnLoadPlanData").removeAttr("disabled");
                    }
                    else {
                        $("#btnLoadPlanData").attr("disabled", "disabled");
                    }

                }).trigger('change');

                $("#btnReindexAll").click(function(e) {
                    e.preventDefault();
                    var url = "${createLink(controller: 'admin', action:'reIndexAll')}";
                    $.ajax(url).done(function(result) {
                        document.location.reload();
                    }).fail(function (result) {
                                alert(result);
                            });
                });


                $("#btnSyncCollectoryOrgs").click(function(e) {
                    e.preventDefault();
                    $.ajax("${createLink(controller: 'admin', action:'syncCollectoryOrgs')}"
                    ).done(function(result) {
                        alert("Ecodata organisations synchronized with Collectory!")
                        document.location.reload();
                    }).fail(function (result) {
                        alert(result.statusText);
                    });
                });

                $("#btnSyncSciStarter").click(function(e) {
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

                $("#btnSyncRematchSpeciesId").click(function(e) {
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
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Tool</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <button id="btnReloadConfig" class="btn btn-small btn-info">Reload&nbsp;External&nbsp;Config</button>
                    </td>
                    <td>
                        Reads any defined config files and merges new config with old. Usually used after a change is
                        made to external config files. Note that this cannot remove a config item as the result is a
                        union of the old and new config.
                    </td>
                </tr>
                <tr>
                    <td>
                        <button id="btnClearMetadataCache" class="btn btn-small btn-info">Clear&nbsp;Metadata&nbsp;Cache</button>
                        <label class="checkbox" style="padding-top:5px;"><input type="checkbox" id="clearEcodataCache" checked="checked">Also clear ecodata cache</label>
                    </td>
                    <td>
                        Removes all cached values for metadata requests and causes the metadata to be requested
                        from the source at the next attempt to use the metadata.
                    </td>
                </tr>
                <tr>
                    <td><button disabled id="btnLoadProjectData" class="btn btn-small btn-info" title="Load project data">Load Projects from CSV</button>
                    </td>
                    <td>
                        Loads (or reloads) project information from a csv file.
                        <p><g:uploadForm class="loadProjectData" controller="admin" action="importProjectData"><input id="projectData" type="file" accept="text/csv" name="projectData"/><input type="checkbox" name="importWithErrors">Force import (even with validation errors)</g:uploadForm></p>
                    </td>
                </tr>
                <tr>
                    <td><button disabled id="btnLoadPlanData" class="btn btn-small btn-info" title="Load project data">Load Plans from CSV</button>
                    </td>
                    <td>
                        Loads (or reloads) project plan information from a csv file.
                        <p><g:uploadForm class="loadPlanData" controller="admin" action="importPlanData"><input id="planData" type="file" accept="text/csv" name="planData"/><input type="checkbox" name="overwriteActivities">Replace existing activities</g:uploadForm></p>
                    </td>
                </tr>
                <tr>
                    <td>
                        <a style="color:white" class="btn btn-small btn-info" href="${createLink(controller:'admin', action:'bulkLoadUserPermissions')}">Bulk Load Permissions</a>
                    </td>
                    <td>
                        Loads user project roles from a csv file
                    </td>
                </tr>
                <tr>
                    <td><button id="btnReindexAll" class="btn btn-small btn-info" title="Re-index all data">Re-index all</button>
                    </td>
                    <td>
                        Re-indexes all data in the search index.
                    </td>
                </tr>
                <tr>
                    <td><button id="btnSyncCollectoryOrgs" class="btn btn-small btn-info" title="Sync collectory organisations">Sync collectory orgs</button>
                    </td>
                    <td>
                        Ensures that all institutions in collectory have a corresponding organisation in ecodata.
                    </td>
                </tr>
                <tr>
                    <td>
                        <button id="btnSyncSciStarter" class="btn btn-small btn-info" title="Synchronise Biocollect with SciStarter">Import SciStarter Projects</button>
                    </td>
                    <td>
                        Import projects from SciStarter to Biocollect. Note: this might take a long time
                    </td>
                </tr>
                <tr>
                    <td>
                        <button id="btnSyncRematchSpeciesId" class="btn btn-small btn-info" title="Synchronise Biocollect with SciStarter">Rematch species guid</button>
                    </td>
                    <td>
                        Re-match species guid
                    </td>
                </tr>
                <tr>
                    <td><button disabled id="btnLoadSightingsData" class="btn btn-small btn-info" title="Load sightings data">Load Sightings from JSON</button>
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
            </tbody>
        </table>
    </body>
</html>