<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | ${activity.type} | Field Capture</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${hubConfig.skin}"/>
        <title>Edit | ${activity.type} | Field Capture</title>
    </g:else>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${project.projectId},Project"/>
    <meta name="breadcrumb" content="Enter data"/>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate', id: activity.activityId)}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete', id: activity.activityId, params:[returnTo:grailsApplication.config.grails.serverURL + '/' + returnTo])}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        imageLocation:"${asset.assetPath(src:'')}",
        speciesSearch: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        surveyName: "${metaModel.name}",
        speciesSearchUrl: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        speciesImageUrl:"${createLink(controller:'species', action:'speciesImage')}",
        noImageUrl: '${asset.assetPath(src: "no-image-2.png")}',
        searchBieUrl: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        getOutputSpeciesIdUrl : "${createLink(controller: 'output', action: 'getOutputSpeciesIdentifier')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        sites: <fc:modelAsJavascript model="${project?.sites ?: []}"/>,
        allowAdditionalSurveySites: ${canEditSites}
        },
        here = document.location.href;
    </asset:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="enterActivityData.js"/>
    <asset:javascript src="meritActivity.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <div class="row-fluid title-block input-block-level">
            <div class="span12 title-attribute">
                <h1><span data-bind="click:goToProject" class="clickable">${project?.name?.encodeAsHTML() ?: 'no project defined!!'}</span></h1>
                <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">Activity: <span data-bind="text:type"></span></h3>
                <h4><span>${project.associatedProgram?.encodeAsHTML()}</span> <span>${project.associatedSubProgram?.encodeAsHTML()}</span></h4>
            </div>
        </div>


        <div class="row-fluid">
            <div class="span9">
                <!-- Common activity fields -->

                <div class="row-fluid space-after">

                    <div class="span9 required">
                        <label class="for-readonly" for="description">Description</label>
                        <input id="description" type="text" class="input-xxlarge" data-bind="value:description" data-validation-engine="validate[required]"></span>
                    </div>
                </div>
                <div class="row-fluid space-after">
                    <div class="span6" data-bind="visible:transients.themes && transients.themes.length > 1">
                        <label for="theme">Major theme</label>
                        <select id="theme" data-bind="value:mainTheme, options:transients.themes, optionsCaption:'Choose..'" class="input-xlarge">
                        </select>
                    </div>
                    <div class="span6" data-bind="visible:transients.themes && transients.themes.length == 1">
                        <label for="theme">Major theme</label>
                        <span data-bind="text:mainTheme">
                        </span>
                    </div>
                </div>
                <div class="row-fluid space-after">
                    <div class="span6">
                        <label class="for-readonly inline">Activity progress</label>
                        <button type="button" class="btn btn-small"
                                data-bind="css: {'btn-warning':progress()=='planned','btn-success':progress()=='started','btn-info':progress()=='finished','btn-danger':progress()=='deferred','btn-inverse':progress()=='cancelled'}"
                                style="line-height:16px;cursor:default;color:white">
                            <span data-bind="text: progress"></span>
                        </button>
                    </div>
                </div>

                <div class="row-fluid space-after">

                    <div class="span6" data-bind="visible:plannedStartDate()">
                        <label class="for-readonly inline">Planned start date</label>
                        <span class="readonly-text" data-bind="text:plannedStartDate.formattedDate"></span>
                    </div>
                    <div class="span6" data-bind="visible:plannedEndDate()">
                        <label class="for-readonly inline">Planned end date</label>
                        <span class="readonly-text" data-bind="text:plannedEndDate.formattedDate"></span>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span6 required">
                        <label for="startDate"><b>Actual start date</b>
                        <fc:iconHelp title="Start date" printable="${printView}">Date the activity was started.</fc:iconHelp>
                        </label>
                        <g:if test="${printView}">
                            <div class="row-fluid">
                                <fc:datePicker targetField="startDate.date" name="startDate" data-validation-engine="validate[required]" printable="${printView}"/>
                            </div>
                        </g:if>
                        <g:else>
                            <div class="input-append">
                                <fc:datePicker targetField="startDate.date" name="startDate" data-validation-engine="validate[required]" printable="${printView}"/>
                            </div>
                        </g:else>
                    </div>
                    <div class="span6 required">
                        <label for="endDate"><b>Actual end date</b>
                        <fc:iconHelp title="End date" printable="${printView}">Date the activity finished.</fc:iconHelp>
                        </label>
                        <g:if test="${printView}">
                            <div class="row-fluid">
                            <fc:datePicker targetField="endDate.date" name="endDate" data-validation-engine="validate[future[startDate]]" printable="${printView}" />
                            </div>
                        </g:if>
                        <g:else>
                            <div class="input-append">
                                <fc:datePicker targetField="endDate.date" name="endDate" data-validation-engine="validate[future[startDate]]" printable="${printView}" />
                            </div>
                        </g:else>
                    </div>
                </div>


            </div>
        </div>

        <g:if env="development" test="${!printView}">
          <div class="expandable-debug">
              <hr />
              <h3>Debug</h3>
              <div>
                  <h4>KO model</h4>
                  %{--<pre data-bind="text:ko.toJSON($root.modelForSaving(),null,2)"></pre>--}%
                  <h4>Activity</h4>
                  <pre>${activity?.encodeAsHTML()}</pre>
                  <h4>Site</h4>
                  <pre>${site?.encodeAsHTML()}</pre>
                  <h4>Sites</h4>
                  <pre>${(sites as JSON).toString()}</pre>
                  <h4>Project</h4>
                  <pre>${project?.encodeAsHTML()}</pre>
                  <h4>Activity model</h4>
                  <pre>${metaModel}</pre>
                  <h4>Output models</h4>
                  <pre>${outputModels?.encodeAsHTML()}</pre>
                  <h4>Themes</h4>
                  <pre>${themes.toString()}</pre>
                  <h4>Map features</h4>
                  <pre>${mapFeatures.toString()}</pre>
              </div>
          </div>
        </g:if>
    </div>

