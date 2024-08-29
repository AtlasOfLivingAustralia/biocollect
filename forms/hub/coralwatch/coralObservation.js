var imageCarousel = '<img style="height:300px" src="https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&filename=plate.png&model=coralWatch" alt="Plate"><img style="height:300px" src="https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=boulder_layout.png" alt="Boulder"><img style="height:300px" src="https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=branching.png" alt="Branching"><img style="height:300px" src="https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=soft.png" alt="Boulder">';
$(".form-actions").before(imageCarousel);
const coralWatchContainerValueIncrement = function (e, a) {
    if (!e || !a) return;
    e.has(a) || e.set(a, 0);
    const t = e.get(a) + 1;
    e.set(a, t)
}, coralWatchContainerToChartDataItems = function (e, a) {
    if (console.warn("[CoralWatch] coralWatchContainerToChartDataItems start", e(), a), !e) return;
    a || (a = new Map);
    const t = "CustomChartDataItem", o = [];
    a.forEach((function (a, r) {
        const c = t + "|||" + r.toString() + "|||" + a.toString();
        if (o.push(c), -1 === e.indexOf(c)) {
            const a = t + "|||" + r.toString() + "|||", o = e().findIndex((function (e) {
                return e.startsWith(a)
            }));
            o > -1 ? e.splice(o, 1, c) : e.push(c)
        }
    })), e.remove((function (e) {
        return -1 === o.indexOf(e)
    })), console.warn("[CoralWatch] coralWatchContainerToChartDataItems finish", e())
}, coralWatchRecordLevelCountUpdate = function (e) {
    const a = new Map, t = new Map;
    e.forEach((function (e) {
        const o = e.colourCodeAverage();
        coralWatchContainerValueIncrement(a, o);
        const r = e.typeOfCoral();
        coralWatchContainerValueIncrement(t, r)
    })), coralWatchContainerToChartDataItems(self.data.colourCodeAverageRecordLevelCount, a), coralWatchContainerToChartDataItems(self.data.typeOfCoralRecordLevelCount, t)
}, coralWatchActivitySelfData = self.data;
var observationCounter = 0, prevObject = void 0, Output_CoralWatch_coralObservationsRow = function (e, a, t, o) {
    var r = this;
    observationCounter = t.index + 1, ecodata.forms.NestedModel.apply(r, [e, a, t, o]), t = _.extend(t, {parent: r}), r.sampleId = ko.observable().extend({numericString: 2}), r.colourCodeLightest = ko.observable().extend({
        metadata: {
            metadata: r.dataModel.colourCodeLightest,
            context: r.$context,
            config: o
        }
    }), r.colourCodeDarkest = ko.observable().extend({
        metadata: {
            metadata: r.dataModel.colourCodeDarkest,
            context: r.$context,
            config: o
        }
    }), r.colourCodeAverage = ko.observable().extend({numericString: 2}), r.typeOfCoral = ko.observable().extend({
        metadata: {
            metadata: r.dataModel.typeOfCoral,
            context: r.$context,
            config: o
        }
    });
    var c = _.extend(o, {printable: "", dataFieldName: "coralSpecies", output: "CoralWatch", surveyName: ""});
    r.coralSpecies = new SpeciesViewModel({}, c), r.speciesPhoto = ko.observableArray([]), r.speciesPhoto = ko.observableArray([]), r.loadspeciesPhoto = function (e) {
        void 0 !== e && $.each(e, (function (e, a) {
            r.speciesPhoto.push(new ImageViewModel(a, !1, t))
        }))
    }, r.loadData = function (e) {
        r.sampleId(ecodata.forms.orDefault(e.sampleId, observationCounter)), r.colourCodeLightest(ecodata.forms.orDefault(e.colourCodeLightest, void 0)), r.colourCodeDarkest(ecodata.forms.orDefault(e.colourCodeDarkest, void 0)), r.colourCodeAverage(ecodata.forms.orDefault(e.colourCodeAverage, 0)), r.typeOfCoral(ecodata.forms.orDefault(e.typeOfCoral, void 0)), r.coralSpecies.loadData(ecodata.forms.orDefault(e.coralSpecies, {})), r.loadspeciesPhoto(ecodata.forms.orDefault(e.speciesPhoto, []))
    }, r.loadData(e || {}), r.colourCodeLightest.subscribe((function (e) {
        var a = r.colourCodeLightest();
        if (a) {
            var t = ["B1", "B2", "B3", "B4", "B5", "B6", "C1", "C2", "C3", "C4", "C5", "C6", "D1", "D2", "D3", "D4", "D5", "D6", "E1", "E2", "E3", "E4", "E5", "E6"],
                o = (t.indexOf(a), []);
            $.each(t, (function (e, t) {
                var r = a.charAt(1);
                parseInt(t.charAt(1)) >= r && o.push({text: t, value: t})
            })), bootbox.prompt({
                title: "<h1>Select Dark colour code value<h1>",
                closeButton: !1,
                required: !0,
                inputType: "select",
                inputOptions: o,
                buttons: {
                    confirm: {label: "OK", className: "btn-success"},
                    cancel: {label: "Clear", className: "d-none"}
                },
                callback: function (e) {
                    if (r.colourCodeDarkest(e), r.colourCodeDarkest() && r.colourCodeLightest()) {
                        var a = parseInt(r.colourCodeDarkest().charAt(1)) + parseInt(r.colourCodeLightest().charAt(1));
                        a > 0 && r.colourCodeAverage((a / 2).toFixed(2))
                    }
                }
            })
        }
    })), r.typeOfCoral.subscribe((function (e) {
        if (e) {
            switch (e) {
                case"Plate corals":
                    "https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=plate.png";
                    break;
                case"Boulder corals":
                    "https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=boulder_layout.png";
                    break;
                case"Branching corals":
                    "https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=branching.png";
                    break;
                case"Soft corals":
                    "https://biocollect.ala.org.au/download/getScriptFile?hub=coralwatch&model=coralWatch&filename=soft.png";
                    break;
                default:
                    ""
            }
        }
    })), r.colourCodeAverage.subscribe((function (e) {
        const a = coralWatchActivitySelfData.coralObservations();
        coralWatchRecordLevelCountUpdate(a)
    })), r.typeOfCoral.subscribe((function (e) {
        const a = coralWatchActivitySelfData.coralObservations();
        coralWatchRecordLevelCountUpdate(a)
    }))
}, context = _.extend({}, context, {parent: self, listName: "coralObservations"});
self.data.coralObservations = ko.observableArray().extend({
    list: {
        metadata: self.dataModel,
        constructorFunction: Output_CoralWatch_coralObservationsRow,
        context: context,
        userAddedRows: !0,
        config: config
    }
}), self.data.coralObservations.subscribe((function (e) {
    coralWatchRecordLevelCountUpdate(self.data.coralObservations())
})), self.data.coralObservations.loadDefaults = function () {
    self.data.coralObservations.addRow()
}, self.data.depthInMetres.subscribe((function (e) {
    var a = 3.28084 * parseFloat(self.data.depthInMetres());
    a = a.toFixed(2), self.data.depthInFeet(a)
})), self.data.waterTemperatureInDegreesCelcius.subscribe((function (e) {
    var a = parseFloat(1.8 * parseFloat(self.data.waterTemperatureInDegreesCelcius()).toFixed(2) + 32);
    a = a.toFixed(2), self.data.waterTemperatureInDegreesFarenheit(a)
})), self.transients.convert = ko.computed((function () {
    if ("0" == self.data.waterTemperatureInDegreesFarenheit() && "0" == self.data.waterTemperatureInDegreesCelcius()) ; else {
        var e = (parseFloat(self.data.waterTemperatureInDegreesFarenheit()).toFixed(2) - 32) / 1.8;
        e = e.toFixed(2), self.data.waterTemperatureInDegreesCelcius(e)
    }
    var a = parseFloat(self.data.depthInFeet()).toFixed(2) / 3.28084;
    a = a.toFixed(2), self.data.depthInMetres(a)
}), this);
