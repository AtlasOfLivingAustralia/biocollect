<bc:koLoading>
    <!-- ko foreach: sites -->
    <div data-bind="visible: name">
        <h4><a data-bind="attr:{href:getSiteUrl()}, text: name"></a></h4>
        <div class="margin-left-20">
            <div data-bind="visible: description"><span data-bind="text: description"></span></div>
            <div data-bind="visible: type"><span>Site type:</span> <span data-bind="text: type"></span></div>
            <div data-bind="visible: numberOfPoi() != undefined"><span>Number of POI:</span> <span data-bind="text: numberOfPoi"></span><br></div>
            <div data-bind="visible: numberOfProjects() != undefined"><span>Number of associated projects:</span> <span data-bind="text: numberOfProjects"></span></div>
        </div>
        <hr>
    </div>
    <!-- /ko -->
    <!-- ko if: sites().length == 0 -->
    <h4>No sites found</h4>
    <!-- /ko -->
</bc:koLoading>