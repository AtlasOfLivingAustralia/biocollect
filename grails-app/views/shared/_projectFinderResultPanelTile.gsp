<g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>
<div id="projects" class="row">
    <!-- ko foreach: pageProjects -->
    <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
        <a class="project-image" title="Project Title"
           data-bind="visible: !(!transients.imageUrl && ${hubConfig?.content?.hideProjectFinderNoImagePlaceholderTile == true}), attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
            <div class="project-image-inner">
                <img class="image-logo lazy" alt="${message(code: 'g.noImage')}"
                     data-bind="attr:{title:name, 'data-src':transients.imageUrl || '${noImageUrl}'}"
                     onerror="imageError(this, '${noImageUrl}');">
            </div>
        </a>

        <div data-bind="visible: isSciStarter" class="position-absolute scistarter-logo-pf">
            <img class="logo-small"
                 src="${asset.assetPath(src: 'robot.png')}"
                 title="Project is sourced from SciStarter">
        </div>

        <a class="project-link" title="Project Title"
           data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
            <h4 data-bind="text:transients.truncatedName"></h4>

            <p class="subtitle"></p>
        </a>
        <g:if test="${controllerName != 'organisation'}">
            <a class="tile-organisation" data-bind="attr:{href:transients.orgUrl}">
                <h5 data-bind="text:transients.truncatedOrganisationName"></h5>
            </a>
        </g:if>
        <div class="excerpt" data-bind="text:transients.truncatedName"></div>
        <div class="detail" data-bind="visible:transients.daysSince() >= 0">
            <span class="status" aria-label="">Started <!--ko text:transients.since--><!--/ko--></span>
        </div>
        <g:render template="/project/dayscountTile"/>
    </div>
    <!-- /ko -->
</div>