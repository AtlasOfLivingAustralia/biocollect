<table data-table-list>
    <tbody>
    <tr class="padding10-small-screen">
        <td><h3 id="pt-resultsReturned"></h3></td>
        <td>
            <g:if test="${fc.userIsAlaOrFcAdmin()}">
                <div>
                    <a href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning"
                       title="${message(code:'project.download.tooltip')}" data-bind="click: download">
                        <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download" /></a>
                </div>
            </g:if>
        </td>
    </tr>
    </tbody>
</table>
