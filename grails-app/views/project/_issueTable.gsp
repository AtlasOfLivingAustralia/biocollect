<label><b>Project Issues <span style="color: red;"><b>*</b></span></b></label>
<g:render template="/shared/restoredData"
          model="[id: 'restoredIssueData', saveButton: 'Save issues', cancelButton: 'Cancel edits to issues']"/>

<div class="row-fluid space-after">
    <div class="required">
        <p>Please enter project issues and the mitigation strategies being used to manage them:</p>

        <div id="project-issues" class="margin-bottom-10 margin-right-20">
            <table style="width:100%;">
                <thead>
                <tr>
                    <th class="required">Type of issue </th>
                    <th class="required">Description </th>
                    <th class="required">Assessment </th>
                    <th class="required">Action plan </th>
                    <th class="required">Impact</th>
                    <th></th>
                </tr>
                </thead>
                <tbody data-bind="foreach : issues">
                <tr>
                    <td width="22%">
                        <input data-validation-engine="validate[required]" data-bind="value:type">
                    </td>
                    <td width="22%">
                        <textarea data-validation-engine="validate[required]" class="input-xlarge"
                                  data-bind="value: description" rows="5"></textarea>
                    </td>
                    <td width="22%">
                        <textarea data-validation-engine="validate[required]" class="input-xlarge"
                                  data-bind="value: assessment" rows="5"></textarea>
                    </td>
                    <td width="22%">
                        <textarea data-validation-engine="validate[required]" class="input-xlarge"
                                  data-bind="value: actionPlan" rows="5"></textarea>
                    </td>
                    <td width="10%">
                        <select data-validation-engine="validate[required]"
                                data-bind="options: impact.options, value: impact,  optionsCaption: 'Please select'"></select>
                    </td>
                    <td width="4%">
                        <span><i class="icon-remove" data-bind="click: $parent.removeIssue"></i></span>
                    </td>
                </tr>
                </tbody>
                <tfoot>
                <tr>
                    <td colspan="0" style="text-align:left;">
                        <button type="button" class="btn btn-small" data-bind="click: addIssue">
                            <i class="icon-plus"></i> Add an issue</button></td>
                </tr>
                </tfoot>

            </table>
            <br/>
        </div>
    </div>
</div>
