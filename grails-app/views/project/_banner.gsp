<g:set var="utilService" bean="utilService"/>
<g:set var="logo" value="${utilService.getLogoURL(project.documents)}"/>
<content tag="projectLogo">${logo?"margin-buffer":""}</content>
<content tag="banner">
    <bc:koLoading>
        <div class="project-title">
        <div class="container">
            <div class="row d-flex">
                <g:if test="${logo}">
                    <div class="col-12 col-lg-auto flex-shrink-1 d-flex justify-content-center justify-content-lg-end">
                        <div class="main-image">
                            <img src="${logo}" alt="<g:message code="logo.img.alt" args="${[project.name]}"/>">
                        </div>
                    </div>
                </g:if>
                <div class="col d-flex flex-column flex-md-row align-items-center justify-content-between">
                    <div>
                        <div class="row">
                            <div class="col">
                                <h1 class="text-white">${project.name}</h1>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <h4 class="organisation" data-bind="visible:!organisationId(),text:organisationName"></h4>
                                <a class="text-reset text-decoration-none" data-bind="visible:organisationId(),attr:{href:fcConfig.organisationLinkBaseUrl + '/' + organisationId()}">
                                    <h4 class="organisation mb-1" data-bind="text:organisationName"></h4>
                                </a>
                            </div>
                        </div>
                        <div class="row" data-bind="visible:urlWeb">
                            <div class="col-12 banner-image-container">
%{--                                <img src="" data-bind="attr: {src: mainImageUrl}" class="banner-image"/>--}%
                                <a class="banner-image-caption text-reset text-decoration-none" data-bind="visible:urlWeb, attr: {href: urlWeb}"><g:message code="g.visitUsAt" /></a>
                            </div>
                        </div>

%{--                        <div id="weburl" data-bind="visible:!mainImageUrl()">--}%
%{--                            <div data-bind="visible:urlWeb"><strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:urlWeb}"><span data-bind="text:urlWeb"></span></a></strong></div>--}%
%{--                        </div>--}%

                    </div>
                    <div class="project-details">
                        <div class="status">
                            <g:if test="${hubConfig?.content?.hideProjectStatusIndicator != true}">
                                <g:render template="dayscount"/>
                            </g:if>
                        </div>
                        <div class="date">
                            <div>
                                <!-- ko if: plannedStartDate -->
                                    <span class="label">Start date:</span>
                                    <!-- ko text: moment(plannedStartDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                <!-- /ko -->
                            </div>
                            <div>
                                <!-- ko if: plannedEndDate -->
                                    <span class="label">End date:</span>
                                    <!-- ko text: moment(plannedEndDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                <!-- /ko -->
                            </div>
                        </div>
                        <div class="status">
                            <g:render template="daysline"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </bc:koLoading>
</content>