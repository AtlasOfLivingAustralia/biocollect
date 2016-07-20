var ActivityModel = function (act, model) {
    var self = this;
    self.name = ko.observable(act.name);
    self.type = ko.observable(act.type);
    self.outputs = ko.observableArray(act.outputs || []);
    self.outputConfig = ko.observableArray($.map(act.outputConfig || [], function (outputConfig) {
        return new OutputConfig(outputConfig);
    }));

    self.expanded = ko.observable(false);
    self.category = ko.observable(act.category);
    self.enabled = ko.observable(!act.status || act.status == 'active');
    self.status = ko.observable(act.status);
    self.gmsId = ko.observable(act.gmsId);
    self.supportsSites = ko.observable(act.supportsSites);
    self.supportsPhotoPoints = ko.observable(act.supportsPhotoPoints);

    self.outputs.subscribe(function () {
        self.initialiseOutputConfig();
    });
    self.enabled.subscribe(function (enabled) {
        if (enabled) {
            self.status('active');
        }
        else {
            self.status('deleted');
        }
    });
    self.toggle = function (data, event) {
        if (!self.expanded()) {
            $.each(model.activities(), function (i, obj) {
                obj.expanded(false); // close all
                obj.done(); // exit editing mode
            });
            self.expanded(true);
            model.selectedActivity(self);
        } else {
            self.expanded(false);
            self.done(); // in case we were editing
            model.selectedActivity(undefined);
        }
    };
    self.type.subscribe(function (newType) {
        if (newType === 'Report') {
            self.supportsSites(false);
            self.supportsPhotoPoints(false);
        }
    });
    self.editing = ko.observable(false);
    self.edit = function () {
        self.editing(true)
    };
    self.done = function () {
        self.editing(false)
    };
    self.displayMode = function () {
        return self.editing() ? 'editActivityTmpl' : 'viewActivityTmpl';
    };
    self.removeOutput = function (data) {
        self.outputs.remove(data);
        self.outputConfig.remove(function (outputConfig) {
            return outputConfig.outputName == data;
        });
    };

    self.findOutputConfigByName = function(outputName) {
        for (var j = 0; j < self.outputConfig().length; j++) {
            if (outputName == self.outputConfig()[j].outputName()) {
                return self.outputConfig()[j];
            }
        }
    };

    self.outputConfigByName = ko.computed(function () {
        var outputConfigByName = {};
        for (var i = 0; i < self.outputs().length; i++) {
            var outputName = self.outputs()[i];
            var outputConfig = self.findOutputConfigByName(outputName);
            if (outputConfig) {
                outputConfigByName[outputName] = outputConfig;
            }
        }
        return outputConfigByName;
    });
    self.initialiseOutputConfig = function () {
        for (var i = 0; i < self.outputs().length; i++) {
            var outputName = self.outputs()[i];
            var outputConfig = self.findOutputConfigByName(outputName);
            if (!outputConfig) {
                self.outputConfig.push(new OutputConfig({
                    outputName: outputName,
                    optional: false,
                    collapsedByDefault: false
                }));
            }
        }
    };
    self.toJSON = function () {
        var js = ko.toJS(this);
        delete js.expanded;
        delete js.editing;
        delete js.enabled;
        delete js.outputConfigByName;
        return js;
    };
    self.initialiseOutputConfig();
};

var OutputConfig = function (outputConfig) {
    var self = this;
    self.outputName = ko.observable(outputConfig.outputName);
    self.optionalQuestionText = ko.observable(outputConfig.optionalQuestionText);
    self.optional = ko.observable(outputConfig.optional);
    self.collapsedByDefault = ko.observable(outputConfig.collapsedByDefault);

    self.optional.subscribe(function (val) {
        if (!val) {
            self.collapsedByDefault(false);
        }
    });
};

var ScoreModel = function (template, score) {
    var self = this;
    self.name = ko.observable(score.name);
    self.label = ko.observable(score.label);
    self.description = ko.observable(score.description);
    self.category = ko.observable(score.category);
    self.units = ko.observable(score.units)
    self.aggregationType = ko.observable(score.aggregationType)
    self.groupBy = ko.observable(score.groupBy);
    self.filterBy = ko.observable(score.filterBy);
    self.displayType = ko.observable(score.displayType);
    self.listName = ko.observable(score.listName);
    self.gmsId = ko.observable(score.gmsId);
    self.buildCompoundName = function (list, name) {
        if (list) {
            return list + '.' + name;
        }
        return name;
    };
    self.compoundName = ko.observable(self.buildCompoundName(self.listName(), self.name()));
    self.compoundName.subscribe(function (name) {
        var bits = name.split('.');
        if (bits.length == 1) {
            self.name(bits[0]);
            self.listName('');
        }
        else {
            self.name(bits[1]);
            self.listName(bits[0]);
        }
    });
    self.nameOptions = ko.observableArray([self.compoundName()]);

    // True if this score can / should be assigned a target for project planning purposes
    self.isOutputTarget = ko.observable(score.isOutputTarget)

    self.template = ko.observable();
    self.template.subscribe(function (template) {
        $.each(template.dataModel, function (i, obj) {
            if (obj.dataType == 'list') {
                $.each(obj.columns, function (i, nested) {
                    self.nameOptions.push(obj.name + '.' + nested.name);
                });
            }
            self.nameOptions.push(obj.name);
        });
    });

    self.template(template);


    self.aggregationTypeValid = ko.computed(function () {
        if (!self.template()) {
            return true;
        }
        $.each(self.template().dataModel, function (i, obj) {
            if (self.name() == obj.name) {
                if (obj.dataType == 'number') {
                    return self.aggregationType() == "SUM" || self.aggregationType() == "AVERAGE";
                }
                else {
                    return !(self.aggregationType() == "SUM" || self.aggregationType() == "AVERAGE");
                }

            }
        });
        return true;
    });

    self.toJSON = function () {
        var js = ko.toJS(this);
        delete js.template;
        delete js.compoundName;
        delete js.nameOptions;
        delete js.aggregationTypeValid;

        return js;
    }
};

