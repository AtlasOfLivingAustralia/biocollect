<!doctype html>
<html>
<head>
    <meta name="layout" content="adminLayout"/>
    <title>Metadata | Admin | Data capture | Atlas of Living Australia</title>
    <asset:script type="text/javascript">
        fcConfig = {
            <g:applyCodec encodeAs="none">
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
            listHubsUrl:"${createLink(controller: 'admin', action: 'listHubs')}",
            getHubUrl:"${createLink(controller: 'admin', action: 'loadHubSettings')}",
            saveHubUrl:"${createLink(controller: 'admin', action: 'saveHubSettings')}",
            listProjectFacetUrl: "${createLink(controller: 'project', action: 'getFacets')}",
            listDynamicFacetsUrl: "${createLink(controller: 'bioActivity', action: 'getFacets')}",
            listDataColumnsUrl: "${createLink(controller: 'bioActivity', action: 'getDataColumns')}",
            defaultOverriddenLabelsURL: "${createLink(controller: 'hub', action: 'defaultOverriddenLabels')}",
            allBaseLayers: <fc:modelAsJavascript model="${grailsApplication.config.map.baseLayers}"/>,
            allOverlays: <fc:modelAsJavascript model="${grailsApplication.config.map.overlays}"/>,
            leafletAssetURL: "${assetPath(src: 'webjars/leaflet/0.7.7/dist/images')}"
            </g:applyCodec>
        };
    </asset:script>
</head>

<body>
<asset:stylesheet src="leaflet-manifest.css"/>
<asset:stylesheet src="admin.css"/>
<asset:stylesheet src="fileupload-ui-manifest.css"/>
<asset:stylesheet src="ckeditor/ckeditor5/ckeditor5.css"/>
<asset:javascript src="ckeditor/ckeditor5/ckeditor5.umd.js"/>
<asset:javascript src="leaflet-manifest.js"/>
<asset:javascript src="common-bs4.js"/>
<asset:javascript src="fileupload-manifest.js"/>
%{-- Todo: cors/jquery.xdr-transport.js needed?--}%
<asset:javascript src="cors/jquery.xdr-transport.js"/>
<asset:javascript src="document.js"/>
<asset:javascript src="hubs.js"/>
<script src="${grailsApplication.config.google.maps.url}" async defer></script>
<content tag="pageTitle">Manage Hubs</content>

<div class="alert alert-info">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <span>You are viewing the hub: ${hubConfig.urlPath}</span>
</div>

<div class="alert alert-info" data-bind="visible:message()">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <span data-bind="text:message"></span>
</div>
<div class="row">
    <div class="col-md-6">
        <div class="form-group row">
            <label class="col-md-4 col-form-label">Configured hubs:</label>
            <div class="col-md-8">
                <select class="form-control" data-bind="value:selectedHubUrlPath, options:hubs"></select>
            </div>
        </div>
    </div>
    <div class="col-md-6 btn-space">
        <button class="btn btn-info" data-bind="click:editHub"><i class="fas fa-pencil-alt"></i> Edit <span data-bind="text:selectedHubUrlPath"></span></button>
        <button class="btn btn-info" data-bind="click:newHub"><i class="fas fa-plus"></i> New Hub</button>
    </div>

</div>

<hr/>

