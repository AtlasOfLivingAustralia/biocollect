<div id="pActivityVisibility" class="well">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->
                <g:render template="/projectActivity/warning"/>
                <div class="row-fluid">
                    <div class="span12 text-left">
                        <h4 >Record Visibility</h4>
                    </div>
                </div>

                </br>

                <div class="row-fluid">
                   <div class="span12 text-left">
                        <label><input type="radio" value="NONE" data-bind="checked: visibility.embargoOption" /> Records publicly visible on submission</label>
                        <label>
                            <input type="radio" value="DAYS" data-bind="checked: visibility.embargoOption" /> Records publicly visible after
                            <select style="width:10%;" data-validation-engine="validate[required]" data-bind="options: $root.datesOptions, value: visibility.embargoForDays, optionsCaption: 'Please select'" ></select> days
                        </label>
                        <label class="inline">
                            <input type="radio" value="DATE" data-bind="checked: visibility.embargoOption" /> Embargo publishing all records until
                            <div class="input-append">
                                <input name="embargoUntilDate" data-bind="datepicker: visibility.embargoUntil.date, datePickerOptions: {endDate: '+12m', startDate: '+0d'}" type="text"/><span class="add-on open-datepicker"><i class="icon-calendar"></i> </span>
                            </div>
                        </label>
                   </div>

                </div>

            <!-- /ko -->
        <!-- /ko -->

        </br>
        <div class="row-fluid">

            <div class="span12">
                <button class="btn-primary btn block" data-bind="click: saveVisibility"> Save </button>
            </div>

        </div>

</div>


