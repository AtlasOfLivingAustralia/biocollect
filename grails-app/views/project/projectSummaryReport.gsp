<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Project Summary | Project | MERIT</title>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>

</head>

<body>
<div class="container">

    <h1>Project Summary</h1>


    <div class="overview">
        <div class="row-fluid">
            <div class="span3 title">Project Name</div>

            <div class="span9">${project.name}</div>
        </div>

        <div class="row-fluid">
            <div class="span3 title">Recipient</div>

            <div class="span9">${project.organisationName}</div>
        </div>

        <div class="row-fluid">
            <div class="span3 title">Project start</div>

            <div class="span9"><g:formatDate format="dd MMM yyyy"
                                             date="${au.org.ala.biocollect.DateUtils.parse(project.plannedStartDate).toDate()}"/></div>
        </div>

        <div class="row-fluid">
            <div class="span3 title">Project finish</div>

            <div class="span9"><g:formatDate format="dd MMM yyyy"
                                             date="${au.org.ala.biocollect.DateUtils.parse(project.plannedEndDate).toDate()}"/></div>
        </div>
    </div>

    <h3>Project Overview</h3>

    <p>${project.description}</p>

    <h3>Activity status summary</h3>

    <g:if test="${project.activities}">
    <table class="table table-striped">
        <thead>
        <tr>
            <g:each in="${['', 'Planned', 'Started', 'Finished', 'Deferred', 'Cancelled']}" var="progress">
                <th>${progress}</th>
            </g:each>
        </tr>
        </thead>
        <tbody>
        <g:each in="${orderedStageNames}" var="stage">
            <tr>
                <th>${stage}</th>
                <g:each in="${['Planned', 'Started', 'Finished', 'Deferred', 'Cancelled']}" var="progress">
                    <td>${activityCountByStage[stage][progress.toLowerCase()] ?: 0}</td>
                </g:each>
            </tr>
        </g:each>

        </tbody>
    </table>
    </g:if>
    <g:else>
        No activities have been defined for this project.
    </g:else>

    <g:render template="dashboard"/>

</div>
</body>
</html>