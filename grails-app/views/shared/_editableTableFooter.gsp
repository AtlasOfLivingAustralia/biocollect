<div class="row-fluid">
    <div class="span4 editable-table-footer-controls-add-row"
         data-bind="if: config.enableAdd">
        <g:message code="editableTable.row.insert.text"/>
        <select data-bind="value:addRowSelected, options:addRowOptions"></select>
        <button type="button" class="btn btn-small"
                data-bind="click: addRow"
                title="<g:message code="editableTable.row.add.text"/>">
            <i class="icon-plus"></i>
            <g:message code="editableTable.row.add.text"/>
        </button>
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

    <div class="span4">
    </div>
</div>