<!-- ko stopBinding: true -->
    <g:each in="${metaModel?.outputs}" var="outputName">
        <g:if test="${outputName != 'Photo Points'}">
            <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
            <g:set var="model" value="${outputModels[outputName]}"/>

            <md:modelStyles model="${model}" edit="true"/>
            <div class="output-block" id="ko${blockId}">
                <g:set var="title" value="${model?.title ?: outputName}"/>
                <h3 data-bind="css:{modified:dirtyFlag.isDirty},attr:{title:'Has been modified'}">${title}</h3><g:if test="${model?.description}"><span class="output-help"><fc:iconHelp titleCode="n/a" title="${title}">${model?.description}</fc:iconHelp></span></g:if>

                <div data-bind="if:transients.optional || outputNotCompleted()">
                    <label class="checkbox"><input type="checkbox" data-bind="checked:outputNotCompleted">
                        <span data-bind="text:transients.questionText"></span>
                    </label>
                </div>

                <div id="${blockId}-content" data-bind="visible:!outputNotCompleted()">
                    <!-- add the dynamic components -->
                    <md:modelView model="${model}" site="${site}" edit="true" output="${outputName}"
                                  printable="${printView}"/>
                </div>

            </div>
            <g:render template="/output/outputJSModel" plugin="ecodata-client-plugin"
                      model="${[viewModelInstance:blockId+'ViewModel', edit:true, activityId:activity.activityId, model:model, outputName:outputName, surveyName: metaModel.name]}"></g:render>
        </g:if>
    </g:each>
<!-- /ko -->

    <g:if test="${metaModel?.supportsPhotoPoints?.toBoolean()}">
        <div class="output-block" data-bind="with:transients.photoPointModel">
            <h3>Photo Points</h3>

             <g:render template="/site/photoPoints"></g:render>
        </div>
    </g:if>

    <g:if test="${!printView}">
        <div class="form-actions">
            <g:render template="/shared/termsOfUse"/>
            <button type="button" id="save" class="btn btn-primary">Save changes</button>
            <button type="button" id="cancel" class="btn">Cancel</button>
            <label class="checkbox inline">
                <input data-bind="checked:transients.markedAsFinished" type="checkbox"> Mark this activity as finished.
            </label>
        </div>
    </g:if>

</div>

<div id="timeoutMessage" class="hide">

    <span class='label label-important'>Important</span><h4>There was an error while trying to save your changes.</h4>
    <p>This could be because your login has timed out or the internet is unavailable.</p>
    <p>Your data has been saved on this computer but you may need to login again before the data can be sent to the server.</p>
    <a href="${createLink(action:'enterData', id:activity.activityId)}?returnTo=${returnTo}">Click here to refresh your login and reload this page.</a>
</div>


<g:render template="/shared/imagerViewerModal" model="[readOnly:false]"></g:render>

