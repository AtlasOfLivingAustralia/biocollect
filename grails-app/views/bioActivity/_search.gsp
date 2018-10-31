<div class="row-fluid" data-bind="slideVisible: searchView()">
    <div class="span12">
        <div class="margin-bottom-10">
            <div class="row-fluid">
                <div class="span12">
                    <div class="input-append pull-right">
                        <input data-bind="value: searchTerm, valueUpdate: 'input', enter: search" type="text"
                               class="form-control list-search-text-input" placeholder="Search records"/>
                        <button data-bind="click: search" title="Only show surveys which contain the search term"
                                class="btn btn-primary form-control" type="button"><i
                                class="icon-search icon-white"></i> Search</button>
                    </div>
                    <span class="search-spinner spinner margin-left-1 pull-right"> <i class='fa fa-spin fa-spinner'></i> Searching...</span>
                </div>
            </div>
        </div>
    </div>
</div>