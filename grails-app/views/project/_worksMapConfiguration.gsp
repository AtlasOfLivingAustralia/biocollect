<div>
    <!-- ko with: mapConfiguration -->
    <div data-bind="css: {'ajax-opacity': transients.loading}">
        <div class="row">
            <div class="col-sm-12 text-left">
                <h2 class="strong"><g:message code="mapConfiguration.heading"/></h2>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <h3><g:message code="mapConfiguration.step.one.title"/></h3>
            </div>
        </div>

        <div class="accordion" id="site-accordion">
            <div class="accordion-group">
                <div class="accordion-heading">
                    <div class="accordion-toggle">
                        <label class="radio">
                            <input type="radio" name="siteType"
                                   data-bind="checked: surveySiteOption, click: transients.toggleSiteOptionPanel.bind({accordionLinkId:'#site-pick-link'}), clickBubble: false" value="sitepick"/>
                            <a id="site-pick-link" data-toggle="collapse" data-parent="#site-accordion" href="#site-pick"
                               data-bind="click: transients.setSurveySiteOption.bind({value: 'sitepick'})">
                                <h4><g:message code="mapConfiguration.sites.pick.title"/></h4>
                            </a>
                        </label>
                    </div>

                </div>

                <div id="site-pick" class="accordion-body collapse"  data-bind="css: { 'in': transients.surveySiteOption == 'sitepick'}">
                    <div class="accordion-inner" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepick'}">
                        <div class="margin-left-30" data-bind="if: surveySiteOption() === 'sitepick', slideVisible: surveySiteOption() === 'sitepick'">
                            <h5><strong><g:message
                                    code="mapConfiguration.user.pick.site.title"/></strong></h5>
                            <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-sites-pick-one'} -->
                            <!-- /ko -->

                        </div>
                    </div>
                </div>
            </div>

            <div class="accordion-group">
                <div class="accordion-heading">
                    <div class="accordion-toggle">
                        <label class="radio">
                            <input type="radio" name="siteType"
                                   data-bind="checked: surveySiteOption, click: transients.toggleSiteOptionPanel.bind({accordionLinkId:'#site-create-link'}), clickBubble: false" value="sitecreate"/>
                            <a id="site-create-link" data-toggle="collapse" data-parent="#site-accordion" href="#site-create"
                               data-bind="click: transients.setSurveySiteOption.bind({value:'sitecreate'})">
                                <h4><g:message code="mapConfiguration.sites.create.title"/></h4>
                            </a>
                        </label>
                    </div>
                </div>

                <div id="site-create" class="accordion-body collapse"  data-bind="css: { 'in': transients.surveySiteOption == 'sitecreate' }">
                    <div class="accordion-inner" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitecreate'}">
                        <div class="margin-left-30" data-bind="if: surveySiteOption() === 'sitecreate', slideVisible: surveySiteOption() === 'sitecreate'">
                            <h5><strong><g:message
                                    code="mapConfiguration.user.created.site.title"/></strong></h5>
                            <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-site-create'} -->
                            <!-- /ko -->

                        </div>
                    </div>
                </div>
            </div>

            <div class="accordion-group">
                <div class="accordion-heading">
                    <div class="accordion-toggle">
                        <label class="radio">
                            <input type="radio" name="siteType"
                                   data-bind="checked: surveySiteOption, click: transients.toggleSiteOptionPanel.bind({accordionLinkId:'#site-pick-create-link'}), clickBubble: false" value="sitepickcreate"/>
                            <a id="site-pick-create-link" data-toggle="collapse" data-parent="#site-accordion"
                               href="#site-pick-create" data-bind="click: transients.setSurveySiteOption.bind({value:'sitepickcreate'})">
                                <h4><g:message code="mapConfiguration.sites.both.title"/></h4>
                            </a>
                        </label>
                    </div>
                </div>

                <div id="site-pick-create" class="accordion-body collapse" data-bind="css: { 'in': transients.surveySiteOption == 'sitepickcreate' }">
                    <div class="accordion-inner" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepickcreate'}">
                        <div class="margin-left-30" data-bind="if: surveySiteOption() === 'sitepickcreate', slideVisible: surveySiteOption() === 'sitepickcreate'">
                            <h5><strong><g:message
                                    code="mapConfiguration.user.pick.site.title"/></strong></h5>
                            <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-sites-pick-one'} -->
                            <!-- /ko -->

                            <hr/>

                            <h5><strong><g:message
                                    code="mapConfiguration.user.created.site.title"/></strong></h5>
                            <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-site-create'} -->
                            <!-- /ko -->

                            <hr/>

                            <h5><strong><g:message
                                    code="mapConfiguration.map.behaviour.title"/></strong></h5>
                            <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                            <!-- ko template: {name: 'template-site-add-to-project'} -->
                            <!-- /ko -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
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
                <button class="btn btn-primary-dark btn-sm block" data-bind="click: $parent.saveMapConfig"><i
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
                <div class="row" data-bind="if: transients.sites.length > 1">
                    <div class="col-sm-6">
                        <div class="large-checkbox">
                            <input id="selectall" type="checkbox" data-bind="checked: transients.isSelectAllSites, click: transients.selectAllSites">
                            <label for="selectall"><span></span> <g:message code="mapConfiguration.site.selectall.title"/></label>
                        </div>
                    </div>
                </div>
                <!-- ko foreach: transients.sites -->
                <div class="row">
                    <div class="col-sm-6">
                        <label class="checkbox">
                            <input type="checkbox" data-bind="checkedValue: $data.siteId, checked: $parent.sites">
                            <a class="btn-link" target="_blank"
                               data-bind="attr:{href: $parent.transients.siteUrl($data)}, text: name"></a>
                        </label>
                    </div>

                    <div class="col-sm-6">
                        <a class="btn btn-mini btn-dark" target="_blank"
                           data-bind="attr:{href: $parent.transients.siteUrl($data)}" role="button">
                            <i class="icon-eye-open"></i>
                            <g:message code="btn.view"/>
                        </a>
                        <button class="btn btn-mini btn-danger"
                                data-bind="click: $parent.transients.deleteSite, disable: $parent.transients.isSiteDeleteDisabled.bind($data)()">
                            <i class="icon-remove icon-white"></i>
                            <g:message code="btn.delete"/>
                        </button>
                    </div>
                </div>
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
            <label>
                <g:message code="mapConfiguration.site.create.choose.title"></g:message>
                <button class="btn-dark btn btn-sm block" data-bind="click: $parent.redirectToSelect"><i
                        class="icon-folder-open"></i> <g:message code="mapConfiguration.site.existing.selection"/>
                </button>
                <button class="btn-dark btn btn-sm block" data-bind="click: $parent.redirectToCreate"><i
                        class="icon-plus"></i> <g:message code="mapConfiguration.site.create"/>
                </button>
                <button class="btn-dark btn btn-sm block" data-bind="click: $parent.redirectToUpload"><i
                        class="icon-arrow-up"></i> <g:message code="mapConfiguration.site.upload"/></button>
            </label>
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
                    <label class="checkbox">
                        <input type="checkbox" data-bind="checked: allowPoints"/>  <g:message code="mapConfiguration.site.point"/>
                    </label>
                    <label class="checkbox">
                        <input type="checkbox" data-bind="checked: allowPolygons"/> <g:message code="mapConfiguration.site.polygon"/>
                    </label>
                    <label class="checkbox">
                        <input type="checkbox" data-bind="checked: allowLine"/> <g:message code="mapConfiguration.site.line"/>
                    </label>
                </div>
            </div>
        </div>
    </div>
</div>
</script>
<script id="template-site-add-to-project" type="text/html">
<div class="row">
    <div class="col-sm-6">
        <label class="checkbox">
            <input type="checkbox"
                   data-bind="checked: addCreatedSiteToListOfSelectedSites, disable: !!isUserSiteCreationConfigValid()"/> <g:message
                code="mapConfiguration.site.create.add.to.project"/>
        </label>
        <span class="help-block"><g:message
                code="mapConfiguration.addCreatedSiteToListOfSelectedSites.help.text"/></span>
    </div>
</div>
</script>