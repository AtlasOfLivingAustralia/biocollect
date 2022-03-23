<!-- Breadcrumb -->
<g:set var="settingService" bean="settingService"></g:set>
<g:if test="${!printView && !mobile && !hubConfig.content?.hideBreadCrumbs}">
    <g:set var="breadCrumbs"
           value="${settingService.getCustomBreadCrumbsSetForControllerAction(controllerName, actionName)}"/>
    <g:if test="${breadCrumbs}">
        <nav id="breadcrumb" aria-label="breadcrumb">
            <ol class="breadcrumb">
                <g:each in="${breadCrumbs}" var="item" status="index">
                    <config:getLinkFromConfig classes="breadcrumb-item" config="${item}" hubConfig="${hubConfig}"></config:getLinkFromConfig>
                </g:each>
            </ol>
        </nav>
    </g:if>
    <g:else>
        <g:set var="index" value="1"></g:set>
        <g:set var="metaName" value="${'meta.breadcrumbParent' + index}"/>
        <g:if test="${pageProperty(name: "meta.breadcrumb")}">
            <nav id="breadcrumb" aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <g:while test="${pageProperty(name: metaName)}">
                        <g:set value="${pageProperty(name: metaName).tokenize(',')}" var="parentArray"/>
                        <li class="breadcrumb-item"><a href="${parentArray[0]}">${parentArray[1]}</a></li>
                        <% index++ %>
                        <g:set var="metaName" value="${'meta.breadcrumbParent' + index}"/>
                    </g:while>
                    <li class="breadcrumb-item active">${pageProperty(name: "meta.breadcrumb")}</li>
                </ol>
            </nav>
        </g:if>
    </g:else>
</g:if>
<!-- End Breadcrumb -->