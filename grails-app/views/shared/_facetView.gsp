<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach: facets -->
        <div class="row-fluid" data-bind="visible: isAnyTermVisible">
            <button data-bind="click: toggleState" class="btn btn-block btn-text-left">
                &nbsp;
                <i data-bind="css: {'icon-plus': state() == 'Collapsed', 'icon-minus': state() == 'Expanded'}"></i>
                <strong data-bind="text: displayName"></strong>
                <a href="#" tabindex="-1" data-bind="visible: helpText, popover: {placement:'right', content: helpText }">
                    <i class="icon-question-sign">&nbsp;</i>
                </a>
            </button>
            <div data-bind="slideVisible: state() == 'Expanded'" class="margin-top-5">
                <!-- ko foreach: terms -->
                <label class="control-label checkbox" data-bind="visible: !refined()">
                    <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                    <span class="label-ellipsis" data-bind="text:displayName, click: filterNow, attr:{title: displayName}"></span>
                </label>
                <!-- /ko -->
                <a href="#" role="button" class="moreFacets tooltips" data-toggle="modal" title="" data-target="#chooseMore"
                   data-original-title="View full list of values" data-bind="click: loadMoreTerms, visible: showChooseMore()">
                    <i class="fa fa-hand-o-right"></i> choose more...
                </a>
            </div>
        </div>
        &nbsp;
        <!-- /ko -->
    </div>
</div>
<!-- Modal -->
%{--inline style is required as the first time so the modal does not block other components on screen--}%
%{--Looks like a bug in Bootstrap--}%
<div id="chooseMore" class="modal fade" role="dialog" style="display: none; ">
    <div class="modal-dialog ">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <span class="modal-title" data-bind="text: displayTitle('<g:message code="facet.dialog.more.title" default="Filter by"/>')"></span>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="input-append control-label pull-right">
                        <input type="text" placeholder="Search" data-bind="value: searchText"><button class="btn"><i class="icon-filter"></i></button>
                    </div>
                </div>
                <!-- ko foreach: showMoreTermList -->
                <label class="control-label checkbox" data-bind="visible: !refined(), visible: showTerm">
                    <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                    <span class="label-ellipsis" data-bind="text:displayName, click: filterNow, attr:{title: displayName}" data-dismiss="modal"></span>
                </label>
                <!-- /ko -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-small" data-bind="click: includeSelection"
                        data-dismiss="modal">
                    <i class="icon-plus"></i>
                    <g:message code="facet.dialog.more.include" default="INCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-small" data-bind="click: excludeSelection"
                        data-dismiss="modal">
                    <i class="icon-minus"></i>
                    <g:message code="facet.dialog.more.exclude" default="EXCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-danger btn-small" data-dismiss="modal">
                        <i class="icon-remove icon-white"></i>
                        <g:message code="facet.dialog.more.close" default="Close"/>
                </button>
            </div>
        </div>

    </div>
</div>