<div id="pActivitySites">

    <!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row mt-4">
        <div class="col-12">
            <h5 class="d-inline"><g:message code="survey.sites.title"/> </h5>
            <g:render template="/projectActivity/status"/>
        </div>
    </div>

    <g:render template="/projectActivity/warning"/>

    <div class="row mt-3">
        <div class="col-12">
            <h6><g:message code="mapConfiguration.step.one.title"/></h6>
        </div>
    </div>

    <div class="px-3" id="site-accordion">
        <div class="">
            <div class="bg-light p-3">
                <div class="form-check form-group m-0">
                    <input class="form-check-input" type="radio" name="siteType"
                           data-bind="checked: surveySiteOption, click: transients.toggleSiteOptionPanel.bind({accordionLinkId:'#site-pick-link'}), clickBubble: false" value="sitepick"/>
                    <label class="form-check-label">
                        <a id="site-pick-link"
                           data-bind="click: transients.setSurveySiteOption.bind({value: 'sitepick'})">
                            <h6 class="m-0"><g:message code="mapConfiguration.sites.pick.title"/></h6>
                        </a>
                    </label>
                    <button class="btn btn-dark btn-sm" data-toggle="collapse" data-target="#site-pick"><i class="fas fa-cog"></i> <g:message code="mapConfiguration.sites.configure"/> </button>
                </div>
            </div>

            <div id="site-pick" class="collapse card ml-5">
                <div class="mt-3 card-body" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepick' }">
                    <div>
                        <h6 class="card-title"><g:message
                                code="mapConfiguration.user.pick.site.title"/></h6>
                        <h6><small class="text-muted"><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h6>
                        <!-- ko template: {name: 'template-sites-pick-one'} -->
                        <!-- /ko -->
                    </div>
                </div>
            </div>
        </div>

        <div class="">
            <div class="bg-light p-3">
                <div class="form-group form-check m-0">
                    <input class="form-check-input" type="radio" name="siteType"
                           data-bind="checked: surveySiteOption, click: transients.toggleSiteOptionPanel.bind({accordionLinkId:'#site-create-link'}), clickBubble: false" value="sitecreate"/>
                    <label class="form-check-label">
                            <a id="site-create-link" data-bind="click: transients.setSurveySiteOption.bind({value:'sitecreate'})">
                                <h6 class="m-0"><g:message code="mapConfiguration.sites.create.title"/></h6>
                            </a>
                    </label>
                    <button class="btn btn-dark btn-sm" data-toggle="collapse" data-target="#site-create"><i class="fas fa-cog"></i> <g:message code="mapConfiguration.sites.configure"/> </button>
                </div>
            </div>

            <div id="site-create" class="card ml-5 collapse" data-bind="css: { 'show': transients.surveySiteOption == 'sitecreate' }">
                <div class="card-body bg-selected-color">
                    <div>
                        <h6 class="card-title"><g:message code="mapConfiguration.user.created.site.title"/></h6>
                        <h6><small class="text-muted"><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h6>
                        <!-- ko template: {name: 'template-site-create'} -->
                        <!-- /ko -->

                    </div>
                </div>
            </div>
        </div>

        <div class="">
            <div class="bg-light p-3">
                <div class="form-check form-group m-0">
                    <input class="form-check-input" type="radio" name="siteType"
                           data-bind="checked: surveySiteOption, click: transients.toggleSiteOptionPanel.bind({accordionLinkId:'#site-pick-create-link'}), clickBubble: false" value="sitepickcreate"/>
                    <label class="form-check-label">
                        <a id="site-pick-create-link" data-bind="click: transients.setSurveySiteOption.bind({value:'sitepickcreate'})">
                            <h6 class="m-0"><g:message code="mapConfiguration.sites.both.title"/></h6>
                        </a>
                    </label>
                    <button class="btn btn-dark btn-sm" data-toggle="collapse" data-target="#site-pick-create"><i class="fas fa-cog"></i> <g:message code="mapConfiguration.sites.configure"/> </button>
                </div>
            </div>

            <div id="site-pick-create" class="collapse card ml-5" data-bind="css: { 'show': transients.surveySiteOption == 'sitepickcreate' }">
                <div class="card-body bg-selected-color">
                    <div>
                        <h6 class="card-title"><strong><g:message code="mapConfiguration.user.pick.site.title"/></strong></h6>
                        <h6 class="text-muted"><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h6>
                        <!-- ko template: {name: 'template-sites-pick-one'} -->
                        <!-- /ko -->

                        <hr/>

                        <h6><g:message
                                code="mapConfiguration.user.created.site.title"/></h6>
                        <h6><small class="text-muted"><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h6>
                        <!-- ko template: {name: 'template-site-create'} -->
                        <!-- /ko -->

                        <hr>

                        <h6><g:message
                                code="mapConfiguration.map.behaviour.title"/></h6>
                        <!-- ko template: {name: 'template-site-add-to-project'} -->
                        <!-- /ko -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row mt-3">
        <div class="col-12">
            <h6><g:message code="mapConfiguration.step.two.title"/></h6>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <map-config-selector params="allBaseLayers: fcConfig.allBaseLayers, allOverlays: fcConfig.allOverlays, mapLayersConfig: mapLayersConfig, type: 'survey'"></map-config-selector>        </div>
    </div>

    <!-- /ko -->
    <!-- /ko -->
</div>

