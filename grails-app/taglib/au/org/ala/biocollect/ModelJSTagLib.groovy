package au.org.ala.biocollect

class ModelJSTagLib {

    static namespace = "md"

    private final static INDENT = "    "
    private final static operators = ['sum':'+', 'times':'*', 'divide':'/','difference':'-']
    private final static String QUOTE = "\"";
    private final static String SPACE = " ";
    private final static String EQUALS = "=";

    /*------------ JAVASCRIPT for dynamic content -------------*/

    def jsModelObjects = { attrs ->
        attrs.model?.dataModel?.each { model ->
            if (model.dataType in ['list', 'photoPoints']) {
                repeatingModel(attrs, model, out)
                totalsModel attrs, model, out
            }
            else if (model.dataType == 'matrix') {
                matrixModel attrs, model, out
            } else if (model.dataType == 'singleSighting' || model.dataType == 'multipleSightings') {
                sightingsModel(attrs, model, out)
            }
        }
        // TODO only necessary if the model has a field of type species.
        out << INDENT*2 << "var speciesLists = ${attrs.speciesLists.toString()};\n"

        def site = attrs.site ? attrs.site.toString() : "{}"
        out << INDENT*2 << "var site = ${site};\n"

        insertControllerScripts(attrs, attrs.model?.viewModel)

    }

    private insertControllerScripts(Map attrs, List viewModel) {
        viewModel?.each { view ->
            switch (view.type) {
                case "masterDetail":
                    masterDetailController(attrs, view, out)
                    break
                case "section":
                    insertControllerScripts(attrs, view.items)
                    break
            }
        }
    }

    def jsViewModel = { attrs ->
        createDataModelJS(attrs)
    }

    def createDataModelJS(attrs, String container = "self.data") {
        attrs.model?.dataModel?.each { mod ->
            if (mod.dataType  == 'list') {
                listViewModel(attrs, mod, out)
                columnTotalsModel out, attrs, mod
            } else if (mod.dataType == 'matrix') {
                matrixViewModel(attrs, mod, out)
            } else if (mod.computed) {
                computedViewModel(out, attrs, mod, 'self.data', 'self.data')
            } else if (mod.dataType == 'text') {
                textViewModel(mod, out)
            } else if (mod.dataType == 'number') {
                numberViewModel(mod, out)
            } else if (mod.dataType == 'stringList') {
                stringListModel(mod, out)
            } else if (mod.dataType == 'image') {
                imageModel(mod, out)
            } else if (mod.dataType == 'photoPoints') {
                photoPointModel(attrs, mod, out)
            } else if (mod.dataType == 'species') {
                speciesModel(attrs, mod, out)
            } else if (mod.dataType == 'date') {
                dateViewModel(mod, out)
            } else if (mod.dataType == 'document') {
                documentViewModel(mod, out)
            } else if (mod.dataType == 'singleSighting') {
                singleSightingViewModel(mod, out, container)
            } else if (mod.dataType == 'masterDetail') {
                masterDetailViewModel(mod, out)
            } else if (mod.dataType == "geoMap") {
                geoMapViewModel(mod, out, container)
            }
        }
        out << INDENT*3 << "self.transients.site = site;"
    }

    /**
     * This js is inserted into the 'loadData()' function of the view model.
     *
     * It loads the existing values (or default values) into the model.
     */
    def jsLoadModel = { attrs ->
        attrs.model?.dataModel?.each { mod ->
            if (mod.dataType == 'list') {
                out << INDENT*4 << "self.load${mod.name}(data.${mod.name});\n"
                loadColumnTotals out, attrs, mod
            }
            else if (mod.dataType == 'matrix') {
                out << INDENT*4 << "self.load${mod.name.capitalize()}(data.${mod.name});\n"
            }
            else if ((mod.dataType == 'text' || mod.dataType == 'date') && !mod.computed) {
                // MEW: Removed the 'orBlank' wrapper on the initial data which means missing data will be
                // 'undefined'. This works better with dropdowns as the default value is undefined and
                // therefore no data change occurs when the model is bound.
                out << INDENT*4 << "self.data['${mod.name}'](data['${mod.name}']);\n"
                // This seemed to work ok for plain text too but if it causes an issue, just add an
                // 'if (mode.constraints)' condition and return plain text to use orBlank.
            }
            else if (mod.dataType == 'number' && !mod.computed) {
                out << INDENT*4 << "self.data['${mod.name}'](orZero(data['${mod.name}']));\n"
            }
            else if (mod.dataType in ['stringList', 'image', 'photoPoints'] && !mod.computed) {
                out << INDENT*4 << "self.load${mod.name}(data['${mod.name}']);\n"
            }
            else if (mod.dataType == 'species') {
                out << INDENT*4 << "self.data['${mod.name}'].loadData(data['${mod.name}']);\n"
            }
            else if (mod.dataType == 'document') {
                out << INDENT*4 << "var doc = findDocumentById(documents, data['${mod.name}']);\n"
                out << INDENT*4 << "if (doc) {\n"
                out << INDENT*8 << "self.data['${mod.name}'](new DocumentViewModel(doc));\n"
                out << INDENT*4 << "}\n"
            } else if (mod.dataType == 'singleSighting') {
                out << INDENT*4 << "self.data.sighting.loadSightingData(data);\n"
            } else if (mod.dataType == 'masterDetail') {
                out << INDENT*4 << "self.data.masterDetail.loadItems(data['${mod.name}']);\n"
            } else if (mod.datType == "geoMap") {
                out << INDENT*4 << "self.data.['${mod.name}'](data['${mod.name}']);\n"
            }
        }
    }

