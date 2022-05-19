<div class="container" id="chartId">

    <!-- ko foreach: chartjsPerRowGroupedItems -->
    <div class="row" data-bind="foreach: $data"> <%--    <div class="row" data-bind="foreach: $data">--%>
        <div data-bind="attr: {class: $parents[1].chartjsPerRowSpan }">
            <canvas data-bind="chartjs: { facetName: 'test', type: chartType, data: data, options: options }"
                    width="2" height="2"></canvas>
        </div>
    </div>
    <!-- /ko -->

</div>

<asset:script type="text/javascript">
    var ctx = document.getElementById('chartId');

    var reportChartjsViewModel = new ReportChartjsViewModel();
    ko.applyBindings(reportChartjsViewModel, ctx);
</asset:script>