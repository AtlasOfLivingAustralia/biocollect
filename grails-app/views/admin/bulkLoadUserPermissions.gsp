<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="adminLayout"/>
        <title>Users | Admin | Data capture | Atlas of Living Australia</title>
    </head>

    <body>
        <r:require module="jqueryValidationEngine"/>
        <content tag="pageTitle">Users - Bulk Load User Permissions</content>
        <div class="container">
            <div class="well">Logged in user is <b class="tooltips" title="${user}">${user.userDisplayName}</b></div>
            <div>
                <p>
                    Upload a csv whose first row contains column headers, and has at least the following 5 columns (in any order):
                </p>
                <code>
                   "Grant ID","Sub-project ID","Recipient email 1","Recipient email 2","Grant manager email"
                </code>
                <p>where:</p>
                <p>
                    <code>Recipient email 1</code> and <code>Recipient email 2</code> are email address for people who will be project administrators
                </p>
                <p>
                    <code>Grant manager email</code> is the email of the person who will be given the Case Manager role for the project
                </p>
            </div>
            <g:uploadForm class="form-horizontal" action="uploadUserPermissionsCSV" enctype="multipart/form-data">
                <div class="control-group">
                    <label class="control-label" for="userPermissions">
                        Select a CSV file to upload
                    </label>
                    <div class="controls">
                        <input type="file" accept="text/csv" name="projectData" />
                    </div>
                </div>

                <div class="control-group">
                    <div class="controls">
                        <g:submitButton name="uploadCSV" value="Load Permissions" class="btn btn-primary" />
                    </div>
                </div>

            </g:uploadForm>
            <g:if test="${results}">
            <div class="alert alert-danger">
                <p>${results.message}</p>
                <ul>
                <g:each in="${results?.validationErrors}" var="message">
                    <li>Line ${message.line}: ${message.message}</li>
                </g:each>
                </ul>
            </div>
            </g:if>
        </div>
    </body>
</html>

<r:script type="text/javascript">

    $(document).ready(function() {
    }); // end document.ready

</r:script>
