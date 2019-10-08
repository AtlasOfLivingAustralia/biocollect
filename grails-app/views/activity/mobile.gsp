<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>

    <meta name="layout" content="mobile"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile', absolute:true)}",
        googleStaticUrl:"http://maps.googleapis.com/maps/api/staticmap?maptype=terrian&zoom=12&sensor=false&size=350x250&markers=color:red%7C"
        },
        here = document.location.href;
    </asset:script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
<div id="koActivityMainBlock">

    <div class="row-fluid">
        <div class="span12">
            <!-- Common activity fields -->

            <div class="row-fluid space-after">
                <div class="span4">

                    <label class="for-readonly">Type</label>
                    <span class="readonly-text" data-bind="text:type"></span>
                </div>
                <div class="span8">

                    <label class="for-readonly">Description</label>
                    <span class="readonly-text" data-bind="text:description"></span>
                </div>
            </div>


            <div class="row-fluid space-after">
                <div class="span4">
                    <label class="for-readonly inline">Planned start date</label>
                    <span class="readonly-text" data-bind="text:plannedStartDate.formattedDate"></span>
                </div>
                <div class="span8">
                    <label class="for-readonly inline">Planned end date</label>
                    <span class="readonly-text" data-bind="text:plannedEndDate.formattedDate"></span>
                </div>
            </div>

            <div class="well">
                <div class="row-fluid">

                    <span class="span8">
                    <div class="row-fluid space-after">

                        <div class="span6 required">
                            <label for="startDate"><b>Actual start date</b>
                                <fc:iconHelp title="Start date">Date the activity was started.</fc:iconHelp>
                            </label>


                            <div class="input-append">
                                <fc:datePicker readonly="readonly" targetField="startDate.date" name="startDate" data-validation-engine="validate[required]"/>
                            </div>

                        </div>
                        <div class="span6" data-bind="css:{required:transients.markedAsFinished}">
                            <label for="endDate"><b>Actual end date</b>
                                <fc:iconHelp title="End date">Date the activity finished.</fc:iconHelp>
                            </label>

                            <div class="input-append">
                                <fc:datePicker readonly="readonly" targetField="endDate.date" name="endDate" data-validation-engine="validate[future[startDate]]" />
                            </div>

                        </div>
                    </div>
                    <div class="row-fluid space-after">
                        <div class="span6">
                            <label for="theme"><b>Major theme</b></label>
                            <select id="theme" data-bind="value:mainTheme, options:transients.themes, optionsCaption:'Choose..'" class="input-xlarge" style="width:90%">
                            </select>
                        </div>

                        <div class="span6">
                            <label><b>Progress</b></label>
                            <label for="activityComplete"><input type="checkbox" id="activityComplete" data-bind="checked:transients.markedAsFinished" style="margin-right:1em;"><span>This activity is complete</span></label>

                        </div>

                    </div>
                    <div class="row-fluid">
                        <div class="span6">
                            <label for="site"><b>Site</b></label>
                            <fc:select id="site" style="width:90%" data-bind='options:transients.sites,optionsText:"name",optionsValue:"siteId",value:siteId,optionsCaption:"Choose a site..."'/>

                        </div>

                        <div class="span3">

                            <button class="btn btn-info" style="margin-top:25px;" data-bind="visible:transients.newSiteSupported,click:createNewSite">Create new Site</button>
                        </div>
                    </div>

                    %{--<div class="row-fluid">--}%
                        %{--<table id="photoPoints">--}%
                            %{--<thead>--}%
                                %{--<tr><td>Photo point</td><td>Lat</td><td>Lon</td><td></td></tr>--}%
                            %{--</thead>--}%
                            %{--<tbody>--}%
                                %{--<tr data-bind="foreach:transients.photoPoints">--}%
                                    %{--<td data-bind="text:name"></td>--}%
                                    %{--<td data-bind="text:geometry.decimalLatitude"></td>--}%
                                    %{--<td data-bind="text:geometry.decimalLongitude"></td>--}%
                                    %{--<td><button class="btn-info" data-bind="click:attachPhotoPoint">Attach Photo</button> </td>--}%

                                %{--</tr>--}%
                            %{--</tbody>--}%
                        %{--</table>--}%

                    %{--</div>--}%
                    </span>
                    <span class="span4">

                        <img id="siteLocationImage" width="100%" data-bind="event:{error:siteLoadError}, attr:{src:transients.siteImgUrl}, visible:transients.siteImgUrl()"/>


                    </span>
                </div>
            </div>
        </div>
    </div>

