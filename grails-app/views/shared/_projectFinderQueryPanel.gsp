<!-- ko with: filterViewModel-->
<div class="row-fluid">
    <div id="pt-selectors" class="well">
        <h4><g:message code="project.search.heading"/></h4>
        <div id="filter-buttons">
            <button class="btn btn-small facetSearch" data-bind="click: mergeTempToRefine"><i class="icon-filter"></i>Refine</button>
            <button class="btn btn-small clearFacet" data-bind="click: reset"><i class="icon-remove-sign"></i>Clear all</button>
        </div>
        <div>
            <h4 data-bind="visible: selectedFacets().length"><g:message code="project.search.currentFilters"/></h4>
            <ul>
                <!-- ko foreach:selectedFacets -->
                <li><span data-bind="text: displayName"></span><a href="#" data-bind="click: remove"><i class="icon-remove"></i></a></li>
                <!-- /ko  -->
            </ul>
        </div>
        <div id="filters-hidden">
            <div id="pt-searchControls" class="row-fluid">
                <g:if test="${hubConfig?.defaultFacetQuery.contains('isCitizenScience:true')}">
                    <g:render template="/shared/facetView"></g:render>
                </g:if>
                %{--<div class="row-fluid">--}%
                    %{--<div class="span12">--}%
                        %{--<h5><g:message code="project.search.status"/></h5>--}%

                        %{--<div class="row-fluid">--}%
                            %{--<div class="btn-group span6" data-toggle="buttons-checkbox" id="pt-status">--}%
                                %{--<g:each var="level" in="${['active', 'completed']}">--}%
                                    %{--<div>--}%
                                        %{--<button type="button" class="btn  btn-small btn-info as-checkbox"--}%
                                            %{--data-value="${level}">--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                            %{--${level.capitalize()}--}%
                                        %{--</button>--}%
                                    %{--</div>--}%
                                %{--</g:each>--}%
                            %{--</div>--}%
                        %{--</div>--}%
                    %{--</div>--}%
                %{--</div>--}%

                <div class="row-fluid">
                    <div class="span12">
                        <g:if test="${!hubConfig?.defaultFacetQuery.contains('isEcoScience:true')}">

                            %{--<h5><g:message code="project.search.difficulty"/></h5>--}%

                            %{--<div class="row-fluid">--}%
                                %{--<div class="btn-group span6" data-toggle="buttons-checkbox" id="pt-search-difficulty">--}%
                                       %{--<g:each var="level" in="${['easy', 'medium', 'hard']}">--}%
                                           %{--<div>--}%
                                            %{--<button type="button" class="btn  btn-small btn-info as-checkbox"--}%
                                                    %{--data-value="${level}">--}%
                                                %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                                %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                                %{--${level.capitalize()}--}%
                                            %{--</button>--}%
                                           %{--</div>--}%
                                        %{--</g:each>--}%
                                    %{--</div>--}%
                            %{--</div>--}%
                        </g:if>
                        <g:else>
                            <h5><g:message code="project.search.programName"/></h5>

                            <div class="row-fluid">
                                <div class="span12">
                                    <g:if test="${associatedPrograms}">
                                        <g:each var="program" in="${associatedPrograms}">
                                            <div>
                                                <button type="button" class="btn btn-small btn-info as-checkbox" data-value="${program}"
                                                    data-toggle="button"
                                                    id="pt-search-program-${program.name.replace(' ', '-')}">
                                                <i class="pull-left toggleIndicator fa fa-check-square-o"></i>
                                                <i class="pull-left toggleIndicator fa fa-square-o"></i>
                                                ${program.name.capitalize()}
                                                </button>
                                            </div>
                                        </g:each>
                                    </g:if>
                                </div>
                            </div>
                        </g:else>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span12" id="pt-tags">
                        <g:if test="${controllerName != 'organisation'}">
                            %{--<h5>Tags</h5>--}%

                            %{--<div class="row-fluid">--}%
                                %{--<div class="span12">--}%
                                    %{--<g:if test="${!hubConfig?.defaultFacetQuery.contains('isEcoScience:true')}">--}%
                                        %{--<div class="row-fluid">--}%
                                            %{--<div data-bind="visible:count, attr:{title:displayName}" class="as-checkbox">--}%
                                                %{--<input type="checkbox" data-bind="checked: checked" style="display: inline-block;">--}%
                                                %{--<a href="#" class="inline-flex " data-bind="click: filterNow">--}%
                                                    %{--<span class="label-ellipsis" data-bind="text:displayName"></span>--}%
                                                %{--</a>--}%
                                            %{--</div>--}%
                                        %{--</div>--}%

                                        %{--<div>--}%
                                        %{--<button id="pt-search-diy" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                                %{--data-toggle="button">--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                            %{--<g:message code="project.tag.diy"/>--}%
                                        %{--</button>--}%
                                        %{--</div>--}%
                                        %{--<div>--}%
                                        %{--<button id="pt-search-noCost" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                                %{--data-toggle="button">--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                            %{--<g:message code="project.tag.noCost"/></button>--}%
                                        %{--</div>--}%
                                        %{--<div>--}%
                                        %{--<button id="pt-search-teach" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                                %{--data-toggle="button">--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                            %{--<g:message code="project.tag.teach"/> </button>--}%
                                        %{--</div>--}%
                                        %{--<div>--}%
                                        %{--<button id="pt-search-children" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                                %{--data-toggle="button">--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                            %{--<g:message code="project.tag.children"/> </button>--}%
                                        %{--</div>--}%
                                    %{--</g:if>--}%
                                    %{--<div>--}%
                                    %{--<button id="pt-search-mobile" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                            %{--data-toggle="button">--}%
                                        %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                        %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                        %{--<g:message code="g.mobileApps"/> </button>--}%
                                    %{--</div>--}%
                                    %{--<div>--}%
                                    %{--<button id="pt-search-dataToAla" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                            %{--data-toggle="button">--}%
                                        %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                        %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                        %{--<g:message code="g.dataToAla"/> </button>--}%
                                    %{--</div>--}%
                                    %{--<div>--}%
                                        %{--<button id="pt-search-isHome" type="button" class="btn btn-info as-checkbox btn-small"--}%
                                                %{--data-toggle="button">--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-check-square-o"></i>--}%
                                            %{--<i class="pull-left toggleIndicator fa fa-square-o"></i>--}%
                                            %{--<g:message code="project.tag.home"/> </button>--}%
                                    %{--</div>--}%
                                %{--</div>--}%
                            %{--</div>--}%
                        </g:if>
                        <g:elseif test="${controllerName == 'organisation'}">
                            <h5><g:message code="project.search.projecttype"/></h5>

                            <div class="row-fluid">
                                <div class="span12">
                                    <div class="btn-group span6" data-toggle="buttons-checkbox"
                                         id="pt-search-projecttype">
                                        <div>
                                        <button type="button" class="btn  btn-small btn-info as-checkbox active"
                                                data-toggle="button"
                                                data-value="citizenScience">
                                            <i class="pull-left toggleIndicator fa fa-check-square-o"></i>
                                            <i class="pull-left toggleIndicator fa fa-square-o"></i>
                                            Citizen Science </button>
                                        </div>
                                        <div>
                                        <button type="button" class="btn  btn-small btn-info as-checkbox active"
                                                data-toggle="button"
                                                data-value="works">
                                            <i class="pull-left toggleIndicator fa fa-check-square-o"></i>
                                            <i class="pull-left toggleIndicator fa fa-square-o"></i>
                                            NRM </button>
                                        </div>
                                        <div>
                                        <button type="button" class="btn  btn-small btn-info as-checkbox active"
                                                data-toggle="button"
                                                data-value="biologicalScience">
                                            <i class="pull-left toggleIndicator fa fa-check-square-o"></i>
                                            <i class="pull-left toggleIndicator fa fa-square-o"></i>
                                            Biological Science</button>
                                        </div>
                                        <div>
                                        <button type="button" class="btn  btn-small btn-info as-checkbox active"
                                                data-toggle="button"
                                                data-value="merit">
                                            <i class="pull-left toggleIndicator fa fa-check-square-o"></i>
                                            <i class="pull-left toggleIndicator fa fa-square-o"></i>
                                            MERIT </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </g:elseif>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span12">
                    <h5><g:message code="project.search.geoFilter"/></h5>
                    <div class="row-fluid">
                        <!-- Trigger the modal with a button -->
                        <button id="filterByRegionButton" type="button" class="btn btn-small btn-info margin-bottom-2" data-toggle="modal" data-target="#mapModal"><g:message code="project.search.mapToggle"/></button>

                        <!-- Modal -->
                        %{--inline style is required as the first time so the modal does not block other components on screen--}%
                        %{--Looks like a bug in Bootstrap--}%
                        <div id="mapModal" class="modal fade" role="dialog" style="display: none; ">
                            <div class="modal-dialog ">

                                <!-- Modal content-->
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                                        <h4 class="modal-title"><g:message code="project.search.mapToggle"/></h4>
                                    </div>
                                    <div class="modal-body">
                                        <m:map id="mapFilter" width="100%"/>
                                    </div>
                                    <div class="modal-footer">
                                        <button id="clearFilterByRegionButton" type="button" class="btn btn-small btn-info"
                                                 ><g:message code="project.search.mapClear"/><i
                                                class="pull-left toggleIndicator icon-remove icon-white"></i></button>
                                        <button type="button" class="btn btn-primary btn-small" data-dismiss="modal"><g:message code="project.search.mapClose"/><i
                                                class="pull-left toggleIndicator icon-remove icon-white"></i></button>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="pull-right" id="pt-control-buttons">
                    <button id="pt-reset" class="btn btn-primary" ><i class="icon-white icon-remove"></i> <g:message
                            code="g.resetSearch"/></button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->