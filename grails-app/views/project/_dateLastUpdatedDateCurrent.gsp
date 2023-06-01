%{--
Use like this:
<g:render template="dateLastUpdatedDateCurrent" model="[canEditDateCurrent:true/false,dateCurrentProp:'prop',lastUpdatedNameProp:'prop']"/>
--}%
<div class="row space-after">
    <div class="col">
        <g:message code="project.details.dateDataCurrent"/>
        <g:if test="${canEditDateCurrent}">
            <div class="input-group input-group-sm">
            <fc:datePicker class="form-control" targetField="${dateCurrentProp}.date" name="dateCurrent" bs4="true"/>
            </div>
        </g:if>
        <g:else>
            <span data-bind="if: ${dateCurrentProp}() && ${dateCurrentProp}().trim() !== '' && !${dateCurrentProp}().includes('NaN')">
                <span data-bind="text: ${dateCurrentProp}.formattedDate"></span>.
            </span>
            <span data-bind="if: !${dateCurrentProp}() || ${dateCurrentProp}().trim() === '' || ${dateCurrentProp}().includes('NaN')">
                has not been set.
            </span>
        </g:else>
    </div>

    <div class="col" style="text-align: right;">
        Last updated
        <span data-bind="if: ${lastUpdatedNameProp ?: 'detailsLastUpdatedDisplayName'}">
            by <span data-bind="text: ${lastUpdatedNameProp ?: 'detailsLastUpdatedDisplayName'}"></span>
        </span>
        <span data-bind="if:${lastUpdatedProp ?: 'detailsLastUpdated'}">
            at <span data-bind="text: ${lastUpdatedProp ?: 'detailsLastUpdated'}.formattedDate"></span>
        </span>
        <span data-bind="ifnot: ${lastUpdatedProp ?: 'detailsLastUpdated'}">has not been set.</span>
    </div>
</div>