var OutputModel = function (out, model, options) {
    var self = this;
    var defaults = {
        outputDataModelUrl:fcConfig.outputDataModelUrl
    };
    var config = $.extend(defaults, options);
    self.name = ko.observable(out.name);
    self.template = ko.observable(out.template);
    self.templateDetail = ko.observable();

    self.scores = ko.observableArray($.map(out.scores || [], function (obj, i) {
        return new ScoreModel(self.templateDetail(), obj);
    }));

    self.templateDetail.subscribe(function (template) {
        $.each(self.scores(), function (i, score) {
            score.template(template);
        });

    });

    self.expanded = ko.observable(false);
    self.toggle = function (data, event) {
        if (!self.expanded()) {
            $.each(model.outputs(), function (i, obj) {
                obj.expanded(false); // close all
                obj.done(); // exit editing mode
            });
            self.expanded(true);
        } else {
            self.expanded(false);
            self.done(); // in case we were editing
        }
    };
    self.editing = ko.observable(false);
    self.edit = function () {
        self.editing(true);
        self.getOutputModelTemplate();
    };
    self.done = function () {
        self.editing(false)
    };
    self.displayMode = function () {
        return self.editing() ? 'editOutputTmpl' : 'viewOutputTmpl';
    };
    self.addScore = function () {
        self.scores.push(new ScoreModel(self.templateDetail(), {}));
    };
    self.removeScore = function (data) {
        self.scores.remove(data);
    };
    self.isReferenced = ko.computed(function () {
        var current = model.selectedActivity(),
            referenced = false;
        if (current === undefined) {
            return false;
        }
        $.each(current.outputs(), function (k, out) {
            if (out === self.name()) {
                referenced = true;
            }
        });
        return referenced;
    });
    self.isAddable = ko.computed(function () {
        if (model.selectedActivity() === undefined) {
            return false;
        }
        return !self.isReferenced();
    });
    self.addToCurrentActivity = function (data) {
        model.selectedActivity().outputs.push(data.name());
    };
    self.toJSON = function () {
        var js = ko.toJS(this);
        delete js.expanded;
        delete js.editing;
        delete js.isReferenced;
        delete js.isAddable;
        delete js.templateDetail;

        js.scores = []
        $.each(self.scores(), function (i, score) {
            js.scores.push(score.toJSON());
        });
        return js;
    };
    self.getOutputModelTemplate = function () {
        $.getJSON(config.outputDataModelUrl+"/" + self.template(), function (data) {
            if (data.error) {
                bootbox.alert('Unable to get output definition for ' + output);

            } else {
                self.templateDetail(data);

            }
        });
    }
};

var ActivityModelViewModel = function (model, options) {
    var self = this;
    var defaults = {
        activityModelUpdateUrl:fcConfig.activityModelUpdateUrl,
        outputDataModelUrl:fcConfig.outputDataModelUrl
    };
    var config = $.extend(defaults, options);
    self.activities = ko.observableArray($.map(model.activities, function (obj, i) {
        return new ActivityModel(obj, self, self.activities);
    }));
    self.selectedActivity = ko.observable();
    self.outputs = ko.observableArray($.map(model.outputs, function (obj, i) {
        return new OutputModel(obj, self, config);
    }));
    self.addActivity = function () {
        var act = new ActivityModel({name: 'new activity', type: 'Activity'}, self);
        self.activities.push(act);
        act.expanded(true);
        act.editing(true);
    };
    self.removeActivity = function () {
        self.activities.remove(this);
    };
    self.addOutput = function () {
        var out = new OutputModel({name: 'new output'}, self);
        self.outputs.push(out);
        out.expanded(true);
        out.editing(true);
    };
    self.removeOutput = function () {
        self.outputs.remove(this);
    };
    self.revert = function () {
        document.location.reload();
    };
    self.save = function () {
        var model = ko.toJS(self);
        $.ajax(config.activityModelUpdateUrl, {
            type: 'POST',
            data: vkbeautify.json(model, 2),
            contentType: 'application/json',
            success: function (data) {
                if (data !== 'error') {
                    document.location.reload();
                } else {
                    alert(data);
                }
            },
            error: function () {
                alert('failed');
            },
            dataType: 'text'
        });
    };

};
