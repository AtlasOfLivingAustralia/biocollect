<div id="pt-table">
    <ul class="nav nav-tabs">
    <li>
    <a data-bind="click:hideshow"><g:message code="g.search.hideShow"/></a>
    </li>
    </ul>
<div id="pt-selectors" class="well" style="display:none">
    <g:if test="${fc.userIsAlaOrFcAdmin()}">
        <div class="row-fluid">
            <a href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning span2 pull-right"
               title="${message(code:'project.download.tooltip')}" data-bind="click: download">
                <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download" /></a>
        </div>
    </g:if>
    <div class="row-fluid">
        <span class="span2" id="pt-resultsReturned"></span>
        <div class="span8 input-append">
            <input class="span12" type="text" name="pt-search" id="pt-search" placeholder="${message(code:'g.search.placeHolder')}"/>
        </div>
        <div class="pull-right">
            <a href="javascript:void(0);" title="${message(code:'project.search.term.tooltip')}" id="pt-search-link" class="btn btn-primary"><g:message code="g.search" /></a>
            <a href="javascript:void(0);" title="${message(code:'g.resetSearch.tooltip')}" id="pt-reset" class="btn"><g:message code="g.resetSearch" /></a>
        </div>
    </div>
    <div id="pt-searchControls" class="row-fluid">
        <div id="pt-sortWidgets">
            <div class="span3">
                <label for="pt-per-page"><g:message code="g.projects"/>&nbsp;<g:message code="g.perPage"/></label>
                <g:select name="pt-per-page" from="[20,50,100,500]"/>
            </div>
            <div class="span3">
                <label for="pt-sort"><g:message code="g.sortBy" /></label>
                <select id="pt-sort" data-bind="options:sortKeys, optionsText:'name', optionsValue:'value'"></select>
            </div>
            <div class="span3">
                <label for="pt-dir"><g:message code="g.sortOrder" /></label>
                <g:select name="pt-dir" from="['Ascending','Descending']" keys="[1,-1]"/>
            </div>
<g:if test="${controllerName == 'organisation'}">
            <div class="span3">
                <label for="pt-search-projecttype"><g:message code="project.search.projecttype" /></label>
                <select id="pt-search-projecttype" multiple data-bind="options:availableProjectTypes, optionsText:'name', optionsValue:'value', selectedOptions: projectTypes" style="width:100%"></select>
                <label><g:message code="g.multiselect.help" /></label>
            </div>
</g:if>
<g:else>
            <div class="span3">
                <label for="pt-search-difficulty"><g:message code="project.search.difficulty" /></label>
                <g:select name="pt-search-difficulty" from="${['Any','Easy','Medium','Hard']}" keys="${['','easy','medium','hard']}"/>
            </div>
</g:else>
        </div>
    </div><!--drop downs-->
<g:if test="${controllerName != 'organisation'}">
    <div class="row-fluid">
        <div class="span4">
            <label class="checkbox"><input id="pt-search-active" type="checkbox" checked /><g:message code="project.search.active" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-diy" type="checkbox" /><g:message code="project.tag.diy" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-noCost" type="checkbox" /><g:message code="project.tag.noCost" /></label>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span4">
            <label class="checkbox"><input id="pt-search-teach" type="checkbox" /><g:message code="project.tag.teach" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-children" type="checkbox" /><g:message code="project.tag.children" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-mobile" type="checkbox" /><g:message code="g.mobileApps" /></label>
        </div>
    </div>
</g:if>
</div>
<p/>
<table class="table table-hover">
    <tbody data-bind="foreach:pageProjects">
    <tr style="border-bottom: 2px solid grey">
        <td style="width:200px">
            <div class="projectLogo well">
                <img style="max-width:100%;max-height:100%" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name,src:transients.imageUrl}"/>
            </div>
        </td>
        <td>
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
                <b><g:message code="project.display.status" /></b>
                <g:render template="/project/daysline"/>
            </div>
            <div data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                <g:message code="project.display.concluded" /> <a data-bind="attr:{href:transients.indexUrl}">
                <span style="font-weight:bold"><g:message code="project.display.view" /></span></a>
            </div>
        </td>
        <td style="width:10em;text-align:center">
            <g:render template="/project/dayscount"/>
<g:if test="${controllerName == 'organisation'}">
            <span class="projectType" data-bind="text:transients.kindOfProjectDisplay"></span>
</g:if>
        </td>
    </tr>
    </tbody>
</table>

<div id="pt-searchNavBar" class="clearfix">
    <div id="pt-navLinks"></div>
</div>

</div>
