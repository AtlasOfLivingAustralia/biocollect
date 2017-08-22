/**
 * Created by koh032 on 14/02/2017.
 */

AEKOS.Utility = {
    createModalElement: function(templateName, viewModel) {
        var deferredElement = $.Deferred();

        ko.renderTemplate(
            templateName,
            viewModel,
            // We need to know when the template has been rendered,
            // so we can get the resulting DOM element.
            // The resolve function receives the element.
            {

                afterRender: function (nodes) {
                    // Ignore any #text nodes before and after the modal element.
                    var elements = nodes.filter(function(node) {
                        return node.nodeType === 1; // Element
                    });
                    // contain the modal element div
                    deferredElement.resolve(elements[0]);
                }

            },
            // The temporary div will get replaced by the rendered template output.
            document.getElementById("aekosWorkflowDialog")
        );
        // Return the deferred DOM element so callers can wait until it's ready for use.
        return deferredElement;
    },

    openModal : function(options) {
        if (typeof options === "undefined") throw new Error("An options argument is required.");
        if (typeof options.viewModel !== "object") throw new Error("options.viewModel is required.");
    
        var viewModel = options.viewModel;
        var template = options.template || viewModel.template;
        var context = options.context;
    
        if (!template) throw new Error("options.template or options.viewModel.template is required.");
    
        return AEKOS.Utility.createModalElement(template, viewModel)
                .pipe(function(modalElement) {
                   var deferredModalResult = $.Deferred();
                   $(modalElement).modal();
             //    viewModel.loadAekosData();
                   AEKOS.Utility.whenUIHiddenThenRemoveUI($(modalElement));
                   return deferredModalResult;
        });
    },
    whenUIHiddenThenRemoveUI: function($ui) {
        // Hidden event is also called when popover and dialog box within aekos modal closes
        // therefore, we need to filter that out. This is to remove aekosModal div once the user click on Close on aekosModal.
        $ui.bind('hidden', function (event) {
            var target = $( event.target );
            if (target.is("#aekosModal:not(.in)")) {
                // Call ko.cleanNode before removal to prevent memory leaks.
                $ui.each(function (index, element) {
                    ko.removeNode(element);
                });
                $ui.remove();
            };
        })
    }
};

AEKOS.Map = function () {
    
    var self = this;

    var mapOptions = {
        drawControl: false,
        showReset: false,
        draggableMarkers: false,
        useMyLocation: false,
        allowSearchLocationByAddress: false,
        allowSearchRegionByAddress: false,
        wmsFeatureUrl: fcConfig.wmsFeaturesUrl,
        wmsLayerUrl: fcConfig.wmsLayerUrl,
        singleDraw: false
    };

    /**
     * creates popup on the map
     * @param projectLinkPrefix
     * @param projectId
     * @param projectName
     * @param activityUrl
     * @param surveyName
     * @param speciesName
     * @returns {string}
     */
    var generatePopup = function (projectLinkPrefix, projectId, projectName, activityUrl, surveyName, speciesName){
        var html = "<div class='projectInfoWindow'>";
        var version = fcConfig.version === undefined ? "" : "?version=" + fcConfig.version

        if (activityUrl && surveyName) {
            html += "<div><i class='icon-home'></i> <a target='_blank' href='" +
                activityUrl + version +"'>" +surveyName + " (record)</a></div>";
        }

        if(projectName){
            html += "<div><a target='_blank' href="+projectLinkPrefix+projectId+version+"><i class='icon-map-marker'></i>&nbsp;" +projectName + " (project)</a></div>";
        }

        if(speciesName){
            html += "<div><i class='icon-camera'></i>&nbsp;"+ speciesName + "</div>";
        }

        return html;
    };

    self.getPointFeatures = function (activity, record) {
        var projectId = activity.projectId;
        var projectName = activity.name;
        var activityUrl = fcConfig.activityViewUrl+'/'+activity.activityId;
        if(record.coordinates && record.coordinates.length && record.coordinates[1] && !isNaN(record.coordinates[1]) && record.coordinates[0] && !isNaN(record.coordinates[0])){
            return {
                // the ES index always returns the coordinate array in [lat, lng] order
                lat: record.coordinates[0],
                lng: record.coordinates[1],
                popup: generatePopup(fcConfig.projectLinkPrefix,projectId,projectName, activityUrl, activity.name, record.name)
            };
        };
    };

    self.showMap = function (data, event) {
        alaMap.redraw();
    };

    var showHideProjectLayer = function () {
        if (self.projectAreaChecked) {
            alaMap.clearLayers();
            self.projectAreaChecked = null;
        } else {
            addProjectLayer();
        }
        self.ibraRegionChecked && alaMap.addWmsLayer (self.ibraRegion);
        alaMap.addClusteredPoints (self.datasetRecordPoints);
    };

    var showHideIbraRegionLayer = function () {
        if (self.ibraRegionChecked) {
            alaMap.clearLayers();
            self.ibraRegionChecked = null;
        } else {
            addIbraRegionLayer(self.ibraRegion, false);
        }
        self.projectAreaChecked && alaMap.addWmsLayer (projectArea.pid);
        alaMap.addClusteredPoints (self.datasetRecordPoints);
    };

    /**
     * creates the map and plots the points on map  
     * @param features
     */
    self.plotOnAekosMap = function (recordPoints, projectArea, ibraRegion){

        if(!alaMap){
            alaMap = new ALA.Map("aekosDatasetMap", mapOptions);
            alaMap.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", alaMap.fitBounds, "bottomleft");
        }

        if (recordPoints && recordPoints[0] != undefined) {
            addRecordsLayer(recordPoints);
        }

        if (ibraRegion && ibraRegion.length > 0) {
            addIbraRegionLayer(ibraRegion[0].pid, true);
        }

        if (projectArea && projectArea.pid) {
            addProjectLayer(projectArea.pid);
        }
    };

    var addRecordsLayer = function (recordPoints) {
        if (recordPoints && recordPoints.length > 0) {
            self.totalPoints = recordPoints && recordPoints.length ? recordPoints.length : 0;
            self.datasetRecordPoints = recordPoints;
            alaMap.addClusteredPoints(recordPoints);
        } else {
            self.totalPoints = 0;
        }
    };

    var addIbraRegionLayer = function (ibraRegionPid, initial) {

        if (!self.ibraRegion) {
            var ibraRegionCheckBox = new L.Control.Checkbox({
                name: 'ibraRegionCheckBox',
                potion: 'topright',
                text: "Ibra Region Area  ",
                initialValue: false,
                onClick: showHideIbraRegionLayer
            });

            alaMap.addControl(ibraRegionCheckBox);
            self.ibraRegion = ibraRegionPid;
        }

        if (self.ibraRegion && !initial) {
            self.ibraRegionChecked = true;
            alaMap.addWmsLayer(self.ibraRegion);
        }
    };

    var addProjectLayer = function (projectAreaPid) {
        if (!self.projectArea) {
            projectCheckBox = new L.Control.Checkbox({
                name: 'projectCheckBox',
                potion: 'topright',
                text: "Project Area  ",
                onClick: showHideProjectLayer
            });
            alaMap.addControl(projectCheckBox);
            self.projectArea = projectAreaPid;
        }

        if (self.projectArea) {
            self.projectAreaChecked = true;
            alaMap.addWmsLayer(self.projectArea);
        }
    };

};