</div>

<!-- ko stopBinding: true -->
<g:each in="${metaModel?.outputs}" var="outputName">
    <g:if test="${outputName != 'Photo Points'}">
    <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
    <g:set var="model" value="${outputModels[outputName]}"/>
    <md:modelStyles model="${model}" edit="true" forceHeaderWrap="true"/>
    <div class="output-block" id="ko${blockId}">
            <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">${outputName}</h3>
        <!-- add the dynamic components -->
        <md:modelView model="${model}" site="${site}" edit="true" disableTableUpload="true" output="${outputName}" />
        <asset:script type="text/javascript">
        $(function(){

            var viewModelName = "${blockId}ViewModel",
                viewModelInstance = viewModelName + "Instance";

            // load dynamic models - usually objects in a list
            <md:jsModelObjects model="${model}" site="${site}" speciesLists="${speciesLists}" edit="true" viewModelInstance="${blockId}ViewModelInstance"/>

            this[viewModelName] = function (output) {
                var self = this;
                self.name = "${outputName}";
                self.outputId = orBlank(output.outputId);

                self.data = {};
                self.transients = {};
                self.transients.dummy = ko.observable();

                // add declarations for dynamic data
                <md:jsViewModel model="${model}"  output="${outputName}" edit="true" viewModelInstance="${blockId}ViewModelInstance"/>

                // this will be called when generating a savable model to remove transient properties
                self.removeBeforeSave = function (jsData) {
                    // add code to remove any transients added by the dynamic tags
                    <md:jsRemoveBeforeSave model="${model}"/>
                    delete jsData.activityType;
                    delete jsData.transients;
                    return jsData;
                };

                // this returns a JS object ready for saving
                self.modelForSaving = function () {
                    // get model as a plain javascript object
                    var jsData = ko.mapping.toJS(self, {'ignore':['transients']});
                    // get rid of any transient observables
                    return self.removeBeforeSave(jsData);
                };

                // this is a version of toJSON that just returns the model as it will be saved
                // it is used for detecting when the model is modified (in a way that should invoke a save)
                // the ko.toJSON conversion is preserved so we can use it to view the active model for debugging
                self.modelAsJSON = function () {
                    return JSON.stringify(self.modelForSaving());
                };

                self.loadData = function (data) {
                    // load dynamic data
                    <md:jsLoadModel model="${model}"/>

                    // if there is no data in tables then add an empty row for the user to add data
                    if (typeof self.addRow === 'function' && self.rowCount() === 0) {
                        self.addRow();
                    }
                    self.transients.dummy.notifySubscribers();
                };
            };


            var savedData = activity;
            if (!savedData.outputs) {
                savedData.outputs = [];
            }
            var savedOutput = {};
            if (savedData) {

                $.each(savedData.outputs, function(i, tmpOutput) {
                    if (tmpOutput.name === '${outputName}') {
                        savedOutput = tmpOutput;
                    }
                });
            }

            window[viewModelInstance] = new this[viewModelName](savedOutput);
            var output = savedOutput.data ? savedOutput.data : {};

            window[viewModelInstance].loadData(output);
            window[viewModelInstance].dirtyFlag = ko.dirtyFlag(window[viewModelInstance], false);

            ko.applyBindings(window[viewModelInstance], document.getElementById("ko${blockId}"));

            // this resets the baseline for detecting changes to the model
            // - shouldn't be required if everything behaves itself but acts as a backup for
            //   any binding side-effects
            // - note that it is not foolproof as applying the bindings happens asynchronously and there
            //   is no easy way to detect its completion
            window[viewModelInstance].dirtyFlag.reset();

            // register with the master controller so this model can participate in the save cycle
            master.register(viewModelInstance, window[viewModelInstance].modelForSaving,
            window[viewModelInstance].dirtyFlag.isDirty, window[viewModelInstance].dirtyFlag.reset);
        });

        </asset:script>
    </div>
    </g:if>
