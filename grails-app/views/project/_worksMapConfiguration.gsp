<div>
    <!-- ko with: mapConfiguration -->
    <div data-bind="css: {'ajax-opacity': transients.loading}">
        <div class="row">
            <div class="col-sm-12 text-left">
                <h2 class="strong"><g:message code="mapConfiguration.heading"/></h2>
            </div>
        </div>

        <div class="row mt-3">
            <div class="col-sm-12">
                <h3><g:message code="mapConfiguration.step.one.title"/></h3>
            </div>
        </div>

        <div class="px-3" id="site-accordion" class="bg-light">
            <div>
                <div class="p-3">
                    <div class="form-check form-group m-0">
                        <input class="form-check-input" type="radio" name="siteType"
                               data-bind="checked: surveySiteOption, clickBubble: false" value="sitepick"/>
                        <label class="form-check-label">
                            <a id="site-pick-link" data-bind="click: transients.setSurveySiteOption.bind({value: 'sitepick'})">
                                <h4 class="m-0"><g:message code="mapConfiguration.sites.pick.title"/></h4>
                            </a>
                        </label>
                        <button class="btn btn-dark btn-sm ml-3" data-toggle="collapse" data-target="#site-pick"  data-bind="enable: surveySiteOption() === 'sitepick'"><i class="fas fa-cog"></i> <g:message code="mapConfiguration.sites.configure"/> </button>
                    </div>
                    <!-- ko if: surveySiteOption() == 'sitepick' && !isSiteConfigValid() -->
                    <div class="formError inline mt-2" >
                        <div class="formErrorContent">
                            <!-- ko text: isSiteSelectionConfigValid() --> <!-- /ko --><br>
                            <g:message code="projectActivity.locations.mandatory"/>
                        </div>
                    </div>
                    <!-- /ko -->

                </div>

                <div id="site-pick" class="collapse card ml-5 p-3">
                    <div class="card-body mt-3" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepick'}">
                        <div data-bind="if: surveySiteOption() === 'sitepick'">
                            <h5 class="card-title"><strong><g:message
                                    code="mapConfiguration.user.pick.site.title"/></strong></h5>
                            <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-sites-pick-one'} -->
                            <!-- /ko -->

                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="p-3">
                    <div class="form-group form-check m-0">
                        <input class="form-check-input" type="radio" name="siteType"
                            data-bind="checked: surveySiteOption, clickBubble: false" value="sitecreate"/>
                        <label class="form-check-label">
                            <a id="site-create-link" data-bind="click: transients.setSurveySiteOption.bind({value:'sitecreate'})">
                                <h4 class="m-0"><g:message code="mapConfiguration.sites.create.title"/></h4>
                            </a>
                        </label>
                        <button class="btn btn-dark btn-sm ml-3" data-toggle="collapse" data-target="#site-create" data-bind="enable: surveySiteOption() === 'sitecreate'"><i class="fas fa-cog"></i> <g:message code="mapConfiguration.sites.configure"/> </button>
                    </div>
                    <!-- ko if: surveySiteOption() == 'sitecreate' && !isSiteConfigValid() -->
                    <div class="formError inline mt-2" >
                        <div class="formErrorContent">
                            <!-- ko text: isUserSiteCreationConfigValid() --> <!-- /ko --> <br>
                            <g:message code="projectActivity.locations.mandatory"/>
                        </div>
                    </div>
                    <!-- /ko -->
                </div>

                <div id="site-create" class="card ml-5 collapse">
                    <div class="card-body" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitecreate'}">
                        <div data-bind="if: surveySiteOption() === 'sitecreate'">
                            <h5 class="card-title"><strong><g:message
                                    code="mapConfiguration.user.created.site.title"/></strong></h5>
                            <h5><small class="text-muted"><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-site-create'} -->
                            <!-- /ko -->

                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="p-3">
                    <div class="form-check form-group m-0">
                        <input class="form-check-input" type="radio" name="siteType"
                               data-bind="checked: surveySiteOption, clickBubble: false" value="sitepickcreate"/>
                        <label class="form-check-label">
                            <a id="site-pick-create-link" data-bind="click: transients.setSurveySiteOption.bind({value:'sitepickcreate'})">
                                <h4 class="m-0"><g:message code="mapConfiguration.sites.both.title"/></h4>
                            </a>
                        </label>
                        <button class="btn btn-dark btn-sm ml-3" data-toggle="collapse" data-target="#site-pick-create" data-bind="enable: surveySiteOption() === 'sitepickcreate'"><i class="fas fa-cog"></i> <g:message code="mapConfiguration.sites.configure"/> </button>
                    </div>
                    <!-- ko if: surveySiteOption() == 'sitepickcreate' && !isSiteConfigValid() -->
                    <div class="formError inline mt-2" >
                        <div class="formErrorContent">
                            <!-- ko text: isUserSiteCreationConfigValid() --> <!-- /ko --> <br>
                            <!-- ko text: isSiteSelectionConfigValid() --> <!-- /ko --> <br>
                            <g:message code="projectActivity.locations.mandatory"/>
                        </div>
                    </div>
                    <!-- /ko -->
                </div>

                <div id="site-pick-create" class="card collapse ml-5">
                    <div class="card-body bg-selected-color" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepickcreate'}">
                        <div data-bind="if: surveySiteOption() === 'sitepickcreate'">
                            <h5 class="card-title"><strong><g:message
                                    code="mapConfiguration.user.pick.site.title"/></strong></h5>
                            <h5><small class="text-muted"><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-sites-pick-one'} -->
                            <!-- /ko -->

                            <hr/>

                            <h5><strong><g:message
                                    code="mapConfiguration.user.created.site.title"/></strong></h5>
                            <h5><small class="text-muted"><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-site-create'} -->
                            <!-- /ko -->

                            <hr/>

                            <h5><strong><g:message
                                    code="mapConfiguration.map.behaviour.title"/></strong></h5>
                            <!-- ko template: {name: 'template-site-add-to-project'} -->
                            <!-- /ko -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-3">
            <div class="col-sm-12">
                <h3><g:message code="mapConfiguration.step.two.title"/></h3>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <map-config-selector
                        params="allBaseLayers: fcConfig.allBaseLayers, allOverlays: fcConfig.allOverlays, mapLayersConfig: $parent.mapLayersConfig, type: 'project'"></map-config-selector>
            </div>
        </div>


        <div class="row">
            <div class="col-sm-12">
                <button class="btn btn-primary-dark btn-sm block" data-bind="click: $parent.saveMapConfig, enable: isSiteConfigValid()"><i
                        class="fas fa-hdd"></i>  Save</button>
            </div>
        </div>
    </div>
    <!-- /ko -->
