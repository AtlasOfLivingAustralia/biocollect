<div class="margin-bottom-10 margin-right-20">
    <label>
        <b><g:message code="project.details.funding"/></b>
        <fc:iconHelp>
            <g:message code="project.details.funding.help"/>
        </fc:iconHelp>
    </label>



    <!-- ko with: transients.fundingEditRows -->
    <g:render template="/shared/editableTableHeader"/>
    <!-- /ko -->

    <div class="project-funding-container">
        <table class="table project-funding-table">
            <g:render template="fundingTableHeader" model="[showHeaderHelp: true, showActions: true]"/>

            <!-- ko with: transients.fundingEditRows -->
            <tbody data-bind="foreach: displayedRows">
            <tr>
                <td class="project-funding-item-number">
                    <span data-bind="text:transients.displayedRowNumber"></span>
                </td>
                <td class="project-funding-item-date">
                    <fc:datePicker class="input-small" targetField="fundingDate.date"
                                   name="fundingDate" id="fundingDate"/>
                </td>
                <td class="project-funding-item-fund-source">
                    <g:field type="text" name="fundingSource" data-bind="value:fundingSource"/>
                </td>
                <td class="project-funding-item-fund-type">
                    <select name="fundingType"
                            data-bind="value:fundingType,
                            options:$parents[1].transients.availableFundingTypes,
                            <g:if test="${!financeDataDisplay.funding.headersByName.fundingType.required}">
                                optionsCaption: '<g:message code="g.selectPrompt"/>',
                            </g:if>
                            optionsText:'text',
                            optionsValue:'value'"></select>
                </td>
                <td class="project-funding-item-fund-class">
                    <select name="fundClass"
                            data-bind="value:fundClass,
                            options:$parents[1].transients.availableFundingClasses,
                            <g:if test="${!financeDataDisplay.funding.headersByName.fundClass.required}">
                                optionsCaption: '<g:message code="g.selectPrompt"/>',
                            </g:if>
                            optionsText:'text',
                            optionsValue:'value'"></select>
                </td>
                <td class="project-funding-item-description">
                    <g:textArea name="description" data-bind="value:description"/>
                </td>
                <td class="project-funding-item-internal-amount">
                    <g:field type="number" step="0.01" min="0" name="fundingInternalAmount"
                             data-bind="value:fundingInternalAmount"
                             data-validation-engine="validate[custom[number]]"/>
                </td>
                <td class="project-funding-item-external-amount">
                    <g:field type="number" step="0.01" min="0" name="fundingExternalAmount"
                             data-bind="value:fundingExternalAmount"
                             data-validation-engine="validate[custom[number]]"/>
                </td>
                <td class="project-funding-item-total-amount">
                    <span data-bind="text: fundingSourceAmount.formattedCurrency"></span>
                </td>
                <td class="project-funding-actions">
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

            <g:render template="fundingTableFooter" model="[showHeaderHelp: true, showActions: true]"/>
        </table>
    </div>

    <!-- ko with: transients.fundingEditRows -->
    <g:render template="/shared/editableTableFooter"/>
    <!-- /ko -->

</div>