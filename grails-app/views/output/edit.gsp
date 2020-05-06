<%@ page import="org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Edit | ${activity.activityId ?: 'new'} | ${site.name} | ${site.projectName} | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="Edit output"/>

    <md:modelStyles model="${model}" edit="true"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="jstz/jstz.min.js"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
</head>
<body>
<div class="container-fluid">
    <div class="row-fluid title-block">
        <div class="span6 title-attribute">
            <h2 class="inline">Project: </h2>
            <g:each in="${projects}" var="p">
                <g:link controller="project" action="index" id="${p.projectId}">${p.name}</g:link>
            </g:each>
        </div>
        <div class="span6 title-attribute">
            <h2 class="inline">Site: </h2><g:link controller="site" action="index" id="${site.siteId}">${site.name}</g:link>
        </div>
    </div>

    <form id="form">
        <div class="row-fluid">
            <div class="span4 control-group">
                <label for="assessmentDate">Assessment date
                <fc:iconHelp title="Start date">Date the data was collected.</fc:iconHelp>
                </label>
                <div class="input-append">
                    <input data-bind="datepicker:assessmentDate.date" type="text" size="12" id="assessmentDate"
                       data-validation-engine="validate[required]"/>
                    <span class="add-on open-datepicker"><i class="icon-th"></i></span>
                </div>
            </div>
            <div class="span4">
                <label for="collector">Collector</label>
                <input data-bind="value: collector,valueUpdate:'afterkeydown'" id="collector" type="text"
                       data-validation-engine="validate[required]"/>
            </div>
        </div>

        <!-- add the dynamic components -->
        <md:modelView model="${model}" site="${site}" edit="true"/>

        <div class="form-actions">
            <button type="button" data-bind="click: save" class="btn btn-primary">Save changes</button>
            <button type="button" id="cancel" class="btn">Cancel</button>
        </div>
    </form>

    <hr />

    <g:if env="development">
        <div class="expandable-debug">
            <h3>Debug</h3>
            <div>
                <h4>KO model</h4>
                <pre data-bind="text:ko.toJSON($root.data,null,2)"></pre>
                <h4>Activity</h4>
                <pre>${activity}</pre>
                <h4>Site</h4>
                <pre>${site}</pre>
                <h4>Projects</h4>
                <pre>${projects}</pre>
                %{--<pre>Map features : ${mapFeatures}</pre>--}%
            </div>
        </div>
    </g:if>

</div>

<%-- JavaScript / knockout templates  --%>
<g:each in="${templates}" var="template">
    <g:render template="${template}"/>
</g:each>

<!-- templates -->
<asset:script type="text/javascript">

    var outputData = ${output.data ?: '{}'},
        returnTo = "${returnTo}";

    $(function(){

        $('#form').validationEngine('attach', {scroll: false});

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#cancel').click(function () {
            document.location.href = returnTo;
        });

// load dynamic models - usually objects in a list
<md:jsModelObjects model="${model}" site="${site}" speciesLists="${speciesLists}" edit="true"/>

        function ViewModel () {
            var self = this;

            self.name = "${output.name}";
            self.assessmentDate = ko.observable("${output.assessmentDate}").extend({simpleDate: false});
            self.collector = ko.observable("${output.collector}")/*.extend({ required: true })*/;
            self.activityId = ko.observable("${activity.activityId}");
            self.activityType = ko.observable("${activity.type}");
            self.deleteAll = function () {
                document.location.href = "${createLink(action:'delete',id:output.outputId,
                    params:[returnTo:grailsApplication.config.grails.serverURL + '/' + returnTo])}";
            };
            self.data = {};
            self.transients = {};
            self.transients.site = site;
            self.transients.dummy = ko.observable();
            self.transients.activityStartDate = ko.observable("${activity.startDate}").extend({simpleDate: false});
            self.transients.activityEndDate = ko.observable("${activity.endDate}").extend({simpleDate: false});

// add declarations for dynamic data
<md:jsViewModel model="${model}" output="${output.name}" edit="true"/>

            // this will be called from the save method to remove transient properties
            self.removeBeforeSave = function (jsData) {
// add code to remove any transients added by the dynamic tags
<md:jsRemoveBeforeSave model="${model}"/>
                delete jsData.activityType;
                delete jsData.transients;
                return jsData;
            };
            self.save = function () {
                if ($('#form').validationEngine('validate')) {
                    var jsData = ko.toJS(self);
                    // get rid of any transient observables
                    jsData = self.removeBeforeSave(jsData);
                    var json = JSON.stringify(jsData);
                    $.ajax({
                        url: '${createLink(action: "ajaxUpdate", id: "${output.outputId}")}',
                        type: 'POST',
                        data: json,
                        contentType: 'application/json',
                        success: function (data) {
                            if (data.error) {
                                alert(data.detail + ' \n' + data.error);
                            } else {
                                document.location.href = returnTo;
                            }
                        },
                        error: function (data) {
                            var status = data.status
                            alert('An unhandled error occurred: ' + data.status);
                        }
                    });
                }
            };
            self.notImplemented = function () {
                alert("Not implemented yet.")
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
        }

        var viewModel = new ViewModel();
        viewModel.loadData(${output.data ?: '{}'});

        ko.applyBindings(viewModel);

    });

</asset:script>
</body>
</html>