<!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row">
        <div class="col-12">
            <button class="btn-primary-dark btn btn-sm" data-bind="click: $parent.saveSites"><i
                    class="fas fa-hdd"></i> Save</button>
            <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-species-tab'}"><i
                    class="far fa-arrow-alt-circle-left"></i> Back</button>
            <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-publish-tab'}"><i
                    class="far fa-arrow-alt-circle-right"></i> Next</button>
        </div>
    </div>
    <!-- /ko -->
<!-- /ko -->

<script id="template-sites-pick-one" type="text/html">
<div>
    <div id="sites-pick-one-message-container"></div>
    <div id="survey-site-list" class="row" data-validation-engine="validate[funcCall[isSiteSelectionConfigValid]]" data-prompt-position="inline" data-position-type="inline" data-prompt-target="sites-pick-one-message-container">
        <div class="col-12">
            <div style="max-height: 500px; overflow-y: auto; overflow-x: hidden;">
                <div class="row" data-bind="if: sites().length > 1">
                    <div class="col-6">
                        <div class="large-checkbox">
                            <input id="selectall" type="checkbox" data-bind="checked: transients.isSelectAllSites, click: transients.selectAllSites">
                            <label for="selectall"><span></span> <g:message code="mapConfiguration.site.selectall.title"/></label>
                        </div>
                    </div>
                </div>
                <!-- ko foreach: sites -->
                <div class="row">
                    <div class="col-6">
                        <label class="checkbox">
                            <input type="checkbox" data-bind="checked: added">
                            <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl}, text: name"></a>
                        </label>
                    </div>
                    <div class="col-6 btn-space">
                        <a class="btn btn-sm btn-primary-dark" target="_blank" data-bind="attr:{href: siteUrl}" role="button">
                            <i class="far fa-eye"></i>
                            <g:message code="btn.view"/>
                        </a>
                        <button class="btn btn-sm btn-danger" data-bind="disable: transients.isSiteDeleteDisabled(), click: transients.deleteSite">
                            <i class="far fa-trash-alt"></i>
                            <g:message code="btn.delete"/>
                        </button>
                    </div>
                </div>
                <!-- /ko -->
            </div>
            <div class="row mt-2">
                <div class="col-12">
                    <label class="btn-space">
                        <g:message code="mapConfiguration.site.create.choose.title"></g:message>
                        <button class="btn-dark btn btn-sm" data-bind="click: $parent.redirectToSelect, disable: transients.warning()"><i class="fas fa-list-ol"></i> <g:message code="mapConfiguration.site.existing.selection"></g:message> </button>
                        <button class="btn-dark btn btn-sm" data-bind="click: $parent.redirectToCreate, disable: transients.warning()"><i class="fas fa-plus"></i> <g:message code="mapConfiguration.site.create"></g:message> </button>
                        <button class="btn-dark btn btn-sm" data-bind="click: $parent.redirectToUpload, disable: transients.warning()"><i class="fas fa-file-upload"></i> <g:message code="mapConfiguration.site.upload"></g:message> </button>
                    </label>
                </div>
            </div>

            <!-- ko if:sites().length == 0 -->
            <div class="alert-info">
                <g:message code="mapConfiguration.site.selection.title" />
            </div>
            <!-- /ko -->
        </div>
    </div>
</div>
</script>
<script id="template-site-create" type="text/html">
<div data-validation-engine="validate[funcCall[isUserSiteCreationConfigValid]]"
     data-prompt-position="inline" data-position-type="inline" data-prompt-target="site-create-message-container">
    <div id="site-create-message-container"></div>
    <div id="survey-site-create" class="row">
        <div class="col-12">
            <div class="form-group form-check">
                <input class="form-check-input" type="checkbox" data-bind="checked: allowPoints"/>
                <label class="form-check-label">
                    <g:message code="mapConfiguration.site.point" />
                </label>
            </div>
            <div class="form-group form-check">
                <input class="form-check-input" type="checkbox" data-bind="checked: allowPolygons"/>
                <label class="form-check-label">
                    <g:message code="mapConfiguration.site.polygon" />
                </label>
            </div>

            <div class="form-group form-check">
                <input class="form-check-input" type="checkbox" data-bind="checked: allowLine"/>
                <label class="form-check-label">
                    <g:message code="mapConfiguration.site.line" />
                </label>
            </div>
        </div>
    </div>
</div>
</script>
<script id="template-site-add-to-project" type="text/html">
<div class="row">
    <div class="col-12">
        <div class="form-group form-check">
            <input class="form-check-input" type="checkbox" data-bind="checked: addCreatedSiteToListOfSelectedSites, disable: !!isUserSiteCreationConfigValid()"/>
            <label class="form-check-label">
                <g:message code="mapConfiguration.site.create.add.to.project"/>
            </label>
        </div>

        <span class="form-text"><g:message
                code="mapConfiguration.addCreatedSiteToListOfSelectedSites.help.text"/></span>
    </div>
</div>
</script>
<script id="template-site-zoom" type="text/html">
<div class="row">
    <div class="col-12">
        <div class="form-group">
            <label><g:message code="mapConfiguration.zoom.area"/></label>
            <select class="form-control" id="siteToZoom1" data-bind="value: defaultZoomArea, foreach: sites">
                <!-- ko if: added() || isProjectArea() -->
                <option data-bind="text: name, value: siteId, attr: {selected: siteId() == $parent.defaultZoomArea()}"></option>
                <!-- /ko -->
            </select>
        </div>
        <span class="form-text"><g:message code="mapConfiguration.zoom.area.help.text"/> </span>
    </div>
</div>
</script>
