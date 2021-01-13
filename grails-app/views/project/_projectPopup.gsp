<asset:script type="text/html" id="script-project-popup-template">
    <!-- ko if: projects().length  -->
    <div class="project-map-popup">
        <div class="container-fluid">
            <h6>Projects</h6>
            <!-- ko foreach: projects -->
            <div data-bind="if: $root.index() == $index()">
                <div class="row-fluid margin-bottom-10" data-bind="if: $data.properties.imageUrl">
                    <div class="span12">
                        <div class="projectLogo image-centre">
                            <a target="_blank" data-bind="attr: { href: fcConfig.projectIndexUrl + '/' + $data.properties.projectId }">
                                <img class="image-window image-logo" onload="findLogoScalingClass(this, 200, 150)" alt="Click to view project"  data-bind="attr: {src: $data.properties.imageUrl || fcConfig.imageLocation + 'no-image-2.png'}" onerror="imageError(this, fcConfig.imageLocation + 'no-image-2.png');">
                            </a>
                        </div>
                    </div>
                </div>
                <dl class="dl-horizontal">
                    <!-- ko if: $data.properties.name -->
                    <dt><g:message code="project.popup.name"/></dt>
                    <dd data-bind="text: $data.properties.name"></dd>
                    <!-- /ko -->
                    <!-- ko if: $data.properties.aim -->
                    <dt><g:message code="project.popup.aim"/></dt>
                    <dd data-bind="text: $data.properties.aim"></dd>
                    <!-- /ko -->
                    <!-- ko if: $data.properties.plannedStartDate -->
                    <dt><g:message code="project.popup.plannedStartDate"/></dt>
                    <dd data-bind="text: moment($data.properties.plannedStartDate).format('DD/MM/YYYY')"></dd>
                    <!-- /ko -->
                    <!-- ko if: $data.properties.plannedEndDate -->
                    <dt><g:message code="project.popup.plannedEndDate"/></dt>
                    <dd data-bind="text: moment($data.properties.plannedEndDate).format('DD/MM/YYYY')"></dd>
                    <!-- /ko -->
                </dl>
                <div class="btn-group">
                    <button type="button" class="btn btn-mini" title="Previous project" data-bind="click: $root.index($root.index() - 1), disable: $root.index() == 0"><span>«</span></button>
                    <button type="button" class="btn btn-mini" title="Next project" data-bind="click: $root.index($root.index() + 1), disable: $root.index() == ($root.projects().length - 1)"><span>»</span></button>
                </div>
                <a class="btn btn-mini" title="View details of this project" target="_blank" data-bind="attr: { href: fcConfig.projectIndexUrl + '/' + $data.properties.projectId }"><span><g:message code="project.popup.view"/></span></a>
            </div>
            <!-- /ko -->
        </div>
    </div>
    <!-- /ko -->
    <!-- ko if: intersects().length  -->
    <div class="overlays-map-popup">
        <div class="container-fluid">
            <h6><g:message code="overlays.popup.title"/></h6>
            <!-- ko foreach: intersects -->
            <div class="row-fluid">
                <div class="span12" data-bind="text: $data"></div>
            </div>
            <!-- /ko -->
        </div>
    </div>
    <!-- /ko -->
</asset:script>