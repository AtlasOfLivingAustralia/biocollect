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
                            <h5>Found <span data-bind="text: total()"></span> record<span data-bind="if: total() >= 2">s</span>
                                <span data-bind="if: searchTerm()">matching '<span data-bind="text: searchTerm()"></span>'
                            </span></h5>
                            <input data-bind="value: searchTerm, valueUpdate: 'input'" type="text"
                                   class="input-block-level" placeholder="Search survey records"/>
                            <button data-bind="click: search" title="Only show surveys which contain the search term"
                                    id="pt-search-link" class="btn btn-primary"><i
                                    class="icon-search icon-white"></i> Search</button>
                            <button data-bind="click: reset" id="pt-search-reset" class="btn btn-primary"><i
                                    class="icon-remove-circle icon-white"></i> Reset</button>
                            <button id="pt-filter" data-bind="click: toggleFilter" class="btn btn-primary"
                                    data-toggle="button">
                                <i data-bind="attr:{class: filter() ? 'icon-chevron-up icon-white' : 'icon-chevron-down icon-white'}"></i> Filter</button>
                            <span id="search-spinner" class="spinner"><i class='fa fa-spin fa-spinner'></i></span>
                        </div>
                    </div>

                </div>
            </div>
            <!-- ko if: filter() -->
            <div class="row-fluid">
                <div class="span12 pull-right">
                    <div class="span8 text-left"></div>

                    <div class="span2 text-right">
                        <label>Sort by:</label>
                        <select class="input-small"
                                data-bind="value:sort, options:sortOptions, optionsText:'name', optionsValue:'id'"></select>
                    </div>

                    <div class="span2 text-right">
                        <label>Sort order:</label>
                        <select class="input-small"
                                data-bind="value:order, options:orderOptions, optionsText:'name', optionsValue:'id'"></select>
                    </div>
                </div>
            </div>
            <!-- /ko -->
        </div>
</div>
<!-- /ko -->
