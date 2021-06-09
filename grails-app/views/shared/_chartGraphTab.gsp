<!-- ko with: chartjsManager -->
<div class="container">
    <div class="row-fluid">
        <!-- ko foreach: chartjsList -->
        <div class="span6">
            <canvas data-bind="chartjs: { facetName: chartFacetName, type: chartType, data: chartData, options: chartOptions }" width="2" height="2"></canvas>
       </div>
       <!-- /ko -->
    </div>
</div>
<!-- /ko -->