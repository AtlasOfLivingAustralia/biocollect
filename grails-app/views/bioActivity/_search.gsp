<div class="row-fluid" data-bind="slideVisible: searchView()">
    <div class="span12">
        <div class="margin-bottom-10">
            <div class="row-fluid">
                <div class="span12">
                    <span id="search-spinner" class="spinner margin-left-1 pull-right"> <i class='fa fa-spin fa-spinner'></i> Searching...</span>
                    <div class="pull-right margin-left-1">
                        <div class="btn-group" data-toggle="buttons-radio">
                            <!-- ko foreach:sortOptions -->
                            <button class="btn form-control" data-bind="html:name, click: $root.sortButtonClick, css:{active:$root.sort()==id}"></button>
                            <!-- /ko -->
                        </div>
                    </div>
                    <div class="input-append pull-right">
                        <input data-bind="value: searchTerm, valueUpdate: 'input'" type="text"
                               class="form-control list-search-text-input" placeholder="Search records"/>
                        <button data-bind="click: search" title="Only show surveys which contain the search term"
                                class="btn btn-primary form-control" type="button"><i
                                class="icon-search icon-white"></i> Search</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>