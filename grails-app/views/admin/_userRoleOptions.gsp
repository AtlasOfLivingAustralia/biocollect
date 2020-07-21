<g:if test="${includeEmptyOption}"><option value="">-- Select a permission level --</option></g:if>
<g:set var="userIsSiteAdmin"><fc:userIsSiteAdmin /></g:set>
<g:each var="role" in="${roles}">
    <g:if test="${role != 'projectParticipant'}">
        <g:set var="disabledHtml" value='disabled="disabled" class="tooltips" title="Only ADMIN users can set Case Manager role"'/>
        <g:set var="disabled" value="${(role == 'caseManager' && !userIsSiteAdmin) ? disabledHtml : ''}" />
        <option value="${role}" ${disabled}><g:message code="label.role.${role}" default="${role}"/></option>
    </g:if>
</g:each>