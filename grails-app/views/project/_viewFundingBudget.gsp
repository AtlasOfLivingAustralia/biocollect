<div data-bind="ifnot: details.status() == 'active'">
    <h4>Project Funding &amp; Budget not available.</h4>
</div>

<div class="edit-view-funding-budget" data-bind="if: details.status() == 'active'">

    <h3>Project Funding &amp; Budget</h3>

    <g:render template="dateLastUpdatedDateCurrent"
              model="[canEditDateCurrent: false, dateCurrentProp: 'details.dateCurrentFundingBudget']"/>

    <g:render template="compareFundingBudget"/>

    <div class="row-fluid space-after no-print">
        <h5>Jump to section</h5>
        <ul class="nav nav-pills">
            <li><a href="#projectFundingBudgetFundingTable">Funding Table</a></li>
            <li><a href="#projectFundingBudgetBudgetTable">Budget Table</a></li>
            <li><a href="#projectFundingBudgetBudgetCommentary">Budget Commentary</a></li>
        </ul>
    </div>

    <hr>

    <div class="row-fluid space-after">
        <g:render template="fundingTableReadOnly"/>
    </div>

    <hr>

    <div class="row-fluid space-after">
        <div class="pull-right">
            <b><g:message code="project.plan.budget.overallProfile"/></b>
            <span data-bind="
                text: details.budget.transients.displayedBudgetOverallProfile,
                css: details.budget.transients.displayedBudgetOverallProfileHighlight"></span>
            <span data-bind="ifnot: details.budget.transients.displayedBudgetOverallProfile">Not set</span>
        </div>

        <!-- ko with: details.budget -->
        <g:render template="budgetTableReadOnly"/>
        <!-- /ko -->

    </div>

    <hr>

    <div class="row-fluid space-after">
        <div class="margin-bottom-10 margin-right-20">
            <label id="projectFundingBudgetBudgetCommentary"><b>Project Budget Commentary</b></label>

            <p data-bind="visible: details.budgetCommentary, html: details.budgetCommentary.markdownToHtml()"></p>

            <p data-bind="ifnot: details.budgetCommentary">No budget commentary set.</p>
        </div>
    </div>

</div>