    def jsSaveModel = { attrs ->

        out << INDENT*4 << "self.modelForSaving = function() {\n"
        out << INDENT*8 << "var outputData = {};\n"

        boolean genericClauseAdded = false

        attrs.model?.dataModel?.each { mod ->
            switch (mod.dataType) {
                case "singleSighting":
                    out << INDENT*8 << "ko.utils.extend(outputData, {\n"
                    out << INDENT*12 << "name: '${attrs.output.name}',\n"
                    out << INDENT*12 << "outputId: '${attrs.output.outputId}',\n"
                    out << INDENT*12 << "data: self.data.sighting.getSightingsDataAsJS()\n"
                    out << INDENT*8 << "});\n"

                    break
                case "masterDetail":
                    out << INDENT*8 << "ko.utils.extend(outputData, {\n"
                    out << INDENT*12 << "name: '${attrs.output.name}',\n"
                    out << INDENT*12 << "outputId: '${attrs.output.outputId}',\n"
                    out << INDENT*12 << "data: {${mod.name}: self.data.masterDetail.items()}\n"
                    out << INDENT*8 << "});\n"
                    break
                default:
                    if (!genericClauseAdded) {
                        out << INDENT*8 << "ko.utils.extend(outputData, ko.mapping.toJS(self, {'ignore':['transients']}));\n"
                        genericClauseAdded = true
                    }
                    break
            }
        }

        out << INDENT*8 << "return outputData;\n"
        out << INDENT*4 << "}\n"

    }

    def jsDirtyFlag = { attrs ->
        if (!attrs.model || !attrs.model.dataModel) {
            out << "window[viewModelInstance].dirtyFlag = ko.dirtyFlag(window[viewModelInstance], false);"
        } else {
            attrs.model?.dataModel?.each { mod ->
                switch (mod.dataType) {
                    case "singleSighting":
                        out << """
                        window[viewModelInstance].dirtyFlag = {
                            isDirty: window[viewModelInstance].data.sighting.isDirty,
                            reset: window[viewModelInstance].data.sighting.resetDirtyFlag
                        };
                    """
                        break
                    default:
                        out << "window[viewModelInstance].dirtyFlag = ko.dirtyFlag(window[viewModelInstance], false);"
                        break
                }
            }
        }
    }

    def columnTotalsModel(out, attrs, model) {
        if (!model.columnTotals) { return }
        out << INDENT*3 << "self.data.${model.columnTotals.name} = ko.observable({});\n"
    }

    def loadColumnTotals(out, attrs, model) {
        if (!model.columnTotals) { return }
        def name = model.columnTotals.name
        def objectName = name.capitalize() + "Row"
        model.columns.each { col ->
            if (!col.noTotal) {
                out << INDENT*4 << "self.data.${name}().${col.name} = new ${objectName}('${col.name}', self);\n"
            }
        }
    }

    def jsRemoveBeforeSave = { attrs ->
        attrs.model?.viewModel?.each({
            if (it.dataType == 'tableWithEditableRows' || it.type == 'photoPoints' || it.type == 'table') {
                out << INDENT*4 << "delete jsData.selected${it.source}Row;\n"
                out << INDENT*4 << "delete jsData.${it.source}TableDataUploadOptions\n"
                out << INDENT*4 << "delete jsData.${it.source}TableDataUploadVisible\n"

            }


        })
        attrs.model?.dataModel?.each({
            if (it.dataType == 'document') {
                // Convert an embedded document into a document id.
                out << INDENT*4 << "if (jsData.data && jsData.data.${it.name}) { jsData.data.${it.name} = jsData.data.${it.name}.documentId; }"
            }
        })
    }

