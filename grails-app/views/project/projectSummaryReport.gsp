<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Project Summary | ${project.name}</title>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <asset:stylesheet src="projects-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="projects-manifest.js"/>
</head>

<body>
<div class="container">

    <h1>Project Summary</h1>


    <div class="overview">
        <div class="row">
            <div class="col-sm-3 title">Project Name</div>

            <div class="col-sm-9">${project.name}</div>
        </div>

        <div class="row">
            <div class="col-sm-3 title">Recipient</div>

            <div class="col-sm-9">${project.organisationName}</div>
        </div>

        <div class="row">
            <div class="col-sm-3 title">Project start</div>

            <div class="col-sm-9"><g:formatDate format="dd MMM yyyy"
                                             date="${au.org.ala.biocollect.DateUtils.parse(project.plannedStartDate).toDate()}"/></div>
        </div>

        <g:if test="${project.plannedEndDate}">
            <div class="row">
                <div class="col-sm-3 title">Project finish</div>

                <div class="col-sm-9"><g:formatDate format="dd MMM yyyy"
                                                 date="${au.org.ala.biocollect.DateUtils.parse(project.plannedEndDate).toDate()}"/></div>
            </div>
        </g:if>
    </div>

    <h3 class="mt-3">Project Overview</h3>

    <p>${project.description}</p>

    <h3>Activity status summary</h3>

    <g:if test="${activities}">
        <div class="project-dashboard">
            <table class="table table-bordered table-striped">
                <thead class="thead-dark">
                <tr>
                    <th>From</th>
                    <th>To</th>
                    <th>Description</th>
                    <th>Activity</th>
                    <th>Site</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${activities}" var="activity">
                    <tr class="${activity.typeCategory}">
                        <td>${au.org.ala.biocollect.DateUtils.isoToDisplayFormat(activity.plannedStartDate)}</td>
                        <td>${au.org.ala.biocollect.DateUtils.isoToDisplayFormat(activity.plannedEndDate)}</td>
                        <td>${activity.description ?: ''}</td>
                        <td>${activity.type}</td>
                        <td>${activity.siteName}</td>
                        <td>${activity.progress}</td>
                    </tr>
                </g:each>

                </tbody>
            </table>
        </div>
    </g:if>
    <g:else>
        No activities have been defined for this project.
    </g:else>

    <div class="mt-3">
        <g:render template="dashboard"/>
    </div>

</div>

<asset:script type="text/javascript">
var project = <fc:modelAsJavascript model="${project}"/>;
var viewModel = new MERIPlan(project, '');
ko.applyBindings(viewModel);

</asset:script>
</body>
</html>