</div>
<script>

</script>

<script id="template-sites-pick-one" type="text/html">
<div data-validation-engine="validate[funcCall[isSiteSelectionConfigValid]]" data-prompt-position="inline"
     data-position-type="inline" data-prompt-target="sites-pick-one-message-container">
    <div id="sites-pick-one-message-container"></div>

    <div id="survey-site-list" class="row">
        <div class="col-sm-12">
            <div style="max-height: 500px; overflow-y: auto;">
                <div class="row no-gutters" data-bind="if: transients.sites.length > 1">
                    <div class="col-sm-6">
                        <div class="custom-checkbox">
                            <input id="selectall" type="checkbox" data-bind="checked: transients.isSelectAllSites, click: transients.selectAllSites">
                            <label for="selectall"><g:message code="mapConfiguration.site.selectall.title"/></label>
                        </div>
                    </div>
                </div>
                <!-- ko foreach: transients.sites -->
                <!-- ko if: !$parent.transients.isProjectArea($data.siteId) -->
                <div class="row no-gutters">
                    <div class="col-sm-6">
                        <label class="checkbox">
                            <input type="checkbox" data-bind="checkedValue: $data.siteId, checked: $parent.sites">
                            <a class="btn-link" target="_blank"
                               data-bind="attr:{href: $parent.transients.siteUrl($data)}, text: name"></a>
                        </label>
                    </div>

                    <div class="col-sm-6 btn-space">
                        <a class="btn btn-sm btn-dark" target="_blank"
                           data-bind="attr:{href: $parent.transients.siteUrl($data)}" role="button">
                            <i class="far fa-eye"></i>
                            <g:message code="btn.view"/>
                        </a>
                        <button class="btn btn-sm btn-danger"
                                data-bind="click: $parent.transients.deleteSite, disable: $parent.transients.isSiteDeleteDisabled.bind($data)()">
                            <i class="far fa-trash-alt"></i>
                            <g:message code="btn.delete"/>
                        </button>
                    </div>
                </div>
                <!-- /ko -->
                <!-- /ko -->
            </div>
            <!-- ko if: transients.sites.length == 0 -->
            <div class="alert-info">
                <g:message code="mapConfiguration.site.selection.title"/>
            </div>
            <!-- /ko -->
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
                <g:message code="mapConfiguration.site.create.choose.title"></g:message>
                <button class="btn btn-dark btn-sm" data-bind="click: $parent.redirectToSelect"><i
                        class="fas fa-list-ol"></i> <g:message code="mapConfiguration.site.existing.selection"/>
                </button>
                <button class="btn btn-dark btn-sm" data-bind="click: $parent.redirectToCreate"><i
                        class="fas fa-plus"></i> <g:message code="mapConfiguration.site.create"/>
                </button>
                <button class="btn btn-dark btn-sm" data-bind="click: $parent.redirectToUpload"><i
                        class="fas fa-file-upload"></i> <g:message code="mapConfiguration.site.upload"/></button>
        </div>
    </div>
</div>
</script>
<script id="template-site-create" type="text/html">
<div>
    <div id="site-create-message-container"></div>
    <div class="row" data-validation-engine="validate[funcCall[isUserSiteCreationConfigValid]]"
         data-prompt-position="inline" data-position-type="inline" data-prompt-target="site-create-message-container">
        <div class="col-sm-12">
            <div id="survey-site-create" class="row">
                <div class="col-sm-12">
                    <div class="form-group form-check">
                        <input class="form-check-input" type="checkbox" data-bind="checked: allowPoints"/>
                        <label class="form-check-label">
                            <g:message code="mapConfiguration.site.point"/>
                        </label>
                    </div>
                    <div class="form-group form-check">
                        <input class="form-check-input" type="checkbox" data-bind="checked: allowPolygons"/>
                        <label class="form-check-label">
                            <g:message code="mapConfiguration.site.polygon"/>
                        </label>
                    </div>
                    <div class="form-group form-check">
                        <input class="form-check-input" type="checkbox" data-bind="checked: allowLine"/>
                        <label class="form-check-label">
                            <g:message code="mapConfiguration.site.line"/>
                        </label>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</script>
<script id="template-site-add-to-project" type="text/html">
<div class="row">
    <div class="col-sm-12">
        <div class="form-group form-check">
            <input class="form-check-input" type="checkbox"
                   data-bind="checked: addCreatedSiteToListOfSelectedSites, disable: !!isUserSiteCreationConfigValid()"/>
            <label class="form-check-label">
                 <g:message
                    code="mapConfiguration.site.create.add.to.project"/>
            </label>
        </div>
        <div class="alert alert-info"><g:message
                code="mapConfiguration.addCreatedSiteToListOfSelectedSites.help.text"/></div>
    </div>
</div>
</script>