    def computedViewModel(out, attrs, model, propertyContext, dependantContext) {
        computedViewModel(out, attrs, model, propertyContext, dependantContext, null)
    }
    def computedViewModel(out, attrs, model, propertyContext, dependantContext, parentModel) {
        out << "\n" << INDENT*3 << "${propertyContext}.${model.name} = ko.computed(function () {\n"
        if (model.computed.dependents == "all") {
            out <<
                    """                var total = 0, value;
                \$.each(${dependantContext}.${parentModel.source}(), function(i, obj) {
                    value = obj[name]();
                    if (isNaN(value)) {
                        total = total + (value ? 1 : 0)
                    } else {
                        total = total + Number(value);
                    }
                });
                return total;
"""
        }
        else if (model.computed.operation == 'percent') {
            if (model.computed.dependents?.size() > 1) {
                def dividend = model.computed.dependents[0]
                def divisor = model.computed.dependents[1]
                def rounding = model.computed.rounding ?: 2
                if (divisor == "#rowCount") {
                    divisor = "${dependantContext}.${parentModel.source}().length"
                }
                out <<
                        """                percent = self.${dividend}() * 100 / ${divisor};
                return neat_number(percent, ${rounding});
"""
            }
        }
        else if (model.computed.operation == 'difference') {
            out << INDENT*4 << "return ${dependantContext}.${model.computed.dependents[0]}() - ${dependantContext}.${model.computed.dependents[1]}();\n"
        }
        else if (model.computed.operation == "lookup") {
            computedByNumberRangeLookupFunction out, attrs, model, "self.${model.computed.dependents[0]}"
        }
        else if (model.computed.operation == 'count') {
            out << INDENT*4 << "return ${dependantContext}.${model.computed.dependents.source}().length;\n"
        }
        else if (model.computed.expression) {
            out << "var expression = Parser.parse('${model.computed.expression}');\n"
            out << "var variables = {};\n";
            for(int i=0; i < model.computed.dependents.source.size(); i++) {
                out << "variables['${model.computed.dependents.source[i]}'] = Number(${dependantContext}.${model.computed.dependents.source[i]}());\n"
            }
            out << "return expression.evaluate(variables);\n"
        }
        else if (model.computed.dependents.fromList) {
            out << INDENT*4 << "var total = 0;\n"
            if (model.computed.operation == 'average') {
                out << INDENT*4 << "var count = 0;\n"
            }
            out << INDENT*4 << "for(var i = 0; i < ${dependantContext}.${model.computed.dependents.fromList}().length; i++) {\n"
            out << INDENT*5 << "var value = ${dependantContext}.${model.computed.dependents.fromList}()[i].${model.computed.dependents.source}();\n"
            if (model.computed.operation != 'average') {
                out << INDENT*6 << "total = total ${operators[model.computed.operation]} Number(value); \n"
                out << INDENT*4 << "}\n"
                out << INDENT*4 << "return total;\n"
            }
            else {
                out << INDENT*6 << "if (!isNaN(parseFloat(value))) {\n"
                out << INDENT*8 << "total = total + Number(value);\n"
                out << INDENT*8 << "count++;\n"
                out << INDENT*6 << "}\n"
                out << INDENT*4 << "}\n"
                out << INDENT*4 << "return count > 0 ? total/count : 0;\n"
            }
        }
        else if (model.computed.dependents.fromMatrix) {
            out << INDENT*4 << "var total = 0;\n"
            if (model.computed.operation == 'average') {
                out << INDENT*4 << "var count = 0;\n"
            }
            out << INDENT*4 << "var grid = ${dependantContext}.${model.computed.dependents.fromMatrix};\n"
            // iterate columns and get value from model.computed.dependents.row
            out << INDENT*4 << "\$.each(grid, function (i,obj) {\n"
            if (model.computed.operation != 'average') {
                out << INDENT*5 << "total = total ${operators[model.computed.operation]} Number(obj.${model.computed.dependents.row}());\n"
                out << INDENT*4 << "});\n"
                out << INDENT*4 << "return total;\n"
            }
            else {
                out << INDENT*6 << "var value = obj.${model.computed.dependents.row}();\n"
                out << INDENT*6 << "if (!isNaN(parseFloat(value))) {\n"
                out << INDENT*8 << "total = total + Number(value);\n"
                out << INDENT*8 << "count++;\n"
                out << INDENT*6 << "}\n"
                out << INDENT*4 << "});\n"
                out << INDENT*4 << "return count > 0 ? total/count : 0;\n"
            }
        }

        else if (model.computed.dependents.from) {
            out << """
                var total = 0, dummyDependency = self.transients.dummy();
                \$.each(${dependantContext}.${model.computed.dependents.from}(), function (i, obj) {
                    total += obj.${model.computed.dependents.source}();
                });
                return total;
"""
        }
        else if (model.computed.operation == 'sum') {
            out << "var total = 0;"
            if (model.computed.dependents.source.size() == 1) {
                out << "total += Number(${dependantContext}.${model.computed.dependents.source[0]}());\n"
            } else {
                for(int i=0; i < model.computed.dependents.source.size(); i++) {
                    out << "total += Number(${dependantContext}.${model.computed.dependents.source[i]}());\n"
                }
            }
            out << INDENT*4 << "return total;"
        }

        out << INDENT*3 << "});\n"
    }

