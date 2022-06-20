<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:set var="title" value="${hubConfig.getTextForCharts(grailsApplication.config.content.defaultOverriddenLabels)}"/>
    <title>${title}</title>
    <meta name="layout" content="bs4"/>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/')},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <asset:script type="text/javascript">
        var fcConfig = {
            getChartConfigUrl: "${createLink(controller: 'report', action: 'getChartConfig')}",
            genericReportUrl: "${createLink(controller: 'report', action: 'genericReport')}",
            populateAssociatedProgramsUrl: "${createLink(controller: 'report', action: 'populateAssociatedPrograms')}",
            populateElectoratesUrl: "${createLink(controller: 'report', action: 'populateElectorates')}",
            downloadReportUrl: "${createLink(controller: 'report', action: 'downloadReport')}"
        }
    </asset:script>
    <asset:javascript src="chart-manifest.js"/>
</head>
<body>

<g:render template="/report/chartGraphTab"/>

</body>
</html>