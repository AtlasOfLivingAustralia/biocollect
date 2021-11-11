<%--
  Created by IntelliJ IDEA.
  User: god08d
  Date: 11/12/17
  Time: 4:33 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Programme Report</title>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <g:set var="fluidLayout" value="false"/>
</head>

<body>
<div class="container">
    <h1>Program Overview</h1>

    <h3>Project Status by type of project</h3>

    <div class="row">
        <g:each in="${projectStatusByType}" var="type">
            <div class="col-md-4">
                <fc:renderScore score="${type.value}" minResults="1" chartOptions="${[pieSliceText: 'value']}" order="${["Current", "Finished"]}" sliceColoursByTitle="${["Current":"#2ECC40", "Finished":"#0074D9"]}"/>
            </div>
        </g:each>

    </div>

    <h3>Risks and Issues</h3>

    <div class="row">
        <div class="col-md-6">

            <fc:renderScore score="${issueCountByImpact}" minResults="1" chartOptions="${[pieSliceText: 'value']}" order="${["Low", "Moderate", "Significant", "Critical"]}" sliceColoursByTitle="${["Low":"#0074D9", "Moderate":"#2ECC40", "Significant":"#FFDC00", "Critical":"#FF4136"]}"/>
        </div>

        <div class="col-md-6">
            <fc:renderScore score="${riskCountByRating}" minResults="1" chartOptions="${[pieSliceText: 'value']}" order="${["Low", "Medium", "Significant", "High"]}" sliceColoursByTitle="${["Low":"#0074D9", "Medium":"#2ECC40", "Significant":"FFDC00", "High":"#FF4136"]}"/>
        </div>
    </div>

    <h3>Project budgets</h3>

    <div class="row">
        <div class="col-12">
            <fc:renderScore score="${budgetByYear}" minResults="1"/>
        </div>
    </div>

</div>
</body>
</html>