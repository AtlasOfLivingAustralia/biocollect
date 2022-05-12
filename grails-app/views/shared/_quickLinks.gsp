<g:if test="${hubConfig.quickLinks}">
    <ul class="list-inline ${cssClasses} quicklinks">
        <g:each in="${hubConfig.quickLinks}" var="link" status="index">
            <config:getLinkFromConfig config="${link}" hubConfig="${hubConfig}" classes="list-inline-item"></config:getLinkFromConfig>
            <g:if test="${index != (hubConfig.quickLinks.size() - 1)}">
                <span class="divider"> | </span>
            </g:if>
        </g:each>
    </ul>
</g:if>