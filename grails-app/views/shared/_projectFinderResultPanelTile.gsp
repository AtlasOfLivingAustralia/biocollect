%{--<div class="well">--}%
%{--    <div class="row">--}%
%{--        <g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>--}%
%{--        <div class="tiles">--}%
%{--            <div data-bind="foreach: partitioned( pageProjects, columns)">--}%
%{--                <div class="row-fluid row-eq-height" data-bind="template: { name: 'projectCell', foreach: $data }">--}%
%{--                </div>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--    </div>--}%
%{--</div>--}%
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

<script id="projectCell" type="text/html">
<div data-bind="attr:{class:'well tile span' + 12 / $root.columns(), id: transients.projectId}">
    <div class="row-fluid">
        <div class="span12 padding-left-5" style="min-width: 80px;">
            <div data-bind="visible: !(!transients.imageUrl && ${hubConfig?.content?.hideProjectFinderNoImagePlaceholderTile == true})">
                <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
                    <img class="image-logo lazy" alt="${message(code: 'g.noImage')}"
                         data-bind="attr:{title:name, 'data-src':transients.imageUrl || '${noImageUrl}'}"
                         onerror="imageError(this, '${noImageUrl}');"/>
                </a>
            </div>

            <div data-bind="visible: isSciStarter" class="inline-block"><img class="logo-small"
                                                                             src="${asset.assetPath(src: 'robot.png')}"
                                                                             title="Project is sourced from SciStarter">
            </div>
        </div>
    </div>

    <div class="tile-title"
         data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
        %{--        <a data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">--}%
        %{--            <span data-bind="text:transients.truncatedName"></span>--}%
        %{--        </a>--}%
    </div>

    <div class="row-fluid">
        <div class="span12">
            %{--            <div class="tile-small">--}%
            %{--                <span data-bind="visible:transients.daysSince() >= 0">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>--}%
            %{--            </div>--}%
            %{--            <div>--}%
            %{--                <g:if test="${controllerName != 'organisation'}">--}%
            %{--                    <a class="tile-organisation" data-bind="text:transients.truncatedOrganisationName,attr:{href:transients.orgUrl}"></a>--}%
            %{--                </g:if>--}%
            %{--            </div>--}%

            %{--            <div data-bind="text:transients.truncatedAim"></div>--}%

            %{--            <div class="tile-small">--}%
            %{--                <g:render template="/project/dayscountTile"/>--}%
            %{--            </div>--}%
        </div>
    </div>
</div>
</script>