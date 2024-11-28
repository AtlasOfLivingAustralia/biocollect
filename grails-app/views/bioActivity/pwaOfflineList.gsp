<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="pwa"/>
    <title>List activities</title>
    <asset:stylesheet src="pwa-offline-list-manifest.css"/>
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
            noImageUrl: "${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}",
            pwaAppUrl: "${grailsApplication.config.getProperty('pwa.appUrl')}",
            isCaching: ${params.getBoolean('cache', false)},
            enableOffline: true
        };
    </asset:script>
</head>

<body>
    <div class="container">
        <h1><g:message code="pwa.unpublished.heading"/></h1>
        <bc:koLoading></bc:koLoading>
        <!-- ko template: {name: 'page-actions-buttons', data: $data } --><!-- /ko -->
        <!-- ko template: {name: 'template-unpublished-records', data: $data } --><!-- /ko -->
        <!-- ko template: {name: 'page-actions-buttons', data: $data } --><!-- /ko -->
    </div>
    <script id="page-actions-buttons" type="text/html">
        <div class="my-2 float-right">
            <button type="button" class="btn btn-success upload-records" disabled data-bind="click: uploadAllHandler, disable: disableUpload()"><i class="fas fa-upload"></i> <g:message code="pwa.upload.all"/></button>
            <!-- ko if: transients.isProjectActivity -->
            <a class="btn btn-primary" id="create-activity" data-bind="attr: {href: transients.addActivityUrl()}">	<i class="fas fa-plus"></i> <g:message code="pwa.add.records"/></a>
            <!-- /ko -->
        </div>
    </script>
    <script id="template-unpublished-records" type="text/html">
    <div class="table-responsive">
        <table id="offlineList" class="table">
            <thead>
            <tr>
                <th><g:message code="pwa.offlinelist.image.heading"/></th>
                <th><g:message code="pwa.offlinelist.surveydate.heading"/></th>
                <th><g:message code="pwa.offlinelist.species.heading"/></th>
                <th><g:message code="pwa.offlinelist.actions.heading"/></th>
            </tr>
            </thead>
            <tbody>
            <!-- ko foreach: activities -->
            <tr data-bind="style: { opacity: uploading() ? 0.5 : 1 }">
                <td>
                    <!-- ko if: featureImage() -->
                    <div class="project-logo" data-bind="">
                        <img class="image-logo image-window" onload="findLogoScalingClass(this, 200, 150)"
                             data-bind="attr: {src: featureImage().thumbnailUrl}" alt="<g:message code="pwa.offlinelist.record.image.alt"/>"/>
                    </div>
                    <!-- /ko -->
                    <!-- ko ifnot: featureImage() -->
                    <div class="project-logo">
                        <img class="image-logo image-window" onload="findLogoScalingClass(this, 200, 150);"
                             data-bind="attr: {src: fcConfig.noImageUrl}" alt="<g:message code="pwa.offlinelist.record.noimage.alt"/>"/>
                    </div>
                    <!-- /ko -->
                </td>
                <td>
                    <span data-bind="text: convertToSimpleDate(surveyDate())"></span>
                </td>
                <td>
                    <ol data-bind="foreach: species">
                        <li data-bind="text: name"></li>
                    </ol>
                </td>
                <td class="btn-space">
                    <button class="btn btn-success btn-sm upload-record" disabled data-bind="click: upload, enable: $parent.online, disable: disableUpload"><i class="fas fa-upload"></i> <g:message code="label.upload"/></button>
                    <a class="btn btn-primary btn-sm view-record" data-bind="attr: {href: transients.viewActivityUrl()}, disable: uploading"><i class="far fa-eye"></i> <g:message code="label.view"/></a>
                    <a class="btn btn-dark btn-sm edit-record" data-bind="attr: {href: transients.editActivityUrl()}, disable: uploading"><i class="fas fa-pencil-alt"></i> <g:message code="label.edit"/></a>
                    <button class="btn btn-danger btn-sm delete-record" data-bind="click: deleteActivity, enable: $parent.online, disable: uploading"><i class="far fa-trash-alt"></i> <g:message code="label.delete"/></button>
                </td>
            </tr>
            <!-- /ko -->
            <!-- ko if: activities().length == 0 -->
            <tr>
                <td colspan="4">
                    <div class="alert alert-info" role="alert">
                        <g:message code="pwa.activities.empty.msg"/>
                    </div>
                </td>
            </tr>
            <!-- /ko -->
            </tbody>
        </table>
    </div>
    <g:render template="/shared/pagination" model="[bs:4]"/>
    </script>
</body>
</html>