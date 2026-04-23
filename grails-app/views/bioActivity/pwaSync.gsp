<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="pwa"/>
    <title>PWA sync</title>

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

        window.addEventListener('load', function () {
            window.parent && window.parent.postMessage({event: 'viewmodelloadded', data: {}}, "*");
        });
    </asset:script>
    <asset:javascript src="pwa-sync-manifest.js"/>
</head>

<body>
</body>
</html>