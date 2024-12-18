<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="showCreate" value="${activity?.activityId ||  (!activity?.activityId && !hubConfig.content?.hideCancelButtonOnForm)}"></g:set>
<bc:koLoading>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <content tag="bannertitle">
        ${title}
    </content>
    <div id="koActivityMainBlock">
        <g:if test="${!mobile}">
            <div class="row">
                %{-- quick links --}%
                <div class="col-12">
                    <g:render template="/shared/quickLinks" model="${[cssClasses: 'float-right']}"></g:render>
                </div>
                %{--quick links END--}%
            </div>
        </g:if>
<g:if test="${isUserAdminModeratorOrEditor && pActivity?.adminVerification}">
    <div class="form-group row">
        <label for="verificationStatusName" class="col-sm-2 col-form-label">
            <g:message code="record.edit.verificationStatus"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="record.edit.verificationStatusTypes.help.title"/>',
                             content:'<g:message code="record.edit.verificationStatusTypes.help"/>'}">
                <i class="fa fa-question-circle"></i>
            </a>
        </label>
        <div class="col-4">
            <select name="verificationStatusName" class="custom-select" data-bind="options:verificationStatusOptions, optionsText:'displayName', optionsValue:'code', value: verificationStatus"></select>
        </div>
    </div>
</g:if>
<!-- start model binding -->
<!-- ko stopBinding: true -->
<g:set var="user" value="${user}"/>
<g:each in="${metaModel?.outputs}" var="outputName">
    <g:if test="${outputName != 'Photo Points'}">
        <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
        <g:set var="model" value="${outputModels[outputName]}"/>
        <g:set var="output" value="${activity?.outputs.find { it.name == outputName }}"/>
        <g:render template="/output/outputJSModelWithGeodata" plugin="ecodata-client-plugin"
                  model="${[edit:true, readonly: false, model:model, outputName:outputName]}"></g:render>


        <g:if test="${!output}">
            <g:set var="output" value="[name: outputName]"/>
        </g:if>

        <md:modelStyles model="${model}" edit="true"/>

        <div class="output-block" id="ko${blockId}">

            <div data-bind="if:transients.optional || outputNotCompleted()">
                <label class="checkbox" ><input type="checkbox" data-bind="checked:outputNotCompleted"> <span data-bind="text:transients.questionText"></span> </label>
            </div>

            <div id="${blockId}-content" data-bind="visible:!outputNotCompleted()">
                <!-- add the dynamic components -->
                <md:modelView model="${model}" site="${site}" edit="true" output="${output.name}" printable="${printView}"/>
            </div>
        </div>
    </g:if>
</g:each>
<!-- /ko -->
<!-- end model binding -->

<g:if test="${metaModel?.supportsSites?.toBoolean()}">
    <div class="card">
        <div class="card-body">
            <h3 class="text-center text-danger card-title">Site Details</h3>
            <div class="output-block text-center">
                <fc:select
                        data-bind='options:transients.pActivitySites,optionsText:"name",optionsValue:"siteId",value:siteId,optionsCaption:"Choose a site..."'
                        printable="${printView}"/>
                <m:map id="activitySiteMap" width="100%" height="512px"/>
            </div>
        </div>
    </div>
</g:if>

<g:if test="${metaModel?.supportsPhotoPoints?.toBoolean()}">
    <div class="card">
        <div class="card-body">
            <h3 class="text-center text-danger card-title">Photo Points</h3>
            <div class="output-block" data-bind="with:transients.photoPointModel">
                    <g:render template="/site/photoPoints"></g:render>
            </div>
        </div>
    </div>
</g:if>

<g:if test="${!printView}">
    <div class="form-actions">
        <g:render template="/shared/termsOfUse"/>
        <br>
        <g:if test="${!preview}">
            <!-- ko ifnot: window.unpublished -->
            <button type="button" id="save" class="btn btn-primary-dark btn-lg"><i class="fas fa-upload"></i> <g:message code="g.submit"/></button>
            <!-- /ko -->
            <!-- ko if: window.unpublished -->
            <button type="button" id="saveOffline" class="btn btn-primary-dark btn-lg"><i class="fas fa-hdd"></i> <g:message code="bioactivity.save"/></button>
            <!-- /ko -->
        </g:if>
        <g:if test="${bulkUpload || (showCreate && !mobile && !preview)}">
            <button type="button" id="cancel" class="btn btn-dark btn-lg"><i class="far fa-times-circle"></i> <g:message code="g.cancel"/></button>
        </g:if>
    </div>
</g:if>

<g:if env="development" test="${!printView && !preview}">
    <div class="expandable-debug">
        <hr/>

        <h3>Debug</h3>

        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root.modelForSaving(),null,2)"></pre>
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
            <pre>${(outputModels as JSON)?.encodeAsHTML()}</pre>
            <h4>Map features</h4>
            <pre>${mapFeatures.toString()}</pre>
        </div>
    </div>
</g:if>

</div>

<div id="timeoutMessage" class="hide">

    <span class='badge badge-danger'>Important</span><h4>There was an error while trying to save your changes.</h4>

    <p>This could be because your login has timed out or the internet is unavailable.</p>

    <p>Your data has been saved on this computer but you may need to login again before the data can be sent to the server.</p>
    <a href="${createLink(action: 'create', id: activity?.activityId)}?returnTo=${returnTo}">Click here to refresh your login and reload this page.</a>
</div>


<g:render template="/shared/imagerViewerModal" model="[readOnly: false]"/>
<g:render template="/shared/attachDocument"/>
<g:render template="/shared/documentTemplate"/>
</div>
</bc:koLoading>