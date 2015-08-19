<!doctype html>
<html>
<head>
    <meta name="layout" content="adminLayout"/>
    <title>Metadata | Admin | Data capture | Atlas of Living Australia</title>
    <r:require modules="jquery,knockout,jqueryValidationEngine,attachDocuments"/>
</head>

<body>

<content tag="pageTitle">Create / Edit Hub</content>

<div class="alert" data-bind="visible:transients.message()">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <span data-bind="text:transients.message"></span>
</div>
<div>
    Current hub: ${hubConfig.id}
</div>

<div>
    Enter hub id: <input type="text" name="selectHub" data-bind="value:transients.selectedHub">
</div>

<form class="form-horizontal validationEngineContainer" data-bind="visible:transients.selectedHub()">
    <div class="control-group">
        <label class="control-label" for="name">Hub id (used in the URL, so keep short)</label>
        <div class="controls required">
            <input type="text" id="name" class="input-xxlarge" data-bind="value:id" data-validation-engine="validate[required]" readonly="readonly" placeholder="Hub id">
        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="skin">Skin</label>
        <div class="controls required">
            <select id="skin" data-bind="value:skin,options:transients.availableSkins" data-validation-engine="validate[required]"></select>
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
            <ul id="supported-programs" data-bind="foreach:transients.programNames" class="unstyled">
                <li><label><input type="checkbox" data-bind="checked:$root.supportedPrograms, attr:{value:$data}"> <span data-bind="text:$data"></span></label></li>
            </ul>

        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="available-facets">Available Facets (Only these facets will display on the home page)</label>
        <div class="controls">
            <ul id="available-facets" data-bind="foreach:transients.availableFacets" class="unstyled">
                <li><label><input type="checkbox" data-bind="checked:$root.availableFacets, attr:{value:$data}"> <span data-bind="text:$data"></span> <span data-bind="text:$root.facetOrder($data)"></span></label></li>
            </ul>

        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="available-facets">Admin Facets (Only these facets will display on the home page)</label>
        <div class="controls">
            <ul id="admin-facets" data-bind="foreach:transients.adminFacets" class="unstyled">
                <li><label><input type="checkbox" data-bind="checked:$root.adminFacets, attr:{value:$data}"> <span data-bind="text:$data"></span> <span data-bind="text:$root.facetAdminOrder($data)"></span></label></li>
            </ul>

        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="available-facets">Available Map Facets (Only these facets will display on the home page map menu)</label>
        <div class="controls">
            <ul id="admin-map-facets" data-bind="foreach:transients.availableMapFacets" class="unstyled">
                <li><label><input type="checkbox" data-bind="checked:$root.availableMapFacets, attr:{value:$data}"> <span data-bind="text:$data"></span> <span data-bind="text:$root.facetMapAdminOrder($data)"></span></label></li>
            </ul>

        </div>
    </div>

    <div class="control-group">
        <label class="control-label" for="default-facets-list">Default Facet Query (Searches will automatically include these facets)</label>
        <div class="controls">
            <ul id="default-facets-list" data-bind="foreach:defaultFacetQuery">
                <li>
                    <input type="text" class="input-xxlarge"  data-bind="value:query" placeholder="query string as produced by the home page"> <button class="btn" data-bind="click:$root.removeDefaultFacetQuery">Remove</button>
                </li>
            </ul>
            <button class="btn" data-bind="click:$root.addDefaultFacetQuery">Add</button>

        </div>
    </div>

    <div class="form-actions">
        <button type="button" id="save" data-bind="click:save" class="btn btn-primary">Save</button>
        <button type="button" id="cancel" class="btn">Cancel</button>
    </div>
</form>

