<div class="margin-bottom-10 margin-right-20">
    <label>
        <b><g:message code="project.plan.budget"/></b>
        <fc:iconHelp>
            <g:message code="project.plan.budget.help"/>
        </fc:iconHelp>
    </label>

    <!-- ko with: transients.viewRows -->
    <g:render template="/shared/editableTableHeader"/>
    <!-- /ko -->

    <table class="table table-bordered project-budget-table">

        <g:render template="budgetTableHeader" model="[showActions: false]"/>

        <!-- ko with: transients.viewRows -->
        <tbody data-bind="foreach: displayedRows">
        <tr>
            <td class="project-budget-item-number">
                <span data-bind="text:transients.displayedRowNumber"></span>
            </td>
            <td class="project-budget-item-category">
                <span data-bind="text:transients.displayedCategory"></span>
            </td>
            <td class="project-budget-item-payment-number">
                <span data-bind="text:paymentNumber"></span>
            </td>
            <td class="project-budget-item-fund-class">
                <span data-bind="text:transients.displayedClass"></span>
            </td>
            <td class="project-budget-item-funding-source">
                <span data-bind="text:fundingSource"></span>
            </td>
            <td class="project-budget-item-payment-status">
                <span data-bind="text:transients.displayedPaymentStatus"></span>
            </td>
            <td class="project-budget-item-risk-status">
                <span data-bind="text: transients.displayedRiskStatus,css: transients.displayedRiskStatusHighlight"></span>
            </td>
            <td class="project-budget-item-due-date">
                <span data-bind="text:dueDate.formattedDate"></span>
            </td>
            <td class="project-budget-item-description">
                <span data-bind="text: description"></span>
            </td>

            <!-- ko foreach: costs -->
            <td class="project-budget-item-year">
                <span data-bind="text: dollar.formattedCurrency"></span>
            </td>
            <!-- /ko -->

            <td class="project-budget-item-total">
                <span data-bind="text: rowTotal.formattedCurrency"></span>
            </td>
        </tr>
        </tbody>
        <!-- /ko -->

        <g:render template="budgetTableFooter" model="[showActions: false]"/>
    </table>

    <!-- ko with: transients.viewRows -->
    <g:render template="/shared/editableTableFooter"/>
    <!-- /ko -->

</div>