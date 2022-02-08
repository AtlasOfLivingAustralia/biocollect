<div class="row-fluid">
    <div class="span4 editable-table-header-controls-displayed-rows">
        <span data-bind="if: config.enablePaging">
            <g:message code="editableTable.row.displayed.showing.text"/>
            <select data-bind="value:displayedRowsSelected, options:displayedRowsOptions"></select>
            <g:message code="editableTable.row.displayed.rowsOf.text"/>
            <span data-bind="text:countRows"></span>
            <g:message code="editableTable.row.displayed.total.text"/>.
        </span>
        <span data-bind="ifnot: config.enablePaging">
            <g:message code="editableTable.row.displayed.showing.text"/>
            <span data-bind="text:countRows"></span>
            <g:message code="editableTable.row.displayed.total.text"/>.
        </span>
    </div>

    <div class="span4 editable-table-header-controls-displayed-page"
         data-bind="if: config.enablePaging">
        <div class="pagination pagination-centered" style="margin-top:5px;">
            <ul data-bind="foreach: displayedPages">
                <li data-bind="attr: {title:itemTitle,class:itemClass}">
                    <!-- ko ifnot: itemEnabled -->
                    <span data-bind="html: itemHtml"></span>
                    <!-- /ko -->
                    <!-- ko if: itemEnabled -->
                    <a href="#" data-bind="html: itemHtml, click: $parent.setDisplayedPage"></a>
                    <!-- /ko -->
                </li>
            </ul>
        </div>
    </div>

    <div class="span4 editable-table-header-controls-displayed-columns"
         data-bind="if: config.enableColumnSelection">
    </div>
</div>