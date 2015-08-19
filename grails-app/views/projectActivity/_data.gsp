<!-- ko stopBinding: true -->
<div id="pActivitiesData">

    <!-- ko if: projectActivities().length == 0 -->
    <div class="row-fluid">
        <div class="span12 text-left">
            <h2>Surveys yet to be published.</h2>
        </div>
    </div>
    <!-- /ko -->

    <!-- ko if: projectActivities().length > 0 -->
    <div class="row-fluid">
        <div class="span12 text-right">

            <div class="btn-group">

                <button type="button" class="btn btn-primary dropdown-toggle " data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <!-- ko  foreach: projectActivities -->
                    <span data-bind="if: current">
                        <span data-bind="text: name"></span> <span class="caret"></span>
                    </span>
                    <!-- /ko -->
                </button>

                <ul class="dropdown-menu" role="menu" style="height: auto;max-height: 200px;overflow-x: hidden;">
                    <!-- ko  foreach: projectActivities -->
                    <li class="text-left">
                        <a href="#" data-bind="click: $parent.setCurrent" >
                            <span data-bind="text: name"></span> <span data-bind="if: current"> <span class="badge badge-important">selected</span></span>
                        </a>
                    </li>
                </br>
                    <!-- /ko -->
                </ul>
            </div>


            <div class="btn-group btn-group-horizontal">
                <a class="btn btn-xs btn-default" > Add Record</a>
            </div>

        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="span3">

                <div class="panel-group well" id="accordion" role="tablist" aria-multiselectable="true">
                    <div class="panel panel-default">

                        <div class="panel-heading" role="tab" id="headingOne">
                            <h5 class="panel-title">
                                <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                    Locations
                                </a>
                            </h5>
                        </div>
                        <div id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
                            <div class="panel-body">
                                <div><input type="checkbox" value="completed" /> <small>Whitegum Lookout (6)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>Pincham Car Park (3)</small></div>

                            </div>
                        </div>

                        <div class="panel-heading" role="tab" id="headingTwo">
                            <h5 class="panel-title">
                                <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" aria-expanded="true" aria-controls="collapseTwo">
                                    Month
                                </a>
                            </h5>
                        </div>
                        <div id="collapseTwo" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingTwo">
                            <div class="panel-body">
                                <div><input type="checkbox" value="completed" /> <small>January (6)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>Feburary (3)</small></div>
                                <div><input type="checkbox" value="completed" /> <small>March (6)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>August (5)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>September (13)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>October (223)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>November (31)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>December (13)</small></div>
                            </div>
                        </div>

                        <div class="panel-heading" role="tab" id="headingThree">
                            <h5 class="panel-title">
                                <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseThree" aria-expanded="true" aria-controls="collapseThree">
                                    Year
                                </a>
                            </h5>
                        </div>
                        <div id="collapseThree" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingTwo">
                            <div class="panel-body">
                                <div><input type="checkbox" value="completed" /> <small>2015 (6)</small></div>
                                <div><input type="checkbox" value="notcompleted" /> <small>2014 (3)</small></div>
                            </div>
                        </div>

                    </div>

                </div>
            </div>

            <div class="span8">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#survey-data-records" data-toggle="pill">Records</a></li>
                    <li><a href="#survey-data-map" data-toggle="pill">Map</a></li>
                    <li><a href="#survey-data-charts" data-toggle="pill">Charts</a></li>
                    <li><a href="#survey-data-images" data-toggle="pill">Recorded Images</a></li>
                </ul>

                <div class="tab-content clearfix">
                    <div class="tab-pane active" id="survey-data-records">
                        <h5>

                            <b>Showing records for:</b>
                            <!-- ko  foreach: projectActivities -->
                            <span data-bind="if: current">
                                <span data-bind="text: name"></span>
                            </span>
                            <!-- /ko -->
                        </h5>
                    </div>

                    <div class="tab-pane" id="survey-data-map">

                    </div>
                    <div class="tab-pane" id="survey-data-charts">

                    </div>
                    <div class="tab-pane" id="survey-data-images">

                    </div>

                </div>

            </div>

        </div>

    </div>
    <!-- /ko -->

</div>
<!-- /ko -->


<r:script>
    function initialiseProjectActivitiesData(pActivitiesVM){
        var pActivitiesDataVM = new ProjectActivitiesDataViewModel(pActivitiesVM);
        ko.applyBindings(pActivitiesDataVM, document.getElementById('pActivitiesData'));
    };
</r:script>