<div id="pSupplementaryActivitySurvey" class="well">

    <div class="row-fluid">
        <div class="span10">
            <h2 class="strong">Supplementary Data</h2>
            Including additional information about this dataset is important for your data to be useful to others, particularly in scientific studies
        </div>
    </div>

    <br/>

    <div class="row-fluid">

        <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->

        <div class="span6 text-left">
            <label class="control-label"><g:message code="project.survey.info.relatedDatasets"/>
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.relatedDatasets"/>', content:'<g:message code="project.survey.info.relatedDatasets.content"/>'}">
                    <i class="icon-question-sign"></i>
                </a>

            </label>

            <!-- ko if: $parent.projectActivities().length <= 1 -->
            <h3 class="text-left margin-bottom-five">
                There are no other related datasets in the project
            </h3>
            <!-- /ko -->

            <!-- ko if: $parent.projectActivities().length > 1 -->
            <div class="panel panel-default" >
                <div class="panel-body" style="max-height: 388px; max-width: 440px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                    <!-- ko foreach: $parent.projectActivities -->

                    <!-- ko if: $parent.projectActivityId != projectActivityId -->
                    <input type="checkbox" data-bind="checkedValue: projectActivityId, checked: $parent.relatedDatasets" />

                    <span data-bind="text: name"></span>

                </br>

                    <!-- /ko -->

                    <!-- /ko -->

                </div>
            </div>
            <!-- /ko -->

        </div>

        <!-- /ko -->
        <!-- /ko -->


    </div>

</div>