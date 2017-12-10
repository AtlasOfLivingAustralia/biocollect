<div>

    <!-- ko with: {} -->
    <div class="row-fluid">
        <div class="span12 text-left">
            <h3 class="strong"><g:message code="project.works.mapConfiguration.title"/></h3>
            <p><g:message code="project.works.mapConfiguration.help"/></p>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span6 ">
            <table class="table white-background table-custom-border borderless">
                <thead>
                    <tr>
                        <th class="text-left"><g:message code="project.works.mapConfiguration.associatedSites"/>
                            <a href="#" data-bind="popover: {content:'<g:message code="project.works.mapConfiguration.associatedSites.help"/>'}"><i  class="icon-question-sign"></i></a>
                        </th>
                    </tr>
                </thead>
                <tbody>
                <!-- ko foreach: sites -->
                <tr data-bind="visible: added()">
                    <!-- ko ifnot: isProjectArea -->
                    <td>
                        <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl}, text: name"></a>
                        <button class="btn btn-mini pull-right btn-default" data-bind="click: removeSite, disable: transients.isDataForSite"  title="Remove this site from survey">
                            <span class="icon-arrow-right"></span>
                        </button>
                    </td>
                    <!-- /ko -->
                </tr>
                <!-- /ko -->
                <!-- ko if: getNumberOfSitesForSurvey() == 0 -->
                <tr>
                    <td>
                        <i><g:message code="project.works.mapConfiguration.associatedSites.message"/> <span class="icon-arrow-left"></span>.</i>
                    </td>
                </tr>
                <!-- /ko -->
                </tbody>
            </table>
        </div>

        <div class="span6">
            <table class="table table-custom-border borderless white-background">
                <thead>
                <tr>
                    <th><g:message code="project.works.mapConfiguration.projectSites"/>
                        <a href="#" data-bind="popover: {content:'<g:message code="project.works.mapConfiguration.projectSites.help"/> '}"><i  class="icon-question-sign"></i></a>
                    </th>
                </tr>
                </thead>

                <tbody>
                <!-- ko foreach: sites -->
                <!-- ko ifnot: name() == '*' -->
                <tr data-bind="visible: !added()">
                    <td>
                        <button class="btn btn-mini btn-primary" data-bind="click: addSite" title="Add this site to whitelist">
                            <span class="icon-arrow-left icon-white"></span>
                        </button>
                        <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl}, text: name"></a>
                    </td>
                </tr>
                <!-- /ko -->
                <!-- /ko -->
                <!-- ko if:sites().length == 0 -->
                <tr>
                    <td>
                        <g:message code="project.works.mapConfiguration.projectSites.message"/>
                    </td>
                </tr>
                <!-- /ko -->
                </tbody>

            </table>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span12">
            <h4><g:message code="project.works.mapConfiguration.site.controls"/></h4>
            <div class="">
                <div class="btn-group btn-group-justified margin-bottom-5">
                    <button class="btn-default btn btn-small block" data-bind="click: $parent.redirectToCreate, disable: transients.warning()"><i class="icon-plus"></i> <g:message code="project.works.mapConfiguration.site.controls.add"/> </button>
                    <button class="btn-default btn btn-small block" data-bind="click: $parent.redirectToSelect, disable: transients.warning()"><i class="icon-folder-open"></i> <g:message code="project.works.mapConfiguration.site.controls.choose"/> </button>
                    <button class="btn-default btn btn-small block" data-bind="click: $parent.redirectToUpload, disable: transients.warning()"><i class="icon-arrow-up"></i> <g:message code="project.works.mapConfiguration.site.controls.upload"/> </button>
                </div>
            </div>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span12">
            <h4><g:message code="project.works.mapConfiguration.drawing.title"/> </h4>
            <label class="checkbox">
                <input type="checkbox" data-bind="checked: allowPolygons"/> Draw Polygons
            </label>
            <label class="checkbox">
                <input type="checkbox" data-bind="checked: allowPoints"/> Mark Points
            </label>

            <label class="checkbox">
                <input type="checkbox" data-bind="checked: allowAdditionalSurveySites, disable: transients.warning()"/> Allow Additional Survey Sites <a href="#" data-bind="popover: {content:'<g:message code="project.works.mapConfiguration.drawing.additionalSites.help"/> '}"><i  class="icon-question-sign"></i></a>
            </label>

            <label class="checkbox">
                <input type="checkbox" data-bind="checked: selectFromSitesOnly, disable: transients.warning()"/> ONLY Select from existing sites <a href="#" data-bind="popover: {content:'<g:message code="project.works.mapConfiguration.drawing.selectFromSiteOnly.help"/> '}"><i  class="icon-question-sign"></i></a></id>
            </label>

        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <h4>Additional map options</h4>
            <auth:ifAnyGranted roles="ROLE_ADMIN">
                <label for="map-tiles">
                    Map tiles:
                    <select id="map-tiles" data-bind="value: baseLayersName, optionsCaption: 'Choose...', disable: transients.warning()">
                        <option>Google Maps</option>
                        <option>Open Layers</option>
                    </select>
                </label>

            </auth:ifAnyGranted>

            <label>
                Default zoom area:
                <select id="siteToZoom"
                        data-bind='options: sites, optionsText: "name", optionsValue: "siteId", value: defaultZoomArea;'></select>
            </label>

        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn btn-small block" data-bind="click: $parent.saveMapConfig"><i class="icon-white  icon-hdd" ></i>  Save </button>
        </div>
    </div>
    <!-- /ko -->
</div>