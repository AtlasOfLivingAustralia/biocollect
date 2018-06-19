<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="adminLayout"/>
        <title>Users | Admin | Data capture | Atlas of Living Australia</title>
    </head>

    <body>
    <asset:stylesheet src="datatables-manifest.css"/>
    <asset:stylesheet src="validationEngine.jquery.css"/>
    <asset:javascript src="jquery.validationEngine/jquery.validationEngine.js"/>
    <asset:javascript src="jquery.validationEngine/jquery.validationEngine-en.js"/>
    <asset:javascript src="permissionTable.js"/>
    <asset:javascript src="datatables-manifest.js"/>
    <content tag="pageTitle">Users</content>

    <div class="container-fluid padding20">
        <div class="well">Logged in user is <b class="tooltips" title="${user}">${user.getDisplayName()}</b></div>

        <div class="row-fluid">
            <div class="span12">
                <g:render template="addPermissions" model="[projects:projects]"/>
            </div>
        </div>
        <div class='hide'>
            <h4>View Permissions for user</h4>
            <form class="form-horizontal">
                <div class="control-group">
                    <label class="control-label" for="userId2">User</label>
                    <div class="controls">
                        <g:select name="user" id="userId2" class="input-xlarge combobox2" from="${userNamesList}" optionValue="${{it.displayName + " <" + it.userName +">"}}" optionKey="userId" noSelection="['':'start typing a user name']"/>
                    </div>
                </div>
                <div class="control-group">
                    <div class="controls">
                        <button id="viewUserPermissionsButton" class="btn btn-primary">View</button>
                        <g:img uri="${asset.assetPath(src:'spinner.gif')}" id="spinner2" class="hide spinner" alt="spinner icon"/>
                    </div>
                </div>
            </form>
            <div class="span8" id="userPermissionsOutput">

            </div>
        </div>
        </div>
    </body>
</html>

<asset:script type="text/javascript">

    $(document).ready(function() {

        $("#viewUserPermissionsButton").click(function(e) {
            e.preventDefault();
            if ($('#userId2').val()) {
                $("#spinner2").show();
                $.ajax( {
                    url: "${createLink(controller: 'user', action: 'viewPermissionsForUserId')}",
                    data: {userId: $("#userId2").val() }
                }).done(function(result) {
                    //console.log("result",result);
                    $("#userPermissionsOutput").html(formatPermissionData(result)); // "<pre>" + JSON.stringify(result, null, 4) + "</pre>"
                }).fail(function(jqXHR, textStatus, errorThrown) { alert(jqXHR.responseText); })
                .always(function(result) { $("#spinner2").hide(); });
            } else {
                alert("No user selected - please check and try again.");
                $("#userPermissionsOutput").html("");
            }
        });

        var namesArray = [];
        <g:each var="it" in="${userNamesList}" status="s">namesArray[${s}] = "${it.userId} -- ${it.displayName?.toLowerCase()} -- ${it.userName?.toLowerCase()}";</g:each>

        $('.combobox2').combobox();
        $('.tooltips').tooltip();
    }); // end document.ready

    /**
     * Produce HTML output for the display of the permissions JSON data
     *
     * @param data
     */
    function formatPermissionData(data) {
        var html = "<table class='table table-bordered table-striped table-condensed'>";
        html += "<thead><tr><th>Project</th><th>Role</th></tr></thead><tbody>";
        $.each(data, function(i, el) {
            html += "<tr><td><a href='${createLink(controller: "project")}/" + el.project.projectId + "'>" + el.project.name + "</a></td><td>" + el.accessLevel.name + "</td></tr>";
        });
        html += "</tbody></table>";
        return html;
    }
</asset:script>
