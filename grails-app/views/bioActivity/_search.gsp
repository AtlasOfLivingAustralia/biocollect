<div class="row-fluid">
    <div class="span12 ">
        <div class="span12 text-right">
            <button data-bind="click: toggleSearchView" class="btn btn-default btn-link">
                <i data-bind="attr:{class: searchView() ? 'icon-chevron-up' : 'icon-chevron-down'}"></i>
                <small data-bind="text: searchView() ? 'Hide ' : 'Show '"></small>
                <small>Search</small>
            </button>
        </div>
    </div>
</div>

<!-- ko if: searchView() -->
<div class="row-fluid">
        <div class="well">
            <div class="row-fluid">
                <div class="span12 ">
                    <div class="span12 text-left">
                        <div class="searchResultSection">
                            <h5>Found <span data-bind="text: total()"></span> record(s)</span>
                                <span data-bind="if: searchTerm()">matching '<span data-bind="text: searchTerm()"></span>'
                            </span></h5>
                            <input data-bind="value: searchTerm, valueUpdate: 'input'" type="text"
                                   class="input-block-level" placeholder="Search survey records"/>
                            <div class="form-inline">
                            <button data-bind="click: search" title="Only show surveys which contain the search term"
                                    id="pt-search-link" class="btn btn-primary"><i
                                    class="icon-search icon-white"></i> Search</button>
                            <button data-bind="click: reset" id="pt-search-reset" class="btn btn-default"><i
                                    class="icon-remove-circle"></i> Reset</button>
                                <div class="pull-right">
                                    <label>Sort by:
                                        <div class="btn-group" data-toggle="buttons-radio">
                                            <!-- ko foreach:sortOptions -->
                                            <button class="btn btn-info " data-bind="html:name, click: $root.sortButtonClick, css:{active:$root.sort()==id}"></button>
                                            <!-- /ko -->
                                        </div>
                                    </label>
                                </div>
                            </div>
                            <span id="search-spinner" class="spinner margin-left-1"> <i class='fa fa-spin fa-spinner'></i> Searching...</span>
                        </div>
                    </div>

                </div>
            </div>

        </div>
</div>
<!-- /ko -->
