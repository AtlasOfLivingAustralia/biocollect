<div class="row-fluid">
        <g:set var="noImageUrl" value="${resource([dir: "images", file: "no-image-2.png"])}"/>
            <div class="tiles">
            <div data-bind="foreach: partitioned( pageProjects, 4)">
                <div class="row-fluid equal-height" data-bind="template: { name: 'projectCell', foreach: $data }">
                </div>
            </div>
        </div>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>
<script id="projectCell" type="text/html">
<div data-bind="attr:{class:'span3 well tile'}">
    <div class="tile-title"
         data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
        <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
            <span data-bind="text:transients.truncatedName"></span>
        </a>
    </div>

    <div class="row-fluid">
        <div class="span12 padding-left-5" style="min-width: 80px;">
            <div>
                <img class="image-logo" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name, src:transients.imageUrl || '${noImageUrl}'}" onerror="imageError(this, '${noImageUrl}');"/>
            </div>
            <div data-bind="visible: isSciStarter" class="inline-block"><img class="logo-small"
                                                                             src="${resource(dir: 'images', file: 'robot.png')}"
                                                                             title="Project is sourced from SciStarter"></div>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span12">
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