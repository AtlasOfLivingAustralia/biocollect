<thead class="thead-dark">
<tr>
    <th class="project-budget-item-number">
        <g:message code="project.plan.budget.rowNumber.label"/>
    </th>
    <th class="project-budget-item-category">
        <g:message code="project.plan.budget.shortLabel.label"/>
        <g:if test="${financeDataDisplay.budget.headersByName.shortLabel.required}">
            <span class="req-field"></span>
        </g:if>
        <fc:iconHelp><g:message code="project.plan.budget.shortLabel.help"/></fc:iconHelp>
    </th>
    <th class="project-budget-item-payment-number">
        <g:message code="project.plan.budget.paymentNumber.label"/>
        <g:if test="${financeDataDisplay.budget.headersByName.paymentNumber.required}">
            <span class="req-field"></span>
        </g:if>
        <fc:iconHelp><g:message code="project.plan.budget.paymentNumber.help"/></fc:iconHelp>
    </th>
    <th class="project-budget-item-fund-class">
        <g:message code="project.plan.budget.fundClass.label"/>
        <g:if test="${financeDataDisplay.budget.headersByName.fundClass.required}">
            <span class="req-field"></span>
        </g:if>
        <fc:iconHelp><g:message code="project.plan.budget.fundClass.help"/></fc:iconHelp>
    </th>
    <th class="project-budget-item-funding-source">
        <g:message code="project.plan.budget.fundingSource.label"/>
        <g:if test="${financeDataDisplay.budget.headersByName.fundingSource.required}">
            <span class="req-field"></span>
        </g:if>
        <fc:iconHelp><g:message code="project.plan.budget.fundingSource.help"/></fc:iconHelp>
    </th>
    <th class="project-budget-item-payment-status">
        <g:message code="project.plan.budget.paymentStatus.label"/>
        <g:if test="${financeDataDisplay.budget.headersByName.paymentStatus.required}">
            <span class="req-field"></span>
        </g:if>
        <fc:iconHelp><g:message code="project.plan.budget.paymentStatus.help"/></fc:iconHelp>
    </th>
    <th class="project-budget-item-risk-status">
        <g:message code="project.plan.budget.riskStatus.label"/>
    </th>
    <th class="project-budget-item-due-date">
        <g:message code="project.plan.budget.dueDate.label"/>
        <span class="req-field"></span>
    </th>
    <th class="project-budget-item-description">
        <g:message code="project.plan.budget.description.label"/>
        <g:if test="${financeDataDisplay.budget.headersByName.description.required}">
            <span class="req-field"></span>
        </g:if>
        <fc:iconHelp><g:message code="project.plan.budget.description.help"/></fc:iconHelp>
    </th>

    <!-- ko foreach: headers -->
    <th class="project-budget-item-year">
        <span data-bind="text:data"></span>
        <g:message code="project.plan.budget.financialYearAmount.label"/>
        <fc:iconHelp><g:message code="project.plan.budget.financialYearAmount.help"/></fc:iconHelp>
    </th>
    <!-- /ko -->

    <th class="project-budget-item-total">
        <g:message code="project.plan.budget.rowTotal.label"/>
    </th>
    <g:if test="${showActions}">
        <th class="project-budget-actions">
            <g:message code="actions"/>
        </th>
    </g:if>
</tr>
</thead>