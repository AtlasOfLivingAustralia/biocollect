<div id="pActivitySites" class="well">

    <!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row-fluid">
        <div class="span10 text-left">
            <h2 class="strong"><g:message code="survey.sites.title"/> </h2>
        </div>
        <div class="span2 text-right">
            <g:render template="/projectActivity/status"/>
        </div>
    </div>

    <g:render template="/projectActivity/warning"/>

    <div class="row-fluid">
        <div class="span12">
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

            <div id="site-pick" class="accordion-body collapse" data-bind="css: { 'in': transients.surveySiteOption == 'sitepick' }">
                <div class="accordion-inner" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepick' }">
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

            <div id="site-create" class="accordion-body collapse" data-bind="css: { 'in': transients.surveySiteOption == 'sitecreate' }">
                <div class="accordion-inner" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitecreate' }">
                    <div class="margin-left-30" data-bind="if: surveySiteOption() === 'sitecreate', slideVisible: surveySiteOption() === 'sitecreate'">
                        <h5><strong><g:message code="mapConfiguration.user.created.site.title"/></strong></h5>
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
                <div class="accordion-inner" data-bind="css: {'bg-selected-color':  surveySiteOption() === 'sitepickcreate' }">
                    <div class="margin-left-30" data-bind="if: surveySiteOption() === 'sitepickcreate', slideVisible: surveySiteOption() === 'sitepickcreate'">
                        <h5><strong><g:message code="mapConfiguration.user.pick.site.title"/></strong></h5>
                        <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                        <!-- ko template: {name: 'template-sites-pick-one'} -->
                        <!-- /ko -->

                        <hr/>

                        <h5><strong><g:message
                                code="mapConfiguration.user.created.site.title"/></strong></h5>
                        <h5><small><span class="req-field"></span> <g:message code="mapConfiguration.site.mandatory.title"/></small></h5>
                        <!-- ko template: {name: 'template-site-create'} -->
                        <!-- /ko -->

                        <hr>

                        <h5><strong><g:message
                                code="mapConfiguration.map.behaviour.title"/></strong></h5>
                        <!-- ko template: {name: 'template-site-add-to-project'} -->
                        <!-- /ko -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <h3><g:message code="mapConfiguration.step.two.title"/></h3>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <map-config-selector params="allBaseLayers: fcConfig.allBaseLayers, allOverlays: fcConfig.allOverlays, mapLayersConfig: mapLayersConfig, type: 'survey'"></map-config-selector>        </div>
    </div>

    <!-- /ko -->
    <!-- /ko -->
</div>

<!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn btn-small block" data-bind="click: $parent.saveSites"><i class="icon-white  icon-hdd" ></i>  Save </button>
            <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-species-tab'}"><i class="icon-white icon-chevron-left" ></i>Back</button>
            <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-publish-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
        </div>
    </div>
    <!-- /ko -->
<!-- /ko -->

<script id="template-sites-pick-one" type="text/html">
<div>
    <div id="sites-pick-one-message-container"></div>
    <div id="survey-site-list" class="row-fluid" data-validation-engine="validate[funcCall[isSiteSelectionConfigValid]]" data-prompt-position="inline" data-position-type="inline" data-prompt-target="sites-pick-one-message-container">
        <div class="span12">
            <div style="max-height: 500px; overflow-y: auto;">
                <div class="row-fluid" data-bind="if: sites().length > 1">
                    <div class="span6">
                        <div class="large-checkbox">
                            <input id="selectall" type="checkbox" data-bind="checked: transients.isSelectAllSites, click: transients.selectAllSites">
                            <label for="selectall"><span></span> <g:message code="mapConfiguration.site.selectall.title"/></label>
                        </div>
                    </div>
                </div>
                <!-- ko foreach: sites -->
                <div class="row-fluid">
                    <div class="span6">
                        <label class="checkbox">
                            <input type="checkbox" data-bind="checked: added">
                            <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl}, text: name"></a>
                        </label>
                    </div>
                    <div class="span6">
                        <a class="btn btn-mini btn-default" target="_blank" data-bind="attr:{href: siteUrl}" role="button">
                            <i class="icon-eye-open"></i>
                            <g:message code="btn.view"/>
                        </a>
                        <button class="btn btn-mini btn-danger" data-bind="disable: transients.isSiteDeleteDisabled(), click: transients.deleteSite">
                            <i class="icon-remove icon-white"></i>
                            <g:message code="btn.delete"/>
                        </button>
                    </div>
                </div>
                <!-- /ko -->
            </div>
            <div class="row-fluid padding-top-10">
                <div class="span12">
                    <label>
                        <g:message code="mapConfiguration.site.create.choose.title"></g:message>
                        <button class="btn-default btn btn-small" data-bind="click: $parent.redirectToSelect, disable: transients.warning()"><i class="icon-folder-open"></i> <g:message code="mapConfiguration.site.existing.selection"></g:message> </button>
                        <g:if test="${hubConfig?.isSystematic}">
                            <button class="btn-default btn btn-small" data-bind="click: $parent.redirectToCreateSystematic, disable: transients.warning()"><i class="icon-plus"></i> <g:message code="mapConfiguration.site.createSystematic"/> </button>
                        </g:if>
                        <g:else>
                            <button class="btn-default btn btn-small" data-bind="click: $parent.redirectToCreate, disable: transients.warning()"><i class="icon-plus"></i> <g:message code="mapConfiguration.site.create"></g:message> </button>
                        </g:else>
                        <button class="btn-default btn btn-small" data-bind="click: $parent.redirectToUpload, disable: transients.warning()"><i class="icon-arrow-up"></i> <g:message code="mapConfiguration.site.upload"></g:message> </button>
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
    <div id="survey-site-create" class="row-fluid">
        <div class="span12">
            <label class="checkbox">
                <input type="checkbox" data-bind="checked: allowPoints"/>  <g:message code="mapConfiguration.site.point" />
            </label>
            <label class="checkbox">
                <input type="checkbox" data-bind="checked: allowPolygons"/> <g:message code="mapConfiguration.site.polygon" />
            </label>
            <label class="checkbox">
                <input type="checkbox" data-bind="checked: allowLine"/> <g:message code="mapConfiguration.site.line" />
            </label>
        </div>
    </div>
</div>
</script>
<script id="template-site-add-to-project" type="text/html">
<div class="row-fluid">
    <div class="span6">
        <label class="checkbox">
            <input type="checkbox" data-bind="checked: addCreatedSiteToListOfSelectedSites, disable: !!isUserSiteCreationConfigValid()"/>
            <g:message code="mapConfiguration.site.create.add.to.project"/>
        </label>
        <span class="help-block"><g:message
                code="mapConfiguration.addCreatedSiteToListOfSelectedSites.help.text"/></span>
    </div>
</div>
</script>
<script id="template-site-zoom" type="text/html">
<div class="row-fluid">
    <div class="span6">
        <label>
            <g:message code="mapConfiguration.zoom.area"/>
            <select id="siteToZoom1" data-bind="value: defaultZoomArea, foreach: sites">
                <!-- ko if: added() || isProjectArea() -->
                <option data-bind="text: name, value: siteId, attr: {selected: siteId() == $parent.defaultZoomArea()}"></option>
                <!-- /ko -->
            </select>
        </label>
        <span class="help-block"><g:message code="mapConfiguration.zoom.area.help.text"/> </span>
    </div>
</div>
</script>