    def computedByNumberRangeLookupFunction(out, attrs, model, source) {
        def lookupMap = findInDataModel(attrs, model.computed.lookupMap)
        out <<
                """                var x = Number(${source}());
                if (isNaN(x)) { return '' }
"""
        lookupMap.map.each {
            if (it.inputMin == it.inputMax) {
                out << INDENT*4 << "if (x === ${it.inputMin}) { return ${it.output} }\n"
            } else {
                out << INDENT*4 << "if (x > ${it.inputMin} && x <= ${it.inputMax}) { return ${it.output} }\n"
            }
        }
    }

    def makeRowModelName(name) {
        def rowModelName = "${name}Row"
        return rowModelName[0].toUpperCase() + rowModelName.substring(1)
    }

    /**
     * Creates a js array that holds the row keys in the correct order, eg,
     * var <modelName>Rows = ['row1key','row2key']
     */
    def matrixModel(attrs, model, out) {
        out << INDENT*2 << "var ${model.name}Rows = [";
        def rows = []
        model.rows.each {
            rows << "'${it.name}'"
        }
        out << rows.join(',')
        out << "];\n"
        out << INDENT*2 << "var ${model.name}Columns = [";
        def cols = []
        model.columns.each {
            cols << "'${it.name}'"
        }
        out << cols.join(',')
        out << "];\n"
    }

    /**
     * Creates a js array containing Sighting objects for use with single or multiple sighing models
     */
    def sightingsModel(attrs, model, out) {
        out << INDENT*2 << "var ${model.name}Sightings = [];"
    }

    def matrixViewModel(attrs, model, out) {
        out << """
            self.data.${model.name} = [];//ko.observable([]);
            self.data.${model.name}.init = function (data, columns, rows) {
                var that = this, column;
                if (!data) data = [];
                \$.each(columns, function (i, col) {
                    column = {};
                    column.name = col;
"""
        model.rows.eachWithIndex { row, rowIdx ->
            if (!row.computed) {
                def value = "data[i] ? data[i].${row.name} : 0"
                switch (row.dataType) {
                    case 'number': value = "data[i] ? orZero(${value}) : '0'"; break
                    case 'text': value = "data[i] ? orBlank(${value}) : ''"; break
                    case 'boolean': value = "data[i] ? orFalse(${value}) : 'false'"; break
                }
                out << INDENT*5 << "column.${row.name} = ko.observable(${value});\n"
            }
        }
        // add observables to array before declaring the computed observables
        out << INDENT*5 << "that.push(column);\n"
        model.rows.eachWithIndex { row, rowIdx ->
            if (row.computed) {
                computedObservable(row, 'column', 'that[i]', out)
            }
        }

        out << """
                });
            };
            self.data.${model.name}.get = function (row,col) {
                var value = this[col][${model.name}Rows[row]];
"""
        if (attrs.edit) {
            out << INDENT*4 << "return value;\n"
        } else {
            out << INDENT*4 << "return (value() == 0) ? '' : value;\n"
        }
        out << """
            };
            self.load${model.name.capitalize()} = function (data) {
                self.data.${model.name}.init(data, ${model.name}Columns, ${model.name}Rows);
            };
"""
    }

