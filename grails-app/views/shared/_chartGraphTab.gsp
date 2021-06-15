<!-- ko with: chartjsManager -->
<div class="container">

    <!-- ko ifnot: chartjsListShow -->
    <p>None of the filters are set to display charts.</p>
    <!-- /ko -->

    <!-- ko if: chartjsListShow -->
    <p>
        <g:message code="project.search.graphTab.intro"/>

        Show
        <select style="width:50px;" data-bind="options: chartjsPerRowOptions, value: chartjsPerRowSelected"></select>
        charts per line.
    </p>

    <!-- ko foreach: chartjsPerRowGroupedItems -->
    <div class="row-fluid" data-bind="foreach: $data">
        <div data-bind="attr: {class: $parents[1].chartjsPerRowSpan }">
            <canvas data-bind="chartjs: { facetName: chartFacetName, type: chartType, data: chartData, options: chartOptions }"
                    width="2" height="2"></canvas>
        </div>
    </div>
    <!-- /ko -->

    <!-- /ko -->
</div>
<!-- /ko -->