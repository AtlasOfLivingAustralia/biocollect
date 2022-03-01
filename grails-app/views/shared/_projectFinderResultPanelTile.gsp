<g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>
<div id="projects" class="row">
    <!-- ko foreach: pageProjects -->
    <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item mb-1">
        <a class="project-image" title="Project Title"
           data-bind="visible: !(${hubConfig?.content?.hideProjectFinderNoImagePlaceholderTile == true}), attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
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
            <h2 class="my-2" data-bind="text:transients.truncatedName"></h2>
        </a>
        <g:if test="${controllerName != 'organisation'}">
            <a class="tile-organisation" data-bind="attr:{href:transients.orgUrl}">
                <h6 class="mb-2" data-bind="text:transients.truncatedOrganisationName"></h6>
            </a>
        </g:if>
        <div class="excerpt" data-bind="text:transients.truncatedAim"></div>
    </div>
    <!-- /ko -->
</div>