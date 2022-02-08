<table class="table responsive-table-stacked project-funding-table"
       data-bind="if: fundings().length">
    <g:render template="fundingTableHeader" model="[showHeaderHelp: false, showActions: false]"/>
    <tbody data-bind="foreach: fundings">
    <tr>
        <td><span data-bind="text: $index()+1"></span></td>
        <td><span data-bind="text: fundingDate.formattedDate"></span></td>
        <td><span data-bind="text: fundingType"></span></td>
        <td><span data-bind="text: fundClass"></span></td>
        <td><span data-bind="text: description"></span></td>
        <td><span data-bind="text: fundingInternalAmount.formattedCurrency"></span></td>
        <td><span data-bind="text: fundingExternalAmount.formattedCurrency"></span></td>
    </tr>
    </tbody>
    <g:render template="fundingTableFooter" model="[showHeaderHelp: false, showActions: false]"/>
</table>

