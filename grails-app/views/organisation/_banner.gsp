<g:set var="utilService" bean="utilService"/>
<g:set var="logo" value="${utilService.getLogoURL(organisation.documents)}"/>
<content tag="banner">
    <div class="project-title">
        <div class="container">
            <div class="row d-flex">
                <g:if test="${logo}">
                <div class="col-12 col-lg-auto flex-shrink-1 d-flex justify-content-center justify-content-lg-end">
                    <div class="main-image">
                        <img src="${logo}" alt="<g:message code="logo.img.alt" args="${[organisation.name]}"/>">
                    </div>
                </div>
                </g:if>
                <div class="col d-flex flex-column flex-md-row align-items-center justify-content-between">
                    <h1>${organisation.name}</h1>
                    <div class="project-details">
                        <div class="status">
                            <div class="row">
                                <g:if test="${organisation.url}">
                                <div class="col-1">
                                    <a class="btn btn-sm text-white" href="${organisation.url}" target="_blank" rel="noopener"><i class="fas fa-globe-asia"></i></a>
                                </div>
                                </g:if>
                                <g:each in="${organisation.links}" var="link">
                                <div class="col-1">
                                    <a class="btn btn-sm text-white" href="${link.externalUrl}" target="_blank" rel="noopener"><i class="<config:getSocialMediaIcons document="${link}"/>"></i></a>
                                </div>
                                </g:each>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</content>