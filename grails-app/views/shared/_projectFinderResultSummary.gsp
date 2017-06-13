<div id="pt-display-options">
    <div class="row-fluid clearfix margin-bottom-5">
        <div class="span12 ">
            <button id="pt-filter" class="btn btn-mini margin-right-10" title="${message(code: 'project.search.filter.tooltip')}"
                    data-status="1"
                    data-toggle="button"><i class="icon-align-justify"></i></button>
            <div class="text-right pull-right">
                <div class="nowrap inline-block margin-bottom-5">
                    <small><g:message code="g.sortBy"></g:message>&nbsp;</small>

                    <div class="btn-group " data-toggle="buttons-radio" id="pt-sort">
                        <button type="button" class="btn  btn-mini active"
                                data-value="dateCreatedSort">Most recent</button>
                        <button type="button" class="btn  btn-mini"
                                data-value="nameSort">Name</button>
                        <button type="button" class="btn  btn-mini"
                                data-value="_score">Relevance</button>
                        <button type="button" class="btn  btn-mini"
                                data-value="organisationSort">Organisation</button>
                    </div>
                </div>
                <div class="nowrap inline-block margin-bottom-5">
                    &nbsp;
                    <small><g:message code="g.projects"/>&nbsp;<g:message
                            code="g.perPage"/>&nbsp;</small>

                    <div class="btn-group" data-toggle="buttons-radio" id="pt-per-page">
                        <button type="button" class="btn  btn-mini active" data-value="20">20</button>
                        <button type="button" class="btn  btn-mini" data-value="50">50</button>
                        <button type="button" class="btn  btn-mini" data-value="100">100</button>
                        <button type="button" class="btn  btn-mini" data-value="500">500</button>
                    </div>
                </div>
                <div class="nowrap inline-block margin-bottom-5" id="pt-aus-world-block">
                    &nbsp;
                    <small><g:message
                            code="project.label"/>&nbsp;</small>
                    <div class="btn-group margin-bottom-5" data-toggle="buttons-radio" id="pt-aus-world">
                        <button class="btn btn-small btn-mini active" title="${message(code: 'project.australia.title')}"
                                data-toggle="button" data-value="false">${message(code: 'project.australia.text')}</button>
                        <button class="btn btn-small btn-mini" title="${message(code: 'project.worldwide.title')}"
                                data-toggle="button" data-value="true">${message(code: 'project.worldwide.text')}</button>
                    </div>
                </div>
                <div class="btn-group margin-bottom-5 margin-left-10" data-toggle="buttons-radio" id="pt-view">
                    <button class="btn btn-small" title="${message(code: 'project.tile.view.tooltip')}"
                            data-toggle="button" data-value="tileView"><i
                            class="icon-th-large"></i></button>
                    <button class="btn btn-small" title="${message(code: 'project.list.view.tooltip')}"
                            data-toggle="button" data-value="listView"><i
                            class="icon-list"></i></button>
                    <button class="btn btn-small" title="${message(code: 'project.map.view.tooltip')}"
                            data-toggle="button" data-value="mapView"><i
                            class="icon-globe"></i></button>
                </div>
                <div></div>
            </div>
        </div>

    </div>
</div>

