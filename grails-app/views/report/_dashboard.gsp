<g:if test="${metadata.projects.size() > 1}">
    <p>
        Data presented in this dashboard has been extracted from grant recipient progress reports approved by the Department of the Environment. While efforts are made to ensure the accuracy of the ecological information contained in MERIT, for confirmation of authoritative data please contact the <g:createLink
                controller="home"
                action="contacts">Department of Environment</g:createLink>. Also note that dashboard data for Biodiversity Fund Round One are incomplete due to legacy issues.
    </p>

    <div class="accordion" id="reports">
        <g:each in="${categories}" var="category" status="i">

            <g:set var="categoryContent" value="category_${i}"/>
            <div class="card">
                <div class="card-header">
                    <button class="btn btn-link btn-block" data-toggle="collapse" data-parent="#reports"
                       data-target="#${categoryContent}">
                        ${category} <g:if test="${!scores[category]}"><span class="float-right"
                                                                            style="font-weight:normal">[no data available]</span></g:if>

                    </button>
                </div>

                <div id="${categoryContent}" class="outputData collapse show">
                    <div class="card-body">
                        <g:if test="${scores[category]}">
                            <div class="col-md-6" style="min-width: 460px;">

                                <g:each in="${scores[category][0]}" var="categoryScores">

                                    <g:each in="${categoryScores}" var="outputScores">

                                        <div class="card">
                                            <div class="card-body">
                                                <h3 class="card-title">${outputScores.key}</h3>
                                                <g:each in="${outputScores.value}" var="score">
                                                    <fc:renderScore score="${score}"></fc:renderScore>
                                                </g:each>
                                            </div>
                                        </div>
                                    </g:each>

                                </g:each>
                            </div>

                            <div class="col-md-6" style="min-width: 460px;">

                                <g:each in="${scores[category][1]}" var="categoryScores">

                                    <g:each in="${categoryScores}" var="outputScores">

                                        <div class="card">
                                            <div class="card-body">
                                                <h3 class="card-title">${outputScores.key}</h3>
                                                <g:each in="${outputScores.value}" var="score">
                                                    <fc:renderScore score="${score}"></fc:renderScore>
                                                </g:each>
                                            </div>
                                        </div>

                                    </g:each>

                                </g:each>
                            </div>
                        </g:if>
                        <g:else>
                            There is no data available for this category.<br/>
                        </g:else>
                    </div>
                </div>

            </div>
        </g:each>

        <div id="metadata">
            results include approved reported data from ${metadata.projects.size()} projects, ${metadata.sites} sites and ${metadata.activities} activities

        </div>

    </div>

</g:if>
<g:else>
    <div class="alert alert-danger">
        Not enough data was returned to display summary data for your facet selection.
    </div>
</g:else>