<div class="selected-hub form-horizontal" data-bind="visible:selectedHub(), with:selectedHub">
    <h2><span data-bind="visible:hubId">Editing: </span><span data-bind="visible:!hubId()">Creating: </span> <span data-bind="text:urlPath"></span></h2>
    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link active" href="#hubPrograms" data-toggle="tab">Programs</a>
        </li>
        <li class="nav-item"><a class="nav-link" href="#hubTemplate"  data-toggle="tab">Template</a></li>
        <li class="nav-item" data-bind="disable: transients.isSkinAConfigurableTemplate"><a class="nav-link" href="#hubHeader"  data-toggle="tab">Header</a></li>
        <li class="nav-item" data-bind="disable: transients.isSkinAConfigurableTemplate"><a class="nav-link" href="#hubFooter"  data-toggle="tab">Footer</a></li>
        <li class="nav-item" data-bind="disable: transients.isSkinAConfigurableTemplate"><a class="nav-link" href="#hubBanner"  data-toggle="tab">Banner</a></li>
        <li class="nav-item"><a class="nav-link" href="#hubContent"  data-toggle="tab">Content</a></li>
        <li class="nav-item"><a class="nav-link" href="#hubFacet"  data-toggle="tab">Facets</a></li>
        <li class="nav-item"><a class="nav-link" href="#hubData"  data-toggle="tab">Data</a></li>
        <li class="nav-item"><a class="nav-link" href="#hubMap"  data-toggle="tab">Map</a></li>
        <li class="nav-item" data-bind="disable: transients.isSkinAConfigurableTemplate"><a class="nav-link" href="#hubHomepage"  data-toggle="tab">Homepage</a></li>
    </ul>
    <div class="tab-content mt-3">
        <div class="tab-pane active" id="hubPrograms">

            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="name">URL path (added to URL to select the hub)</label>
                <div class="col-md-8 required">
                    <input type="text" id="name" class="form-control" data-bind="value:urlPath" data-validation-engine="validate[required]">
                </div>
            </div>

            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="description">Title</label>
                <div class="col-md-8 required">
                    <textarea rows="3" class="form-control" data-bind="value:title" data-validation-engine="validate[required]" id="description" placeholder="Displays as a heading on the home page"></textarea>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="description">Home Page Path</label>
                <div class="col-md-8 required">
                    <input type="text" class="form-control" data-bind="value:homePagePath" placeholder="Relative path to home page (leave blank for default)"></input>
                </div>
            </div>
            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="description">Fathom site id</label>
                <div class="col-md-8 required">
                    <input type="text" class="form-control" data-bind="value:fathomSiteId" placeholder="Fathom analytics site id"></input>
                </div>
            </div>
            <div>
                <label>Favicon image</label>
                <div class="row">
                    <div class="col-6">
                        <img data-bind="visible:faviconlogoUrl(), attr:{src:faviconlogoUrl}">
                    </div>
                    <div class="offset-4 col-2">
                        <button type="button" class="btn  btn-sm btn-danger" data-bind="visible:faviconlogoUrl(), click:removeFaviconlogo"><i class="far fa-trash-alt"></i> Remove Favicon</button>
                        <span class="btn fileinput-button float-right btn-dark"
                              data-url="${createLink(controller: 'image', action:'upload')}"
                              data-role="faviconlogo"
                              data-owner-type="hubId"
                              data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents, visible:!faviconlogoUrl()">
                            <i class="fas fa-file-upload"></i>
                            <input id="faviconlogo" type="file" name="files" accept="image/png">
                            <span>Attach Favicon Logo</span>
                        </span>
                    </div>
                </div>
            </div>
            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="supported-programs">Supported Programs (Projects in this hub can only select from these programs)</label>
                <div class="col-md-8">
                    <ul class="list-unstyled" id="supported-programs" data-bind="foreach:$parent.transients.programNames">
                        <li><label><input type="checkbox" data-bind="checked:$parent.supportedPrograms, attr:{value:$data}"> <span data-bind="text:$data"></span></label></li>
                    </ul>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="default-program">Default program (new projects created from this hub will inherit this program)</label>
                <div class="col-md-8">
                    <select class="form-control" id="default-program" data-bind="value:defaultProgram, options:supportedPrograms"></select>
                </div>
            </div>
        </div>

        <div class="tab-pane" id="hubTemplate">
            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="skin">Skin</label>
                <div class="col-md-8 required">
                    <select class="form-control" id="skin" data-bind="value:skin,options:$parent.transients.availableSkins" data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div data-bind="slideVisible: transients.isSkinAConfigurableTemplate">
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: styles -->
                        <div class="form-group row">
                            <label class="col-md-4 col-form-label" for="skin">Colour scheme</label>
                            <div class="col-md-8">
                                <!-- ko template: { name: 'templateStyles'} -->
                                <!-- /ko -->
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-md-4 col-form-label" for="skin" id="preview">Preview</label>
                            <div class="col-md-8">
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
                        <div class="form-group row">
                            <label class="col-md-4 col-form-label">Choose between the following header options: </label>
                            <div class="col-md-8">
                                <select class="form-control" data-bind="value: type">
                                    <option value="">Please choose</option>
                                    <option value="ala">ALA</option>
                                    <option value="custom">Custom header</option>
                                </select>
                            </div>
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
                                    <th>Introductory text</th>
                                    <th>Role</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- ko foreach: links -->
                                <!-- ko template: { name: 'templateLink', data: {disableRoles:false, enableIntroText: true, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                                <!-- /ko -->
                                <!-- /ko -->
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td>
                                        <button type="button" class="btn btn-dark" data-bind="click: addLink"><i class="fas fa-plus"></i> Add link</button>
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
                        <div class="form-group row">
                            <label class="col-md-4 col-form-label">
                                Choose between the following footer options:
                            </label>
                            <div class="col-md-8">
                                <select class="form-control" data-bind="value: type">
                                    <option value="">Please choose</option>
                                    <option value="ala">ALA</option>
                                    <option value="custom">Custom footer</option>
                                </select>
                            </div>
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
                                <!-- ko template: { name: 'templateLink', data: {disableRoles:false, enableIntroText: false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                                <!-- /ko -->
                                <!-- /ko -->
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td>
                                        <button type="button" class="btn btn-dark" data-bind="click: addLink"><i class="fas fa-plus"></i> Add link</button>
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
                                            <button type="button" class="btn btn-dark" data-bind="click: addSocialMedia"><i class="fas fa-plus"></i> Add social media</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div>
                        <h3>Footer Logo</h3>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Image</th>
                                    <th>Href</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- ko foreach: logos -->
                                <tr>
                                    <td>
                                        <img class="col-3" data-bind="visible: url, attr:{src:url}">
                                    </td>
                                    <td>
                                        <input class="form-control" type="text" data-bind="value: href"></input>
                                    </td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-danger" data-bind="visible:$data, click:remove"><i class="far fa-trash-alt"></i> Remove Banner</button>
                                    </td>
                                </tr>
                                <!-- /ko -->
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td>
                                        <span class="btn fileinput-button float-right btn-dark"
                                              data-url="${createLink(controller: 'image', action:'upload')}"
                                              data-role="footerlogo"
                                              data-owner-type="hubId"
                                              data-bind="attr:{'data-owner-id':name}, stagedImageUpload:$parents[1].documents">
                                            <i class="fas fa-file-upload"></i>
                                            <input id="footerLogo" type="file" name="files">
                                            <span>Add a Logo</span>
                                        </span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
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
                <div class="row">
                    <div class="col-6">
                        <img data-bind="visible:logoUrl(), attr:{src:logoUrl}">
                    </div>
                    <div class="offset-4 col-2">
                        <button type="button" class="btn  btn-sm btn-danger" data-bind="visible:logoUrl(), click:removeLogo"><i class="far fa-trash-alt"></i> Remove Logo</button>
                        <span class="btn fileinput-button float-right btn-dark"
                              data-url="${createLink(controller: 'image', action:'upload')}"
                              data-role="logo"
                              data-owner-type="hubId"
                              data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents, visible:!logoUrl()">
                            <i class="fas fa-file-upload"></i> <input id="logo" type="file" name="files">
                            <span>
                            Attach Organisation Logo
                            </span>
                        </span>
                    </div>
                </div>
            </div>
            <div>
                <h3>Carousel settings</h3>
                <!-- ko with: templateConfiguration -->
                    <!-- ko with: banner -->
                        <div class="row mb-2" data-bind="slideVisible: images().length">
                            <div class="col-6">Carousel image transition speed in milli-seconds (ms)</div>
                            <div class="col-2">
                                <input class="form-control" type="number" data-bind="value: transitionSpeed">
                            </div>
                        </div>
                        <h4>Carousel images</h4>
                        <!-- ko foreach: images -->
                            <div class="row mb-2">
                                <div class="col-6">
                                    <img data-bind="visible: url, attr:{src:url}">
                                </div>
                                <div class="col-4">
                                    <textarea class="form-control" data-bind="value: caption"></textarea>
                                </div>
                                <div class="col-2">
                                    <button type="button" class="btn btn-sm btn-danger" data-bind="visible:$data, click:$parent.removeBanner"><i class="far fa-trash-alt"></i> Remove Banner</button>
                                </div>
                            </div>
                        <!-- /ko -->
                        %{-- END bannerImages --}%
                    <!-- /ko -->
                <!-- /ko -->
                <div class="row">
                    <div class="col-10"></div>
                    <div class="col-2">
                        <span class="btn fileinput-button float-right  btn-dark"
                              data-url="${createLink(controller: 'image', action:'upload')}"
                              data-role="banner"
                              data-owner-type="hubId"
                              data-bind="attr:{'data-owner-id':name}, stagedImageUpload:documents">
                            <i class="fas fa-file-upload"></i> <input id="bannerupload" type="file" name="files">
                            <span>Attach Banner Image</span>
                        </span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane" id="hubContent">
            <div>
                <h3>Settings</h3>
                <small>Hide or show certain components on Biocollect</small>
                <!-- ko with: content-->
                <h5>Global</h5>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideBreadCrumbs"> Hide bread crumbs
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: nespFavicon"> Use HUB favicon
                </div>

                <h5>Project finder</h5>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectFinderHelpButtons"> Hide 'Getting Started' & 'What is this?' buttons on project finder
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectFinderStatusIndicatorList"> Hide project status indicator (List view)
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectFinderProjectTags"> Hide project tags
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectFinderNoImagePlaceholderTile"> Hide image when project has no uploaded image (Tile view)
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectFinderNoImagePlaceholderList"> Hide image when project has no uploaded image (List view)
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: enablePartialSearch"> Enable partial search
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: disableOrganisationHyperlink"> Disable organisation hyperlink
                </div>
                <h5>Project page</h5>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectBackButton"> Hide 'Back to search results' button on project page
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectBlogTab"> Hide blog tab on project page
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectStatusIndicator"> Hide project status indicator
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectAboutOriginallyRegistered"> Hide 'project originally registered in'
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectAboutContributing"> Hide 'This project is  contributing data to the Atlas of Living Australia'.
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectAboutParticipateInProject"> Hide 'You can participate in this project in'
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectEditCountries"> Hide 'Countries' (Edit page)
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectEditScienceTypes"> Hide 'Science types' (Edit page)
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectAboutUNRegions"> Hide 'UN Regions'
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectSurveyDownloadXLSX"> Hide 'Download XLSX template'
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectGettingStartedButton"> Hide 'Getting Started' on project information
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: showCustomMetadata"> Show Custom Metadata such as Category, Raid, Indigenous Cultural etc
                </div>

                <h5>Record listing</h5>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideProjectAndSurvey"> Hide project and survey when listing records on pages like all records
                </div>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: showNote"> Show note on record listing page
                </div>
                <div class="margin-top-1 row" data-bind="slideVisible: showNote">
                    <textarea class="form-control" class="col-6" data-bind="value: recordNote">

                    </textarea>
                </div>


                <h5>Data entry page</h5>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideCancelButtonOnForm"> Hide 'Cancel' button on form create page
                </div>
                <h5>Record view page</h5>
                <div class="checkbox">
                    <input type="checkbox" data-bind="checked: hideNewButtonOnRecordView"> Hide 'Add new record' button on form create page
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
                    <!-- ko template: { name: 'templateLink', data: {$parent: $parent, disableRoles:true, enableIntroText: false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                    <!-- /ko -->
                    <!-- /ko -->
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td>
                            <button type="button" class="btn btn-dark" data-bind="click: addLink"><i class="fas fa-plus"></i> Add link</button>
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
                            <button type="button" class="btn btn-dark" data-bind="click: addCustomBreadCrumb"><i class="fas fa-plus"></i> Add breadcrumb for a page</button>
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

                <h3>Label overrides</h3>
                <small>Configure overrides for certain sections</small>
                <!-- ko with:content -->
                <table class="table">
                <thead>
                <tr>
                    <td>Page</td>
                    <td>Default text</td>
                    <td>Enable</td>
                    <td>Custom text</td>
                    <td>Notes</td>
                </tr>
                </thead>
                <tbody data-bind="foreach: overriddenLabels">
                <tr>
                    <td>
                        <label data-bind="text: page"></label>
                    </td>
                    <td>
                        <label data-bind="text: defaultText"></label>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label><input type="checkbox" data-bind="checked: showCustomText"></label>
                        </div>
                    </td>
                    <td>
                        <input class="form-control" type="text" data-bind="value: customText">
                    </td>
                    <td>
                        <label data-bind="text: notes"></label>
                    </td>
                </tr>
                </tbody>
                </table>
                <!-- /ko -->


            </div>
        </div>
        <div class="tab-pane" id="hubFacet">
            <div class="form-group row">
                <label class="col-md-4 col-form-label" for="default-facets-list">Default Facet Query (Searches will automatically include these facets)</label>
                <div class="col-md-8 btn-space">
                    <ul id="default-facets-list" data-bind="foreach:defaultFacetQuery" class="list-unstyled">
                        <li class="btn-space">
                            <input type="text" class="form-control"  data-bind="value:query" placeholder="query string as produced by the home page"> <button class="btn btn-danger" data-bind="click:$parent.removeDefaultFacetQuery"><i class="far fa-trash-alt"></i> Remove</button>
                        </li>
                    </ul>
                    <button class="btn btn-dark" data-bind="click:addDefaultFacetQuery"><i class="fas fa-plus"></i> Add</button>

                </div>
            </div>

            <div class="border-bottom-4">
                <h4><strong>Configure project finder facets</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.projectFinder } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on all records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.allRecords } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on my records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.myRecords } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on project's data tab</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.project } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on my project records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.myProjectRecords } -->
                    <!-- /ko -->
                </div>
            </div>


            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on user's project activity records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.userProjectActivityRecords } -->
                    <!-- /ko -->
                </div>
            </div>


            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on project records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.projectRecords } -->
                    <!-- /ko -->
                </div>
            </div>

            <div class="mb-4 border-bottom-4">
                <h4><strong>Configure facets on bulk import records page</strong></h4>
                <div class="overflow-x">
                    <!-- ko template: { name: 'templateDataPageFacetConfiguration', data: pages.bulkImport } -->
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
        <div class="tab-pane" id="hubMap">
            <div class="border-bottom-4">
                <h4><strong>Configure base layers for maps shown on this hub</strong></h4>
                <div class="overflow-x">
                    <map-config-selector params="allBaseLayers: fcConfig.allBaseLayers, allOverlays: fcConfig.allOverlays, mapLayersConfig: mapLayersConfig"></map-config-selector>
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
                                    <select class="form-control" data-bind="value: homePageConfig">
                                        <option value="projectfinder">Project finder</option>
                                        <option value="buttons">Buttons</option>
                                    </select>
                                </div>
                            </div>
                            <div class="mt-2">
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
    <div class="form-actions mt-2">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save</button>
        <button type="button" id="cancel" class="btn btn-dark"><i class="far fa-times-circle"></i> Cancel</button>
    </div>
</div>
<!-- ko stopBinding: true -->
<!-- Introductory text Modal -->
<div class="modal fade vh-100" id="introTextModal" data-backdrop="static" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="staticBackdropLabel">Introductory text</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <bc:koLoading>
                <textarea class="ckeditor" data-bind="ckeditor: introductoryText"></textarea>
                </bc:koLoading>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" data-bind="click: saveIntroductoryText">Save</button>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->
<script id="templateLink" type="text/html">
    <tr>
        <td>
            <input class="form-control" type="text" data-bind="value: link.displayName"/>
        </td>
        <td>
            <select class="form-control" data-bind="value: link.contentType">
                <option value="content">Biocollect content</option>
                <option value="static">Static page</option>
                <option value="external">External link</option>
                <option value="nolink">No link - text only</option>
                <option value="">---------</option>
                <option value="admin">Admin</option>
                <option value="allrecords">All Records</option>
                <option value="home">Home</option>
                <option value="charts">Charts</option>
                <option value="resources">Resources</option>
                <option value="login">Login / Logout</option>
                <option value="newproject">New Project</option>
                <option value="sites">Sites</option>
                <option value="biocacheexplorer">Biocache Explorer</option>
                <option value="recordSighting">Record a Sighting</option>
            </select>
        </td>
        <td>
            <input class="form-control" type="text" data-bind="value: link.href"/>
        </td>
        <!-- ko if: enableIntroText -->
        <td>
        <!-- ko ifnot: ['external', 'nolink', 'login', 'biocacheexplorer'].indexOf(link.contentType()) > -1 -->
            <button class="btn btn-sm btn-primary" data-bind="click: link.launchModal">
                <i class="fas fa-pencil-alt"></i> Edit&nbsp;intro
            </button>
        <!-- /ko -->
        </td>
        <!-- /ko -->
        <!-- ko if:!disableRoles -->
        <td>
            <select class="form-control" data-bind="value: link.role">
                <option value="">Anyone</option>
                <g:render template="/admin/userRoleOptions"/>
            </select>
        </td>
        <!-- /ko -->
        <td>
            <button class="btn btn-sm btn-danger" data-bind="click: removeLink">
                <i class="far fa-trash-alt"></i> Remove
            </button>
        </td>
    </tr>
</script>

<script id="templateCustomBreadCrumb" type="text/html">
    <tr>
        <td>
            <input class="form-control" type="text" data-bind="value: controllerName"/>
        </td>
        <td>
            <input class="form-control" type="text" data-bind="value: actionName"/>
        </td>
        <td>
            <button class="btn btn-danger" data-bind="click: $parent.removeCustomBreadCrumb">
                <i class="far fa-trash-alt"></i> Remove
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
                <!-- ko template: { name: 'templateLink', data: {$parent: $parent, disableRoles:true, enableIntroText: false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                <!-- /ko -->
                <!-- /ko -->
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>
                        <button type="button" class="btn btn-dark" data-bind="click: addBreadCrumb"><i class="fas fa-plus"></i> Add a breadcrumb</button>
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
            <select class="form-control" data-bind="value: contentType">
                <option value="youtube">Youtube</option>
                <option value="facebook">Facebook</option>
                <option value="twitter">Twitter</option>
            </select>
        </td>
        <td>
            <input class="form-control" type="text" data-bind="value: href"/>
        </td>
        <td>
            <button class="btn btn-danger" data-bind="click: $parent.removeLink">
                <i class="far fa-trash-alt"></i> Remove
            </button>
        </td>
    </tr>
</script>

<script id="templateStyles" type="text/html">
    <table class="table borderless table-hover">
        <thead>
        <tr>
            <th>Styling Component</th>
            <th>Hex value</th>
            <th>Preview</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td colspan="2">
                <strong>Header</strong>
                <!-- ko template: {'name': 'collapseExpandComponent', data: {flag: transients.showHeader} } -->
                <!-- /ko -->
            </td>
            <td><a href="#preview"><i class="fas fa-chevron-down"></i> Preview</a></td>
        </tr>
        <tr data-bind="visible: transients.showHeader">
            <td>Menu background colour</td>
            <td><input class="form-control" type="color" data-bind="value: menuBackgroundColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: menuTextColor, backgroundColor: menuBackgroundColor, text: 'Menu'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showHeader">
            <td>Menu text colour</td>
            <td><input class="form-control" type="color" data-bind="value: menuTextColor"/></td>
        </tr>
        <tr>
            <td colspan="2">
                <strong>Banner</strong>
                <!-- ko template: {'name': 'collapseExpandComponent', data: {flag: transients.showBanner} } -->
                <!-- /ko -->
            </td>
            <td><a href="#preview"><i class="fas fa-chevron-down"></i> Preview</a></td>
        </tr>
        <tr data-bind="visible: transients.showBanner">
            <td>Inset panel background colour</td>
            <td><input class="form-control" type="color" data-bind="value: insetBackgroundColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: insetTextColor, backgroundColor: insetBackgroundColor, text: 'Inset'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showBanner">
            <td>Inset panel text colour</td>
            <td><input class="form-control" type="color" data-bind="value: insetTextColor"/></td>
        </tr>
        <tr>
            <td colspan="2">
                <strong>Global styles</strong>
                <!-- ko template: {'name': 'collapseExpandComponent', data: {flag: transients.showGlobal} } -->
                <!-- /ko -->
            </td>
            <td><a href="#preview"><i class="fas fa-chevron-down"></i> Preview</a></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Primary</td>
            <td><input class="form-control" type="color" data-bind="value: primaryColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: primaryColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Primary dark</td>
            <td><input class="form-control" type="color" data-bind="value: primaryDarkColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: primaryDarkColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Secondary</td>
            <td><input class="form-control" type="color" data-bind="value: secondaryColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: secondaryColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Success</td>
            <td><input class="form-control" type="color" data-bind="value: successColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: successColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Info</td>
            <td><input class="form-control" type="color" data-bind="value: infoColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: infoColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Warning</td>
            <td><input class="form-control" type="color" data-bind="value: warningColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: warningColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Danger</td>
            <td><input class="form-control" type="color" data-bind="value: dangerColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: dangerColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Light</td>
            <td><input class="form-control" type="color" data-bind="value: lightColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: lightColor, text: ''}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Dark</td>
            <td><input class="form-control" type="color" data-bind="value: darkColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: '', backgroundColor: darkColor, text: ''}}"></td>
        </tr>

        <tr data-bind="visible: transients.showGlobal">
            <td>Body background colour</td>
            <td><input class="form-control" type="color" data-bind="value: bodyBackgroundColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: bodyTextColor, backgroundColor: bodyBackgroundColor, text: 'Body'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Body text colour</td>
            <td><input class="form-control" type="color" data-bind="value: bodyTextColor"/></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Title text colour</td>
            <td><input class="form-control" type="color" data-bind="value: titleTextColor"/></td>
            <td data-bind="template: {name: 'textPreview', data: {textColor: titleTextColor, backgroundColor: 'transparent', text: 'Title'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Breadcrumbs background colour</td>
            <td><input class="form-control" type="color" data-bind="value: breadCrumbBackGroundColour"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':breadCrumbBackGroundColour}"></div></td>
        </tr>
        <tr data-bind="visible: transients.showGlobal">
            <td>Href colour</td>
            <td><input class="form-control" type="color" data-bind="value: hrefColor"/></td>
            <td data-bind="template: {name: 'textPreview', data: {textColor: hrefColor, backgroundColor: 'transparent', text: 'Anchor'}}"></td>
        </tr>
        <tr>
            <td colspan="2">
                <strong>Buttons</strong>
                <!-- ko template: {'name': 'collapseExpandComponent', data: {flag: transients.showButtons} } -->
                <!-- /ko -->
            </td>
            <td><a href="#preview"><i class="fas fa-chevron-down"></i> Preview</a></td>
        </tr>
        <tr data-bind="visible: transients.showButtons">
            <td>'Getting started' button background colour</td>
            <td><input class="form-control" type="color" data-bind="value: gettingStartedButtonBackgroundColor"/></td>
            <td data-bind="template: {name: 'buttonPreview', data: {backgroundColor: gettingStartedButtonBackgroundColor, textColor: '#fff'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showButtons">
            <td>'What is this' button background colour</td>
            <td><input class="form-control" type="color" data-bind="value: whatIsThisButtonBackgroundColor"/></td>
            <td data-bind="template: {name: 'buttonPreview', data: {backgroundColor: whatIsThisButtonBackgroundColor, textColor: '#fff'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showButtons">
            <td>'Add a record' button background colour</td>
            <td><input class="form-control" type="color" data-bind="value: addARecordButtonBackgroundColor"/></td>
            <td data-bind="template: {name: 'buttonPreview', data: {backgroundColor: addARecordButtonBackgroundColor, textColor: '#fff'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showButtons">
            <td>'View records' button background colour</td>
            <td><input class="form-control" type="color" data-bind="value: viewRecordsButtonBackgroundColor"/></td>
            <td data-bind="template: {name: 'buttonPreview', data: {backgroundColor: viewRecordsButtonBackgroundColor, textColor: '#fff'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showButtons">
            <td>Button home page background colour</td>
            <td><input class="form-control" type="color" data-bind="value: homepageButtonBackgroundColor"/></td>
            <td data-bind="template: {name: 'buttonPreview', data: {backgroundColor: homepageButtonBackgroundColor, textColor: '#fff'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showButtons">
            <td>Button home page text colour</td>
            <td><input class="form-control" type="color" data-bind="value: homepageButtonTextColor"/></td>
            <td data-bind="template: {name: 'buttonPreview', data: {backgroundColor: homepageButtonTextColor, textColor: '#fff'}}"></td>
        </tr>
        <tr>
            <td colspan="2">
                <strong>Other components</strong>
                <!-- ko template: {'name': 'collapseExpandComponent', data: {flag: transients.showOtherComponents} } -->
                <!-- /ko -->
            </td>
            <td><a href="#preview"><i class="fas fa-chevron-down"></i> Preview</a></td>
        </tr>
        <tr data-bind="visible: transients.showOtherComponents">
            <td>Nav text colour</td>
            <td><input class="form-control" type="color" data-bind="value: navTextColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: navTextColor, backgroundColor: navBackgroundColor, text: 'Nav'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showOtherComponents">
            <td>Nav background colour</td>
            <td><input class="form-control" type="color" data-bind="value: navBackgroundColor"/></td>
        </tr>
        <tr data-bind="visible: transients.showOtherComponents">
            <td>Facet background colour</td>
            <td><input class="form-control" type="color" data-bind="value: facetBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':facetBackgroundColor}"></div></td>
        </tr>
        <tr data-bind="visible: transients.showOtherComponents">
            <td>Tile background colour</td>
            <td><input class="form-control" type="color" data-bind="value: tileBackgroundColor"/></td>
            <td><div class="previewColor" data-bind="style:{'background-color':tileBackgroundColor}"></div></td>
        </tr>
        <tr data-bind="visible: transients.showOtherComponents">
            <td>Tag background colour</td>
            <td><input class="form-control" type="color" data-bind="value: tagBackgroundColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: tagTextColor, backgroundColor: tagBackgroundColor, text: 'Tag'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showOtherComponents">
            <td>Tag text colour</td>
            <td><input class="form-control" type="color" data-bind="value: tagTextColor"/></td>
        </tr>
        <tr>
            <td colspan="2">
                <strong>Footer</strong>
                <!-- ko template: {'name': 'collapseExpandComponent', data: {flag: transients.showFooter} } -->
                <!-- /ko -->
            </td>
            <td><a href="#preview"><i class="fas fa-chevron-down"></i> Preview</a></td>
        </tr>
        <tr data-bind="visible: transients.showFooter">
            <td>Footer background colour</td>
            <td><input class="form-control" type="color" data-bind="value: footerBackgroundColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'textPreview', data: {textColor: footerTextColor, backgroundColor: footerBackgroundColor, text: 'Contact us'}}"></td>
        </tr>
        <tr data-bind="visible: transients.showFooter">
            <td>Footer text colour</td>
            <td><input class="form-control" type="color" data-bind="value: footerTextColor"/></td>
        </tr>
        <tr data-bind="visible: transients.showFooter">
            <td>Social media icon colour</td>
            <td><input class="form-control" type="color" data-bind="value: socialTextColor"/></td>
            <td rowspan="2" data-bind="template: {name: 'socialMediaPreview', data: {textColor: socialTextColor}}"></td>
        </tr>
        </tbody>
    </table>
</script>

<script id="templateHomePage" type="text/html">
<div class="accordion" id="homePageConfiguration">
    <div>
        <h4>
            <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                Project Finder Home Page Config <i class="fas fa-chevron-down float-right"></i>
            </button>
        </h4>
        <div id="collapseOne" class="collapse show" data-parent="#homePageConfiguration">
            <!-- ko with: projectFinderConfig -->
                <div class="pl-4">
                    <div class="form-group row">
                        <label class="col-form-label col-sm-4">Default content view:</label>
                        <div class="col-sm-8">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="defaultView" data-bind="checked: defaultView" value="grid">
                                <label class="form-check-label">
                                    Projects Grid
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="defaultView" data-bind="checked: defaultView" value="list">
                                <label class="form-check-label">
                                    Projects List
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="defaultView" data-bind="checked: defaultView" value="map" disabled>
                                <label class="form-check-label">
                                    Projects Map
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group row">
                        <div class="col-12">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="showProjectRegion" data-bind="checked: showProjectRegionSwitch">
                                <label class="form-check-label">
                                    Show project region button
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group row">
                        <div class="col-12">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="showProjectDownloadButton" data-bind="checked: showProjectDownloadButton">
                                <label class="form-check-label">
                                    Show project download button (hub admins only)
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            <!-- /ko -->
        </div>
    </div>
    <div>
        <h4>
            <button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                Buttons Home Page Config <i class="fas fa-chevron-down float-right"></i>
            </button>
        </h4>
        <div id="collapseTwo" class="collapse">
            <!-- ko with: buttonsConfig -->
                <div class="pl-4">
                    <div class="form-group row">
                        <label class="col-md-4 col-form-label">Number of columns</label>
                        <div class="col-md-8">
                            <select class="form-control" data-bind="value: numberOfColumns">
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
                        <!--ko template: { name: 'templateLink', data: {disableRoles:false, enableIntroText: false, link:$data, removeLink:function() {$parent.removeLink($data)} }} -->
                        <!-- /ko -->
                        <!-- /ko -->
                        <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td>
                                <button type="button" class="btn btn-dark" data-bind="click: addButton"><i class="fas fa-plus"></i> Add button</button>
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
        <div class="row previewHeader" data-bind="style:{'background-color': menuBackgroundColor}">
            <div class="col-12">
                <ul class="list-inline float-right">Choose between the following header option
                    <li class="list-inline-item"><a href="#" data-bind="style:{color: menuTextColor}">Home</a> <span class="divider" data-bind="style:{color: menuTextColor}">|</span></li>
                    <li class="list-inline-item"><a href="#" data-bind="style:{color: menuTextColor}">Data</a> <span class="divider" data-bind="style:{color: menuTextColor}">|</span></li>
                    <li class="list-inline-item"><a href="#" data-bind="style:{color: menuTextColor}">Help</a></li>
                </ul>
            </div>
        </div>
        <div class="row previewHeaderBannerSpace" data-bind="style:{'background-color': headerBannerBackgroundColor}">
            <div class="col-12"></div>
        </div>
        <div class="row">
            <div class="col-12">
                <div class="previewBanner row mb-4"  >
                    <div class="offset-2 col-8 previewBannerImage">
                        <div class="previewLogo text-center"><p>Logo</p></div>
                        <div class="previewInset" data-bind="style:{'background-color': insetBackgroundColor}">
                            <p class="text-center" data-bind="style:{color: insetTextColor}">Inset text</p>
                        </div>
                        <h4 class="text-center">Banner Image</h4>
                    </div>
                </div>
                <div class="row previewBody" data-bind="style:{'background-color': bodyBackgroundColor}">
                    <div class="col-12">
                        <div class="row mb-4">
                            <div class="col-4"><h1 data-bind="style:{color: titleTextColor}">Title text</h1></div>
                            <div class="col-4"><h1 data-bind="style:{color: bodyTextColor}">Body text</h1></div>
                            <div class="col-4">
                                <!-- ko template: {name: 'textPreview', data: {textColor: hrefColor, backgroundColor: 'transparent', text: 'Anchor'}} -->
                                <!-- /ko -->
                            </div>
                        </div>
                        <div class="row">
                            <div class="offset-4 col-2">
                                <!-- ko template: {name: 'buttonPreview', data: {textColor: '#fff', backgroundColor: primaryDarkColor}} -->
                                <!-- /ko -->
                            </div>
                            <div class="col-2">
                                <!-- ko template: {name: 'buttonPreview', data: {textColor: '#fff', backgroundColor: darkColor}} -->
                                <!-- /ko -->
                            </div>
                        </div>
                        <div class="row mb-4">
                            <div class="offset-4 col-2">
                                <!-- ko template: {name: 'textPreview', data: {textColor: tagTextColor, backgroundColor: tagBackgroundColor, text: 'Tag'}} -->
                                <!-- /ko -->
                            </div>
                            <div class="col-2">
                                <!-- ko template: {name: 'textPreview', data: {textColor: navTextColor, backgroundColor: navBackgroundColor, text: 'Nav'}} -->
                                <!-- /ko -->
                            </div>
                        </div>
                        <div class="row ">
                            <div class="col-4 border h-100" data-bind="style:{'background-color': facetBackgroundColor}"><h3>Facet Background</h3></div>
                            <div class="col-4 border h-100" data-bind="style:{'background-color': tileBackgroundColor}"><h3>Tile Background</h3></div>
                            <div class="col-4 border h-100" data-bind="style:{'background-color': wellBackgroundColor}">
                                <h3>Well colour</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row previewFooter"  data-bind="style:{'background-color': footerBackgroundColor}">
            <div class="col-12">
                <ul class="list-inline float-left">
                    <li class="list-inline-item"><a href="#" data-bind="style:{color: footerTextColor}">Contact us</a> <span class="divider" data-bind="style:{color: footerTextColor}">|</span></li>
                    <li class="list-inline-item"><a href="#" data-bind="style:{color: footerTextColor}">Disclaimer</a> <span class="divider" data-bind="style:{color: footerTextColor}">|</span></li>
                    <li class="list-inline-item"><a href="#" data-bind="style:{color: footerTextColor}">About us</a></li>
                </ul>
                <div class="float-right">
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
<table class="table">
    <thead>
    <tr>
        <th>Facet name</th>
        <th>Display name</th>
        <th>Display State</th>
        <th>Facet term type</th>
        <th>Display interval</th>
        <th>Chart type</th>
        <th>Help text</th>
        <th>Action</th>
    </tr>
    </thead>
    <tbody>
    <!-- ko foreach: facets -->
    <tr>
        <td>
            <p data-bind="text: title"></p>

            <p class="muted" data-bind="text: name"></p>
        </td>
        <td>
            <input class="form-control" type="text" data-bind="value:title" placeholder="Give a custom name for facet.">
        </td>
        <td>
            <select class="form-control" data-bind="value: state">
                <option value="Expanded">Show - Expanded</option>
                <option value="Collapsed">Show - Collapsed</option>
                <option value="Hidden">Hidden - used for chart data</option>
            </select>
        </td>
        <td>
            <select class="form-control" data-bind="value: facetTermType">
                <option value="Default">Default</option>
                <option value="ActiveOrCompleted">Active or Completed</option>
                <option value="PresenceOrAbsence">Presence or Absence</option>
                <option value="Histogram">Histogram</option>
                <option value="Date">Date</option>
                %{--<option value="GeoMap">Map</option>--}%
            </select>
        </td>
        <td>
            <input class="form-control" type="number" data-bind="value:interval, disable: isNotHistogram" step="1" min="0">
        </td>
        <td class="btn-space">
            <select class="form-control" data-bind="value: chartjsType">
                <option value="none">None</option>
                <option value="pie">Pie</option>
                <option value="bar">Bar</option>
                <option value="line">Line</option>
            </select>
            <button class="btn btn-sm btn-dark" data-bind="visible: chartjsType() !== 'none', click: editChartjsConfig"><i class="fas fa-pencil-alt"></i> Edit Config</button>
        </td>
        <td>
            <textarea class="form-control" rows="2" data-bind="value:helpText"
                      placeholder="Add custom help text"></textarea>
        </td>
        <td>
            <button class="btn btn-sm btn-danger" style="width:85px;" data-bind="click: $parent.remove">
                <i class="far fa-trash-alt"></i> Remove
            </button>
        </td>
    </tr>
    <!-- /ko -->
    <!-- ko ifnot: facets().length -->
    <tr>
        <td colspan="8">
            No Facets selected.
        </td>
    </tr>
    <!-- /ko -->
    </tbody>
    <tfoot>
    <tr>
        <td colspan="8">
            <div class="form-group row">
                <div class="col-label-form col-sm-2">
                    Pick a facet
                </div>
                <div class="col-sm-10 btn-space">
                    <select class="form-control" data-bind="options: transients.facetList,
                        optionsText:'formattedName', value: transients.selectedFacet"></select>
                    <button class="btn btn-sm btn-dark" data-bind="click: add"><i class="fas fa-plus"></i> Add</button>
                </div>
            </div>
        </td>
        <td>

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
            <input class="form-control" type="text"  data-bind="value:displayName" placeholder="Give a custom name for column." />
        </td>
        <td>
            <div class="custom-control custom-radio">

            </div>
            <div class="form-group form-check form-control-lg">
                <input class="form-check-input" type="radio" name="sort" data-bind="value: code, checked: $parent.transients.sortColumn, disable: !isSortable()" />
            </div>
        </td>
        <td>
            <select class="form-control" data-bind="value: order, disable: !isSortable()">
                <option value="asc">Ascending</option>
                <option value="desc">Descending</option>
            </select>
        </td>
        <td>
            <button class="btn btn-sm btn-danger" data-bind="click: $parent.removeDataColumn"><i class="far fa-trash-alt"></i> Remove</button>
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
            <div class="form-group row">
                <label class="col-sm-2 col-form-label">Pick a column</label>
                <div class="col-sm-10 btn-space">
                    <select class="form-control" data-bind="options: transients.defaultDataColumns, optionsText: 'name', value: transients.selectedDataColumn"></select>
                    <button class="btn btn-sm btn-dark" data-bind="click: addDataColumn"><i class="fas fa-plus"></i> Add</button>
                </div>
            </div>
        </td>
    </tr>
    </tfoot>
</table>
</script>
<script id="buttonPreview" type="text/html">
    <div class="text-center btn-preview" data-bind="style:{'background-color': backgroundColor, color: textColor, borderColor: backgroundColor}">
        Click me
    </div>
</script>
<script id="outlineButtonPreview" type="text/html">
<div class="text-center btn-preview-outline" data-bind="style:{'background-color': 'transparent', color: textColor, borderColor: textColor}">
    Click me
</div>
<div class="text-center btn-preview-outline" data-bind="style:{'background-color': textColor, color: hoverTextColor, borderColor: textColor}">
    On hover
</div>
</script>
<script id="textPreview" type="text/html">
<div class="text-center drawBorder margin-top-5" data-bind="style:{'background-color': backgroundColor, color: textColor, 'border-color': backgroundColor}, html: text">
</div>
</script>
<script id="socialMediaPreview" type="text/html">
<a class="do-not-mark-external" href="" data-bind="style:{color: textColor}">
    <span class="fa-stack fa-lg">
    <i class="fa fa-circle fa-stack-2x fa-inverse"></i>
    <i class="fa fa-twitter fa-stack-1x"></i>
    </span>
</a>
</script>
<script id="collapseExpandComponent" type="text/html">
<div class="inline">
    <i class="fas fa-chevron-down" data-bind="visible: !flag(), click: function(){flag(true)}"></i>
    <i class="fas fa-chevron-up" data-bind="visible: flag, click: function(){flag(false)}"></i>
</div>
</script>
<asset:script type="text/javascript">

    $(function() {

        var programsModel = <fc:modelAsJavascript model="${programsModel}"/>;
        var options = $.extend({formSelector:'.validationEngineContainer', currentHub:'${hubConfig.urlPath}'}, fcConfig);

        var viewModel = new HubSettingsViewModel(programsModel, options);

        ko.applyBindings(viewModel);

    });

</asset:script>

<g:render template="/shared/jsonEditorModal"/>
</body>
</html>
