<ul class="breadcrumb ${cssClasses} quicklinks">
    <g:if test="${hubConfig.quickLinks}">
        <g:each in="${hubConfig.quickLinks}" var="link" status="index">
            <config:getLinkFromConfig config="${link}" hubConfig="${hubConfig}"></config:getLinkFromConfig>
            <g:if test="${index != (hubConfig.quickLinks.size() - 1)}">
                <span class="divider">|</span>
            </g:if>
        </g:each>
    </g:if>
</ul>