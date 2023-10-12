<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="pwa"/>
    <title>PWA settings</title>
    <asset:stylesheet src="pwa-settings-manifest.css"/>
    <asset:javascript src="pwa-settings-manifest.js"/>
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
        <h1><g:message code="pwa.settings.heading"/></h1>
        <div id="storage-settings">
            <bc:koLoading>
                <h3><g:message code="pwa.settings.storage.heading"/></h3>
                <!-- ko if: supported -->
                <table class="table">
                    <tbody>
                        <tr>
                            <td colspan="2">
                                <div class="progress">
                                    <div class="progress-bar bg-success" role="progressbar" data-bind="style: {width: percentage() + '%'}, text: percentage() + '%', attr: {'aria-valuenow': percentage}" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td><g:message code="pwa.settings.storage.total"/></td>
                            <td data-bind="text: maximum"></td>
                        </tr>
                        <tr>
                            <td><g:message code="pwa.settings.storage.free"/></td>
                            <td  data-bind="text: free"></td>
                        </tr>
                        <tr>
                            <td><g:message code="pwa.settings.storage.used"/></td>
                            <td data-bind="text: used"></td>
                        </tr>
                        <tr>
                            <td><g:message code="pwa.settings.storage.totalPercentage"/></td>
                            <td  data-bind="text: percentage() + ' %'"></td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <button class="btn btn-sm btn-success" data-bind="click: refresh">
                                    <i class="fas fa-sync"></i>
                                    <g:message code="pwa.settings.storage.btn.refresh"/>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <!-- /ko -->
                <!-- ko ifnot: supported -->
                <div class="alert alert-info" role="alert">
                    <h4 class="alert-heading"><g:message code="pwa.settings.storage.alert.heading"/> </h4>
                    <p><g:message code="pwa.settings.storage.alert.message"/></p>
                </div>
                <!-- /ko -->
                <h3><g:message code="pwa.settings.manage.title"/> </h3>
                <div class="alert alert-danger" role="alert">
                    <h4 class="alert-heading"><g:message code="pwa.settings.manage.alert.heading"/> </h4>
                    <p><g:message code="pwa.settings.manage.alert.message"/></p>
                </div>
                <div class="row mb-2">
                    <div class="col-12">
                        <button class="btn btn-danger" data-bind="click: clearAll, disable: isOffline">
                            <i class="fas fa-trash"></i>
                            <g:message code="pwa.settings.manage.btn.clearAll"/>
                        </button>
                    </div>
                </div>
                <h6><g:message code="pwa.settings.manage.delete.progress"/> </h6>
                <div class="row">
                    <div class="col-12">
                        <div class="progress">
                            <div class="progress-bar bg-success" role="progressbar" data-bind="style: {width: deletePercentage() + '%'}, text: deletePercentage() + '%', attr: {'aria-valuenow': deletePercentage}" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                    </div>
                </div>
            </bc:koLoading>
        </div>
    </div>
</body>
</html>