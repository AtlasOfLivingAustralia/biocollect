<div id="charts" class="my-4 my-md-5">
    <content tag="bannertitle">
        ${hubConfig.getTextForCharts(grailsApplication.config.content.defaultOverriddenLabels)}
    </content>

    <div class="container-fluid" id="chartId">
        <div class="row mb-2">
            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label for="associatedProgram" class="input-group-text">Program</label>
                    </div>
                    <select id="associatedProgram" class="custom-select" data-bind="options: associatedProgramFilterFieldOptions, optionsCaption: 'No Filters', value: associatedProgramFilterField"></select>
                    <div class="input-group-append">
                        <button id="addAssociatedProgram" class="btn btn-primary-dark" data-bind="click: addAssociatedProgram"><i class="fas fa-plus"></i> Add</button>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3 mt-1 mt-lg-0">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label for="electorate" class="input-group-text">Electorate</label>
                    </div>
                    <select id="electorate" class="custom-select" data-bind="options: electorateFilterFieldOptions, optionsCaption: 'No Filters', value: electorateFilterField"></select>
                    <div class="input-group-append">
                        <button id="addElectorate" class="btn btn-primary-dark" data-bind="click: addElectorate"><i class="fas fa-plus"></i> Add</button>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3 mt-1 mt-lg-0">
                <button id="downloadReport" class="btn btn-primary-dark" data-bind="click: downloadReport"><i class="fas fa-download"></i> Download</button>
            </div>
        </div>

        <div class="row mb-2">
            <div class="col-12">
                <div class="filter-bar d-flex align-items-center my-0">
                    <h4 class="m-0">Applied Filters: </h4>

                    <!-- ko foreach: allFilters() -->
                    <button class="filter-item btn btn-outline-dark btn-sm" data-bind="click: $parent.removeFilter"> <!-- ko text: $data.searchText --> <!-- /ko --> <i class="far fa-trash-alt"></i></button>
                    <!-- /ko -->
                    <!-- ko if: (allFilters().length > 0) -->
                    <button class="btn btn-sm btn-dark clear-filters" data-bind="click: resetAll" aria-label="Clear all filters"><i class="far fa-trash-alt"></i> Clear All</button>
                    <!-- /ko -->
                </div>
            </div>
        </div>

        <!-- ko foreach: chartjsPerRowGroupedItems -->
        <div class="row" data-bind="foreach: $data">
            <div data-bind="attr: {class: $parents[1].chartjsPerRowSpan }" class="customChart">
                <canvas class="customChartCanvas" data-bind="chartjs: { facetName: 'test', type: chartType, data: data, options: options }"
                        width="2" height="2"></canvas>
            </div>
        </div>
        <!-- /ko -->
    </div>
</div>

<asset:script type="text/javascript">
    var ctx = document.getElementById('chartId');
    Chart.register(ChartDataLabels);

    var reportChartjsViewModel = new ReportChartjsViewModel();
    ko.applyBindings(reportChartjsViewModel, ctx);
</asset:script>