<tfoot>
<tr>
    <th colspan="6" style="text-align: right;">
        <span style="font-weight: bold;">
            <g:message code="project.details.funding.columnTotal.label"/>
        </span>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.columnTotal.help"/></fc:iconHelp>
        </g:if>:
    </th>
    <th>
        <span data-bind="text:fundingInternalTotal.formattedCurrency"></span>
    </th>
    <th>
        <span data-bind="text:fundingExternalTotal.formattedCurrency"></span>
    </th>
    <th>
        <span style="font-weight: bold;" data-bind="text:funding.formattedCurrency"></span>
    </th>
    <g:if test="${showActions}">
        <th></th>
    </g:if>
</tr>
<tr>
    <th></th>
    <th></th>
    <th></th>
    <th class="project-funding-item-fund-type">
        <select name="totalFilterFundingType"
                data-bind="value:transients.totalFilterFundingTypeSelected,
                            options:transients.totalFilterFundingTypeOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th class="project-funding-item-fund-class">
        <select name="totalFilterFundClass"
                data-bind="value:transients.totalFilterFundClassSelected,
                            options:transients.totalFilterFundClassOptions,
                            optionsCaption: 'No filter',
                            optionsText:'text',
                            optionsValue:'value'"></select>
    </th>
    <th style="text-align: right;">
        <g:message code="project.details.funding.filteredTotal.label"/>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.filteredTotal.help"/></fc:iconHelp>
        </g:if>:
    </th>
    <th>

        <span data-bind="text:transients.totalFilterInternal.formattedCurrency"></span>
    </th>
    <th>

        <span data-bind="text:transients.totalFilterExternal.formattedCurrency"></span>
    </th>
    <th>
        <span style="font-weight: bold;" data-bind="text:transients.totalFilterOverall.formattedCurrency"></span>
    </th>
    <g:if test="${showActions}">
        <th></th>
    </g:if>
</tr>
</tfoot>
