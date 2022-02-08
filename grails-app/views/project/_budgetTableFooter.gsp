<tfoot>
<tr>
    <th colspan="9" style="text-align: right;">
        <g:message code="project.plan.budget.columnTotal.label"/>
        <fc:iconHelp><g:message code="project.plan.budget.columnTotal.help"/></fc:iconHelp>:
    </th>
    <!-- ko foreach: columnTotal -->
    <th>
        <span data-bind="text:data.formattedCurrency"></span>
    </th>
    <!-- /ko -->
    <th class="project-budget-item-total">
        <span data-bind="text:overallTotal.formattedCurrency"></span>
    </th>
    <g:if test="${showActions}">
        <th class="project-budget-actions">
        </th>
    </g:if>
</tr>
<tr>
    <th class="project-budget-item-number"></th>
    <th  class="project-budget-item-category">
        <select name="totalFilterShortLabel"
                data-bind="value:transients.totalFilterShortLabelSelected,
                            options:transients.totalFilterShortLabelOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select></th>
    <th class="project-budget-item-payment-number">
        <select name="totalFilterPaymentNumber"
                data-bind="value:transients.totalFilterPaymentNumberSelected,
                            options:transients.totalFilterPaymentNumberOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th class="project-budget-item-fund-class">
        <select name="totalFilterFundClass"
                data-bind="value:transients.totalFilterFundClassSelected,
                            options:transients.totalFilterFundClassOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th class="project-budget-item-funding-source">
        <select name="totalFilterFundingSource"
                data-bind="value:transients.totalFilterFundingSourceSelected,
                            options:transients.totalFilterFundingSourceOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th class="project-budget-item-payment-status">
        <select name="totalFilterPaymentStatus"
                data-bind="value:transients.totalFilterPaymentStatusSelected,
                            options:transients.totalFilterPaymentStatusOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th class="project-budget-item-risk-status">
        <select name="totalFilterRiskStatus"
                data-bind="value:transients.totalFilterRiskStatusSelected,
                            options:transients.totalFilterRiskStatusOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th class="project-budget-item-due-date"></th>
    <th class="project-budget-item-description" style="text-align: right;">
        <g:message code="project.plan.budget.filteredTotal.label"/>
        <fc:iconHelp><g:message code="project.plan.budget.filteredTotal.help"/></fc:iconHelp>:
    </th>
    <!-- ko foreach: transients.totalFilterColumns -->
    <th class="project-budget-item-year">
        <span data-bind="text:dollar.formattedCurrency"></span>
    </th>
    <!-- /ko -->
    <th class="project-budget-item-total">
        <span data-bind="text:transients.totalFilterOverall.formattedCurrency"></span>
    </th>
    <g:if test="${showActions}">
        <th class="project-budget-actions">
        </th>
    </g:if>
</tr>
</tfoot>