<script type="text/javascript">
    function ActivityLevelData() {
        var self = this;
        self.activity = <fc:modelAsJavascript model="${activity}"/>;
        self.site = <fc:modelAsJavascript model="${site}"/>;
        self.project = <fc:modelAsJavascript model="${project}"/>;
        self.metaModel = <fc:modelAsJavascript model="${metaModel}"/>;
        self.mapFeatures = <fc:modelAsJavascript model="${mapFeatures}"/>;
        self.themes = <fc:modelAsJavascript model="${themes}"/>;
        self.speciesConfig = <fc:modelAsJavascript model="${speciesConfig}"/>;
        // We only need the sites from a pActivity within works projects
        self.pActivity = self.project;
        self.pActivity.allowAdditionalSurveySites =  ${canEditSites};
    }

    var activityLevelData = new ActivityLevelData();

    $(function(){
        var returnTo = "${returnTo}";

        // Release the lock when leaving the page.  async:false is deprecated but is still the easiest solution to achieve
        // an unconditional lock release when leaving a page.
        var locked = ${locked?:false};
        if (locked) {
            var unlockActivity = function() {
                $.ajax(fcConfig.unlockActivityUrl+'/'+activityId, {method:'POST', async:false});
            };
            window.onunload = unlockActivity;
        }

        var minOptionalSections = 1;
        if (!_.isUndefined(activityLevelData.metaModel.minOptionalSectionsCompleted)) {
            minOptionalSections = activityLevelData.metaModel.minOptionalSectionsCompleted;
        }
        var master = new Master(activityLevelData.activity.activityId,
            {activityUpdateUrl: fcConfig.activityUpdateUrl,
                minOptionalSectionsCompleted: minOptionalSections});

        var viewModel = new ActivityHeaderViewModel(activityLevelData.activity, activityLevelData.site, activityLevelData.project, activityLevelData.metaModel, activityLevelData.themes);

        ko.applyBindings(viewModel);
        viewModel.initialiseMap(activityLevelData.mapFeatures);
        // We need to reset the dirty flag after binding but doing so can miss a transition from planned -> started
        // as the "mark activity as finished" will have already updated the progress to started.
        if (activityLevelData.activity.progress == viewModel.progress()) {
            viewModel.dirtyFlag.reset();
        }

        <g:if test="${params.progress}">
        var newProgress = '${params.progress}';
        if (newProgress == 'corrected') {
            viewModel.progress(newProgress);
        }
        else {
            viewModel.transients.markedAsFinished(newProgress == 'finished');
        }
        </g:if>

        master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset, viewModel.updateIdsAfterSave);

        var url = '${g.createLink(controller: 'activity', action:'activitiesWithStage', id:activity.projectId)}';
        var activityUrl = '${g.createLink(controller:'activity', action:'enterData')}';
        var activityId = activityLevelData.activity.activityId;
        var projectId = activityLevelData.activity.projectId;
        var siteId = activityLevelData.activity.siteId || "";
        var options = {navigationUrl:url, activityUrl:activityUrl, returnTo:returnTo};
        options.navContext = '${navContext}';
        options.activityNavSelector = '#activity-nav';
        options.savedNavMessageSelector = '#saved-nav-message-holder';

        var navigationMode = '${navigationMode}';
        var activityNavigationModel = new ActivityNavigationViewModel(navigationMode, projectId, activityId, siteId, options);

        var outputModelConfig = {
            projectId:projectId,
            activityId:activityId,
            stage:  stageNumberFromStage(activityLevelData.activity.projectStage),
            disablePrepop : activityLevelData.activity.progress === "${au.org.ala.biocollect.merit.ActivityService.PROGRESS_FINISHED}",
            speciesConfig : activityLevelData.speciesConfig
        };
        outputModelConfig = _.extend(fcConfig, outputModelConfig);

        <g:each in="${metaModel?.outputs}" var="outputName">
            <g:if test="${outputName != 'Photo Points'}">
                <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
                <g:set var="model" value="${outputModels[outputName]}"/>
                <g:set var="output" value="${activity.outputs.find {it.name == outputName} ?: [name: outputName]}"/>

                var viewModelName = "${blockId}ViewModel",
                    elementId = "ko${blockId}";

                var output = <fc:modelAsJavascript model="${output}"/>;
                var config = ${fc.modelAsJavascript(model:metaModel.outputConfig?.find{it.outputName == outputName}, default:'{}')};
                config.model = ${fc.modelAsJavascript(model:model)};
                config = _.extend({}, outputModelConfig, config, activityLevelData);

                initialiseOutputViewModel(viewModelName, config.model.dataModel, elementId, activityLevelData.activity, output, master, config, viewModel);
            </g:if>
        </g:each>

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#save').click(function () {
            master.save(activityNavigationModel.afterSave);
        });

        $('#cancel').click(function () {
            activityNavigationModel.cancel();
        });

        $('#validation-container').validationEngine('attach', {scroll: true});

        $('.imageList a[target="_photo"]').attr('rel', 'gallery').fancybox({type:'image', autoSize:true, nextEffect:'fade', preload:0, 'prevEffect':'fade'});

    });
</script>
</body>
</html>