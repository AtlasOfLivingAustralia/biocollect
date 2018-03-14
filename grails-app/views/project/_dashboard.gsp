<%@ page import="au.org.ala.biocollect.DateUtils" %>
%{-- Not using this tag as we want  a protocol-less import<gvisualization:apiImport/>--}%
<script type="text/javascript" src="//www.google.com/jsapi"></script>

<div class="project-dashboard">
    <h3>Risks and issues</h3>
    <g:if test="${project.custom?.details?.risks?.rows}">
        <!-- ko with: details -->
        <g:render template="riskTableReadOnly"/>
        <!-- /ko -->
    </g:if>
    <g:else>
        No risks have been identified for this project.
    </g:else>

    <g:if test="${project.custom?.details?.issues?.issues}">
        <!-- ko with: details.issues -->
        <g:render template="issueTableReadOnly"/>
        <!-- /ko -->
    </g:if>
    <g:else>
        No issues have been identified for this project.
    </g:else>

    <h3>Project Milestones</h3>
    <g:set var="milestones" value="${activities.findAll { it.typeCategory == 'Milestone' }}"/>
    <g:if test="${milestones}">
        <table class="milestones table-striped">
            <thead>
            <tr>
                <th class="date">Date</th>
                <th class="description">Description</th>
                <th class="status">Status</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${milestones}" var="milestone">
                <tr>
                    <td>${au.org.ala.biocollect.DateUtils.isoToDisplayFormat(milestone.plannedEndDate)}</td>
                    <td class="milestone-description">${milestone.description}</td>
                    <td class="milestone-progress">${milestone.progress}</td>
                </tr>

            </g:each>

            </tbody>
        </table>
    </g:if>
    <g:else>
        No milestones have been specified for this project.
    </g:else>

    <h3>Project Budget</h3>
    <g:render template="budgetTableReadOnly"/>

    <h3>Progress towards outcomes</h3>
    <g:if test="${project?.custom?.details?.outcomeProgress}">
        <table class="outcomes-progress table-striped">
            <thead>
            <tr>
                <th class="date">Date</th>
                <th class="type">Interim / Final</th>
                <th class="outcome-progress">Progress</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${project.custom.details.outcomeProgress}" var="outcome">

                <tr>
                    <td class="date">
                        ${DateUtils.isoToDisplayFormat(outcome.date)}
                    </td>
                    <td class="type">
                        ${outcome.type}
                    </td>
                    <td class="outcome-progress">${outcome.progress}</td>
                </tr>

            </g:each>
            </tbody>
        </table>
    </g:if>
    <g:else>
        No outcome data has been entered for this project.
    </g:else>



    <div class="project-statistics">
        <h3>Targets and metrics</h3>
        <g:set var="targets" value="${metrics.targets}"/>
        <g:set var="other" value="${metrics.other}"/>
        <g:if test="${targets || other}">

            <g:if test="${targets}">
                <h3 style="margin-top:0;">Output Targets</h3>

                <div class="row-fluid">
                <div class="span4">
                    <g:set var="count" value="${targets.size()}"/>
                    <g:each in="${targets?.entrySet()}" var="metric" status="i">
                    %{--This is to stack the output metrics in three columns, the ceil biases uneven amounts to the left--}%
                        <g:if test="${i == Math.ceil(count / 3) || i == Math.ceil(count / 3 * 2)}">
                            </div>
                            <div class="span4">
                        </g:if>
                        <div class="well">
                            <h3>${metric.key}</h3>
                            <g:each in="${metric.value}" var="score">
                                <fc:renderScore score="${score}"></fc:renderScore>
                            </g:each>
                        </div>
                    </g:each>
                </div>
                </div>
            </g:if>

            <g:if test="${other}">

                <h3>Outputs without targets</h3>

                <div class="row-fluid outputs-without-targets">
                    <g:each in="${other?.entrySet()}" var="metric" status="i">

                        <div class="well well-small">
                            <h3>${metric.key}</h3>
                            <g:each in="${metric.value}" var="score">
                                <fc:renderScore score="${score}"></fc:renderScore>
                            </g:each>
                        </div><!-- /.well -->

                    </g:each>
                </div>
            </g:if>
        </g:if>
        <g:else>
            <p>No activity or target data exists for this project.</p>
        </g:else>
    </div>
</div>
<script>

    $(document).on('dashboardShown', function () {

        var content = $('.outputs-without-targets');
        var columnized = content.find('.column').length > 0;
        if (!columnized) {
            content.columnize({columns: 2, lastNeverTallest: true, accuracy: 10});
        }

    });
</script>

