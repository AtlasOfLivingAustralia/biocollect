<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <bc:koLoading>

            <!-- ko stopBinding:true -->
            <g:each in="${metaModel?.outputs}" var="outputName">
                <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
                <g:set var="model" value="${outputModels[outputName]}"/>
                <g:set var="output" value="${activity?.outputs.find { it.name == outputName }}"/>
                <g:if test="${!output}">
                    <g:set var="output" value="[name: outputName]"/>
                </g:if>
                <g:render template="/output/outputJSModelWithGeodata" plugin="ecodata-client-plugin"
                          model="${raw([edit: false, readonly: true, model: model, outputName: outputName])}"></g:render>

                <div class="output-block" id="ko${blockId}">
                    <div data-bind="if:outputNotCompleted">
                        <label class="checkbox"><input type="checkbox" disabled="disabled"
                                                       data-bind="checked:outputNotCompleted"> <span
                                data-bind="text:transients.questionText"></span></label>
                    </div>
                    <g:if test="${!output.outputNotCompleted}">
                        <!-- add the dynamic components -->
                        <md:modelView model="${model}" site="${site}" readonly="true"
                                      userIsProjectMember="${userIsProjectMember}"/>
                    </g:if>
                </div>
            </g:each>
            <!-- /ko -->
        </bc:koLoading>
    </div>
</div>
<!-- templates -->
<asset:deferredScripts/>