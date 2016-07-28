<div id="pt-display-options">
    <div class="row-fluid">
        <div class="span6">
            <table data-table-list>
                <tbody>
                <tr class="padding10-small-screen">
                    <td><h3 id="pt-resultsReturned"></h3></td>
                    <td>
                        <g:if test="${fc.userIsAlaOrFcAdmin()}">
                            <div>
                                <a href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning"
                                   title="${message(code: 'project.download.tooltip')}" data-bind="click: download">
                                    <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download"/></a>
                            </div>
                        </g:if>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>

    </div>

    <div class="row-fluid clearfix margin-bottom-5">
        <div class="span12 ">
            <button id="pt-filter" class="btn btn-mini" title="${message(code: 'project.search.filter.tooltip')}"
                    data-status="1"
                    data-toggle="button"><i class="icon-align-justify"></i></button>

            <div class="btn-group pull-right" data-toggle="buttons-radio" id="pt-view">
                <button class="btn btn-mini" title="${message(code: 'project.tile.view.tooltip')}"
                        data-toggle="button" data-value="tileView"><i
                        class="icon-th"></i></button>
                <button class="btn btn-mini" title="${message(code: 'project.list.view.tooltip')}"
                        data-toggle="button" data-value="listView"><i
                        class="icon-th-list"></i></button>
            </div>
        </div>

    </div>

    <div class="row-fluid clearfix margin-bottom-5">
        <div class="span12 text-right">
            <div class="pull-right margin-bottom-5">

                <div class="nowrap inline-block">
                    <small><g:message code="g.sortBy"></g:message>&nbsp;</small>

                    <div class="btn-group " data-toggle="buttons-radio" id="pt-sort">
                        <button type="button" class="btn  btn-mini active"
                                data-value="nameSort">Name</button>
                        <button type="button" class="btn  btn-mini"
                                data-value="_score">Relevance</button>
                        <button type="button" class="btn  btn-mini"
                                data-value="organisationSort">Organisation</button>
                    </div>
                </div>
                <div class="nowrap inline-block">
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
            </div>
        </div>
    </div>
</div>

