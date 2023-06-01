<!-- ko with: transients.fundingBudgetComparison -->
<div class="alert alert-error" data-bind="visible: outcome() === false">
    <h4>Warning!</h4>

    <p>
        The project Budget of
        <span data-bind="text:budgetTotal.formattedCurrency"></span>
        does not match project Funding of
        <span data-bind="text:fundingTotal.formattedCurrency"></span>,
        they differ by
        <span data-bind="text:diff.formattedCurrency"></span>.
    </p>
</div>

<div class="alert alert-info" data-bind="visible: outcome() === true">
    <h4>Notice</h4>

    <p>
        The project Budget and project Funding match. They are both
        <span data-bind="text:budgetTotal.formattedCurrency"></span>.
    </p>
</div>
<!-- /ko -->