<div id="pt-table">
    <div class="row-fluid">
        <div class="">
            <h3 class="inline span10" id="pt-resultsReturned"></h3>
            <g:if test="${fc.userIsAlaOrFcAdmin()}">
                <a href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning span2 inline pull-right"
                   title="${message(code:'project.download.tooltip')}" data-bind="click: download">
                    <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download" /></a>
            </g:if>
        </div>
    </div>
    <p/>
    <bc:koLoading>
            <div data-bind="foreach:pageProjects">
            <div class="row-fluid padding5" style="border-bottom: 2px solid grey">
                <div class="span2 padding5">
                    <div class="projectLogo row-fluid">
                        <img class="image-logo img-polaroid span12" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name,src:transients.imageUrl}"/>
                    </div>
                </div>
                <div class="span8 padding5 pf-project-text">
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
                    <br/>
                    <div data-bind="visible:transients.daysSince() >= 0">
                        <g:render template="/project/daysline"/>
                    </div>
                    <div data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                        <g:message code="project.display.concluded" /> <a data-bind="attr:{href:transients.indexUrl}">
                        <span style="font-weight:bold"><g:message code="project.display.view" /></span></a>
                    </div>
                </div>
                <div class="span2 padding5 pf-project-status">
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
            </div>
            </div>
    </bc:koLoading>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>