    def repeatingModel(attrs, model, out) {
        def edit = attrs.edit as boolean
        def editableRows = viewModelFor(attrs, model.name, '')?.editableRows
        def observable = editableRows ? 'protectedObservable' : 'observable'
        out << INDENT*2 << "var ${makeRowModelName(model.name)} = function (data) {\n"
        out << INDENT*3 << "var self = this;\n"
        out << INDENT*3 << "if (!data) data = {};\n"
        out << INDENT*3 << "self.transients = {};\n"

        if (edit && editableRows) {
            // This observable is subscribed to by the SpeciesViewModel (so as to
            // allow editing to be controlled at the table row level) so needs to
            // be declared before any model data fields / observables.
            out << INDENT*3 << "this.isSelected = ko.observable(false);\n"
            out << """
            this.commit = function () {
                self.doAction('commit');
            };
            this.reset = function () {
                self.doAction('reset');
            };
            this.doAction = function (action) {
                var prop, item;
                for (prop in self) {
                    if (self.hasOwnProperty(prop)) {
                        item = self[prop];
                        if (ko.isObservable(item) && item[action]) {
                           item[action]();
                        }
                    }
                }
            };
            this.isNew = false;
            this.toJSON = function () {
                return ko.mapping.toJS(this, {'ignore':['transients', 'isNew', 'isSelected']});
            };
"""
        }
        model.columns.each { col ->
            if (col.computed) {
                switch (col.dataType) {
                    case 'number':
                        computedObservable(col, 'self', 'self', out)
                        break;
                }
            }
            else {
                switch (col.dataType) {
                    case 'simpleDate':
                    case 'date':
                        out << INDENT*3 << "this.${col.name} = ko.${observable}(orBlank(data['${col.name}'])).extend({simpleDate: false});\n"
                        break;
                    case 'text':
                        out << INDENT*3 << "this.${col.name} = ko.${observable}(orBlank(data['${col.name}']));\n"
                        break;
                    case 'number':
                        out << INDENT*3 << "this.${col.name} = ko.${observable}(orZero(data['${col.name}']));\n"
                        break;
                    case 'boolean':
                        out << INDENT*3 << "this.${col.name} = ko.${observable}(orFalse(data['${col.name}']));\n"
                        break;
                    case 'embeddedImage':
                        out << INDENT*3 << "if (data['${col.name}']) {\n"
                        out << INDENT*4 << "this.${col.name} = data['${col.name}'];\n"
                        out << INDENT*3 << "} else {\n"
                        out << INDENT*4 << "this.${col.name} = {};\n"
                        out << INDENT*3 << "}\n"
                        break;
                    case 'embeddedImages':
                        out << INDENT*3 << "this.${col.name} = ko.observableArray();\n"
                        out << INDENT*3 << "if (data['${col.name}'] instanceof Array) {\n"
                        out << INDENT*4 << "for (var i=0; i< data['${col.name}'].length; i++) {this.${col.name}.push(image(data['${col.name}'][i]))}\n"
                        out << INDENT*3 << "} else if (data['${col.name}']) {\n"
                        out << INDENT*4 << "this.${col.name}.push(image(data['${col.name}']));\n"
                        out << INDENT*3 << "}\n"
                        break;
                    case 'species':
                        out << INDENT*3 << "this.${col.name} =  new SpeciesViewModel(data['${col.name}'], speciesLists);\n"
                        break
                    case 'stringList':
                        out << INDENT*3 << "this.${col.name}=ko.observableArray(orEmptyArray(data['${col.name}']));\n";
                        break

                }
                modelConstraints(col, out)
            }
        }

        out << INDENT*2 << "};\n"
    }

    def totalsModel(attrs, model, out) {
        if (!model.columnTotals) { return }
        out << """
        var ${model.columnTotals.name.capitalize()}Row = function (name, context) {
            var self = this;
"""
        model.columnTotals.rows.each { row ->
            computedViewModel(out, attrs, row, 'this', "context.data", model.columnTotals)
        }
        out << """
        };
"""
    }

    def textViewModel(model, out) {
        out << "\n" << INDENT*3 << "self.data.${model.name} = ko.observable();\n"
        modelConstraints(model, out)
    }

    def numberViewModel(model, out) {
        out << "\n" << INDENT*3 << "self.data.${model.name} = ko.observable();\n"
        modelConstraints(model, out)
    }

    def dateViewModel(model, out) {
        out << "\n" << INDENT*3 << "self.data.${model.name} = ko.observable().extend({simpleDate: false});\n"
    }

