<div class="row-fluid">
        <g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>
        <table data-table-list class="project-finder-table">
            <tbody data-bind="foreach:pageProjects">
                <tr>
                    <td class="projectLogoTd">
                        <div class="projectLogo project-row-layout">
                            <img class="image-logo lazy" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name, 'data-src':transients.imageUrl || '${noImageUrl}'}" onload="findLogoScalingClass(this)" onerror="imageError(this, '${noImageUrl}');"/>
                        </div>
                    </td>
                    <td>
                        <div class="project-row-layout pf-project-text">
                            <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
                                <span data-bind="text:name" style="font-size:150%;font-weight:bold"></span>
                            </a>
                            <div data-bind="visible:transients.orgUrl">
                                <span data-bind="visible:transients.daysSince() >= 0" style="font-size:80%;color:grey">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>
                                <g:if test="${controllerName != 'organisation'}">
                                    <a data-bind="text:organisationName,attr:{href:transients.orgUrl}"></a>
                                </g:if>
                            </div>
                            <div data-bind="text:aim"></div>
                            <div data-bind="if: transients.links.length > 0" class="inline-block">
                                <i class="icon-info-sign"></i>&nbsp;<span data-bind="html:transients.links"/>
                            </div>
                            <div data-bind="visible: isSciStarter" class="inline-block">&nbsp;|&nbsp;<img class="logo-small" src="${asset.assetPath(src: 'robot.png')}" title="Project is sourced from SciStarter"></div>
                            <div style="line-height:2.2em" data-bind="visible:!isMERIT()">
                                TAGS:&nbsp;<g:render template="/project/tags"/>
                            </div>
                            <div data-bind="if: !isExternal()">
                                <img src="${asset.assetPath(src: "ala-logo-small.png")}" class="logo-icon" alt="Atlas of Living Australia logo"><g:message code="project.contributingToALA"/>
                            </div>
                        </div>
                    </td>
                    <td class="span2">
                        <div class="project-row-layout project-row-status">
                            <g:render template="/project/dayscount"/>
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