<r:script>

    $(function() {
        var saveSettingsUrl = '${createLink(controller:'admin', action: 'saveHubSettings')}';
        var getSettingsUrl = '${createLink(controller:'admin', action: 'loadHubSettings')}';

        var HubSettingsViewModel = function(programsModel) {
            var self = this;

            self.id = ko.observable();
            self.skin = ko.observable();
            self.title = ko.observable();
            self.supportedPrograms = ko.observableArray();
            self.availableFacets = ko.observableArray();
            self.adminFacets = ko.observableArray();
            self.availableMapFacets = ko.observableArray();
            self.defaultFacetQuery = ko.observableArray();
            self.homePagePath = ko.observable();
            self.bannerUrl = ko.observable();
            self.logoUrl = ko.observable();
            self.documents = ko.observableArray();

            self.documents.subscribe(function(documents) {
                $.each(documents, function(i, document) {
                    if (document.role == 'banner') {
                        self.bannerUrl(document.url);
                    }
                    else if (document.role == 'logo') {
                        self.logoUrl(document.url);
                    }
                });
            });

            self.removeLogo = function() {
                self.logoUrl(null);
                var document = findDocumentByRole(self.documents(), 'logo');
                self.documents.remove(document);
            };

            self.removeBanner = function() {
                self.bannerUrl(null);
                var document = findDocumentByRole(self.documents(), 'banner');
                self.documents.remove(document);
            };

            var programNames = $.map(programsModel.programs, function(program, i) {
               return program.name;
            });
            self.transients = {
                availableFacets:['status','organisationFacet','associatedProgramFacet','associatedSubProgramFacet','mainThemeFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','otherFacet', 'gerSubRegionFacet','electFacet','cmzFacet','meriPlanAssetFacet', 'partnerOrganisationTypeFacet'],
                availableMapFacets:['status', 'organisationFacet','associatedProgramFacet','associatedSubProgramFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','electFacet', 'cmzFacet'],
                adminFacets:['electFacet', 'cmzFacet','meriPlanAssetFacet', 'partnerOrganisationTypeFacet'],
                programNames:programNames,
                message:ko.observable(),
                selectedHub:ko.observable(),
                availableSkins:['nrm', 'ala2']
            };

            self.removeDefaultFacetQuery = function(data) {
                self.defaultFacetQuery.remove(data);
            };
            self.addDefaultFacetQuery = function() {
                self.defaultFacetQuery.push({query:ko.observable()});
            };
            self.facetOrder = function(facet) {
                var facetList = self.availableFacets ? self.availableFacets : [];
                var index = facetList.indexOf(facet);
                return index >= 0 ? '('+(index + 1)+')' : '';
            }

            self.facetAdminOrder = function(facet) {
                var facetList = self.adminFacets ? self.adminFacets : [];
                var index = facetList.indexOf(facet);
                return index >= 0 ? '('+(index + 1)+')' : '';
            }

            self.facetMapAdminOrder = function(facet) {
                var facetList = self.availableMapFacets ? self.availableMapFacets : [];
                var index = facetList.indexOf(facet);
                return index >= 0 ? '('+(index + 1)+')' : '';
            }

            self.loadSettings = function(settings) {
               self.id(settings.id);
               self.skin(settings.skin);
               self.title(settings.title);
               self.supportedPrograms(self.orEmptyArray(settings.supportedPrograms));
               self.availableFacets(self.orEmptyArray(settings.availableFacets));
               self.adminFacets(self.orEmptyArray(settings.adminFacets));
               self.availableMapFacets(self.orEmptyArray(settings.availableMapFacets));
               self.bannerUrl(self.orBlank(settings.bannerUrl));
               self.logoUrl(self.orBlank(settings.logoUrl));
               self.homePathPath(self.orBlank(settings.homePagePath));

               if (settings.defaultFacetQuery && settings.defaultFacetQuery instanceof Array) {
                   $.each(settings.defaultFacetQuery, function(i, obj) {
                       self.defaultFacetQuery.push({query: ko.observable(obj)});
                   });
               }
            };

            self.transients.selectedHub.subscribe(function(newValue) {
               $.get(getSettingsUrl, {id:newValue, format:'json'}, function(data) {
                    if (!data.id) {
                        self.transients.message('Creating a new hub with id: '+newValue);
                        data.id = newValue;
                    }
                    else {
                        self.transients.message('');
                    }
                    self.loadSettings(data);

               }, 'json').fail(function() {
                 self.transients.message('Error loading hub details');
               });
           });

           self.orEmptyArray = function(value) {
               if (value === undefined || value === null) {
                   return [];
               }
               else if (!(value instanceof Array)) {
                    value = [value];
               }
               return value;
           }
           self.orBlank = function(value) {
               if (value === undefined || value === null) {
                   return '';
               }
               return value;
           }


           self.save = function() {
               var js = ko.mapping.toJS(self, {ignore:'transients'});
               // Unwrap the default facet query which we wrapped to allow binding to values in the array
               var defaultFacetQuery = [];
               $.each(js.defaultFacetQuery, function(i, query) {
                   if (query.query) {
                       defaultFacetQuery.push(query.query);
                   }
               });
               js.defaultFacetQuery = defaultFacetQuery;
               var json = JSON.stringify(js);

               $.ajax(saveSettingsUrl, {type:'POST', data:json, contentType:'application/json'}).done( function(data) {
                if (data.errors) {
                    self.transients.message(data.errors);
                }
                else {
                    self.transients.message('Hub saved!');
                }

            }).fail( function() {

                self.transients.message('An error occurred saving the settings.');
            });
           };

        };
        var programsModel = <fc:modelAsJavascript model="${programsModel}"/>;
        var viewModel = new HubSettingsViewModel(programsModel);

        ko.applyBindings(viewModel);
        $('.validationEngineContainer').validationEngine();
    });

</r:script>

</body>
</html>