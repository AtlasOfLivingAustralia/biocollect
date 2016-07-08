<div id="pt-table" class="row-fluid">

    <bc:koLoading>
        <g:set var="noImageUrl" value="${resource([dir: "images", file: "no-image-2.png"])}"/>
        <div  class="statistics ">
            <div data-bind="foreach: partitioned( pageProjects, 3)">
                <div class="row-fluid" data-bind="template: { name: 'projectCell', foreach: $data }" >
                </div>
            </div>
        </div>
    </bc:koLoading>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>
<script id="projectCell" type="text/html">
%{--There are 6 different stat-n styles--}%
<div data-bind="attr:{class:'row-fluid span4 stat stat-' + (transients.index() % 6 +1)}">
    <div class="stat-image">
        <div class="stat-thumb" data-bind="attr:{title:name, style: backgroundImageStyle(transients.imageUrl || '${noImageUrl}') }" onerror="backgroundImageError(this, '${noImageUrl}');" ></div>
        <div class="stat-overlay"></div>
    </div>

    <div>
        <div>
            <div class="stat-title"
               data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
                <span data-bind="text:name"></span>
            </div>

            <div class="stat-units" data-bind="visible:transients.orgUrl">
                <span data-bind="visible:transients.daysSince() >= 0">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>
                <g:if test="${controllerName != 'organisation'}">
                    <div class="stat-text" data-bind="text:organisationName,attr:{href:transients.orgUrl}"></div>
                </g:if>
            </div>

            <div data-bind="text:aim"></div>

            %{--<div data-bind="if: transients.links.length > 0" class="inline-block">--}%
                %{--<i class="icon-info-sign"></i>&nbsp;<span data-bind="html:transients.links"/>--}%
            %{--</div>--}%

            <div data-bind="visible: isSciStarter" class="inline-block"><img class="logo-small"
                                                                                          src="${resource(dir: 'images', file: 'robot.png')}"
                                                                                          title="Project is sourced from SciStarter">
            </div>

        </div>
    </div>

</div>
</script>