
<div id="pActivityInfo" class="well">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->
            <div class="row-fluid">
                <div class="span10">
                    <h2 class="strong">Step 1 of 7 - Describe the survey</h2>
                </div>
                <div class="span2 text-right">
                    <g:render template="../projectActivity/status"/>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="name"><g:message code="project.survey.info.name"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.name"/>', content:'<g:message code="project.survey.info.name.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span></label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <input id="name" type="text" class="full-width" data-bind="valueUpdate: 'input',value: name" data-validation-engine="validate[required]">
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="description"><g:message code="project.survey.info.description"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.description"/>', content:'<g:message code="project.survey.info.description.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <textarea id="description" rows="4" class="full-width" data-bind="value: description"
                                  data-validation-engine="validate[required]"></textarea>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="attribution"><g:message code="project.survey.info.attribution"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.attribution"/>', content:'<g:message code="project.survey.info.attribution.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <textarea id="attribution" rows="4" class="full-width" data-bind="value: attribution"
                                  data-validation-engine="validate[required]"></textarea>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="methodType"><g:message code="project.survey.info.methodType"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodType"/>', content:'<g:message code="project.survey.info.methodType.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <select id="methodType" class="full-width" data-bind="value: methodType"
                                data-validation-engine="validate[required]">
                            <option value=""><g:message code="project.survey.info.methodType.noSelection.displayName"/></option>
                            <g:each in="${grailsApplication.config.methodType}" var="type">
                                <option value="${type}"><g:message code="project.facets.methodType.${type}"/></option>
                            </g:each>
                        </select>
                    </div>
                </div>
            </div>


            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="methodName"><g:message code="project.survey.info.methodName"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodName"/>', content:'<g:message code="project.survey.info.methodName.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <input id="methodName" class="full-width" type="text" data-bind="value: methodName" data-validation-engine="validate[required]">
                    </div>
                </div>
            </div>

            <div  data-bind="slideVisible: transients.isSystematicSurvey">
                <div class="row-fluid">
                    <div class="span4"></div>
                    <div class="span8">
                        <div class="row-fluid">
                            <div class="span12">
                                <label class="control-label" for="methodAbstract"><g:message code="project.survey.info.methodAbstract"/>
                                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodAbstract"/>', content:'<g:message code="project.survey.info.methodAbstract.content"/>'}">
                                        <i class="icon-question-sign"></i>
                                    </a>
                                    <span class="right-padding"></span>
                                </label>
                                <div>
                                    <div class="controls">
                                        <textarea id="methodAbstract" rows="4" class="full-width" data-bind="value: methodAbstract" data-validation-engine="validate[groupRequired[DescriptionSurveyMethod]]"></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row-fluid">
                            <div class="span12">
                                <label class="control-label" for="methodUrl"><g:message code="project.survey.info.methodUrl"/>
                                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodUrl"/>', content:'<g:message code="project.survey.info.methodUrl.content"/>'}">
                                        <i class="icon-question-sign"></i>
                                    </a>
                                    <span class="right-padding"></span>
                                </label>
                                <div>
                                    <div class="controls">
                                        <input id="methodUrl" class="full-width" type="text" data-bind="value: methodUrl" data-validation-engine="validate[groupRequired[DescriptionSurveyMethod],custom[url]]"/>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Method document-->
                        <div class="row-fluid space-after">
                            <div class="span12">
                                <label class="control-label" ><g:message code="project.survey.info.methodDoc"/>
                                    <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodDoc"/>', content:'<g:message code="project.survey.info.methodDoc.content"/>'}">
                                        <i class="icon-question-sign"></i>
                                    </a>
                                    <span class="right-padding"></span>
                                </label>
                                <div class="text-left">
                                    <a data-bind="attr:{href:methodDocUrl}" target="_blank">
                                        <small class="media-heading" data-bind="text:methodDocName"></small>
                                    </a>
                                </br>
                                    <span class="btn fileinput-button pull-left"
                                          data-bind="
                                        attr:{'data-role':'methodDoc',
                                            'data-url': transients.methoddocumentUpdateUrl(),
                                            'data-owner-type': 'projectActivityId',
                                            'data-owner-id': projectActivityId()},
                                             stagedImageUpload: documents,
                                                 visible:!methodDocUrl(), validateObservable: methodDocUrl"
                                          data-validation-engine="validate[groupRequired[DescriptionSurveyMethod]]">
                                        <i class="icon-plus"></i>
                                        <input id="mthDoc" type="file" name="files">
                                        <span>Attach Document</span></span>
                                    <button class="btn btn-small" data-bind="click:removeMethodDoc, visible:methodDocUrl()"><i class="icon-minus"></i> Remove Document</button>
                                </div>
                            </div>
                        </div>
                        <!-- end of Document -->
                    </div>
                </div>
            </div>
            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="startDate"> <g:message code="project.survey.info.startDate"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.startDate"/>', content:'<g:message code="project.survey.info.startDate.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span></label>
                </div>

                <div class="span8">
                    <div class="controls input-append">
                        <input id="startDate" data-bind="datepicker:startDate.date" type="text"  data-validation-engine="validate[required]" />
                        <span class="add-on  open-datepicker"><i class="icon-calendar"></i> </span>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="endDate"><g:message code="project.survey.info.endDate"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.endDate"/>', content:'<g:message code="project.survey.info.endDate.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls input-append">
                        <input id="endDate" data-bind="datepicker:endDate.date" type="text"/>
                        <span class="add-on open-datepicker"><i class="icon-calendar"></i> </span>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="publicAccess"><g:message code="project.survey.info.publicData"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.publicData"/>', content:'<g:message code="project.survey.info.publicData.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <input id="publicAccess" type="checkbox" data-bind="checked: publicAccess"/>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="allowComments"><g:message code="project.survey.info.comments"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.comments"/>', content:'<g:message code="project.survey.info.comments.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <input id="allowComments" type="checkbox" data-bind="checked: commentsAllowed"/>
                    </div>
                </div>
            </div>

            <div class="row-fluid space-after">
                <div class="span4 text-right">
                    <label class="control-label" for="dataSharingLicense"><g:message code="project.survey.info.dataSharingLicense"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataSharingLicense"/>', content:'<g:message code="project.survey.info.dataSharingLicense.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <g:select id="dataSharingLicense" class="full-width form-control" name="dateSharingLicence" from="${licences}" optionValue="name" data-bind="value:dataSharingLicense"
                                  noSelection="['':'-Please select the licence-']" optionKey="url" data-validation-engine="validate[required]" />
                        <g:each in="${licences}">
                            <label class="space-after" data-bind="visible: dataSharingLicense() == '${it.url}'"><a href="${it.url}" target="_blank"><img src="${asset.assetPath(src: "licence/${it.logo}")}">&nbsp;&nbsp;${it.description}</a> </label>
                        </g:each>
                    </div>
                </div>
            </div>

            <div class="row-fluid space-after">
                <div class="span4 text-right">
                    <label class="control-label"><g:message code="project.survey.info.logo"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.logo"/>', content:'<g:message code="project.survey.info.logo.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>

                <div class="span2 text-left">
                    <img  alt="No image" data-bind="attr:{src: transients.logoUrl()}">
                    </br>
                    <span class="btn fileinput-button pull-left"
                          data-bind="
                            attr:{'data-role':'logo',
                                'data-url': transients.imageUploadUrl(),
                                'data-owner-type': 'projectActivityId',
                                'data-owner-id': projectActivityId()},
                                 stagedImageUpload: documents,
                                     visible:!logoUrl()">
                            <i class="icon-plus"></i>
                            <input id="logo" type="file" name="files">
                            <span>Attach</span></span>
                    <button class="btn btn-small space-after" data-bind="click:removeLogoImage, visible:logoUrl()"><i class="icon-minus"></i> Remove</button>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="legalCustodian"><g:message code="project.survey.info.legalCustodian"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.legalCustodian"/>', content:'<g:message code="project.survey.info.legalCustodian.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>
                <div class="span8 text-left">
                    <div class="controls">
                        <input id="legalCustodian" class="full-width-input form-control" type="text" data-bind="value: legalCustodianOrganisation" data-validation-engine="validate[required]" >
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="legalCustodian"><g:message code="project.survey.info.reliabilityTag"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.reliabilityTag"/>', content:'<g:message code="project.survey.info.reliabilityTag.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>
                <div class="span8 text-left">
                    <div class="controls">
                        <div class="row-fluid">
                            <div class="span6">

                                <div class="row-fluid">
                            <div class="span12">
                                <strong>
                                    <g:message code="project.survey.info.spatialAccuracy.text"/>
                                </strong>
                                <span class="req-field"></span>
                            </div>
                        </div>
                        <label class="radio">
                            <input name="spatialAccuracy" class="form-control" type="radio"
                                   data-bind="checked: spatialAccuracy"
                                   value="<g:message code="project.survey.info.spatialAccuracy.high.value"/>"
                                   data-validation-engine="validate[required]" >
                            <g:message code="project.facets.spatialAccuracy.high"/>
                        </label>
                        <label class="radio">
                            <input name="spatialAccuracy" class="form-control" type="radio"
                                   data-bind="checked: spatialAccuracy"
                                   value="<g:message code="project.survey.info.spatialAccuracy.moderate.value"/>"
                                   data-validation-engine="validate[required]" >
                            <g:message code="project.facets.spatialAccuracy.moderate"/>
                        </label>
                        <label class="radio">
                            <input name="spatialAccuracy" class="form-control" type="radio"
                                   data-bind="checked: spatialAccuracy"
                                   value="<g:message code="project.survey.info.spatialAccuracy.low.value"/>"
                                   data-validation-engine="validate[required]" >
                            <g:message code="project.facets.spatialAccuracy.low"/>
                        </label>
                            </div>
        <div class="span6">

                        %{-- species identification confidence --}%
                        <div class="row-fluid">
                            <div class="span12">
                                <strong>
                                    <g:message code="project.survey.info.speciesIdentification.text"/>
                                </strong>
                                <span class="req-field"></span>
                            </div>
                        </div>
                        <label class="radio">
                            <input name="speciesIdentification" class="form-control" type="radio"
                                   data-bind="checked: speciesIdentification"
                                   value="<g:message code="project.survey.info.speciesIdentification.high.value"/>"
                                   data-validation-engine="validate[required]" >
                            <g:message code="project.facets.speciesIdentification.high"/>
                        </label>
                        <label class="radio">
                            <input name="speciesIdentification" class="form-control" type="radio"
                                   data-bind="checked: speciesIdentification"
                                   value="<g:message code="project.survey.info.speciesIdentification.moderate.value"/>"
                                   data-validation-engine="validate[required]" >
                            <g:message code="project.facets.speciesIdentification.moderate"/>
                        </label>
                        <label class="radio">
                            <input name="speciesIdentification" class="form-control" type="radio"
                                   data-bind="checked: speciesIdentification"
                                   value="<g:message code="project.survey.info.speciesIdentification.low.value"/>"
                                   data-validation-engine="validate[required]" >
                            <g:message code="project.facets.speciesIdentification.low"/>
                        </label>
                        %{-- species identification confidence - END--}%
        </div>
                    </div>
                        <div class="row-fluid">
                            <div class="span6">
                                <div class="row-fluid">
                                    <div class="span12">
                                        <strong>
                                            <g:message code="project.survey.info.temporalAccuracy.text"/>
                                        </strong>
                                        <span class="req-field"></span>
                                    </div>
                                </div>
                                <label class="radio">
                                    <input name="temporalAccuracy" class="form-control" type="radio"
                                           data-bind="checked: temporalAccuracy"
                                           value="<g:message code="project.survey.info.temporalAccuracy.high.value"/>"
                                           data-validation-engine="validate[required]" >
                                    <g:message code="project.facets.temporalAccuracy.high"/>
                                </label>
                                <label class="radio">
                                    <input name="temporalAccuracy" class="form-control" type="radio"
                                           data-bind="checked: temporalAccuracy"
                                           value="<g:message code="project.survey.info.temporalAccuracy.moderate.value"/>"
                                           data-validation-engine="validate[required]" >
                                    <g:message code="project.facets.temporalAccuracy.moderate"/>
                                </label>
                                <label class="radio">
                                    <input name="temporalAccuracy" class="form-control" type="radio"
                                           data-bind="checked: temporalAccuracy"
                                           value="<g:message code="project.survey.info.temporalAccuracy.low.value"/>"
                                           data-validation-engine="validate[required]" >
                                    <g:message code="project.facets.temporalAccuracy.low"/>
                                </label>
                            </div>
                            <div class="span6">
                                <div class="row-fluid">
                                    <div class="span12">
                                        <strong>
                                            <g:message code="project.survey.info.nonTaxonomicAccuracy.text"/>
                                        </strong>
                                        <span class="req-field"></span>
                                    </div>
                                </div>
                                <label class="radio">
                                    <input name="nonTaxonomicAccuracy" class="form-control" type="radio"
                                           data-bind="checked: nonTaxonomicAccuracy"
                                           value="<g:message code="project.survey.info.nonTaxonomicAccuracy.high.value"/>"
                                           data-validation-engine="validate[required]" >
                                    <g:message code="project.facets.nonTaxonomicAccuracy.high"/>
                                </label>
                                <label class="radio">
                                    <input name="nonTaxonomicAccuracy" class="form-control" type="radio"
                                           data-bind="checked: nonTaxonomicAccuracy"
                                           value="<g:message code="project.survey.info.nonTaxonomicAccuracy.moderate.value"/>"
                                           data-validation-engine="validate[required]" >
                                    <g:message code="project.facets.nonTaxonomicAccuracy.moderate"/>
                                </label>
                                <label class="radio">
                                    <input name="nonTaxonomicAccuracy" class="form-control" type="radio"
                                           data-bind="checked: nonTaxonomicAccuracy"
                                           value="<g:message code="project.survey.info.nonTaxonomicAccuracy.low.value"/>"
                                           data-validation-engine="validate[required]" >
                                    <g:message code="project.facets.nonTaxonomicAccuracy.low"/>
                                </label>
                            </div>
                        </div>
                        %{-- --}%
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="dataQualityAssuranceMethod"><g:message code="project.survey.info.dataQualityAssuranceMethod"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataQualityAssuranceMethod"/>', content:'<g:message code="project.survey.info.dataQualityAssuranceMethod.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls" id="dataQualityAssuranceMethod" data-bind="validateObservable: dataQualityAssuranceMethods" data-validation-engine="validate[required]">
                        <g:set var="multiple" value="${2}"/>
                        <g:set var="ceil" value="${(Integer)Math.ceil(grailsApplication.config.dataQualityAssuranceMethods.size()/2)}"/>
                        <g:each in="${0..<ceil}" var="index">
                            <g:set var="start" value="${ index * multiple}"/>
                            <g:set var="end" value="${(index + 1) * multiple - 1}"/>
                            <g:if test="${end >= grailsApplication.config.dataQualityAssuranceMethods.size()}">
                                <g:set var="end" value="${end -1}"/>
                            </g:if>
                            <div class="row-fluid">
                                <g:each in="${grailsApplication.config.dataQualityAssuranceMethods[start..end]}" var="dqMethod">
                                    <div class="span6">
                                        <label class="checkbox">
                                            <input type="checkbox" value="${dqMethod}" data-bind="checked: transients.dataQualityAssuranceMethods"/>
                                            <g:message code="project.facets.dataQualityAssuranceMethod.${dqMethod}"/>
                                        </label>
                                    </div>
                                </g:each>
                            </div>
                        </g:each>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="dataAccessMethod"><g:message code="project.survey.info.dataAccessMethod"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataAccessMethod"/>', content:'<g:message code="project.survey.info.dataAccessMethod.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <select id="dataAccessMethod" class="full-width form-control" name="dataAccessMethod" data-bind="value:dataAccessMethod"
                                  data-validation-engine="validate[required]">
                            <option value=""><g:message code="project.survey.info.dataAccessMethod.noSelection"/></option>
                            <g:each in="${grailsApplication.config.dataAccessMethods}" var="daMethod">
                                <option value="${daMethod}"><g:message code="project.facets.dataAccessMethod.${daMethod}"/></option>
                            </g:each>
                        </select>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="dataAccessExternalURL"><g:message code="project.survey.info.dataAccessExternalURL"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataAccessExternalURL"/>', content:'<g:message code="project.survey.info.dataAccessExternalURL.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <input id="dataAccessExternalURL" class="full-width" type="text" data-bind="value: dataAccessExternalURL" data-validation-engine="validate[custom[url]]"/>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="dataQualityAssuranceDescription"><g:message code="project.survey.info.dataQualityAssuranceDescription"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataQualityAssuranceDescription"/>', content:'<g:message code="project.survey.info.dataQualityAssuranceDescription.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>
                <div class="span8">
                    <div class="controls">
                        <textarea id="dataQualityAssuranceDescription" rows="6" class="full-width" data-bind="value: dataQualityAssuranceDescription"></textarea>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="usageGuide"><g:message code="project.survey.info.usageGuide"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.usageGuide"/>', content:'<g:message code="project.survey.info.usageGuide.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="right-padding"></span>
                    </label>
                </div>
                <div class="span8">
                    <div class="controls">
                        <textarea id="usageGuide" rows="6" class="full-width" data-bind="value: usageGuide"></textarea>
                    </div>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="isDataManagementPolicyDocumented"><g:message code="project.survey.info.isDataManagementPolicyDocumented"/>
                        <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.isDataManagementPolicyDocumented"/>', content:'<g:message code="project.survey.info.isDataManagementPolicyDocumented.content"/>'}">
                            <i class="icon-question-sign"></i>
                        </a>
                        <span class="req-field"></span>
                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <select id="isDataManagementPolicyDocumented" name="isDataManagementPolicyDocumented" class="full-width" data-bind="value: transients.isDataManagementPolicyDocumented" data-validation-engine="validate[required]">
                            <option selected value="">- Please select an option -</option>
                            <option value="<g:message code="project.survey.info.isDataManagementPolicyDocumented.yes.value"/>"><g:message code="project.facets.isDataManagementPolicyDocumented.yes"/></option>
                            <option value="<g:message code="project.survey.info.isDataManagementPolicyDocumented.no.value"/>"><g:message code="project.facets.isDataManagementPolicyDocumented.no"/></option>
                        </select>
                    </div>
                </div>
            </div>

            <div data-bind="slideVisible: isDataManagementPolicyDocumented">
                <div class="row-fluid">
                    <div class="span4 text-right">
                        <label class="control-label" for="dataManagementPolicyDescription"><g:message code="project.survey.info.dataManagementPolicyDescription"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataManagementPolicyDescription"/>', content:'<g:message code="project.survey.info.dataManagementPolicyDescription.content"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                            <span class="right-padding"></span>
                        </label>
                    </div>

                    <div class="span8">
                        <div class="controls">
                            <textarea id="dataManagementPolicyDescription" rows="4" class="full-width" data-bind="value: dataManagementPolicyDescription" data-validation-engine="validate[groupRequired[DataManagement]]"></textarea>
                        </div>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-right">
                        <label class="control-label" for="dataManagementPolicyURL"><g:message code="project.survey.info.dataManagementPolicyURL"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataManagementPolicyURL"/>', content:'<g:message code="project.survey.info.dataManagementPolicyURL.content"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                            <span class="right-padding"></span>
                        </label>
                    </div>

                    <div class="span8">
                        <div class="controls">
                            <input id="dataManagementPolicyURL" type="text" class="full-width" data-bind="value: dataManagementPolicyURL" data-validation-engine="validate[custom[url],groupRequired[DataManagement]]"/>
                        </div>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-right">
                        <label class="control-label" ><g:message code="project.survey.info.dataManagementPolicyDocument"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataManagementPolicyDocument"/>', content:'<g:message code="project.survey.info.dataManagementPolicyDocument.content"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                            <span class="right-padding"></span>
                        </label>
                    </div>

                    <div class="span8 text-left">
                        <div class="row-fluid">
                            <div class="span12">
                                <div class="space-after">
                                    <a data-bind="attr: { href: transients.dataManagementPolicyDocumentURL}, text: transients.dataManagementPolicyDocumentURL, visible: dataManagementPolicyDocument, validateObservable:dataManagementPolicyDocument" data-validation-engine="validate[groupRequired[DataManagement]]" target="_blank"></a>
                                </div>
                                <button class="btn btn-small" data-bind="click:deleteDocument, visible: dataManagementPolicyDocument"><i class="icon-minus"></i> Remove Document</button>
                                <div class="row-fluid attachDocumentModal" data-bind="visible: !dataManagementPolicyDocument()">
                                    <button class="btn btn-small btn-primary" id="doAttach" data-bind="click:attachDocument"><i class="icon-white icon-plus"></i> Attach Document</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /ko -->
            <g:render template="../projectActivity/indexingNote"/>

    <!-- /ko -->
<!-- /ko -->
</div>


%{-- todo: render supplementaryData template here once TERN is using Biocollect and Aekos system is ready. --}%

<div class="row-fluid">
    <div class="span12">
        <div class="alert alert-info" data-bind="visible: !isSurveyInfoFormFilled()">Enable Next button by filling all mandatory fields on this page.</div>
        <button class="btn-primary btn btn-small block" data-bind="disable: !isSurveyInfoFormFilled(), click: saveInfo"><i class="icon-white  icon-hdd" ></i>  Save </button>
        <button class="btn-primary btn btn-small block" data-bind="disable: !isSurveyInfoFormFilled(), showTabOrRedirect: {url:'', tabId: '#survey-visibility-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
    </div>
</div>