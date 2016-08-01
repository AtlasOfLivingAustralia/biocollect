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

<div class="selected-hub" data-bind="visible:selectedHub()">

    <form class="form-horizontal validationEngineContainer" data-bind="with:selectedHub">
        <h2><span data-bind="visible:hubId">Editing: </span><span data-bind="visible:!hubId()">Creating: </span> <span data-bind="text:urlPath"></span></h2>
        <div class="control-group">
            <label class="control-label" for="name">URL path (added to URL to select the hub)</label>
            <div class="controls required">
                <input type="text" id="name" class="input-xxlarge" data-bind="value:urlPath" data-validation-engine="validate[required]">
            </div>
        </div>

        <div class="control-group">
            <label class="control-label" for="skin">Skin</label>
            <div class="controls required">
                <select id="skin" data-bind="value:skin,options:$parent.transients.availableSkins" data-validation-engine="validate[required]"></select>
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

        <div class="form-actions">
            <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Save</button>
            <button type="button" id="cancel" class="btn">Cancel</button>
        </div>
</form>
</div>

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