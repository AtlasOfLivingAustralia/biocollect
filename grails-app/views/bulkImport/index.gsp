<%@ page import="org.apache.tomcat.jni.Local" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<g:set var="messageSource" bean="messageSource"></g:set>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Bulk load | ${pActivityFormName} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/' + hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${projectId},Project"/>
    <meta name="breadcrumbParent3"
          content="${createLink(controller: 'project', action: 'index')}/${projectId}?tab=activities-tab,${name}"/>
    <meta name="breadcrumb"
          content="${messageSource.getMessage('projectActivity.create.bulkload', [].toArray(), '', Locale.default)}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
        var fcConfig = {
        <g:applyCodec encodeAs="none">
        projectId: "${projectId}",
        bulkImportUrl: "${createLink(controller: 'bulkImport')}",
        bulkImportId: "${bulkImportId}",
        convertExcelToDataUrl: "${createLink(controller: 'bioActivity', action: 'convertExcelToOutputData')}",
        formName: "${pActivityFormName}",
        createActivityUrl: '${createLink(controller: 'bioActivity', action: 'mobileCreate', params: [id: "${projectActivityId}", bulkUpload: true, embedded: true], absolute: true)}',
        projectActivityId: "${projectActivityId}",
        originUrl: "${grailsApplication.config.server.serverURL}",
        returnTo: "${returnTo ?: (createLink(controller: 'project', action: 'index') + "/" + projectId)}"
        </g:applyCodec>
        },
        here = document.location.href;
    </asset:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="bulk-import-view-models.js"/>
</head>

<body>
<h1><g:message code="bulkimport.index.title" /></h1>
<div class="mt-5">
    <h2><g:message code="bulkimport.stepone.title" /></h2>
    <div>
        <div class="form-group">
            <label for="description"><g:message code="bulkimport.stepone.describe"/> <span class="req-field"/></label>
            <textarea id="description" class="form-control" data-bind="value: activityImport.description"></textarea>
        </div>
        <div class="form-group">
            <label for="spreadsheetFile"><g:message code="bulkimport.stepone.spreadsheet"/> </label>
            <input id="spreadsheetFile" class="form-control-file" type="file" name="data" data-bind="event: {change: fileInputChangeHandler}"/>
        </div>
        <div class="form-group">
            <label class="form-check-label" for="jsonData"><g:message code="bulkimport.stepone.json"/> <span class="req-field"/></label>
            <pre id="jsonData" class="h-200px p-2 border mt-2" data-bind="text: JSON.stringify(activityImport.dataToLoad() || [], null, 2)">

            </pre>
        </div>
        <button type="submit" class="btn btn-primary" data-bind="click: submitButtonHandler"><i class="fas fa-upload"></i> Submit</button>
    </div>
</div>

<div class="mt-5">
    <h2><g:message code="bulkimport.steptwo.title" /></h2>
    <table class="table">
        <thead>
        <tr>
            <th scope="col"></th>
            <th scope="col">Number</th>
            <th scope="col">Actions</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <th scope="row"><g:message code="bulkimport.data.total.title" default="Total number of rows in data"/></th>
            <td data-bind="text: activityImport.transients.numberOfActivities"></td>
            <td>
                <button class="btn btn-dark" data-bind="click: importButtonHandler, enable: showImportBtn"><i
                    class="fas fa-file-import"></i> <g:message
                    code="projectActivity.bulkupload.submit.btn"/></button>
                <button class="btn btn-dark" data-bind="click: validateButtonHandler, enable: showValidateBtn"><i
                        class="fas fa-bug"></i> <g:message
                        code="projectActivity.bulkupload.load.btn" default="Check data"/></button>
            </td>
        </tr>
        <tr>
            <th scope="row"><g:message code="bulkimport.data.imported.title" default="Total number of rows imported"/></th>
            <td data-bind="text: activityImport.transients.numberOfActivitiesLoaded"></td>
            <td>
                <button class="btn btn-dark" data-bind="click: viewButtonHandler, enable: showViewBtn"><i
                    class="far fa-eye"></i> <g:message code="projectActivity.bulkupload.view.btn"
                                                       default="View activities"/></button>
                <button class="btn btn-success" data-bind="click: publishButtonHandler, enable: showPublishBtn"><i
                        class="fas fa-upload"></i> <g:message code="projectActivity.bulkupload.publish.btn"
                                                              default="Publish activities"/></button>
                <button class="btn btn-dark" data-bind="click: embargoButtonHandler, enable: showEmbargoBtn"><i
                        class="fas fa-lock"></i> <g:message code="projectActivity.bulkupload.publish.btn"
                                                            default="Embargo activities"/></button>
                <button class="btn btn-danger" data-bind="click: deleteButtonHandler, enable: showDeleteBtn"><i
                        class="far fa-trash-alt"></i> <g:message code="projectActivity.bulkupload.delete.btn"
                                                                 default="Delete activities"/></button>

            </td>
        </tr>
        <tr>
            <th scope="row"><g:message code="bulkimport.data.invalid.title" default="Total number of rows with error"/></th>
            <td data-bind="text: activityImport.transients.numberOfActivitiesInvalid"></td>
            <td>
                <button class="btn btn-dark" data-bind="click: invalidButtonHandler, enable: showFixInvalid">
                <i class="fas fa-tools"></i>
                <g:message
                        code="projectActivity.bulkupload.fix.invalid.btn" default="Fix invalid"/></button>
            </td>
        </tr>
        </tbody>
    </table>
</div>
<div class="mt-5">
<!-- ko template: {name: 'iframeTemplate', if: showIframe, afterRender: adjustIframeHeight } -->
<!-- /ko -->
</div>
<asset:script>
%{--    $(function(){--}%
    var model = new ActivityImport({projectActivityId: fcConfig.projectActivityId, formName: fcConfig.formName, projectId: fcConfig.projectId}),
        bulkUploadViewModel = new BulkUploadViewModel(model);
    ko.applyBindings(bulkUploadViewModel);
%{--    });--}%
</asset:script>
<script id="iframeTemplate" type="text/html">
<h2 id="iframeTitle"><g:message code="bulkimport.stepthree.title" /></h2>
<div id="iframeContainer">
    <iframe id="createIframe" width="100%" height="800px"></iframe>
</div>
</script>
</body>
</html>