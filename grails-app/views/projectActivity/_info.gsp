<div id="pActivityInfo">

    <!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row mt-4">
        <div class="col-12">
            <h5 class="d-inline">Step 1 of 7 - Describe the survey</h5>
            <g:render template="/projectActivity/status"/>
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-12">
            <div class="alert alert-info">
                <p>
                    <g:message code="project.survey.info.alertText.1"/>
                </p>

                <p>
                    <g:message code="project.survey.info.alertText.2"/>
                </p>

                <p>
                    <g:message code="project.survey.info.alertText.3"/>
                </p>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="name"><g:message code="project.survey.info.name"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.name"/>', content:'<g:message
                       code="project.survey.info.name.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <input id="name" type="text" class="form-control" data-bind="valueUpdate: 'input',value: name"
                   data-validation-engine="validate[required]">
        </div>
    </div>

    <div class="row form-group">

        <label class="col-12 col-md-4 col-form-label" for="description"><g:message
                code="project.survey.info.description"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.description"/>', content:'<g:message
                       code="project.survey.info.description.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <textarea id="description" rows="4" class="form-control" data-bind="value: description"
                      data-validation-engine="validate[required]"></textarea>
        </div>
    </div>

    <div class="row">
        <div class=" offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>

    <div class="row form-group">

        <label class="col-12 col-md-4 col-form-label" for="methodType"><g:message
                code="project.survey.info.methodType"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.methodType"/>', content:'<g:message
                       code="project.survey.info.methodType.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <select id="methodType" class="form-control" data-bind="value: methodType"
                    data-validation-engine="validate[required]">
                <option value=""><g:message code="project.survey.info.methodType.noSelection.displayName"/></option>
                <g:each in="${grailsApplication.config.methodType}" var="type">
                    <option value="${type}"><g:message code="facets.methodType.${type}"/></option>
                </g:each>
            </select>
        </div>
    </div>


    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="methodName"><g:message
                code="project.survey.info.methodName"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.methodName"/>', content:'<g:message
                       code="project.survey.info.methodName.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <input id="methodName" class="form-control" type="text"
                   data-bind="autocompleteFromList: {value: methodName, dropDownOnFocus: true, config: {source: fcConfig.surveyMethods, minLength: 0, autoFocus: true}}"
                   data-validation-engine="validate[required]">
        </div>
    </div>

    <div data-bind="slideVisible: transients.isSystematicSurvey">
        <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label" for="methodAbstract"><g:message
                    code="project.survey.info.methodAbstract"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message
                           code="project.survey.info.methodAbstract"/>', content:'<g:message
                           code="project.survey.info.methodAbstract.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>

            <div class="col-12 col-md-8">
                <textarea id="methodAbstract" rows="4" class="form-control" data-bind="value: methodAbstract"
                          data-validation-engine="validate[groupRequired[DescriptionSurveyMethod]]"></textarea>
            </div>
        </div>

        <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label" for="methodUrl"><g:message
                    code="project.survey.info.methodUrl"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="project.survey.info.methodUrl"/>', content:'<g:message
                           code="project.survey.info.methodUrl.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>

            <div class="col-12 col-md-8">
                <input id="methodUrl" class="form-control" type="text" data-bind="value: methodUrl"
                       data-validation-engine="validate[groupRequired[DescriptionSurveyMethod],custom[url]]"/>
            </div>
        </div>

        <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label"><g:message code="project.survey.info.methodDoc"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="project.survey.info.methodDoc"/>', content:'<g:message
                           code="project.survey.info.methodDoc.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>

            <div class="col-12 col-md-8">
                <!-- Method document-->
                <div class="row mb-3">
                    <div class="col-12">
                        <div class="text-left">
                            <a data-bind="attr:{href:methodDocUrl}" target="_blank">
                                <small class="media-heading" data-bind="text:methodDocName"></small>
                            </a>

                            <span class="btn fileinput-button float-left"
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
                            <button class="btn btn-sm btn-danger"
                                    data-bind="click:removeMethodDoc, visible:methodDocUrl()"><i
                                    class="fas fa-info-circle"></i> Remove Document</button>
                        </div>
                    </div>
                </div>
                <!-- end of Document -->
            </div>
        </div>
    </div>

    <div class="row">
        <div class="offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-label-" for="startDate"><g:message code="project.survey.info.startDate"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.startDate"/>', content:'<g:message
                       code="project.survey.info.startDate.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span></label>

        <div class="col-12 col-md-8">
            <div class="input-group">
                <input class="form-control" id="startDate" data-bind="datepicker:startDate.date" type="text"
                       data-validation-engine="validate[required]"/>
                <div class="input-group-append">
                    <button class="btn btn-dark open-datepicker"><i class="far fa-calendar-alt"></i></button>
                </div>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="endDate"><g:message code="project.survey.info.endDate"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.endDate"/>', content:'<g:message
                       code="project.survey.info.endDate.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-12 col-md-8">
            <div class="input-group">
                <input class="form-control" id="endDate" data-bind="datepicker:endDate.date" type="text"/>
                <div class="input-group-append">
                    <button class="btn btn-dark open-datepicker"><i class="far fa-calendar-alt"></i></button>
                </div>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="publicAccess"><g:message
                code="project.survey.info.publicData"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.publicData"/>', content:'<g:message
                       code="project.survey.info.publicData.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-12 col-md-8">
            <div class="form-check">
                <input class="form-check-input" id="publicAccess" type="checkbox" data-bind="checked: publicAccess"/>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="allowComments"><g:message
                code="project.survey.info.comments"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.comments"/>', content:'<g:message
                       code="project.survey.info.comments.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-12 col-md-8">
            <div class="form-check">
                <input class="form-check-input" id="allowComments" type="checkbox" data-bind="checked: commentsAllowed"/>
            </div>
        </div>
    </div>

    <div class="row space-after">
        <label class="col-12 col-md-4 col-form-label"><g:message code="project.survey.info.logo"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.logo"/>', content:'<g:message
                       code="project.survey.info.logo.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-8">
            <img class="img-thumbnail" alt="No image" data-bind="attr:{src: transients.logoUrl()}">
            <div class="btn-space">
                <button class="btn btn-sm btn-dark fileinput-button float-none"
                      data-bind="
                                attr:{'data-role':'logo',
                                    'data-url': transients.imageUploadUrl(),
                                    'data-owner-type': 'projectActivityId',
                                    'data-owner-id': projectActivityId()},
                                     stagedImageUpload: documents,
                                         visible:!logoUrl()">
                    <i class="fas fa-file-upload"></i>
                    <input id="logo" type="file" name="files">
                    <span>Attach</span></button>
                <button class="btn btn-sm btn-danger" data-bind="click:removeLogoImage, visible:logoUrl()"><i
                        class="far fa-trash-alt"></i> Remove</button>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="dataSharingLicense"><g:message
                code="project.survey.info.dataSharingLicense"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message
                       code="project.survey.info.dataSharingLicense"/>', content:'<g:message
                       code="project.survey.info.dataSharingLicense.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <g:select id="dataSharingLicense" class="full-width form-control" name="dateSharingLicence"
                      from="${licences}"
                      optionValue="name" data-bind="value:dataSharingLicense"
                      noSelection="['': '-Please select the licence-']" optionKey="url"
                      data-validation-engine="validate[required]"/>
            <g:each in="${licences}">
                <label class="my-1" data-bind="visible: dataSharingLicense() == '${it.url}'"><a href="${it.url}"
                                                                                                       target="_blank"><img
                            src="${asset.assetPath(src: "licence/${it.logo}")}">&nbsp;&nbsp;${it.description}</a>
                </label>
            </g:each>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="legalCustodian"><g:message
                code="project.survey.info.legalCustodian"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.legalCustodian"/>', content:'<g:message
                       code="project.survey.info.legalCustodian.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <input id="legalCustodian" class="form-control" type="text" data-bind="value: legalCustodianOrganisation"
                   data-validation-engine="validate[required]">
        </div>
    </div>

    <div class="row">
        <div class="offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>


    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label"><g:message code="project.survey.info.reliabilityTag"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.reliabilityTag"/>', content:'<g:message
                       code="project.survey.info.reliabilityTag.content" encodeAs="JavaScript"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-12 col-md-8">
            <div class="row">
                <div class="col-12 col-md-6">
                    <div class="row">
                        <div class="col-12">
                            <strong>
                                <g:message code="project.survey.info.spatialAccuracy.text"/>
                            </strong>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.spatialAccuracy.text"/>', content:'<g:message
                                    code="project.survey.info.spatialAccuracy.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                            <span class="req-field"></span>
                        </div>
                    </div>
                    <div class="form-check">
                        <input name="spatialAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: spatialAccuracy"
                               value="<g:message code="project.survey.info.spatialAccuracy.high.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.spatialAccuracy.high"/></label>
                    </div>
                    <div class="form-check">
                        <input name="spatialAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: spatialAccuracy"
                               value="<g:message code="project.survey.info.spatialAccuracy.moderate.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.spatialAccuracy.moderate"/></label>
                    </div>
                    <div class="form-check">
                        <input name="spatialAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: spatialAccuracy"
                               value="<g:message code="project.survey.info.spatialAccuracy.low.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.spatialAccuracy.low"/></label>
                    </div>
                </div>

                <div class="col-12 col-md-6">
                    %{-- species identification confidence --}%
                    <div class="row">
                        <div class="col-12">
                            <strong>
                                <g:message code="project.survey.info.speciesIdentification.text"/>
                            </strong>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.speciesIdentification.text"/>', content:'<g:message
                                    code="project.survey.info.speciesIdentification.content" encodeAs="JavaScript"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                            <span class="req-field"></span>
                        </div>
                    </div>
                    <div class="form-check">
                        <input name="speciesIdentification" class="form-check-input" type="radio"
                               data-bind="checked: speciesIdentification"
                               value="<g:message code="project.survey.info.speciesIdentification.high.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.speciesIdentification.high"/></label>
                    </div>
                    <div class="form-check">
                        <input name="speciesIdentification" class="form-check-input" type="radio"
                               data-bind="checked: speciesIdentification"
                               value="<g:message code="project.survey.info.speciesIdentification.moderate.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.speciesIdentification.moderate"/></label>
                    </div>
                    <div class="form-check">
                        <input name="speciesIdentification" class="form-check-input" type="radio"
                               data-bind="checked: speciesIdentification"
                               value="<g:message code="project.survey.info.speciesIdentification.low.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.speciesIdentification.low"/></label>
                    </div>
                    <div class="form-check">
                        <input name="speciesIdentification" class="form-check-input" type="radio"
                               data-bind="checked: speciesIdentification"
                               value="<g:message code="project.survey.info.speciesIdentification.na.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.speciesIdentification.na"/></label>
                    </div>
                    %{-- species identification confidence - END--}%
                </div>
            </div>

            <div class="row">
                <div class="col-12 col-md-6">
                    <div class="row">
                        <div class="col-12">
                            <strong>
                                <g:message code="project.survey.info.temporalAccuracy.text"/>
                            </strong>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.temporalAccuracy.text"/>', content:'<g:message
                                    code="project.survey.info.temporalAccuracy.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                            <span class="req-field"></span>
                        </div>
                    </div>
                    <div class="form-check">
                        <input name="temporalAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: temporalAccuracy"
                               value="<g:message code="project.survey.info.temporalAccuracy.high.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.temporalAccuracy.high"/></label>
                    </div>
                    <div class="form-check">
                        <input name="temporalAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: temporalAccuracy"
                               value="<g:message code="project.survey.info.temporalAccuracy.moderate.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.temporalAccuracy.moderate"/></label>
                    </div>
                    <div class="form-check">
                        <input name="temporalAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: temporalAccuracy"
                               value="<g:message code="project.survey.info.temporalAccuracy.low.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.temporalAccuracy.low"/></label>
                    </div>
                </div>

                <div class="col-12 col-md-6">
                    <div class="row">
                        <div class="col-12">
                            <strong>
                                <g:message code="project.survey.info.nonTaxonomicAccuracy.text"/>
                            </strong>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.nonTaxonomicAccuracy.text"/>', content:'<g:message
                                    code="project.survey.info.nonTaxonomicAccuracy.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                            <span class="req-field"></span>
                        </div>
                    </div>
                    <div class="form-check">
                        <input name="nonTaxonomicAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: nonTaxonomicAccuracy"
                               value="<g:message code="project.survey.info.nonTaxonomicAccuracy.high.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.nonTaxonomicAccuracy.high"/></label>
                    </div>
                    <div class="form-check">
                        <input name="nonTaxonomicAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: nonTaxonomicAccuracy"
                               value="<g:message code="project.survey.info.nonTaxonomicAccuracy.moderate.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.nonTaxonomicAccuracy.moderate"/></label>
                    </div>
                    <div class="form-check">
                        <input name="nonTaxonomicAccuracy" class="form-check-input" type="radio"
                               data-bind="checked: nonTaxonomicAccuracy"
                               value="<g:message code="project.survey.info.nonTaxonomicAccuracy.low.value"/>"
                               data-validation-engine="validate[required]">
                        <label class="form-check-label"><g:message code="facets.nonTaxonomicAccuracy.low"/></label>
                    </div>
                </div>
            </div>
        </div>
    </div>
    %{--</div>--}%

    <div class="row">
        <div class="offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>

    <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label" for="dataQualityAssuranceMethod"><g:message
                    code="project.survey.info.dataQualityAssuranceMethod"/>
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                        code="project.survey.info.dataQualityAssuranceMethod"/>', content:'<g:message
                        code="project.survey.info.dataQualityAssuranceMethod.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="req-field"></span>
            </label>

        <div class="col-12 col-md-8">
            <div class="controls" id="dataQualityAssuranceMethod"
                 data-bind="validateObservable: dataQualityAssuranceMethods"
                 data-validation-engine="validate[required]">
                <g:set var="multiple" value="${2}"/>
                <g:set var="ceil"
                       value="${(Integer) Math.ceil(grailsApplication.config.dataQualityAssuranceMethods.size() / 2)}"/>
                <g:each in="${0..<ceil}" var="index">
                    <g:set var="start" value="${index * multiple}"/>
                    <g:set var="end" value="${(index + 1) * multiple - 1}"/>
                    <g:if test="${end >= grailsApplication.config.dataQualityAssuranceMethods.size()}">
                        <g:set var="end" value="${end - 1}"/>
                    </g:if>
                    <div class="row">
                        <g:each in="${grailsApplication.config.dataQualityAssuranceMethods[start..end]}" var="dqMethod">
                            <div class="col-6">
                                <label class="form-check">
                                    <input class="form-check-input" type="checkbox" value="${dqMethod}"
                                           data-bind="checked: transients.dataQualityAssuranceMethods"/>
                                    <g:message code="facets.dataQualityAssuranceMethods.${dqMethod}"/>
                                </label>
                            </div>
                        </g:each>
                    </div>
                </g:each>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <div class="col-12 col-md-4 col-form-label">
            <label class="col-12 col-md-4 col-form-label" for="dataQualityAssuranceDescription"><g:message
                    code="project.survey.info.dataQualityAssuranceDescription"/>
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                        code="project.survey.info.dataQualityAssuranceDescription"/>', content:'<g:message
                        code="project.survey.info.dataQualityAssuranceDescription.content" encodeAs="JavaScript"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>
        </div>

        <div class="col-12 col-md-8">
            <div class="controls">
                <textarea id="dataQualityAssuranceDescription" rows="6" class="form-control"
                          data-bind="value: dataQualityAssuranceDescription"></textarea>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>

    %{--todo: add data access method section once its behaviour is finalised. Behaviour to be finalised are its interaction with "public access to data" and "embargo date" --}%
    %{--<div class="row form-group">--}%
    %{--<div  class="col-12 col-md-4 col-form-label">--}%
    %{--<label  class="col-12 col-md-4 col-form-label" for="dataAccessMethods"><g:message code="project.survey.info.dataAccessMethods"/>--}%
    %{--<a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataAccessMethods"/>', content:'<g:message code="project.survey.info.dataAccessMethods.content"/>'}">--}%
    %{--<i class="fas fa-info-circle"></i>--}%
    %{--</a>--}%
    %{--<span class="req-field"></span>--}%
    %{--</label>--}%
    %{--</div>--}%

    %{--<div class="col-12 col-md-8">--}%
    %{--<div class="controls" id="dataAccessMethods" data-bind="validateObservable: dataAccessMethods" data-validation-engine="validate[required]">--}%
    %{--<g:set var="multiple" value="${2}"/>--}%
    %{--<g:set var="ceil" value="${(Integer)Math.ceil(grailsApplication.config.dataAccessMethods.size()/2)}"/>--}%
    %{--<g:each in="${0..<ceil}" var="index">--}%
    %{--<g:set var="start" value="${ index * multiple}"/>--}%
    %{--<g:set var="end" value="${(index + 1) * multiple - 1}"/>--}%
    %{--<g:if test="${end >= grailsApplication.config.dataAccessMethods.size()}">--}%
    %{--<g:set var="end" value="${end -1}"/>--}%
    %{--</g:if>--}%
    %{--<div class="row form-group">--}%
    %{--<g:each in="${grailsApplication.config.dataAccessMethods[start..end]}" var="daMethod">--}%
    %{--<div class="span6">--}%
    %{--<label class="checkbox">--}%
    %{--<input type="checkbox" value="${daMethod}" data-bind="checked: transients.dataAccessMethods"/>--}%
    %{--<g:message code="facets.dataAccessMethods.${daMethod}"/>--}%
    %{--</label>--}%
    %{--</div>--}%
    %{--</g:each>--}%
    %{--</div>--}%
    %{--</g:each>--}%
    %{--</div>--}%
    %{--<hr class="border-bottom-separator"/>--}%
    %{--</div>--}%
    %{--</div>--}%

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="dataAccessExternalURL"><g:message
                code="project.survey.info.dataAccessExternalURL"/>
            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                    code="project.survey.info.dataAccessExternalURL"/>', content:'<g:message
                    code="project.survey.info.dataAccessExternalURL.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-12 col-md-8">
            <input id="dataAccessExternalURL" class="form-control" type="text" data-bind="value: dataAccessExternalURL"
                   data-validation-engine="validate[custom[url]]"/>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="usageGuide"><g:message
                code="project.survey.info.usageGuide"/>
            <a href="#" class="helphover"
               data-bind="popover: {title:'<g:message code="project.survey.info.usageGuide"/>', content:'<g:message
                       code="project.survey.info.usageGuide.content"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="right-padding"></span>
        </label>

        <div class="col-12 col-md-8">
            <textarea id="usageGuide" rows="6" class="form-control" data-bind="value: usageGuide"></textarea>
        </div>
    </div>

    <div class="row">
        <div class="offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>

    <div class="row form-group">
        <label class="col-12 col-md-4 col-form-label" for="isDataManagementPolicyDocumented"><g:message
                code="project.survey.info.isDataManagementPolicyDocumented"/>
            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                    code="project.survey.info.isDataManagementPolicyDocumented"/>', content:'<g:message
                    code="project.survey.info.isDataManagementPolicyDocumented.content" encodeAs="JavaScript"/>'}">
                <i class="fas fa-info-circle"></i>
            </a>
            <span class="req-field"></span>
        </label>

        <div class="col-12 col-md-8">
            <select id="isDataManagementPolicyDocumented" name="isDataManagementPolicyDocumented" class="form-control"
                    data-bind="value: transients.isDataManagementPolicyDocumented"
                    data-validation-engine="validate[required]">
                <option selected value="">- Please select an option -</option>
                <option value="<g:message
                        code="project.survey.info.isDataManagementPolicyDocumented.yes.value"/>"><g:message
                        code="facets.isDataManagementPolicyDocumented.yes"/></option>
                <option value="<g:message
                        code="project.survey.info.isDataManagementPolicyDocumented.no.value"/>"><g:message
                        code="facets.isDataManagementPolicyDocumented.no"/></option>
            </select>
        </div>
    </div>

    <div data-bind="slideVisible: isDataManagementPolicyDocumented">
        <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label" for="dataManagementPolicyDescription"><g:message
                    code="project.survey.info.dataManagementPolicyDescription"/>
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                        code="project.survey.info.dataManagementPolicyDescription"/>', content:'<g:message
                        code="project.survey.info.dataManagementPolicyDescription.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>

            <div class="col-12 col-md-8">
                <textarea id="dataManagementPolicyDescription" rows="4" class="form-control"
                          data-bind="value: dataManagementPolicyDescription"
                          data-validation-engine="validate[groupRequired[DataManagement]]"></textarea>
            </div>
        </div>

        <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label" for="dataManagementPolicyURL"><g:message
                    code="project.survey.info.dataManagementPolicyURL"/>
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                        code="project.survey.info.dataManagementPolicyURL"/>', content:'<g:message
                        code="project.survey.info.dataManagementPolicyURL.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>

            <div class="col-12 col-md-8">
                <input id="dataManagementPolicyURL" type="text" class="form-control"
                       data-bind="value: dataManagementPolicyURL"
                       data-validation-engine="validate[groupRequired[DataManagement],custom[url]]"/>
            </div>
        </div>

        <div class="row form-group">
            <label class="col-12 col-md-4 col-form-label"><g:message
                    code="project.survey.info.dataManagementPolicyDocument"/>
                <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                        code="project.survey.info.dataManagementPolicyDocument"/>', content:'<g:message
                        code="project.survey.info.dataManagementPolicyDocument.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
                <span class="right-padding"></span>
            </label>

            <div class="col-12 col-md-8">
                <div class="row form-group">
                    <div class="col-12">
                        <div class="space-after">
                            <a data-bind="attr: { href: transients.dataManagementPolicyDocumentURL}, text: transients.getFileNameForDataManagementDocument(), visible: dataManagementPolicyDocument, validateObservable:dataManagementPolicyDocument"
                               data-validation-engine="validate[groupRequired[DataManagement]]" target="_blank"></a>
                        </div>
                        <button class="btn btn-sm btn-danger"
                                data-bind="click:deleteDocument, visible: dataManagementPolicyDocument"><i
                                class="far fa-trash-alt"></i> Remove Document</button>

                        <div class="row attachDocumentModal" data-bind="visible: !dataManagementPolicyDocument()">
                            <button class="btn btn-sm btn-primary-dark" id="doAttach"
                                    data-bind="click:attachDocument"><i
                                    class="fas fa-file-upload"></i> Attach Document</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="offset-md-4 col-12 col-md-8">
            <hr class="border-bottom-separator"/>
        </div>
    </div>
    <g:render template="/projectActivity/indexingNote"/>
    <!-- /ko -->
    <!-- /ko -->
</div>


%{-- todo: render supplementaryData template here once TERN is using Biocollect and Aekos system is ready. --}%

<div class="row">
    <div class="col-12">
        <button class="btn-primary-dark btn btn-sm" data-bind="click: saveInfo"><i class="fas fa-hdd"></i> Save
        </button>
        <button class="btn-dark btn btn-sm"
                data-bind="visible: showInfoNext(), showTabOrRedirect: {url:'', tabId: '#survey-visibility-tab'}"><i
                class="far fa-arrow-alt-circle-right"></i> Next</button>
    </div>
</div>