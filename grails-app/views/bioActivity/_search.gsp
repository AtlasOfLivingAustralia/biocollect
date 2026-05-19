<div class="row" data-bind="slideVisible: searchView()">
    <div class="col-12">
        <div class="input-group float-end">
            <input type="text"
                    class="form-control list-search-text-input"
                    data-bind="value: searchTerm, valueUpdate: 'input', enter: search"
                    placeholder="Search records"
                    aria-label="Search records"
                    aria-describedby="record-search-button"
            >

            <button class="btn btn-primary-dark"
                    type="button"
                    id="record-search-button"
                    data-bind="click: search"
            >
                <i class="fas fa-search"></i> Search
            </button>
        </div>

        <span class="search-spinner spinner ms-1 float-end">
            <i class="fa fa-spin fa-spinner"></i> Searching...
        </span>
    </div>
</div>