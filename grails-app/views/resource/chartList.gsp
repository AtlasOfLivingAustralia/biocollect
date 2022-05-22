<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="bs4"/>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/')},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:stylesheet src="data-manifest.css"/>
    <asset:script type="text/javascript">
        var fcConfig = {
            chartPopulateUrl: "${createLink(controller: 'document', action: 'populateChartData')}",
            reportConfigUrl: "${createLink(controller: 'document', action: 'getReportConfig')}",
        }
    </asset:script>
    <asset:javascript src="chartjs/chart.min.js"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="chartjsManager.js"/>
</head>
<body>

<div class="main-content">
    <g:render template="/resource/chartGraphTab"/>
</div>

</body>
</html>