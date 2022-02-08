<%@ page import="java.text.DateFormat" %>
<div class="margin-bottom-10 margin-right-20">
    <label>
        <b><g:message code="project.plan.budget"/></b>
        <fc:iconHelp><g:message code="project.plan.budget.help"/></fc:iconHelp>
    </label>

    <!-- ko with: transients.editRows -->
    <g:render template="/shared/editableTableHeader"/>
    <!-- /ko -->

    <div class="project-budget-container">
        <table class="table project-budget-table">

            <g:render template="budgetTableHeader" model="[showActions: true]"/>

            <!-- ko with: transients.editRows -->
            <tbody data-bind="foreach: displayedRows">
            <tr>
                <td class="project-budget-item-number">
                    <span data-bind="text:transients.displayedRowNumber"></span>
                </td>
                <td class="project-budget-item-category">
                    <select
                        <g:if test="${financeDataDisplay.budget.headersByName.shortLabel.required}">
                            data-validation-engine="validate[required]"
                        </g:if>
                            data-bind="options: $parents[1].transients.availableCategories,
                        optionsText: 'text',
                        optionsValue: 'value',
                        <g:if test="${!financeDataDisplay.budget.headersByName.shortLabel.required}">
                                optionsCaption: '<g:message code="g.selectPrompt"/>',
                            </g:if>
                        value: shortLabel"></select>
                </td>

                <td class="project-budget-item-payment-number">
                    <input type="text"
                        <g:if test="${financeDataDisplay.budget.headersByName.paymentNumber.required}">
                            data-validation-engine="validate[required]"
                        </g:if>
                           data-bind="value:paymentNumber">
                </td>
                <td class="project-budget-item-fund-class">
                    <select
                        <g:if test="${financeDataDisplay.budget.headersByName.fundClass.required}">
                            data-validation-engine="validate[required]"
                        </g:if>

                            data-bind="options: $parents[1].transients.availableClasses,
                        optionsText: 'text',
                        optionsValue: 'value',
                        <g:if test="${!financeDataDisplay.budget.headersByName.fundClass.required}">
                                optionsCaption: '<g:message code="g.selectPrompt"/>',
                            </g:if>
                        value:fundClass"></select>
                </td>
                <td class="project-budget-item-funding-source">
                    <div class="control-group">
                        <div class="controls">
                            <input type="text"
                                <g:if test="${financeDataDisplay.budget.headersByName.fundingSource.required}">
                                    data-validation-engine="validate[required]"
                                </g:if>
                                   data-bind="value:fundingSource">
                        </div>
                    </div>
                </td>
                <td class="project-budget-item-payment-status">
                    <select
                        <g:if test="${financeDataDisplay.budget.headersByName.paymentStatus.required}">
                            data-validation-engine="validate[required]"
                        </g:if>
                            data-bind="options:$parents[1].transients.availablePaymentStatuses,
                        optionsText: 'text',
                        optionsValue:'value',
                        <g:if test="${!financeDataDisplay.budget.headersByName.paymentStatus.required}">
                                optionsCaption: '<g:message code="g.selectPrompt"/>',
                            </g:if>
                        value:paymentStatus"></select>
                </td>
                <td class="project-budget-item-risk-status">
                    <select
                        <g:if test="${financeDataDisplay.budget.headersByName.budgetRiskStatus.required}">
                            data-validation-engine="validate[required]"
                        </g:if>
                            data-bind="options: $parents[1].transients.availableRiskStatuses,
                            optionsText: 'text',
                            optionsValue:'value',
                            <g:if test="${!financeDataDisplay.budget.headersByName.budgetRiskStatus.required}">
                                optionsCaption: '<g:message code="g.selectPrompt"/>',
                            </g:if>
                            value:riskStatus,
                            css: transients.displayedRiskStatusHighlight"></select>
                </td>
                <td class="project-budget-item-due-date">
                    <fc:datePicker class="input-small" targetField="dueDate.date" name="dueDate"
                                   data-validation-engine="validate[${financeDataDisplay.budget.headersByName.dueDate.required ? 'required' : ''}]"
                                   data-prompt-position="topLeft"/>
                </td>
                <td class="project-budget-item-description">
                    <textarea rows="3"
                        <g:if test="${financeDataDisplay.budget.headersByName.description.required}">
                            data-validation-engine="validate[required]"
                        </g:if>
                              data-bind="value: description"></textarea>
                </td>

                <!-- ko foreach: costs -->
                <td class="project-budget-item-year">
                    <div class="control-group">
                        <div class="controls">
                            <input type="number" step="0.01" class="input-xlarge myInput"
                                   data-validation-engine="validate[${financeDataDisplay.budget.headersByName.financialYearAmount.required ? 'required,' : ''}custom[number]]"
                                   data-bind="value: dollar, disable: $root.isProjectDetailsLocked()"/>
                        </div>
                    </div>
                </td>
                <!-- /ko -->

                <td class="project-budget-item-total">
                    <span data-bind="text: rowTotal.formattedCurrency"></span>
                </td>
                <td class="project-budget-actions">
                    <div class="btn-group">
                        <button type="button" class="btn btn-small"
                                data-bind="click: $parent.moveRowUp"
                                title="<g:message code="editableTable.row.moveup.text"/>">
                            <i class="icon-chevron-up"></i>
                        </button>
                        <button type="button" class="btn btn-small"
                                data-bind="click: $parent.moveRowDown"
                                title="<g:message code="editableTable.row.movedown.text"/>">
                            <i class="icon-chevron-down"></i>
                        </button>
                        <button type="button" class="btn btn-small"
                                data-bind="click: $parent.deleteRow"
                                title="<g:message code="editableTable.row.remove.text"/>">
                            <i class="icon-remove"></i>
                        </button>
                    </div>
                </td>
            </tr>
            </tbody>
            <!-- /ko -->

            <g:render template="budgetTableFooter" model="[showActions: true]"/>

        </table>
    </div>

    <!-- ko with: transients.editRows -->
    <g:render template="/shared/editableTableFooter"/>
    <!-- /ko -->

</div>
