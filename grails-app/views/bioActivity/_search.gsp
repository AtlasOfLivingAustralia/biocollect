<div class="row" data-bind="slideVisible: searchView()">
    <div class="col-12">
        <div class="input-group float-right">
            <input type="text" class="form-control list-search-text-input"
                   data-bind="value: searchTerm, valueUpdate: 'input', enter: search"
                   placeholder="Search records" aria-label="Search records"
                   aria-describedby="record-search-button">

            <div class="input-group-append">
                <button class="btn btn-primary-dark" type="button" id="record-search-button" data-bind="click: search">
                    <i class="fas fa-search"></i> Search
                </button>
            </div>
        </div>
        <span class="search-spinner spinner margin-left-1 float-right"><i
                class='fa fa-spin fa-spinner'></i> Searching...</span>
    </div>
</div>
