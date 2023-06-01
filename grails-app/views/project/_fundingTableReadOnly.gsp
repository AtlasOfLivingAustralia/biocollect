<div class="margin-bottom-10 margin-right-20">
    <label>
        <b><g:message code="project.details.funding"/></b>
        <fc:iconHelp>
            <g:message code="project.details.funding.help"/>
        </fc:iconHelp>
    </label>

    <!-- ko with: transients.fundingViewRows -->
    <g:render template="/shared/editableTableHeader"/>
    <!-- /ko -->

    <table class="table project-funding-table">
        <g:render template="fundingTableHeader" model="[showHeaderHelp: true, showActions: false]"/>

        <!-- ko with: transients.fundingViewRows -->
        <tbody data-bind="foreach: displayedRows">
        <tr>
            <td>
                <span data-bind="text: transients.displayedRowNumber"></span>
            </td>
            <td>
                <span data-bind="text: fundingDate.formattedDate"></span>
            </td>
            <td>
                <span data-bind="text: fundingSource"></span>
            </td>
            <td>
                <span data-bind="text: fundingType"></span>
            </td>
            <td>
                <span data-bind="text: fundClass"></span>
            </td>
            <td>
                <span data-bind="text: description"></span>
            </td>
            <td>
                <span data-bind="text: fundingInternalAmount.formattedCurrency"></span>
            </td>
            <td>
                <span data-bind="text: fundingExternalAmount.formattedCurrency"></span>
            </td>
            <td>
                <span data-bind="text: fundingSourceAmount.formattedCurrency"></span>
            </td>
        </tr>
        </tbody>
        <!-- /ko -->

        <g:render template="fundingTableFooter" model="[showHeaderHelp: true, showActions: false]"/>
    </table>

    <!-- ko with: transients.fundingViewRows -->
    <g:render template="/shared/editableTableFooter"/>
    <!-- /ko -->
</div>