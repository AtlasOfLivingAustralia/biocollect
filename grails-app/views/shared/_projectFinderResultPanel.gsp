<div id="pt-table" class="row-fluid">

    <bc:koLoading>
        <g:set var="noImageUrl" value="${resource([dir: "images", file: "no-image-2.png"])}"/>
        <div  class="statistics ">
            <div data-bind="foreach: partitioned( pageProjects, 3)">
                <div class="row-fluid" data-bind="template: { name: 'projectCell', foreach: $data }" >
                    %{--<div>Stay tuned</div>--}%
                </div>
            </div>
        </div>
    </bc:koLoading>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>
<script id="projectCell" type="text/html">
%{--<div class="span4 stat stat-2" >--}%
%{--There are 6 different stat-n styles--}%
<div data-bind="attr:{class:'span4 stat stat-' + (transients.index() % 6 +1)}">
    <div class="projectLogoTd">
        %{--<div class="projectLogo project-row-layout">--}%
        %{--<img class="image-logo" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name, src:transients.imageUrl || '${noImageUrl}'}" onload="findLogoScalingClass(this)" onerror="imageError(this, '${noImageUrl}');"/>--}%
        %{--</div>--}%
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

            <div data-bind="if: transients.links.length > 0" class="inline-block">
                <i class="icon-info-sign"></i>&nbsp;<span data-bind="html:transients.links"/>
            </div>

            <div data-bind="visible: isSciStarter" class="inline-block">&nbsp;|&nbsp;<img class="logo-small"
                                                                                          src="${resource(dir: 'images', file: 'robot.png')}"
                                                                                          title="Project is sourced from SciStarter">
            </div>
            
        </div>
    </div>

</div>
</script>