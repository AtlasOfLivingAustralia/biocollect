<div class="row">
        <g:set var="noImageUrl" value="${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}"/>
        <table data-table-list class="table">
            <tbody data-bind="foreach:pageProjects">
                <tr data-bind="attr: {id: transients.projectId}">
                    <td class="projectLogoTd">
                        <div class="project-logo" data-bind="visible: !(!transients.imageUrl && ${hubConfig?.content?.hideProjectFinderNoImagePlaceholderList == true})">
                            <img class="image-logo lazy" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name, 'data-src':transients.imageUrl || '${noImageUrl}'}" onload="findLogoScalingClass(this)" onerror="imageError(this, '${noImageUrl}');"/>
                        </div>
                    </td>
                    <td>
                        <div class="">
                            <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
                                <span data-bind="text:name" style="font-size:150%;font-weight:bold"></span>
                            </a>

                                <div data-bind="visible:transients.orgUrl">
                                    <small data-bind="visible:transients.daysSince() >= 0">
                                        Started <!--ko text:transients.since--><!--/ko-->&nbsp;
                                        <g:if test="${controllerName != 'organisation'}">
                                            <g:if test="${hubConfig?.content?.disableOrganisationHyperlink}">
                                                <span data-bind="text:organisationName"></span>
                                            </g:if>
                                            <g:else>
                                                <a data-bind="text:organisationName,attr:{href:transients.orgUrl}"></a>
                                            </g:else>
                                        </g:if>
                                    </small>
                                </div>

                            <div data-bind="text:aim"></div>
                            <div class="d-inline-block">
                                <span>
                                    <!-- ko if: urlWeb -->
                                        |&nbsp;
                                        <i class="fas fa-info-circle"></i>&nbsp;
                                        <a data-bind="attr: {href:urlWeb}"><g:message code="g.website"/></a>
                                        &nbsp;
                                    <!-- /ko -->
                                    <!-- ko if: transients.mobileApps().length > 0-->
                                        |&nbsp;<g:message code="g.appsLinks"/>
                                        <!-- ko foreach: transients.mobileApps -->
                                            <!-- ko if: role != 'pwa' -->
                                            <a class="do-not-mark-external" data-bind="attr: {href: link.url}"><i data-bind="attr: {class: icon()}"></i></a>
                                            <!-- /ko -->
                                            <!-- ko if: role == 'pwa' -->
                                            <a class="do-not-mark-external" data-bind="attr: {href: pwaAppProjectUrl()}"><span class="pwa-mobile small"><img src="${asset.assetPath(src: 'logo-dark-32x32.png')}"/></span></a>
                                            <!-- /ko -->
                                        <!-- /ko -->
                                        &nbsp;
                                    <!-- /ko -->
                                    <!-- ko if: transients.socialMedia().length > 0-->
                                        |&nbsp;<g:message code="g.socialMedia"/>
                                        <!-- ko foreach: transients.socialMedia -->
                                            <a class="do-not-mark-external" data-bind="attr: {href: link.url}"><i data-bind="attr: {class: icon()}"></i></a>
                                        <!-- /ko -->
                                        &nbsp;
                                    <!-- /ko -->
                                </span>
                            </div>
                            <div class="d-inline-block"><div data-bind="visible: isSciStarter">|&nbsp;<img class="logo-small mb-1" src="${asset.assetPath(src: 'robot.png')}" title="Project is sourced from SciStarter"></div></div>
                            <g:if test="${hubConfig?.content?.hideProjectFinderProjectTags != true}">
                            <div class="" data-bind="visible:!isMERIT()">
                                TAGS:&nbsp;<g:render template="/project/tags"/>
                            </div>
                            </g:if>
                            <div data-bind="if: !isExternal()">
                                <img class="logo-icon" src="${asset.assetPath(src: "ala-logo-small.png")}" alt="Atlas of Living Australia logo"><g:message code="project.contributingToALA"/>
                            </div>
                        </div>
                    </td>
                    <td class="align-top">
                        <div>
                            <g:if test="${hubConfig?.content?.hideProjectFinderStatusIndicatorList != true}">
                            <g:render template="/project/dayscount"/>
                            </g:if>
                            <span data-bind="visible:plannedStartDate">
                                <small data-bind="text:'Start date: ' + moment(plannedStartDate()).format('DD MMMM, YYYY')"></small>
                            </span>
                            <span data-bind="visible:plannedEndDate">
                                <br/><small data-bind="text:'End date: ' + moment(plannedEndDate()).format('DD MMMM, YYYY')"></small>
                            </span>
                            <g:if test="${controllerName == 'organisation'}">
                                <span class="projectType" data-bind="text:transients.kindOfProjectDisplay"></span>
                            </g:if>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
</div>