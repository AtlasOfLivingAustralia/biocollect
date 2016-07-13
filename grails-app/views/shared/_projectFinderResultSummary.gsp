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