    def documentViewModel(model, out) {
        out << "\n" << INDENT*3 << "self.data.${model.name} = ko.observable();\n"
    }

    def singleSightingViewModel(model, out, String container = "self.data") {
        out << "\n" << INDENT*3 << "${container}.sighting = new Sighting();\n"
    }

    def masterDetailViewModel(model, out) {
        out << "\n" << INDENT*3 << "self.data.masterDetail = new MasterDetail();\n"

        createDataModelJS([model: [dataModel: [model.detail]]], "self.data.masterDetail.detailView")
    }

    def geoMapViewModel(model, out, String container = "self.data") {
        out << "\n" << INDENT*3 << """
            ${container}.${model.name} = ko.observable();
            ${container}.${model.name}Latitude = ko.observable();
            ${container}.${model.name}Longitude = ko.observable();

            var mapOptions = {
                mapContainer: '${model.name}Map',
                scrollwheel: false,
                zoomToBounds: true,
                zoomLimit: 10,
                zoom: 4,
                defaultZoom: 4,
                highlightOnHover: true,
                features: [],
                featureService: "${createLink(controller: 'proxy', action: 'feature')}",
                wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
            };

            var ${model.name}Map = new MapWithFeatures(mapOptions);
            var ${model.name}PointerMarker = addCenteredMarkerTo${model.name}Map();

            ${container}.reset${model.name}Map = function() {
                ${container}.${model.name}(null);
                ${model.name}Map.clearFeatures();
                ${model.name}PointerMarker = addCenteredMarkerTo${model.name}Map();
            };

            function movePointerOn${model.name}Map() {
                var newPosition = new google.maps.LatLng(${container}.${model.name}Latitude(), ${container}.${model.name}Longitude());
                ${model.name}PointerMarker.setPosition(newPosition);
            };

            function addCenteredMarkerTo${model.name}Map() {
                var marker = ${model.name}Map.loadFeature({type: 'point', draggable: true}, null);
                var mapCenter = ${model.name}Map.getCenter();
                ${container}.${model.name}Latitude(mapCenter.lat());
                ${container}.${model.name}Longitude(mapCenter.lng());

                google.maps.event.addListener(marker, 'drag', function(event) {
                    ${container}.${model.name}Latitude(event.latLng.lat());
                    ${container}.${model.name}Longitude(event.latLng.lng());
                });

                return marker;
            };

            function moveMarkerOn${model.name}Map() {
                var newPosition = new google.maps.LatLng(${container}.${model.name}Latitude(), ${container}.${model.name}Longitude());
                ${model.name}PointerMarker.setPosition(newPosition);
            };

            function update${model.name}MapForSite(siteId) {
                if (typeof siteId !== "undefined" && siteId) {
                    var matchingSite = \$.grep(activityLevelData.pActivity.sites, function(site) { return siteId == site.siteId})[0];
                    ${model.name}Map.clearFeatures();
                    if (matchingSite) {
                        ${model.name}Map.replaceAllFeatures([matchingSite.extent.geometry]);
                        ${model.name}PointerMarker = addCenteredMarkerTo${model.name}Map();
                    }
                }
            };

            ${container}.${model.name}.subscribe(update${model.name}MapForSite);\n
            ${container}.${model.name}Latitude.subscribe(movePointerOn${model.name}Map);\n
            ${container}.${model.name}Longitude.subscribe(movePointerOn${model.name}Map);\n

        """
    }


    def computedObservable(model, propertyContext, dependantContext, out) {
        out << INDENT*5 << "${propertyContext}.${model.name} = ko.computed(function () {\n"
        // must be at least one dependant
        def numbers = []
        def checkNumberness = []
        model.computed.dependents.each {
            def ref = it
            def path = dependantContext
            if (ref.startsWith('$')) {
                ref = ref[1..-1]
                path = "self.data"
            }
            numbers << "Number(${path}.${ref}())"
            checkNumberness << "isNaN(Number(${path}.${ref}()))"
        }
        out << INDENT*6 << "if (" + checkNumberness.join(' || ') + ") { return 0; }\n"
        if (model.computed.operation == 'divide') {
            // can't divide by zero
            out << INDENT*6 << "if (${numbers[-1]} === 0) { return 0; }\n"
        }
        def expression = numbers.join(" ${operators[model.computed.operation]} ")
        if (model.computed.rounding) {
            expression = "neat_number(${expression},${model.computed.rounding})"
        }
        out << INDENT*6 << "return " + expression + ";\n"

        out << INDENT*5 << "});\n"
    }

