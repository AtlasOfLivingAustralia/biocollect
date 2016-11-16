<!doctype html>
<html>
<head>
    <meta name="layout" content="adminLayout"/>
    <title>Metadata | Admin | Data capture | Atlas of Living Australia</title>
    <r:require modules="jquery,knockout,jqueryValidationEngine,attachDocuments,admin"/>
    <r:script disposition="head">
        fcConfig = {
            listHubsUrl:"${createLink(controller: 'admin', action: 'listHubs')}",
            getHubUrl:"${createLink(controller: 'admin', action: 'loadHubSettings')}",
            saveHubUrl:"${createLink(controller: 'admin', action: 'saveHubSettings')}"
        };
    </r:script>
</head>

<body>

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
    <ul class="nav nav-pills">
        <li class="active">
            <a href="#hubPrograms" data-toggle="tab">Programs</a>
        </li>
        <li><a href="#hubTemplate"  data-toggle="tab">Template</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubHeader"  data-toggle="tab">Header</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubFooter"  data-toggle="tab">Footer</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubBanner"  data-toggle="tab">Banner</a></li>
        <li data-bind="disable: transients.isSkinAConfigurableTemplate"><a href="#hubHomepage"  data-toggle="tab">Homepage</a></li>
    </ul>
    <div class="pill-content">
        <div class="pill-pane active" id="hubPrograms">

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

            <div class="control-group">
                <label class="control-label" for="available-facets">Available Facets (Only these facets will display on the home page)</label>
                <div class="controls">
                    <ul id="available-facets" data-bind="foreach:$parent.transients.availableFacets" class="unstyled">
                        <li><label><input type="checkbox" data-bind="checked:$parent.availableFacets, attr:{value:$data}"> <span data-bind="text:$data"></span> <span data-bind="text:$parent.facetOrder($data)"></span></label></li>
                    </ul>

                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="available-facets">Admin Facets (Only these facets will display on the home page)</label>
                <div class="controls">
                    <ul id="admin-facets" data-bind="foreach:$parent.transients.adminFacets" class="unstyled">
                        <li><label><input type="checkbox" data-bind="checked:$parent.adminFacets, attr:{value:$data}"> <span data-bind="text:$data"></span> <span data-bind="text:$parent.facetAdminOrder($data)"></span></label></li>
                    </ul>

                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="available-facets">Available Map Facets (Only these facets will display on the home page map menu)</label>
                <div class="controls">
                    <ul id="admin-map-facets" data-bind="foreach:$parent.transients.availableMapFacets" class="unstyled">
                        <li><label><input type="checkbox" data-bind="checked:$parent.availableMapFacets, attr:{value:$data}"> <span data-bind="text:$data"></span> <span data-bind="text:$parent.facetMapAdminOrder($data)"></span></label></li>
                    </ul>

                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="default-facets-list">Default Facet Query (Searches will automatically include these facets)</label>
                <div class="controls">
                    <ul id="default-facets-list" data-bind="foreach:defaultFacetQuery">
                        <li>
                            <input type="text" class="input-xxlarge"  data-bind="value:query" placeholder="query string as produced by the home page"> <button class="btn" data-bind="click:$parent.removeDefaultFacetQuery">Remove</button>
                        </li>
                    </ul>
                    <button class="btn" data-bind="click:addDefaultFacetQuery">Add</button>

                </div>
            </div>
        </div>

        <div class="pill-pane" id="hubTemplate">
            <div class="control-group">
                <label class="control-label" for="skin">Skin</label>
                <div class="controls required">
                    <select id="skin" data-bind="value:skin,options:$parent.transients.availableSkins" data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div data-bind="slideVisible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <div class="control-group">
                        <label class="control-label" for="skin">Colour scheme</label>
                        <div class="controls">
                            <!-- ko with: styles -->
                                <!-- ko template: { name: 'templateStyles'} -->
                                <!-- /ko -->
                            <!-- /ko -->
                        </div>
                    </div>
                <!-- /ko -->
            </div>
        </div>
        <div class="pill-pane" id="hubHeader">
            <div data-bind="visible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: header -->
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
                                <!-- ko foreach: links -->
                                <!-- ko template: { name: 'templateLink'} -->
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
                <!-- /ko -->
                <!-- /ko -->
            </div>

            <div data-bind="visible: !transients.isSkinAConfigurableTemplate()">
                <!-- ko template: {name: 'configurableTemplateNotSelectedMessage'} -->
                <!-- /ko -->
            </div>
        </div>
        <div class="pill-pane" id="hubFooter">
            <div data-bind="visible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: footer -->
                    <div>
                        <h3>Footer</h3>
                        <div class="">
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
                                <!-- ko foreach: links -->
                                <!-- ko template: { name: 'templateLink'} -->
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
        <div class="pill-pane" id="hubBanner">
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
        <div class="pill-pane" id="hubHomepage">
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
            <input type="text" data-bind="value: displayName"/>
        </td>
        <td>
            <select data-bind="value: contentType">
                <option value="content">Biocollect content</option>
                <option value="static">Static page</option>
                <option value="external">External link</option>
                <option value="">---------</option>
                <option value="admin">Admin</option>
                <option value="allrecords">All Records</option>
                <option value="home">Home</option>
                <option value="login">Login / Logout</option>
                <option value="newproject">New Project</option>
                <option value="sites">Sites</option>
            </select>
        </td>
        <td>
            <input type="text" data-bind="value: href"/>
        </td>
        <td>
            <button class="btn btn-danger" data-bind="click: $parent.removeLink">
                <i class="icon icon-remove icon-white"></i> Remove
            </button>
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
            <td>Header banner space background colour</td>
            <td><input type="text" data-bind="value: headerBannerBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':headerBannerBackgroundColor}"></div></td>
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
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <!-- ko foreach: buttons -->
                        <!-- ko template: { name: 'templateLink'} -->
                        <!-- /ko -->
                        <!-- /ko -->
                        <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td>
                                <button type="button" class="btn" data-bind="click: addButtton"><i class="icon-plus"></i> Add button</button>
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
        <strong>Other settings</strong> Href value for content type such as 'home' is predefined. Hence it should be left empty.
    </div>
</script>
<r:script>

    $(function() {

        var programsModel = <fc:modelAsJavascript model="${programsModel}"/>;
        var options = $.extend({formSelector:'.validationEngineContainer', currentHub:'${hubConfig.urlPath}'}, fcConfig);

        var viewModel = new HubSettingsViewModel(programsModel, options);

        ko.applyBindings(viewModel);

    });

</r:script>

</body>
</html>