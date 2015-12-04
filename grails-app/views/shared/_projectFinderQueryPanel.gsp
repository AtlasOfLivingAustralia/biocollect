<g:if test="${showSearch}">
    <div class="row-fluid">
        <g:render template="/shared/projectFinderQueryInput"/>
    </div>
</g:if>
<div class="row-fluid">
    <div id="pt-selectors" class="well" style="display:none">
        <div id="filters-hidden">
            <div id="pt-searchControls" class="row-fluid">
                <div id="pt-sortWidgets" class="span8">
                    <div class="row-fluid">
                        <div class="span6">
                            <h5><g:message code="g.sortBy"></g:message> </h5>
                            <div class="row-fluid">
                                <div class="btn-group span12" data-toggle="buttons-radio" id="pt-sort">
                                    <button type="button" class="btn  btn-small btn-info active" data-value="nameSort">Name</button>
                                    <button type="button" class="btn  btn-small btn-info" data-value="_score">Relevance</button>
                                    <button type="button" class="btn  btn-small btn-info" data-value="organisationSort">Organisation</button>
                                </div>
                            </div>
                        </div>
                        <div class="span6">
                            <h5><g:message code="g.projects"/>&nbsp;<g:message code="g.perPage"/> </h5>
                            <div class="row-fluid">
                                <div class="btn-group span12" data-toggle="buttons-radio" id="pt-per-page">
                                    <button type="button" class="btn  btn-small btn-info active" data-value="20">20</button>
                                    <button type="button" class="btn  btn-small btn-info" data-value="50">50</button>
                                    <button type="button" class="btn  btn-small btn-info" data-value="100">100</button>
                                    <button type="button" class="btn  btn-small btn-info" data-value="500">500</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span6">
                            <h5><g:message code="project.search.status"/></h5>
                            <div class="row-fluid">
                                <div class="btn-group span6" data-toggle="buttons-checkbox" id="pt-status">
                                    <g:each var="level" in="${['active','completed']}">
                                        <button type="button" class="btn  btn-small btn-info" data-value="${level}">${level.capitalize()} <i class="toggleIndicator icon-remove icon-white"></i></button>
                                    </g:each>
                                </div>
                            </div>
                        </div>
                        <div class="span6">
                            <h5><g:message code="project.search.difficulty"/> </h5>
                            <div class="row-fluid">
                                <div>
                                    <div class="btn-group span6" data-toggle="buttons-checkbox" id="pt-search-difficulty">
                                        <g:each var="level" in="${['easy','medium','hard']}">
                                            <button type="button" class="btn  btn-small btn-info" data-value="${level}">${level.capitalize()} <i class="toggleIndicator icon-remove icon-white"></i></button>
                                        </g:each>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="span4" id="pt-tags">
                    <g:if test="${controllerName != 'organisation'}">
                        <h5>Tags</h5>
                        <div class="row-fluid">
                            <div class="span12">
                                <button id="pt-search-diy" type="button" class="btn btn-info btn-small" data-toggle="button"><g:message code="project.tag.diy" /> <i class="toggleIndicator icon-remove icon-white"></i> </button>
                                <button id="pt-search-noCost" type="button" class="btn btn-info btn-small" data-toggle="button"><g:message code="project.tag.noCost" /> <i class="toggleIndicator icon-remove icon-white"></i></button>
                                <button id="pt-search-teach" type="button" class="btn btn-info btn-small" data-toggle="button"><g:message code="project.tag.teach" /> <i class="toggleIndicator icon-remove icon-white"></i></button>
                                <button id="pt-search-children" type="button" class="btn btn-info btn-small" data-toggle="button"><g:message code="project.tag.children" /> <i class="toggleIndicator icon-remove icon-white"></i></button>
                                <button id="pt-search-mobile" type="button" class="btn btn-info btn-small" data-toggle="button"><g:message code="g.mobileApps" /> <i class="toggleIndicator icon-remove icon-white"></i></button>
                            </div>
                        </div>
                    </g:if>
                    <g:elseif test="${controllerName == 'organisation'}">
                        <h5><g:message code="project.search.projecttype" /></h5>
                        <div class="row-fluid">
                            <div class="span12">
                                <div class="btn-group span6" data-toggle="buttons-checkbox" id="pt-search-projecttype">
                                    <button type="button" class="btn  btn-small btn-info active" data-value="citizenScience">Citizen Science <i class="toggleIndicator icon-remove icon-white"></i></button>
                                    <button type="button" class="btn  btn-small btn-info active" data-value="works">NRM <i class="toggleIndicator icon-remove icon-white"></i></button>
                                    <button type="button" class="btn  btn-small btn-info active" data-value="survey">MERIT <i class="toggleIndicator icon-remove icon-white"></i></button>
                                </div>
                            </div>
                        </div>
                    </g:elseif>
                </div>
            </div>

            <h5><g:message code="project.search.geoFilter" /></h5>
            <div class="row-fluid">
                <button id="pt-map-filter" type="button" class="btn btn-small btn-info margin-bottom-2" data-toggle="button"><g:message code="project.search.mapToggle"/><i class="toggleIndicator icon-remove icon-white"></i></button>

                <div id="pt-map-filter-panel" class="hide">
                    <m:map id="mapFilter" width="100%"/>
                </div>
            </div>


            <div class="row-fluid">
                <button class="btn btn-primary pull-right" id="pt-reset"><i class="icon-white icon-remove"></i> <g:message code="g.resetSearch" /></button>
                <button class="btn btn-default pull-right" id="pt-collapse"><i class="icon-white icon-arrow-up"></i> <g:message code="g.collapseFilter" /></button>
            </div>
        </div>
    </div>
</div>