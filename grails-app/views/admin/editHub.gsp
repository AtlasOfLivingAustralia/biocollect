<!doctype html>
<html>
<head>
    <meta name="layout" content="adminLayout"/>
    <title>Metadata | Admin | Data capture | Atlas of Living Australia</title>
    <asset:script type="text/javascript">
        fcConfig = {
            listHubsUrl:"${createLink(controller: 'admin', action: 'listHubs')}",
            getHubUrl:"${createLink(controller: 'admin', action: 'loadHubSettings')}",
            saveHubUrl:"${createLink(controller: 'admin', action: 'saveHubSettings')}",
            listProjectFacetUrl: "${createLink(controller: 'project', action: 'getFacets')}",
            listDynamicFacetsUrl: "${createLink(controller: 'bioActivity', action: 'getFacets')}",
            listDataColumnsUrl: "${createLink(controller: 'bioActivity', action: 'getDataColumns')}"
        };
    </asset:script>
</head>

<body>
<asset:stylesheet src="admin.css"/>
<asset:stylesheet src="fileupload-ui-manifest.css"/>
<asset:javascript src="common.js"/>
<asset:javascript src="fileupload-manifest.js"/>
<asset:javascript src="document.js"/>
<asset:javascript src="hubs.js"/>

<content tag="pageTitle">Create / Edit Hub</content>

<div class="alert alert-info">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <span>You are viewing the hub: ${hubConfig.urlPath}</span>
</div>

<div class="alert" data-bind="visible:message()">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <span data-bind="text:message"></span>
</div>
<div class="row-fluid">
    <div class="span4">
        Configured hubs: <select data-bind="value:selectedHubUrlPath, options:hubs"></select>
    </div>
    <div class="span2">
        <button class="btn btn-info" data-bind="click:editHub">Edit <span data-bind="text:selectedHubUrlPath"></span></button>
        <button class="btn btn-info" data-bind="click:newHub">New Hub</button>
    </div>

</div>

<hr/>

