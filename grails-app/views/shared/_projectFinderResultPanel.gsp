<div id="pt-table" class="row-fluid">

    <bc:koLoading>
        <g:set var="noImageUrl" value="${resource([dir: "images", file: "no-image-2.png"])}"/>
        <div class="tiles">
            <div data-bind="foreach: partitioned( pageProjects, 3)">
                <div class="row-fluid" data-bind="template: { name: 'projectCell', foreach: $data }">
                </div>
            </div>
        </div>
    </bc:koLoading>
    <div id="pt-searchNavBar" class="clearfix">
        <div id="pt-navLinks"></div>
    </div>
</div>

<script id="projectCell" type="text/html">
%{--There are 6 different tile-n styles--}%
<div data-bind="attr:{class:'span4 tile tile-' + (transients.index() % 6 +1)}">
    <div class="tile-title"
         data-bind="attr:{href:transients.indexUrl}, click: $root.setTrafficFromProjectFinderFlag">
        <span data-bind="text:name"></span>
    </div>

    <div class="row-fluid">
        <div class="span4">
            <div class="tile-image">
                <div class="tile-thumb"
                     data-bind="attr:{title:name, style: backgroundImageStyle(transients.imageUrl || '${noImageUrl}') }"
                     onerror="backgroundImageError(this, '${noImageUrl}');"></div>

                <div class="tile-overlay"></div>

            </div>

            <div data-bind="visible: isSciStarter" class="inline-block"><img class="logo-small"
                                                                             src="${resource(dir: 'images', file: 'robot.png')}"
                                                                             title="Project is sourced from SciStarter">
            </div>
        </div>

        <div class="span8">

            <div class="tile-units" data-bind="visible:transients.orgUrl">
                <span data-bind="visible:transients.daysSince() >= 0">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>
                <g:if test="${controllerName != 'organisation'}">
                    <div class="tile-text" data-bind="text:organisationName,attr:{href:transients.orgUrl}"></div>
                </g:if>
            </div>

            <div data-bind="text:aim"></div>
        </div>

    </div>
</div>
</script>