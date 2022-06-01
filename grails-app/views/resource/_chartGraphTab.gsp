<div id="projectResources" class="my-4 my-md-5">
    <div class="container-fluid" id="chartId">
        <content tag="bannertitle">
            ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}
        </content>

        <div class="row mb-2">
            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label for="associatedProgram" class="input-group-text">Program</label>
                    </div>
                    <select id="associatedProgram" class="custom-select" data-bind="options: associatedPrograms, selectedOptions: associatedProgramFilterFields" size="5" multiple="true"></select>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label for="electorate" class="input-group-text">Electorate</label>
                    </div>
                    <select id="electorate" class="custom-select" data-bind="options: electorateFilterFieldOptions, selectedOptions: electorateFilterFields" size="5" multiple="true"></select>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <button id="downloadReport" class="btn btn-primary-dark" data-bind="click: function() { downloadReport() }"><i class="fas fa-download"></i> Download</button>
                </div>
            </div>
        </div>

        <!-- ko foreach: chartjsPerRowGroupedItems -->
        <div class="row" data-bind="foreach: $data">
            <div data-bind="attr: {class: $parents[1].chartjsPerRowSpan }">
                <canvas data-bind="chartjs: { facetName: 'test', type: chartType, data: data, options: options }"
                        width="2" height="2"></canvas>
            </div>
        </div>
        <!-- /ko -->
    </div>
</div>

<asset:script type="text/javascript">
    var ctx = document.getElementById('chartId');

    var reportChartjsViewModel = new ReportChartjsViewModel();
    ko.applyBindings(reportChartjsViewModel, ctx);
</asset:script>