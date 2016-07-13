<div class="row-fluid">
        <g:set var="noImageUrl" value="${resource([dir: "images", file: "no-image-2.png"])}"/>
            <div class="tiles">
            <div data-bind="foreach: partitioned( pageProjects, 4)">
                <div class="row-fluid" data-bind="template: { name: 'projectCell', foreach: $data }">
                </div>
            </div>
        </div>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>

<script id="projectCell2" type="text/html">
<div class="span4">
    <div>
        <span>Title</span>
    </div>
    <div class="row-fluid">
        <div class="span4" style="min-width: 80px">
            <div style="min-width: 80px">
                <img style="width: 80px; height: 80px; display: block" class="image-logo" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name, src:transients.imageUrl || '${noImageUrl}'}" onload="findLogoScalingClass(this)" onerror="imageError(this, '${noImageUrl}');"/>
            </div>
        </div>
        <div class="span8">
            <div class="span12">
                Second column
            </div>
            </div>
    </div>
</div>
</script>

<script id="projectCell" type="text/html">
%{--There are 6 different tile-n styles--}%
<div data-bind="attr:{class:'span3 tile tile-' + (transients.index() % 6 +1)}">
    <div class="tile-title"
         data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
        <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
            <span data-bind="text:transients.truncatedName"></span>
        </a>
        %{--<span data-bind="text:name"></span>--}%
    </div>

    <div class="row-fluid">
        <div class="span4" style="min-width: 80px;">
            <div class="tile-image">
                %{--<div >--}%
                <div class="tile-thumb"
                     data-bind="attr:{title:name, style: backgroundImageStyle(transients.imageUrl || '${noImageUrl}') }"
                     onerror="backgroundImageError(this, '${noImageUrl}');"></div>

                <div class="tile-overlay"></div>
%{--Plain&nbsp;content again--}%
            </div>

            <div data-bind="visible: isSciStarter" class="inline-block"><img class="logo-small"
                                                                             src="${resource(dir: 'images', file: 'robot.png')}"
                                                                             title="Project is sourced from SciStarter">
            </div>
        </div>

        <div class="span8">

            <div class="tile-small">
                <span data-bind="visible:transients.daysSince() >= 0">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>
            </div>
            <div>
                <g:if test="${controllerName != 'organisation'}">
                    <a class="tile-organisation" data-bind="text:transients.truncatedOrganisationName,attr:{href:transients.orgUrl}"></a>
                </g:if>
            </div>

            <div data-bind="text:transients.truncatedAim"></div>

            <div>
                <g:render template="/project/dayscount"/>
            </div>

        </div>

    </div>
</div>
</script>