</g:each>
<!-- /ko -->

</div>

<asset:script type="text/javascript">


    /* Master controller for page. This handles saving each model as required. */
    var Master = function () {
        var self = this;
        this.subscribers = [];
        // client models register their name and methods to participate in saving
        self.register = function (modelInstanceName, getMethod, isDirtyMethod, resetMethod) {
            this.subscribers.push({
                model: modelInstanceName,
                get: getMethod,
                isDirty: isDirtyMethod,
                reset: resetMethod
            });
        };
        // master isDirty flag for the whole page - can control button enabling
        this.isDirty  = function () {
            var dirty = false;
            $.each(this.subscribers, function(i, obj) {
                dirty = dirty || obj.isDirty();
            });
            return dirty;
        };
        /**
         * Makes an ajax call to save any sections that have been modified. This includes the activity
         * itself and each output.
         *
         * Modified outputs are injected as a list into the activity object. If there is nothing to save
         * in the activity itself, then the root is an object that is empty except for the outputs list.
         *
         * NOTE that the model for each section must register itself to be included in this save.
         *
         * Validates the entire page before saving.
         * @return -1 if the page was not modified, 0 if validation failed, 1 if validation succeeded (or was not requested).
         */
        this.save = function (validate) {
            // Ensure any active change is committed - the knockout binding typically fires on blur.
            $( document.activeElement ).blur();

            if (validate === undefined) {
                validate = true;
            }
            var activityData, outputs = [];

            var success = true;
            if (validate) {
                success = $('#validation-container').validationEngine('validate');
            }
            if (!self.isDirty()) {
                mobileBindings.onSaveActivity(-1, null);
                return -1;
            }
            if (success) {
                $.each(this.subscribers, function(i, obj) {
                    if (obj.model === 'activityModel') {
                        activityData = obj.get();
                    } else {
                        outputs.push(obj.get());
                    }
                });

                if (activityData === undefined) { activityData = {}}
                activityData.outputs = outputs;

                var toSave = JSON.stringify(activityData);
                mobileBindings.onSaveActivity(1, toSave);

            }
            else {
                mobileBindings.onSaveActivity(0, null);
            }
            return success?1:0;
        };

        this.reset = function () {
            $.each(this.subscribers, function(i, obj) {
                if (obj.isDirty()) {
                    obj.reset();
                }
            });
        };

        this.addSite = function(site) {
            var viewModel = ko.dataFor(document.getElementById('site'));
            viewModel.transients.sites.push(site);
            viewModel.siteId(site.siteId);
        }
    };

    if (mobileBindings == undefined) {
        var mobileBindings = {
        <g:if test="${activity}">
            loadActivity:function(){return '${(activity as JSON).toString().encodeAsJavaScript()}'},
        </g:if>
        <g:else>
            loadActivity:function(){return "{}"},
        </g:else>
        <g:if test="${sites}">
            loadSites:function(){return '${(sites as JSON).toString().encodeAsJavaScript()}'},
        </g:if>
        <g:else>
            loadSites:function(){return "[]"},
        </g:else>
        <g:if test="${themes}">
            loadThemes:function(){return '${(themes as JSON).toString().encodeAsJavaScript()}'},
        </g:if>
        <g:else>
            loadThemes:function(){return "[]"},
        </g:else>

        supportsNewSite:function() { return true; },
        onSaveActivity:function(){},
        createNewSite:function(){}
    };
}
var master = new Master();
var activity = JSON.parse(mobileBindings.loadActivity());
var sites = JSON.parse(mobileBindings.loadSites());
var themes = JSON.parse(mobileBindings.loadThemes());

