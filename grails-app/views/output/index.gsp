<%@ page import="org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Edit | ${activity.activityId ?: 'new'} | ${site.name} | ${site.projectName} | Field Capture</title>
    <md:modelStyles model="${model}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="jstz/jstz.min.js"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
</head>
<body>
<div class="container-fluid">
    <legend>
        <table style="width: 100%">
            <tr>
                <td><g:link class="discreet" action="index">Outputs</g:link><fc:navSeparator/>
                    <g:if test="${create}">create</g:if>
                    <g:else>
                        <span data-bind="text:activityType"></span>
                        <span data-bind="text:activityStartDate.formattedDate"></span>/<span data-bind="text:activityEndDate.formattedDate"></span>
                    </g:else>
                </td>
                <td style="text-align: right"><span></span></td>
            </tr>
        </table>
    </legend>
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

    <div class="row-fluid ">
        <span class="span3"><span class="label preLabel">Assessment date:</span><span data-bind="text:assessmentDate.formattedDate"></span></span>
        <span class="span3"><span class="label preLabel">Assessor:</span><span data-bind="text:collector"></span></span>
    </div>

<!-- add the dynamic components -->
<md:modelView model="${model}"/>

    <div class="row-fluid">
        <button type="button" class="btn"
                onclick="document.location.href='${createLink(action:"edit", id:"${output.outputId}")}'"
        >Edit this data</button>
    </div>

    <hr />
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
            <h4>Activity</h4>
            <pre>${activity}</pre>
            <h4>Site</h4>
            <pre>${site}</pre>
            <h4>Projects</h4>
            <pre>${projects}</pre>
            %{--<pre>Map features : ${mapFeatures}</pre>--}%
        </div>
    </div>
</div>

<asset:script type="text/javascript">

    var outputData = ${output.data ?: '{}'};

    $(function(){

        // add any object declarations for the dynamic part of the model
<md:jsModelObjects model="${model}"/>

        function ViewModel () {
            var self = this;
            self.data = {};
            self.transients = {};
            self.transients.dummy = ko.observable('');

            // add the properties for the dynamic part of the model
<md:jsViewModel model="${model}"  output="${output.name}"/>

        // add props that are standard for all outputs
        self.assessmentDate = ko.observable("${output.assessmentDate}").extend({simpleDate: false});
            self.collector = ko.observable("${output.collector}")/*.extend({ required: true })*/;
            self.activityId = ko.observable("${activity.activityId}");
            self.activityType = ko.observable("${activity.type}");
            self.activityStartDate = ko.observable("${activity.startDate}").extend({simpleDate: false});
            self.activityEndDate = ko.observable("${activity.endDate}").extend({simpleDate: false});

            self.loadData = function (data) {
                // load data for the dynamic part of the model
<md:jsLoadModel model="${model}"/>

            self.transients.dummy.notifySubscribers();

            };
        }

var viewModel = new ViewModel();
viewModel.loadData(outputData);

ko.applyBindings(viewModel);

});

</asset:script>
</body>
</html>>