    def listViewModel(attrs, model, out) {
        def rowModelName = makeRowModelName(model.name)
        def editableRows = viewModelFor(attrs, model.name, '')?.editableRows
        def defaultRows = []
        model.defaultRows?.each{
            defaultRows << INDENT*5 + "self.data.${model.name}.push(new ${rowModelName}(${it.toString()}));"
        }
        def insertDefaultModel = defaultRows.join('\n')

        // If there are no default rows, insert a single blank row and make it available for editing.
        if (attrs.edit && insertDefaultModel.isEmpty()) {
            insertDefaultModel = "self.add${model.name}Row();"
        }

        out << """
            self.data.${model.name} = ko.observableArray([]);
            self.selected${model.name}Row = ko.observable();
        """
        if (model.dataType != 'photoPoints') {
            out << """

            self.load${model.name} = function (data, append) {
                if (!append) {
                    self.data.${model.name}([]);
                }
                if (data === undefined) {
                    ${insertDefaultModel}
                } else {
                    \$.each(data, function (i, obj) {
                        self.data.${model.name}.push(new ${rowModelName}(obj));
                    });
                }
            };
"""
        }
        if (attrs.edit) {
            out << """
            self.add${model.name}Row = function () {
                var newRow = new ${rowModelName}();
                self.data.${model.name}.push(newRow);
                ${editableRows ? "newRow.isNew = true; self.edit${model.name}Row(newRow);" : ""}
            };
            self.remove${model.name}Row = function (row) {
                self.data.${model.name}.remove(row);
                ${editableRows ? "self.selected${model.name}Row(null);" : ""}
            };
            self.${model.name}rowCount = function () {
                return self.data.${model.name}().length;
            };

            self.${model.name}TableDataUploadVisible = ko.observable(false);
            self.show${model.name}TableDataUpload = function() {
                self.${model.name}TableDataUploadVisible(!self.${model.name}TableDataUploadVisible());
            };

            self.${model.name}TableDataUploadOptions = {
                    url:'${createLink([controller: 'activity', action: 'ajaxUpload'])}',
                    done:function(e, data) {
                        if (data.result.error) {
                            self.uploadFailed(data.result.error);
                        }
                        else {
                            self.load${model.name}(data.result.data, self.appendTableRows());
                        }
                    },
                    fail:function(e, data) {
                        var message = 'Please contact MERIT support and attach your spreadsheet to help us resolve the problem';
                        self.uploadFailed(data);

                    },
                    uploadTemplateId: "${model.name}template-upload",
                    downloadTemplateId: "${model.name}template-download",
                    formData:{type:'${attrs.output}', listName:'${model.name}'}
            };
            self.appendTableRows = ko.observable(true);
            self.uploadFailed = function(message) {
                        var text = "<span class='label label-important'>Important</span><h4>There was an error uploading your data.</h4>";
                        text += "<p>"+message+"</p>";
                        bootbox.alert(text)
            };
"""
            if (editableRows) {
                out << """
            self.${model.name}templateToUse = function (row) {
                return self.selected${model.name}Row() === row ? '${model.name}editTmpl' : '${model.name}viewTmpl';
            };
            self.edit${model.name}Row = function (row) {
                self.selected${model.name}Row(row);
                row.isSelected(true);
            };
            self.accept${model.name} = function (row, event) {
            if(\$(event.currentTarget).closest('.validationEngineContainer').validationEngine('validate')) {
                // todo: validation
                row.commit();
                self.selected${model.name}Row(null);
                row.isSelected(false);
                row.isNew = false;
                };
            };
            self.cancel${model.name} = function (row) {
                if (row.isNew) {
                    self.remove${model.name}Row(row);
                } else {
                    row.reset();
                    self.selected${model.name}Row(null);
                    row.isSelected(false);
                }
            };
            self.${model.name}Editing = function() {
                return self.selected${model.name}Row() != null;
            };
"""
            }
        }
    }

    def stringListModel(model, out) {
        out << INDENT*4 << "self.data.${model.name}=ko.observableArray([]);\n"
        modelConstraints(model, out)
        populateList(model, out)

    }

    def populateList(model, out) {
        out << INDENT*4 << """
        self.load${model.name} = function (data) {
            if (data !== undefined) {
                \$.each(data, function (i, obj) {
                    self.data.${model.name}.push(obj);
                });
        }};
        """
    }

