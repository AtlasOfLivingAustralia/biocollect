<div id="pt-table" class="row-fluid">
    <table data-table-list>
        <tbody>
            <tr>
                <td><h3 id="pt-resultsReturned"></h3></td>
                <td>
                    <g:if test="${fc.userIsAlaOrFcAdmin()}">
                        <div>
                            <a href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning"
                               title="${message(code:'project.download.tooltip')}" data-bind="click: download">
                                <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download" /></a>
                        </div>
                    </g:if>
                </td>
            </tr>
        </tbody>
    </table>
    <bc:koLoading>
        <table data-table-list class="project-finder-table">
            <tbody data-bind="foreach:pageProjects">
                <tr>
                    <td class="projectLogoTd">
                        <div class="projectLogo project-row-layout">
                            %{--<img class="image-logo" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name,src:transients.imageUrl}, event: { load: transients.findLogoScalingClass}"/>--}%
                        </div>
                    </td>
                    <td>
                        <div class="project-row-layout pf-project-text">
                            <a data-bind="attr:{href:transients.indexUrl}">
                                <span data-bind="text:name" style="font-size:150%;font-weight:bold"></span>
                            </a>
                            <div data-bind="visible:transients.orgUrl">
                                <span data-bind="visible:transients.daysSince() >= 0" style="font-size:80%;color:grey">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>
                                <g:if test="${controllerName != 'organisation'}">
                                    <a data-bind="text:organisationName,attr:{href:transients.orgUrl}"></a>
                                </g:if>
                            </div>
                            <div data-bind="text:aim"></div>
                            <div style="padding: 4px">
                                <i class="icon-info-sign"></i>&nbsp;<span data-bind="html:transients.links"/>
                            </div>
                            <div style="line-height:2.2em">
                                TAGS:&nbsp;<g:render template="/project/tags"/>
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
    </bc:koLoading>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>