$(function(){

var scroll = false;
<g:if test="${params.android}">
    scroll = true;
</g:if>
$('#validation-container').validationEngine('attach', {scroll: scroll});

$('.helphover').popover({animation: true, trigger:'hover'});

$('#reset').click(function () {
master.reset();
});

function ViewModel (act, sites, themes) {
var self = this;
var today = new Date().toISOStringNoMillis();

self.activityId = act.activityId;
self.description = ko.observable(act.description);
self.notes = ko.observable(act.notes);
self.startDate = ko.observable(act.startDate || today).extend({simpleDate: false});
self.endDate = ko.observable(act.endDate).extend({simpleDate: false});
self.plannedStartDate = ko.observable(act.plannedStartDate).extend({simpleDate: false});
self.plannedEndDate = ko.observable(act.plannedEndDate).extend({simpleDate: false});
self.eventPurpose = ko.observable(act.eventPurpose);
self.fieldNotes = ko.observable(act.fieldNotes);
self.associatedProgram = ko.observable(act.associatedProgram);
self.associatedSubProgram = ko.observable(act.associatedSubProgram);
self.progress = ko.observable(act.progress);
self.mainTheme = ko.observable(act.mainTheme);
self.type = ko.observable(act.type);
self.siteId = ko.observable(act.siteId);
self.projectId = act.projectId;
self.transients = {};
self.transients.sites = ko.observableArray(sites);
self.transients.photoPoints = ko.computed(function() {
    var site = $.grep(self.transients.sites(), function(site, index) { return site.siteId == self.siteId(); })[0];
     if (site) {
         return site.photoPoints ? site.photoPoints : site.poi;
     }
     return [];
});
self.transients.activityProgressValues = ['planned','started','finished'];
self.transients.themes = themes?themes:[];
self.transients.markedAsFinished = ko.observable(act.progress === 'finished');
self.transients.markedAsFinished.subscribe(function (finished) {
    self.progress(finished ? 'finished' : 'started');
    if (finished || !self.endDate()) {
        self.endDate(today);
    }
});
self.transients.siteImgUrl = ko.computed(function() {
    if (self.siteId()) {
         var site = $.grep(self.transients.sites(), function(site, index) { return site.siteId == self.siteId(); })[0];
         if (site) {
            var lat,lon;
            if (site.centroidLat !== undefined && site.centroidLon !== undefined) {
                lat = site.centroidLat;
                lon = site.centroidLon;
            }
            else if (site.extent && site.extent.geometry && site.extent.geometry.centre) {
                lat = site.extent.geometry.centre[1];
                lon = site.extent.geometry.centre[0];
            }
            if (lat !== undefined && lon !== undefined) {
                $('#siteLocationImage').show();
                return fcConfig.googleStaticUrl+lat+","+lon;
            }
         }
    }
    return "";
});
self.siteLoadError = function(data, event) {
    $('#siteLocationImage').hide();
};

self.transients.newSiteSupported = ko.observable( mobileBindings.supportsNewSite());

self.modelForSaving = function () {
    // get model as a plain javascript object
    var jsData = ko.toJS(self);
    delete jsData.transients;
    return jsData;
};
self.modelAsJSON = function () {
    return JSON.stringify(self.modelForSaving());
};

self.save = function (callback, key) {
};

self.createNewSite = function() {
    mobileBindings.createNewSite();
}

self.notImplemented = function () {
    alert("Not implemented yet.")
};

self.attachPhotoPoint = function(e) {
    console.log(e);
};
self.dirtyFlag = ko.dirtyFlag(self, false);

// make sure progress moves to started if we save any data (unless already finished)
// (do this here so the model becomes dirty)
self.progress(self.transients.markedAsFinished() ? 'finished' : 'started');
}


var viewModel = new ViewModel(activity, sites, themes);

ko.applyBindings(viewModel);

master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset);

<g:if test="${params.android}">
// Workaround for Android bug 6721 - prevents components under the datepicker from receiving clicks on the datepicker.
var disabled = null;
$('[data-bind^=datepicker]').datepicker().on('show', function() {
    if (disabled == null) {
        disabled = $("input:enabled, select:enabled, button:enabled");
        disabled.prop('disabled', true);
    }
});
$('[data-bind^=datepicker]').datepicker().on('hide', function() {
    if (disabled !== null) {
        disabled.prop('disabled', false);
        disabled = null;
    }
});
</g:if>
});


</asset:script>

</body>
</html>