    def populateImageList(model, out) {
        out << INDENT*4 << """
        self.load${model.name} = function (data) {
            if (data !== undefined) {
                \$.each(data, function (i, obj) {
                    self.data.${model.name}.push(image(obj));
                });
        }};
        """
    }

    def imageModel(model, out) {
        out << INDENT*4 << "self.data.${model.name}=ko.observableArray([]);\n"
        populateImageList(model, out)
    }

    def photoPointModel(attrs, model, out) {
        listViewModel(attrs, model, out)

        out << g.render(template:"/output/photoPointTemplate", plugin:'fieldcapture-plugin', model:[model:model]);
    }

    def speciesModel(attrs, model, out) {
        out << INDENT*3 << "self.data.${model.name} = new SpeciesViewModel({}, speciesLists);\n"
    }

    def modelConstraints(model, out) {
        if (model.constraints) {

            def stringifiedOptions = "["+ model.constraints.join(",")+"]"
            out << INDENT*3 << "self.transients.${model.name}Constraints = ${stringifiedOptions};\n"
        }
    }

    def masterDetailController(attrs, view, out) {
        out << """
            function MasterDetail() {
                var self = this;

                self.detailView = {};

                self.items = ko.observableArray();
                self.addOrEditMode = ko.observable(false);
                self.currentItem = ko.observable();
                self.selectedIndex = ko.observable(-1);

                self.addItem = function() {
                    self.selectedIndex(-1);
                    self.addOrEditMode(true);
                    self.reset();
                    self.toggleOverallSaveButton();
                };

                self.reset = function() {
                    if (typeof self.detailView === "undefined") {
                        self.detailView = {};
                    }

                    if (typeof self.detailView.sighting === "undefined") {
                        self.detailView.sighting = new Sighting();
                    } else {
                        self.detailView.sighting.reset();
                    }

                    self.toggleOverallSaveButton();
                }

                self.editItem = function(item) {
                    var index = self.items.indexOf(item);
                    if (index > -1 && index < self.items().length) {
                        self.selectedIndex(index);

                        self.reset();
                        self.detailView.sighting.loadSightingData(self.items()[index]);

                        self.addOrEditMode(true);

                        self.toggleOverallSaveButton();
                    }
                };

                self.removeItem = function(item) {
                    var index = self.items.indexOf(item);

                    if (index > -1 && index < self.items().length) {
                        self.items.splice(index, 1);
                    }

                    self.toggleOverallSaveButton();
                };

                self.saveItem = function() {
                    if (\$('#validation-container').validationEngine('validate')) {
                        var data = self.detailView.sighting.getSightingsDataAsJS();

                        if (self.selectedIndex() > -1) {
                            var oldData = self.items()[self.selectedIndex()]
                            self.items.replace(oldData, data);
                        } else {
                            self.items.push(data);
                        }

                        self.addOrEditMode(false);
                        self.selectedIndex(-1);
                        self.toggleOverallSaveButton();
                    }
                };

                self.cancelItem = function() {
                    self.addOrEditMode(false);
                    self.selectedIndex(-1);
                    self.toggleOverallSaveButton();
                };

                self.loadItems = function(data) {
                    if (data) {
                        self.items = ko.observableArray(data);
                    }

                    self.toggleOverallSaveButton();
                };

                self.toggleOverallSaveButton = function() {
                    \$("#save").prop('disabled', (self.items().length == 0  || self.addOrEditMode()));
                };
            };
        """

        jsModelObjects([output: attrs.output, model: constructDetailModelFromMasterDetail(attrs.model)])
    }

    static constructDetailModelFromMasterDetail(Map masterDetailModel) {
        List dataModels = masterDetailModel?.dataModel?.findAll { it.dataType == "masterDetail" }?.detail ?: []
        List viewModels = masterDetailModel?.viewModel?.findAll { it.type == "masterDetail" }?.detail ?: []

        [dataModel: dataModels, viewModel: viewModels]
    }

    /*------------ methods to look up attributes in the view model -------------*/
    static viewModelFor(attrs, name, context) {
        def viewModel = attrs.model.viewModel
        // todo: this needs to use context to do a hierarchy search
        def x = viewModel.find { it.name == name }
        return viewModel.find { it.source == name }
    }

    def findInDataModel(attrs, name) {
        def dataModel = attrs.model.dataModel
        // todo: just search top level for now
        dataModel.find {it.name == name}
    }

}
