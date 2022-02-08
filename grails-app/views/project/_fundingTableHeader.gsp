<thead>
<tr>
    <th>
        <g:message code="project.details.funding.rowNumber.label"/>
    </th>
    <th>
        <g:message code="project.details.funding.fundingDate.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.fundingDate.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundingDate.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.fundingSource.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.fundingSource.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundingSource.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.fundingType.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.fundingType.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundingType.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.fundClass.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.fundClass.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundClass.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.description.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.description.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.description.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.fundingInternalAmount.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.fundingInternalAmount.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundingInternalAmount.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.fundingExternalAmount.label"/>
        <g:if test="${financeDataDisplay.funding.headersByName.fundingExternalAmount.required}">
            <span class="req-field"></span>
        </g:if>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundingExternalAmount.help"/></fc:iconHelp>
        </g:if>
    </th>
    <th>
        <g:message code="project.details.funding.fundingSourceAmount.label"/>
        <g:if test="${showHeaderHelp}">
            <fc:iconHelp><g:message code="project.details.funding.fundingSourceAmount.help"/></fc:iconHelp>
        </g:if>
    </th>
    <g:if test="${showActions}">
        <th>
            <g:message code="actions"/>
        </th>
    </g:if>
</tr>
</thead>
