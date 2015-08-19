<div id="pActivityInfo" class="well">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->

            <div class="row-fluid">
                <h5>General information about the survey</h5>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label"> Name:</label>
                </div>
                <div class="span7">
                    <div class="controls"><input type="text" data-bind="value: name" data-validation-engine="validate[required]"></div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label"> Description:</label>
                </div>

                <div class="span7">
                    <div class="controls">
                        <textarea style="width: 97%;" rows="4"  class="input-xlarge"  data-bind="value: description" data-validation-engine="validate[required]"></textarea>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label"> Start date:</label>
                </div>
                <div class="span7">
                    <div class="controls">
                        <input data-bind="datepicker:startDate.date" type="text"  data-validation-engine="validate[required]" />
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label"> End date:</label>
                </div>
                <div class="span7">
                    <div class="controls">
                        <input data-bind="datepicker:endDate.date" type="text" />
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label">Publish:</label>
                </div>
                <div class="span7">
                    <div class="controls">
                        <input type="checkbox" data-bind="checked: published" />
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span3 text-right">
                    <label class="control-label">Comments on records allowed:</label>
                </div>
                <div class="span7">
                    <div class="controls">
                        <input type="checkbox" data-bind="checked: commentsAllowed" />
                    </div>
                </div>
            </div>
            <!-- /ko -->

        <!-- /ko -->

    </br></br>
    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn block" data-bind="click: saveInfo"> Save </button>
        </div>

    </div>

</div>