<div class="selected-hub form-horizontal" data-bind="visible:selectedHub(), with:selectedHub">
    <h2><span data-bind="visible:hubId">Editing: </span><span data-bind="visible:!hubId()">Creating: </span> <span data-bind="text:urlPath"></span></h2>
    <ul class="nav nav-tabs">
        <li class="active">
            <a href="#hubPrograms" data-toggle="tab">Programs</a>
        </li>
        <li><a href="#hubTemplate"  data-toggle="tab">Template</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubHeader"  data-toggle="tab">Header</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubFooter"  data-toggle="tab">Footer</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubBanner"  data-toggle="tab">Banner</a></li>
        <li><a href="#hubContent"  data-toggle="tab">Content</a></li>
        <li><a href="#hubFacet"  data-toggle="tab">Facets</a></li>
        <li><a href="#hubData"  data-toggle="tab">Data</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubHomepage"  data-toggle="tab">Homepage</a></li>
    </ul>
    <div class="tab-content">
        <div class="tab-pane active" id="hubPrograms">

            <div class="control-group">
                <label class="control-label" for="name">URL path (added to URL to select the hub)</label>
                <div class="controls required">
                    <input type="text" id="name" class="input-xxlarge" data-bind="value:urlPath" data-validation-engine="validate[required]">
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="description">Title</label>
                <div class="controls required">
                    <textarea rows="3" class="input-xxlarge" data-bind="value:title" data-validation-engine="validate[required]" id="description" placeholder="Displays as a heading on the home page"></textarea>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="description">Home Page Path</label>
                <div class="controls required">
                    <input type="text" class="input-xxlarge" data-bind="value:homePagePath" placeholder="Relative path to home page (leave blank for default)"></input>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="supported-programs">Supported Programs (Projects in this hub can only select from these programs)</label>
                <div class="controls">
                    <ul id="supported-programs" data-bind="foreach:$parent.transients.programNames" class="unstyled">
                        <li><label><input type="checkbox" data-bind="checked:$parent.supportedPrograms, attr:{value:$data}"> <span data-bind="text:$data"></span></label></li>
                    </ul>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="default-program">Default program (new projects created from this hub will inherit this program)</label>
                <div class="controls">
                    <select id="default-program" data-bind="value:defaultProgram, options:supportedPrograms"></select>
                </div>
            </div>
        </div>

        <div class="tab-pane" id="hubTemplate">
            <div class="control-group">
                <label class="control-label" for="skin">Skin</label>
                <div class="controls required">
                    <select id="skin" data-bind="value:skin,options:$parent.transients.availableSkins" data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div data-bind="slideVisible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: styles -->
                        <div class="control-group">
                            <label class="control-label" for="skin">Colour scheme</label>
                            <div class="controls">
                                <!-- ko template: { name: 'templateStyles'} -->
                                <!-- /ko -->
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label" for="skin">Preview</label>
                            <div class="controls">
                                <!-- ko template: { name: 'templatePreviewHomePage'} -->
                                <!-- /ko -->
                            </div>
                        </div>
                    <!-- /ko -->
                <!-- /ko -->
            </div>
        </div>
        <div class="tab-pane" id="hubHeader">
            <div data-bind="visible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: header -->
                        <h3>Header</h3>
                        <div>
                            Choose between the following header options: <select data-bind="value: type">
                                <option value="">Please choose</option>
                                <option value="ala">ALA</option>
                                <option value="biocollect">Biocollect classic</option>
                                <option value="custom">Custom header</option>
                            </select>
                        </div>
                        <h3>Custom Header Settings</h3>
                        <!-- ko template: {name: 'templateLinkNotes'} -->
                        <!-- /ko -->
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Display name</th>
                                    <th>Content type</th>
                                    <th>Href value</th>
                                    <th>Role</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- ko foreach: links -->
                                <!-- ko template: { name: 'templateLink', data: {disableRoles:false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                                <!-- /ko -->
                                <!-- /ko -->
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td>
                                        <button type="button" class="btn" data-bind="click: addLink"><i class="icon-plus"></i> Add link</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                <!-- /ko -->
                <!-- /ko -->
            </div>

            <div data-bind="visible: !transients.isSkinAConfigurableTemplate()">
                <!-- ko template: {name: 'configurableTemplateNotSelectedMessage'} -->
                <!-- /ko -->
            </div>
        </div>
        <div class="tab-pane" id="hubFooter">
            <div data-bind="visible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: footer -->
                    <div>
                        <h3>Footer</h3>
                        <div>
                            Choose between the following footer options: <select data-bind="value: type">
                            <option value="">Please choose</option>
                            <option value="ala">ALA</option>
                            <option value="custom">Custom footer</option>
                        </select>
                        </div>
                        <h3>Custom Footer Settings</h3>
                        <div class="">
                            <!-- ko template: {name: 'templateLinkNotes'} -->
                            <!-- /ko -->
                            <table class="table">
                                <thead>
                                <tr>
                                    <th>Display name</th>
                                    <th>Content type</th>
                                    <th>Href value</th>
                                    <th>Role</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <!-- ko foreach: links -->
                                <!-- ko template: { name: 'templateLink', data: {disableRoles:false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                                <!-- /ko -->
                                <!-- /ko -->
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td>
                                        <button type="button" class="btn" data-bind="click: addLink"><i class="icon-plus"></i> Add link</button>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div>
                        <h3>Social media</h3>
                        <div>
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Social media company</th>
                                        <th>Link</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- ko foreach: socials -->
                                        <!-- ko template: { name: 'templateSocial'} -->
                                        <!-- /ko -->
                                    <!-- /ko -->
                                    <tr>
                                        <td></td>
                                        <td></td>
                                        <td>
                                            <button type="button" class="btn" data-bind="click: addSocialMedia"><i class="icon-plus"></i> Add social media</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <!-- /ko -->
                <!-- /ko -->
            </div>

            <div data-bind="visible: !transients.isSkinAConfigurableTemplate()">
                <!-- ko template: {name: 'configurableTemplateNotSelectedMessage'} -->
                <!-- /ko -->
            </div>
        </div>
        <div class="tab-pane" id="hubBanner">
            <div>
                <h3>Logo image</h3>
                <div class="row-fluid">
                    <div class="span6">
                        <img data-bind="visible:logoUrl(), attr:{src:logoUrl}">
                    </div>
                    <div class="offset4 span2">
                        <button type="button" class="btn  btn-small btn-danger" data-bind="visible:logoUrl(), click:removeLogo"><i class="icon icon-white icon-remove"></i> Remove Logo</button>
                        <span class="btn fileinput-button pull-right"
                              data-url="${createLink(controller: 'image', action:'upload')}"
                              data-role="logo"
                              data-owner-type="hubId"
                              data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents, visible:!logoUrl()"><i class="icon-plus"></i> <input id="logo" type="file" name="files"><span>Attach Organisation Logo</span></span>
                    </div>
                </div>
            </div>
            <div>
                <h3>Carousel settings</h3>
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: banner -->
                        <div class="row-fluid" data-bind="slideVisible: images().length">
                            <div class="span6">Carousel image transition speed in milli-seconds (ms)</div>
                            <div class="span2">
                                <input type="number" data-bind="value: transitionSpeed">
                            </div>
                            <div class="row-fluid"><div class="span12"></div></div>
                        </div>
                        <h4>Carousel images</h4>
                        <!-- ko foreach: images -->
                            <div class="row-fluid">
                                <div class="span6">
                                    <img data-bind="visible: url, attr:{src:url}">
                                </div>
                                <div class="span4">
                                    <textarea data-bind="value: caption"></textarea>
                                </div>
                                <div class="span2">
                                    <button type="button" class="btn btn-small btn-danger" data-bind="visible:$data, click:$parent.removeBanner"><i class="icon icon-remove icon-white"></i> Remove Banner</button>
                                </div>
                                <div class="row-fluid"><div class="span12"></div></div>
                            </div>
                        <!-- /ko -->
                        %{-- END bannerImages --}%
                    <!-- /ko -->
                <!-- /ko -->
                <div class="row-fluid">
                    <div class="span10"></div>
                    <div class="span2">
                        <span class="btn fileinput-button pull-right  btn-small"
                              data-url="${createLink(controller: 'image', action:'upload')}"
                              data-role="banner"
                              data-owner-type="hubId"
                              data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents"><i class="icon-plus"></i> <input id="banner" type="file" name="files"><span>Attach Banner Image</span></span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane" id="hubContent">
            <div>
                <h3>Settings</h3>
                <!-- ko with: content-->
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideBreadCrumbs"> Hide bread crumbs
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectAndSurvey"> Hide project and survey when listing records on pages like all records
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideCancelButtonOnForm"> Hide cancel button on form create page
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: isContainer"> Content should be in a fixed width container
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: showNote"> Show note on record listing page
                </div>
                <div class="margin-top-1 row-fluid" data-bind="slideVisible: showNote">
                    <textarea class="span6" data-bind="value: recordNote">

                    </textarea>
                </div>
                <!-- /ko -->
                <h3>Quick links</h3>
                <small>Links that appear on certain content pages like create, view, all records etc.</small>
                <!-- ko template: {name: 'templateLinkNotes'} -->
                <!-- /ko -->
                <table class="table">
                    <thead>
                    <tr>
                        <th>Display name</th>
                        <th>Content type</th>
                        <th>Href value</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <!-- ko foreach: quickLinks -->
                    <!-- ko template: { name: 'templateLink', data: {$parent: $parent, disableRoles:true, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                    <!-- /ko -->
                    <!-- /ko -->
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td>
                            <button type="button" class="btn" data-bind="click: addLink"><i class="icon-plus"></i> Add link</button>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <h3>Custom Breadcrumbs</h3>
                <small>Add breadcrumbs for specific controller actions.  Initially designed so that sightings can have custom breadcrumbs on all its pages</small>
                <!-- ko template: {name: 'templateLinkNotes'} -->
                <!-- /ko -->
                <table class="table">
                    <thead>
                    <tr>
                        <th>Controller name</th>
                        <th>Controller action</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <!-- ko foreach: customBreadCrumbs -->
                    <!-- ko template: { name: 'templateCustomBreadCrumb'} -->
                    <!-- /ko -->
                    <!-- /ko -->
                    <tr>
                        <td></td>
                        <td></td>
                        <td>
                            <button type="button" class="btn" data-bind="click: addCustomBreadCrumb"><i class="icon-plus"></i> Add breadcrumb for a page</button>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <h3>Project Content</h3>
                <small>Configure optional content to record about a project</small>
                <!-- ko with:content -->
                <g:each in="${au.org.ala.biocollect.merit.hub.HubSettings.OPTIONAL_PROJECT_CONTENT}" var="key">
                    <div class="checkbox">
                        <label><input type="checkbox" data-bind="checked:${key}"> <g:message code="project.optionalContent.${key}" default="${key}"></g:message></label>
                    </div>
                </g:each>
                <!-- /ko -->

            </div>
        </div>
        <div class="tab-pane" id="hubFacet">
            <div class="control-group">
                <label class="control-label" for="default-facets-list">Default Facet Query (Searches will automatically include these facets)</label>
                <div class="controls">
                    <ul id="default-facets-list" data-bind="foreach:defaultFacetQuery" class="unstyled">
                        <li>
                            <input type="text" class="input-xxlarge"  data-bind="value:query" placeholder="query string as produced by the home page"> <button class="btn" data-bind="click:$parent.removeDefaultFacetQuery">Remove</button>
                        </li>
                    </ul>
                    <button class="btn" data-bind="click:addDefaultFacetQuery">Add</button>

                </div>
            </div>

            <div class="border-bottom-4">
                <h4><strong>Configure project finder facets</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.projectFinder } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="margin-bottom-20 border-bottom-4">
                <h4><strong>Configure facets on all records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.allRecords } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="margin-bottom-20 border-bottom-4">
                <h4><strong>Configure facets on my records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.myRecords } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="margin-bottom-20 border-bottom-4">
                <h4><strong>Configure facets on project's data tab</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.project } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="margin-bottom-20 border-bottom-4">
                <h4><strong>Configure facets on my project records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.myProjectRecords } -->
                    <!-- /ko -->
                </div>
            </div>


            <div class="margin-bottom-20 border-bottom-4">
                <h4><strong>Configure facets on user's project activity records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.userProjectActivityRecords } -->
                    <!-- /ko -->
                </div>
            </div>


            <div class="margin-bottom-20 border-bottom-4">
                <h4><strong>Configure facets on project records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.projectRecords } -->
                    <!-- /ko -->
                </div>
            </div>
        </div>
        <div class="tab-pane" id="hubData">
            <div class="border-bottom-4">
                <h4><strong>Configure data page table columns</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageColumnConfiguration' } -->
                    <!-- /ko -->
                </div>
            </div>
        </div>
        <div class="tab-pane" id="hubHomepage">
            <div data-bind="visible: transients.isSkinAConfigurableTemplate">
                <div>

                    <!-- ko with: templateConfiguration -->
                        <!-- ko with: homePage -->
                            <div>
                                <h4>Homepage</h4>
                                <div>
                                    <select data-bind="value: homePageConfig">
                                        <option value="projectfinder">Project finder</option>
                                        <option value="buttons">Buttons</option>
                                    </select>
                                </div>
                            </div>
                            <div>
                                <h4>Homepage content settings</h4>
                                <div>
                                    <!-- ko template: {name: 'templateHomePage'} -->
                                    <!-- /ko -->
                                </div>
                            </div>
                    <!-- /ko -->
                    <!-- /ko -->
                </div>
            </div>
            <div data-bind="visible: !transients.isSkinAConfigurableTemplate()">
                <!-- ko template: {name: 'configurableTemplateNotSelectedMessage'} -->
                <!-- /ko -->
            </div>
        </div>
    </div>
    <div class="form-actions">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Save</button>
        <button type="button" id="cancel" class="btn">Cancel</button>
    </div>
</div>

<script id="templateLink" type="text/html">
    <tr>
        <td>
            <input type="text" data-bind="value: link.displayName"/>
        </td>
        <td>
            <select data-bind="value: link.contentType">
                <option value="content">Biocollect content</option>
                <option value="static">Static page</option>
                <option value="external">External link</option>
                <option value="nolink">No link - text only</option>
                <option value="">---------</option>
                <option value="admin">Admin</option>
                <option value="allrecords">All Records</option>
                <option value="home">Home</option>
                <option value="login">Login / Logout</option>
                <option value="newproject">New Project</option>
                <option value="sites">Sites</option>
                <option value="biocacheexplorer">Biocache Explorer</option>
                <option value="recordSighting">Record a Sighting</option>
            </select>
        </td>
        <td>
            <input type="text" data-bind="value: link.href"/>
        </td>
        <!-- ko if:!disableRoles -->
        <td>
            <select data-bind="value: link.role">
                <option value="">Anyone</option>
                <g:render template="/admin/userRoleOptions"/>
            </select>
        </td>
        <!-- /ko -->
        <td>
            <button class="btn btn-danger" data-bind="click: removeLink">
                <i class="icon icon-remove icon-white"></i> Remove
            </button>
        </td>
    </tr>
</script>

<script id="templateCustomBreadCrumb" type="text/html">
    <tr>
        <td>
            <input type="text" data-bind="value: controllerName"/>
        </td>
        <td>
            <input type="text" data-bind="value: actionName"/>
        </td>
        <td>
            <button class="btn btn-danger" data-bind="click: $parent.removeCustomBreadCrumb">
                <i class="icon icon-remove icon-white"></i> Remove
            </button>
        </td>
    </tr>
    <tr>
        <td>
            <b>Breadcrumbs</b>
        </td>
        <td colspan="2">
            <table class="table">
                <thead>
                <tr>
                    <th>Display name</th>
                    <th>Content type</th>
                    <th>Href value</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <!-- ko foreach: breadCrumbs -->
                <!-- ko template: { name: 'templateLink', data: {$parent: $parent, disableRoles:true, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                <!-- /ko -->
                <!-- /ko -->
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>
                        <button type="button" class="btn" data-bind="click: addBreadCrumb"><i class="icon-plus"></i> Add a breadcrumb</button>
                    </td>
                </tr>
                </tbody>
            </table>
        </td>
    </tr>
</script>

<script id="templateSocial" type="text/html">
    <tr>
        <td>
            <select data-bind="value: contentType">
                <option value="youtube">Youtube</option>
                <option value="facebook">Facebook</option>
                <option value="twitter">Twitter</option>
            </select>
        </td>
        <td>
            <input type="text" data-bind="value: href"/>
        </td>
        <td>
            <button class="btn btn-small btn-danger" data-bind="click: $parent.removeLink">
                <i class="icon icon-remove icon-white"></i> Remove
            </button>
        </td>
    </tr>
</script>

<script id="templateStyles" type="text/html">
    <table class="table borderless">
        <thead>
        <tr>
            <th>Styling Component</th>
            <th>Hex value</th>
            <th>Preview</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td>Menu background colour</td>
            <td><input type="text" data-bind="value: menuBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':menuBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Menu text colour</td>
            <td><input type="text" data-bind="value: menuTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':menuTextColor}"></div></td>
        </tr>
        <tr>
            <td>Header banner space background colour</td>
            <td><input type="text" data-bind="value: headerBannerBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':headerBannerBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Banner background colour</td>
            <td><input type="text" data-bind="value: bannerBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':bannerBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Inset panel background colour</td>
            <td><input type="text" data-bind="value: insetBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':insetBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Inset panel text colour</td>
            <td><input type="text" data-bind="value: insetTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':insetTextColor}"></div></td>
        </tr>
        <tr>
            <td>Body background colour</td>
            <td><input type="text" data-bind="value: bodyBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':bodyBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Body text colour</td>
            <td><input type="text" data-bind="value: bodyTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':bodyTextColor}"></div></td>
        </tr>
        <tr>
            <td>Title text colour</td>
            <td><input type="text" data-bind="value: titleTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':titleTextColor}"></div></td>
        </tr>
        <tr>
            <td>Primary button colour</td>
            <td><input type="text" data-bind="value: primaryButtonBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':primaryButtonBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Primary button text colour</td>
            <td><input type="text" data-bind="value: primaryButtonTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':primaryButtonTextColor}"></div></td>
        </tr>
        <tr>
            <td>Default button colour</td>
            <td><input type="text" data-bind="value: defaultButtonBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':defaultButtonBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Default button text colour</td>
            <td><input type="text" data-bind="value: defaultButtonTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':defaultButtonTextColor}"></div></td>
        </tr>
        <tr>
            <td>Default button colour when active</td>
            <td><input type="text" data-bind="value: defaultButtonColorActive"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':defaultButtonColorActive}"></div></td>
        </tr>
        <tr>
            <td>Default button background colour when active</td>
            <td><input type="text" data-bind="value: defaultButtonBackgroundColorActive"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':defaultButtonBackgroundColorActive}"></div></td>
        </tr>
        <tr>
            <td>Breadcrumbs background colour</td>
            <td><input type="text" data-bind="value: breadCrumbBackGroundColour"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':breadCrumbBackGroundColour}"></div></td>
        </tr>
        <tr>
            <td>Href colour</td>
            <td><input type="text" data-bind="value: hrefColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':hrefColor}"></div></td>
        </tr>
        <tr>
            <td>Well background colour</td>
            <td><input type="text" data-bind="value: wellBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':wellBackgroundColor}"></div></td>
        </tr>

        <tr>
            <td>Nav text colour</td>
            <td><input type="text" data-bind="value: navTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{color:navTextColor}"></div></td>
        </tr>
        <tr>
            <td>Nav background colour</td>
            <td><input type="text" data-bind="value: navBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':navBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Facet background colour</td>
            <td><input type="text" data-bind="value: facetBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':facetBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Tile background colour</td>
            <td><input type="text" data-bind="value: tileBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':tileBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Footer background colour</td>
            <td><input type="text" data-bind="value: footerBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':footerBackgroundColor}"></div></td>
        </tr>
        <tr>
            <td>Footer text colour</td>
            <td><input type="text" data-bind="value: footerTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':footerTextColor}"></div></td>
        </tr>
        <tr>
            <td>Social media icon colour</td>
            <td><input type="text" data-bind="value: socialTextColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':socialTextColor}"></div></td>
        </tr>
        </tbody>
    </table>
</script>

<script id="templateHomePage" type="text/html">
<div class="accordion" id="homePageConfiguration">
    <div class="accordion-group">
        <div class="accordion-heading">
            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion2" href="#collapseOne">
                Project Finder Home Page Config
            </a>
        </div>
        <div id="collapseOne" class="accordion-body collapse in">
            <!-- ko with: projectFinderConfig -->
                <div class="accordion-inner">
                    <div class="control-group">
                        <label>Default content view:</label>
                        <label class="radio">
                            <input type="radio" name="defaultView" data-bind="checked: defaultView" value="grid">
                            Projects Grid
                        </label>
                        <label class="radio">
                            <input type="radio" name="defaultView" data-bind="checked: defaultView" value="list">
                            Projects List
                        </label>
                        <label class="radio">
                            <input type="radio" name="defaultView" data-bind="checked: defaultView" value="map" disabled>
                            Projects Map
                        </label>
                    </div>
                    <div class="control-group">
                        <label class="checkbox">
                            <input type="checkbox" name="showProjectRegion" data-bind="checked: showProjectRegionSwitch"> Show project region button
                        </label>
                    </div>
                    <div class="control-group">
                        <label class="checkbox">
                            <input type="checkbox" name="showProjectDownloadButton" data-bind="checked: showProjectDownloadButton"> Show project download button (hub admins only)
                        </label>
                    </div>
                </div>
            <!-- /ko -->
        </div>
    </div>
    <div class="accordion-group">
        <div class="accordion-heading">
            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion2" href="#collapseTwo">
                Buttons Home Page Config
            </a>
        </div>
        <div id="collapseTwo" class="accordion-body collapse">
            <!-- ko with: buttonsConfig -->
                <div class="accordion-inner">
                    <div class="control-group">
                        <label class="control-label">Number of columns</label>
                        <div class="controls">
                            <select data-bind="value: numberOfColumns">
                                <option value="1">1</option>
                                <option value="2">2</option>
                                <option value="3">3</option>
                                <option value="4">4</option>
                            </select>
                        </div>
                    </div>

                    <table class="table">
                        <thead>
                        <tr>
                            <th>Display name</th>
                            <th>Content type</th>
                            <th>Href value</th>
                            <th>Role</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <!-- ko foreach: buttons -->
                        <!--ko template: { name: 'templateLink', data: {disableRoles:false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                        <!-- /ko -->
                        <!-- /ko -->
                        <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td>
                                <button type="button" class="btn" data-bind="click: addButton"><i class="icon-plus"></i> Add button</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>

                </div>
            <!-- /ko -->
        </div>
    </div>
</div>
</script>
<script id="configurableTemplateNotSelectedMessage" type="text/html">
    <div class="alert alert-info">
        You can only see options if the hub's skin is of type 'configurable template'.
    </div>
</script>
<script id="templateLinkNotes" type="text/html">
    <div class="alert alert-info">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        <h4>Note!</h4> The value set for href value will vary according to content type selection.<br/>
        <strong>Biocollect content</strong> Href value must start with forward slash - '/' - e.g. '/hub/index'.<br/>
        <strong>Static page</strong> Href value should be a word. This word should be unique to the hub e.g. 'contact'<br/>
        <strong>External link</strong> Href value should be the full address to a website e.g. 'https://www.ala.org.au'.<br/>
        <strong>No link - text only</strong> Only show text. This does not create a hyperlink. Enter text in display name column.<br/>
        <strong>Other settings</strong> Href value for content type such as 'home' is predefined. Hence it should be left empty.
        One exception is 'Record a Sighting'. It is a button which requires href value.
    </div>
</script>
<script id="templatePreviewHomePage" type="text/html">
    <div class="container-fluid">
        <div class="row-fluid previewHeader" data-bind="style:{'background-color': menuBackgroundColor}">
            <ul class="breadcrumb pull-right">
                <li><a href="#" data-bind="style:{color: menuTextColor}">Home</a> <span class="divider" data-bind="style:{color: menuTextColor}">|</span></li>
                <li><a href="#" data-bind="style:{color: menuTextColor}">Data</a> <span class="divider" data-bind="style:{color: menuTextColor}">|</span></li>
                <li><a href="#" data-bind="style:{color: menuTextColor}">Help</a></li>
            </ul>
        </div>
        <div class="row-fluid previewHeaderBannerSpace" data-bind="style:{'background-color': headerBannerBackgroundColor}">

        </div>
        <div class="row-fluid">
            <div class="previewBanner row-fluid"  data-bind="style:{'background-color': bannerBackgroundColor}">
                <div class="offset2 span8 previewBannerImage">
                    <div class="previewLogo text-center"><p>Logo</p></div>
                    <div class="previewInset" data-bind="style:{'background-color': insetBackgroundColor}">
                        <p class="text-center" data-bind="style:{color: insetTextColor}">Inset text</p>
                    </div>
                    <h4 class="text-center">Banner Image</h4>
                </div>
            </div>
            <div class="row-fluid previewBody" data-bind="style:{'background-color': bodyBackgroundColor}">
                <h1 data-bind="style:{color: titleTextColor}">Title text</h1>
                <h1 data-bind="style:{color: bodyTextColor}">Body text</h1>
                <a href="#" data-bind="style:{color: hrefColor}">Link to</a>
                <div class="row-fluid">
                    <div class="offset4 span2 text-center" data-bind="style:{'background-color': primaryButtonBackgroundColor}">
                        <h3  data-bind="style:{color: primaryButtonTextColor}">Primary button</h3>
                    </div>
                    <div class="span2 text-center" data-bind="style:{'background-color': defaultButtonBackgroundColor}">
                        <h3  data-bind="style:{color: defaultButtonTextColor}">Default button</h3>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="offset4 span4 drawBorder height100" data-bind="style:{'background-color': wellBackgroundColor}">
                        <h3>Well colour</h3>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="offset4 span2">
                        <button class="well nav-well text-center" data-bind="style:{'background-color': navBackgroundColor}">
                            <h3  data-bind="style:{color: navTextColor}">Nav button</h3>
                        </button>
                    </div>
                    <div class="span2">
                        <button class="well nav-well text-center" data-bind="style:{'background-color': navBackgroundColor}">
                            <h3  data-bind="style:{color: navTextColor}">Nav button</h3>
                        </button>
                    </div>
                </div>
                <div class="row-fluid ">
                    <div class="offset1 span2 drawBorder height100" data-bind="style:{'background-color': facetBackgroundColor}"><h3>Facet Background</h3></div>
                    <div class="span8 drawBorder height100" data-bind="style:{'background-color': tileBackgroundColor}"><h3>Tile Background</h3></div>
                </div>
            </div>
        </div>
        <div class="row-fluid previewFooter"  data-bind="style:{'background-color': footerBackgroundColor}">
            <div class="span12">
                <ul class="breadcrumb pull-left">
                    <li><a href="#" data-bind="style:{color: footerTextColor}">Contact us</a> <span class="divider" data-bind="style:{color: footerTextColor}">|</span></li>
                    <li><a href="#" data-bind="style:{color: footerTextColor}">Disclaimer</a> <span class="divider" data-bind="style:{color: footerTextColor}">|</span></li>
                    <li><a href="#" data-bind="style:{color: footerTextColor}">About us</a></li>
                </ul>
                <div class="pull-right">
                    <a class="do-not-mark-external" href="" data-bind="style:{color: socialTextColor}">
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                            <i class="fa fa-facebook fa-stack-1x"></i>
                        </span>
                    </a>
                    <a class="do-not-mark-external" href="" data-bind="style:{color: socialTextColor}">
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                            <i class="fa fa-twitter fa-stack-1x"></i>
                        </span>
                    </a>
                    <a class="do-not-mark-external" href="" data-bind="style:{color: socialTextColor}">
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
                            <i class="fa fa-youtube fa-stack-1x"></i>
                        </span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</script>
<script id="templateDataPageFacetConfiguration" type="text/html">
<table class="table table-custom-border borderless">
    <thead>
    <tr>
        <th>Facet name</th>
        <th>Facet term type</th>
        <th>Expand or Collapse</th>
        <th>Display interval</th>
        <th>Display name</th>
        <th>Help text</th>
        <th>Action</th>
    </tr>
    </thead>
    <tbody>
    <!-- ko foreach: facets -->
    <tr>
        <td data-bind="text: formattedName">

        </td>
        <td>
            <select data-bind="value: facetTermType">
                <option value="Default">Default</option>
                <option value="ActiveOrCompleted">Active or Completed</option>
                <option value="PresenceOrAbsence">Presence or Absence</option>
                <option value="Histogram">Histogram</option>
                <option value="Date">Date</option>
                %{--<option value="GeoMap">Map</option>--}%
            </select>
        </td>
        <td>
            <select data-bind="value: state">
                <option value="Expanded">Expanded</option>
                <option value="Collapsed">Collapsed</option>
            </select>
        </td>
        <td>
            <input type="number"  data-bind="value:interval, disable: isNotHistogram" min="0">
        </td>
        <td>
            <input type="text"  data-bind="value:title" placeholder="Give a custom name for facet.">
        </td>
        <td>
            <textarea data-bind="value:helpText" placeholder="Add custom help text"></textarea>
        </td>
        <td>
            <button class="btn btn-small btn-danger" data-bind="click: $parent.remove"><i class="icon-remove icon-white"></i> Remove</button>
        </td>
    </tr>
    <!-- /ko -->
    <!-- ko ifnot: facets().length -->
    <tr>
        <td colspan="7">
            No Facets selected.
        </td>
    </tr>
    <!-- /ko -->
    </tbody>
    <tfoot>
    <tr>
        <td colspan="6">Pick a facet <select data-bind="options: transients.facetList, optionsText:'formattedName', value: transients.selectedFacet"></select></td>
        <td>
            <button class="btn btn-small btn-default" data-bind="click: add"><i class="icon-plus"></i> Add</button>
        </td>
    </tr>
    </tfoot>
</table>
</script>
<script id="templateDataPageColumnConfiguration" type="text/html">
<table class="table table-custom-border borderless">
    <thead>
    <tr>
        <th>Column</th>
        <th>Display name</th>
        <th>Sort by column</th>
        <th>Order of sorting</th>
        <th>Action</th>
    </tr>
    </thead>
    <tbody>
    <!-- ko foreach: dataColumns -->
    <tr>
        <td data-bind="text: name">

        </td>
        <td>
            <input type="text"  data-bind="value:displayName" placeholder="Give a custom name for column." />
        </td>
        <td>
            <input type="radio" name="sort" data-bind="value: code, checked: $parent.transients.sortColumn, disable: !isSortable()" />
        </td>
        <td>
            <select data-bind="value: order, disable: !isSortable()">
                <option value="asc">Ascending</option>
                <option value="desc">Descending</option>
            </select>
        </td>
        <td>
            <button class="btn btn-small btn-danger" data-bind="click: $parent.removeDataColumn"><i class="icon-remove icon-white"></i> Remove</button>
        </td>

    </tr>
    <!-- /ko -->
    <!-- ko ifnot: dataColumns().length -->
    <tr>
        <td colspan="3">
            No columns selected.
        </td>
    </tr>
    <!-- /ko -->
    </tbody>
    <tfoot>
    <tr>
        <td colspan="5">
            Pick a column <select data-bind="options: transients.defaultDataColumns, optionsText: 'name', value: transients.selectedDataColumn"></select>
            <button class="btn btn-small btn-default" data-bind="click: addDataColumn"><i class="icon-plus"></i> Add</button>
        </td>
    </tr>
    </tfoot>
</table>
</script>
<asset:script type="text/javascript">

    $(function() {

        var programsModel = <fc:modelAsJavascript model="${programsModel}"/>;
        var options = $.extend({formSelector:'.validationEngineContainer', currentHub:'${hubConfig.urlPath}'}, fcConfig);

        var viewModel = new HubSettingsViewModel(programsModel, options);

        ko.applyBindings(viewModel);

    });

</asset:script>

</body>
</html>