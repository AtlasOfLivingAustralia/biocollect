<div class="validationEngineContainer edit-view-funding-budget" id="edit-funding-budget">

    <g:render template="dateLastUpdatedDateCurrent"
              model="[canEditDateCurrent: true, dateCurrentProp: 'details.dateCurrentFundingBudget']"/>

    <p>
        Project Start Date is
        <span data-bind="text:plannedStartDate.formattedDate"></span>
        and End Date is
        <span data-bind="text:plannedEndDate.formattedDate"></span>.

    <g:message code="project.info.currency"/>
    </p>

    <g:render template="compareFundingBudget"/>

    <div class="alert alert-error"
         data-bind="visible: details.budget.transients.showBudgetHeadersChangedWarning() === true">
        <h4>Warning!</h4>

        <p>
            The project start and end dates have changed.
            Please check that the data in the budget table is correct.
        </p>

        <p>
            To confirm changes to the budget table and remove this message, please save the project.
        </p>
    </div>

    <div class="row-fluid space-after">
        <h5>Jump to section</h5>
        <ul class="nav nav-pills">
            <li><a href="#projectPlanBudgetFundingTable">Funding Table</a></li>
            <li><a href="#projectPlanBudgetTable">Budget Table</a></li>
            <li><a href="#projectPlanBudgetCommentary">Budget Commentary</a></li>
        </ul>
    </div>

    <hr>

    <div id="projectPlanBudgetFundingTable" class="row-fluid space-after">
        <g:render template="fundingTable"/>
    </div>

    <hr>

    <div class="row-fluid space-after">
        <div class="pull-right">
            <b><g:message code="project.plan.budget.overallProfile"/></b>
            <span class="req-field"></span>
            <span>
                <select data-validation-engine="validate[required]" data-prompt-position="topLeft"
                        data-bind="options: details.budget.transients.availableRiskStatuses,
                        optionsText: 'text',
                        optionsValue: 'value',
                        optionsCaption: 'Please select',
                        value: details.budget.budgetOverallProfile,
                        css: details.budget.transients.displayedBudgetOverallProfileHighlight"></select>
            </span>
        </div>

        <!-- ko with: details.budget -->
        <g:render template="budgetTable"/>
        <!-- /ko -->

    </div>

    <hr>

    <div class="row-fluid space-after">
        <div class="margin-bottom-10 margin-right-20">
            <label id="projectPlanBudgetCommentary">
                <b>Project Budget Commentary</b>
            </label>
            <textarea style="width: 98%;" maxlength="5000"
                      data-bind="value:details.budgetCommentary, disable: isProjectDetailsLocked()"
                      class="input-xlarge" id="budgetCommentary" rows="10"></textarea>
            <br/>
            <button class="btn popup-edit" data-bind="click:details.transients.editBudgetCommentary">
                <i class="icon-edit"></i> Edit with Markdown Editor
            </button>
        </div>
    </div>

    <div class="row-fluid space-after">
        <div class="span12">
            <div class="form-actions">
                <button type="button" class="btn btn-primary" data-bind="click: saveMeriPlan">
                    <g:message code="g.save"/>
                </button>
                <button type="button" class="btn" data-bind="click: cancelMeriPlanEdits">
                    <g:message code="g.cancel"/>
                </button>
            </div>
        </div>
    </div>

</div>