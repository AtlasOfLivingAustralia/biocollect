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
        <li><a href="#hubHeader"  data-toggle="tab">Header</a></li>
        <li><a href="#hubFooter"  data-toggle="tab">Footer</a></li>
        <li><a href="#hubBanner"  data-toggle="tab">Banner</a></li>
        <li><a href="#hubHomepage"  data-toggle="tab">Homepage</a></li>
        <li><a href="#hubPublish"  data-toggle="tab">Publish</a></li>
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
                <div class="control-group" data-bind="slideVisible: transients.isSkinAConfigurableTemplate">
                    <label class="control-label" for="skin">Configure skin</label>
                    <div class="controls required">
                        <button type="button" class="btn" data-bind="click: toggleTemplateSettings"><i class="icon-pencil"></i> Edit</button>
                    </div>
                </div>


                <!-- ko with: templateConfiguration -->
                <div class="control-group">
                    <label class="control-label" for="skin">Header</label>
                    <div class="controls">
                        <!-- ko with: styles -->
                            <!-- ko template: { name: 'templateStyles'} -->
                            <!-- /ko -->
                        <!-- /ko -->

                        <!-- ko with: header -->
                            <!-- ko foreach: links -->
                                <!-- ko template: { name: 'templateLink'} -->
                                <!-- /ko -->
                            <!-- /ko -->
                            <button type="button" class="btn" data-bind="click: addLink"><i class="icon-plus"></i> Add link</button>
                        <!-- /ko -->
                    </div>
                </div>
                <!-- ko with: footer -->
                <div class="control-group">
                    <label class="control-label" for="skin">Footer</label>
                    <div class="controls">
                        <!-- ko foreach: links -->
                        <!-- ko template: { name: 'templateLink'} -->
                        <!-- /ko -->
                        <!-- /ko -->
                        <button type="button" class="btn" data-bind="click: addLink"><i class="icon-plus"></i> Add link</button>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="skin">Social</label>
                    <div class="controls">
                        <!-- ko foreach: socials -->
                        <!-- ko template: { name: 'templateSocial'} -->
                        <!-- /ko -->
                        <!-- /ko -->
                        <button type="button" class="btn" data-bind="click: addSocialMedia"><i class="icon-plus"></i> Add social media</button>
                    </div>
                </div>
                <!-- /ko -->
                <div class="control-group">
                    <label class="control-label" for="skin">Homepage</label>
                    <div class="controls">
                        <select data-bind="value: homePage">
                            <option value="projectfinder">Project finder</option>
                            <option value="buttons">List of buttons</option>
                        </select>
                        <!-- ko if: homePage() == 'buttons' -->
                            <!-- ko with: buttonsHomePage -->
                                <label>Number of columns</label>
                                <select data-bind="value: numberOfColumns">
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                </select>

                                <!-- ko foreach: buttons -->
                                    <!-- ko template: { name: 'templateLink'} -->
                                    <!-- /ko -->
                                <!-- /ko -->
                                <button type="button" class="btn" data-bind="click: addButtton"><i class="icon-plus"></i> Add button</button>
                            <!-- /ko -->
                        <!-- /ko -->

                        %{--<!-- ko if: homePage() == 'projectfinder' -->--}%
                        %{--<!-- ko with: projectFinderHomePage -->--}%
                        %{--<!-- ko template: { name: 'templateProjectFinder'} -->--}%
                        %{--<!-- /ko -->--}%
                        %{--<!-- /ko -->--}%
                        %{--<!-- /ko -->--}%

                    </div>
                </div>
                <!-- /ko -->
            </div>

        </div>
        <div class="pill-pane" id="hubHeader">

        </div>
        <div class="pill-pane" id="hubFooter"></div>
        <div class="pill-pane" id="hubBanner">
            <div class="control-group">
                <label class="control-label" for="banner">Logo image</label>
                <div class="controls">
                    <img data-bind="visible:logoUrl(), attr:{src:logoUrl}">
                    <button type="button" class="btn" data-bind="visible:logoUrl(), click:removeLogo">Remove Logo</button>
                    <span class="btn fileinput-button pull-right"
                          data-url="${createLink(controller: 'image', action:'upload')}"
                          data-role="logo"
                          data-owner-type="hubId"
                          data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents, visible:!logoUrl()"><i class="icon-plus"></i> <input id="logo" type="file" name="files"><span>Attach Organisation Logo</span></span>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="banner">Banner image</label>
                <div class="controls">
                    <img data-bind="visible:bannerUrl(), attr:{src:bannerUrl}">
                    <button type="button" class="btn" data-bind="visible:bannerUrl(), click:removeBanner">Remove Banner</button>
                    <span class="btn fileinput-button pull-right"
                          data-url="${createLink(controller: 'image', action:'upload')}"
                          data-role="banner"
                          data-owner-type="hubId"
                          data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents, visible:!bannerUrl()"><i class="icon-plus"></i> <input id="banner" type="file" name="files"><span>Attach Banner Image</span></span>
                </div>
            </div>
        </div>
        <div class="pill-pane" id="hubHomepage"></div>
        <div class="pill-pane" id="hubPublish"></div>
    </div>

    <div class="form-actions">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Save</button>
        <button type="button" id="cancel" class="btn">Cancel</button>
    </div>

    %{--<form class="form-horizontal validationEngineContainer" data-bind="with:selectedHub">--}%
    %{--</form>--}%
</div>

<script id="templateLink" type="text/html">
    <label>Display name</label> <input type="text" data-bind="value: displayName"/>
    <label>Content type</label> <select data-bind="value: contentType"><option value="static">Static page</option>
        <option value="content">Biocollect content</option>
        <option value="external">External link</option></select>
    <label>Link</label> <input type="text" data-bind="value: href"/>
</script>

<script id="templateSocial" type="text/html">
<label>Social media group</label>
<select data-bind="value: contentType">
    <option value="youtube">Youtube</option>
    <option value="facebook">Facebook</option>
    <option value="twitter">Twitter</option>
</select>
<label>Link</label> <input type="text" data-bind="value: href"/>
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

<script id="templateButtons" type="text/html">

</script>

<script id="templateProjectFinder" type="text/html">
blahhh
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