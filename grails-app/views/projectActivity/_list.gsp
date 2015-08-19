<!-- ko stopBinding: true -->
<div class="container-fluid" id="pActivitiesList">

    <!-- ko if: projectActivities().length == 0 -->
    <div class="row-fluid">
        <div class="span12 text-left">
            <h2>Surveys yet to be published.</h2>
        </div>
    </div>
    <!-- /ko -->


    <!-- ko if: projectActivities().length > 1 -->
    <div class="row-fluid">

        <div class="span2">
            <span data-bind="click: toggleFilter" class="btn btn-default btn-small">Sort</span>
        </div>
        <div class="span3">
            <!-- ko if: filter -->
            <label class="muted"> Sort by:</label>
            <select style="width:50%;" data-bind="options: sortOptions, optionsText:'name', optionsValue:'id', value: sortBy" ></select>
            <!-- /ko -->
        </div>
        <div class="span3">
            <!-- ko if: filter -->
            <label class="muted"> Sort order:</label>
            <select style="width:50%;" data-bind="options: sortOrderOptions, optionsText:'name', optionsValue:'id', value: sortOrder" ></select>
            <!-- /ko -->
        </div>

    </div>
    <br><br>
    <!-- /ko -->

    <!-- ko foreach: projectActivities -->
    <div class="row-fluid">

        <div class="span12">
            <div class="span2 well">
                <img alt="No image provided" data-bind="attr:{title:name, src:logoUrl}"/>
            </div>
            <div class="span6">
                <a href="#" data-bind="onClickShowTab: $parent.setCurrent, tabId: '#data-tab'"><span data-bind="text:name" style="font-size:150%;font-weight:bold"></span></a>
            </br></br>
                <div data-bind="text:description"></div>
            </br>
                <div data-bind="visible:transients.status()">
                    <span>Status: <span data-bind="text: transients.status"></span></span>
                </div>
            </div>

            <div class="span2">
                <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
                    <h2 data-bind="text:transients.daysRemaining"></h2>
                    <h4>DAYS TO GO</h4>
                </div>
                <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                    <h4>SURVEY</h4>
                    <h4>ENDED</h4>
                </div>
                <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
                    <img data-bind="attr:{src:fcConfig.imageLocation + '/infinity.png'}"/>
                    <h4>SURVEY</h4>
                    <h4>ONGOING</h4>
                </div>
                <div class="dayscount" data-bind="visible:transients.daysSince() < 0">
                    <h4>STARTS IN</h4>
                    <h2 data-bind="text:-transients.daysSince()"></h2>
                    <h4>DAYS</h4>
                </div>
            </div>

            <div class="span2 text-right">
                <a href="#" class="btn btn-success btn-sm" data-bind="click: addActivity"> Add a record</a>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span12">
                <div class="span2"></div>
                <div class="span10">
                    <div class="daysline-positive" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
                        <div data-bind="style:{width: Math.floor(transients.daysRemaining()/transients.daysTotal() * 100) + '%'}"></div>
                    </div>
                    <div class="daysline-positive" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
                        <div style="width:0%"></div>
                    </div>

                    <div class="daysline-zero" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0"></div>
                </div>
            </div>
        </div>

    </div>
    <!-- /ko -->

</div>

<!-- /ko -->

<r:script>
    function initialiseProjectActivitiesList(pActivitiesVM){
        var pActivitiesListVM = new ProjectActivitiesListViewModel(pActivitiesVM);
        ko.applyBindings(pActivitiesListVM, document.getElementById('pActivitiesList'));
    };
</r:script>