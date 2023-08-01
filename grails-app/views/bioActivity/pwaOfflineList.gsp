<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="pwa"/>
    <title>List activities</title>
    <asset:stylesheet src="common-bs4.css"/>
    <asset:javascript src="pwa-offline-list-manifest.js"/>
    <asset:script>
        var fcConfig = {
            siteUrl: "/ws/site",
            addActivityUrl: "/pwa/bioActivity/edit",
            activityViewUrl: "/pwa/bioActivity/index",
            activityEditUrl: "/pwa/bioActivity/edit",
            imageUploadUrl: "/ws/attachment/upload",
            bioActivityUpdate: "/ws/bioactivity/save",
            updateSiteUrl: "/ws/bioactivity/site",
            pwaAppUrl: "${grailsApplication.config.getProperty('pwa.appUrl')}",
            isCaching: ${params.getBoolean('cache', false)},
            isPWA: true
        };
    </asset:script>
</head>

<body>
    <div class="container">
        <h1><g:message code="pwa.unpublished.heading"/></h1>
        <bc:koLoading>
        <!-- ko template: {name: 'page-actions-buttons', data: $data } --><!-- /ko -->
        <table class="table">
            <thead>
            <tr>
                <th>Image</th>
                <th>Species</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <!-- ko foreach: activities -->
            <tr data-bind="">
                <td>
                    <div class="project-logo" data-bind="if: featureImage()">
                        <img class="image-logo image-window" onload="findLogoScalingClass(this, 200, 150)"
                             data-bind="attr: {src: featureImage().thumbnailUrl}"/>
                    </div>
                </td>
                <td>
                    <ol data-bind="foreach: species">
                        <li data-bind="text: name"></li>
                    </ol>
                </td>
                <td>
                    <a class="btn btn-primary" data-bind="attr: {href: transients.viewActivityUrl()}">View</a>
                    <a class="btn btn-dark" data-bind="attr: {href: transients.editActivityUrl()}">Edit</a>
                    <button class="btn btn-dark" data-bind="click: upload, enable: $parent.online">Upload</button>
                </td>
            </tr>
            <!-- /ko -->
            <tr data-bind="if : activities().length == 0">
                <td colspan="3">
                    <div class="alert alert-info" role="alert">
                        <g:message code="pwa.activities.empty.msg"/>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
        <g:render template="/shared/pagination" model="[bs:4]"/>
        <!-- ko template: {name: 'page-actions-buttons', data: $data } --><!-- /ko -->
        </bc:koLoading>
    </div>
    <script id="page-actions-buttons" type="text/html">
        <div class="my-2 float-right">
%{--            <label class="form-check-label"><g:message code="pwa.buttons.actions"/></label>--}%
            <button type="button" class="btn btn-primary" data-bind="click: uploadAllHandler, disable: activities().length == 0"><i class="fas fa-upload"></i> <g:message code="pwa.upload.all"/></button>
            <!-- ko if: transients.isProjectActivity -->
            <a class="btn btn-primary" id="create-activity" data-bind="attr: {href: transients.addActivityUrl()}">	<i class="fas fa-plus"></i> <g:message code="pwa.add.records"/></a>
            <!-- /ko -->
        </div>
    </script>
</body>
</html>