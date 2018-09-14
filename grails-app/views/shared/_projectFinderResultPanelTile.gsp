<div class="well">
    <div class="row-fluid">
        <g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>
        <div class="tiles">
            <div data-bind="foreach: partitioned( pageProjects, columns)">
                <div class="row-fluid row-eq-height" data-bind="template: { name: 'projectCell', foreach: $data }">
                </div>
            </div>
        </div>
    </div>
</div>
<script id="projectCell" type="text/html">
<div data-bind="attr:{class:'well tile span' + 12 / $root.columns()}">
    <div class="row-fluid">
        <div class="span12 padding-left-5" style="min-width: 80px;">
            <div>
                <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
                    <img class="image-logo lazy" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name, 'data-src':transients.imageUrl || '${noImageUrl}'}" onerror="imageError(this, '${noImageUrl}');"/>
                </a>
            </div>
            <div data-bind="visible: isSciStarter" class="inline-block"><img class="logo-small"
                                                                             src="${asset.assetPath(src: 'robot.png')}"
                                                                             title="Project is sourced from SciStarter"></div>
        </div>
    </div>
    <div class="tile-title"
         data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
        <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
            <span data-bind="text:transients.truncatedName"></span>
        </a>
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

            <div class="tile-small">
                <g:render template="/project/dayscountTile"/>
            </div>
        </div>
    </div>
</div>
</script>