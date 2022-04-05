<g:render template="/aekosSubmission/aekosWorkflowModal"/>
<!-- ko stopBinding: true -->
<div class="container-fluid" id="pActivitiesList">

    <!-- ko if: projectActivities().length == 0 -->
    <div class="row">
        <div class="col-12">
            <h2><g:message code="project.survey.noSurveys"/></h2>
        </div>
    </div>
    <!-- /ko -->


    <!-- ko if: projectActivities().length > 1 -->
    <div class="row">
        <div class="col-12">
            <h2><g:message code="project.survey.title"/></h2>
        </div>
    </div>

    %{--    <div class="row  survey-list-actions mb-3">--}%
    %{--        <div class="col-12 col-md-2">--}%
    %{--            <div class="form-group">--}%
    %{--                <span data-bind="click: toggleFilter" class="btn btn-sm btn-dark"><i class="fas fa-sort"></i> <g:message code="g.sort"/></span>--}%
    %{--            </div>--}%
    %{--        </div>--}%
    %{--        <div class="col-12 col-md-3">--}%
    %{--            <div class="form-group row">--}%
    %{--                <!-- ko if: filter -->--}%
    %{--                <label class="muted col-6 col-form-label" for="sort"><g:message code="g.sortBy"/></label>--}%
    %{--                <select class="col-6" id="sort" data-bind="options: sortOptions, optionsText:'name', optionsValue:'id', value: sortBy" ></select>--}%
    %{--                <!-- /ko -->--}%
    %{--            </div>--}%
    %{--        </div>--}%
    %{--        <div class="col-12 col-md-3">--}%
    %{--            <div class="form-group row">--}%
    %{--                <!-- ko if: filter -->--}%
    %{--                <label class="muted col-6 col-form-label" for="sortOrder"><g:message code="g.sortOrder"/></label>--}%
    %{--                <select class="col-6" id="sortOrder" data-bind="options: sortOrderOptions, optionsText:'name', optionsValue:'id', value: sortOrder" ></select>--}%
    %{--                <!-- /ko -->--}%
    %{--            </div>--}%
    %{--        </div>--}%

    %{--    </div>--}%
    <!-- /ko -->
    <g:set var="noImageUrl" value="${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}"/>

    <!-- ko foreach: projectActivities -->
    <!-- ko if: published() -->
    <div class="survey row">
        <div class="col-12 col-md-4 col-lg-3">
            <div class="image d-flex justify-content-center align-content-center">
                <img alt="No image" class="image-logo" data-bind="attr:{alt:name, src: transients.logoUrl()}" src=""
                     onload="findLogoScalingClass(this);addClassForImage(this, '${noImageUrl}', 'w-25');" onerror="imageError(this, '${noImageUrl}');"/>

                <div class="status">
                    <div class="dayscount"
                         data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
                        <!-- ko text:transients.daysRemaining --> <!-- /ko -->
                        <g:message code="project.survey.daysToGo"/>
                    </div>

                    <div class="dayscount"
                         data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                        <g:message code="g.survey"/> <g:message code="g.ended"/>
                    </div>

                    <div class="dayscount"
                         data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
                        <g:message code="g.survey"/> <g:message code="g.ongoing"/>
                    </div>

                    <div class="dayscount" data-bind="visible:transients.daysSince() < 0">
                        <g:message code="project.survey.startsIn"/>
                        <!-- ko text:-transients.daysSince() --> <!-- /ko -->
                        <g:message code="g.days"/>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-md-8 col-lg-9">
            <div class="content">
                <!-- ko if: $parent.userCanEdit($data) -->
                <a href="#"><h4 class="pl-0" data-bind="text:name, click: addActivity"></h4></a>
                <!-- /ko -->
                <!-- ko if: !$parent.userCanEdit($data) -->
                <h4 data-bind="text:name"></h4>
                <!-- /ko -->
                <div class="meta">
                    <div class="item" data-bind="visible:transients.status()">
                        <span class="label"><g:message code="g.status"/>:</span> <span
                            data-bind="text: transients.status" aria-label="Survey Status"></span>
                    </div>
                    <!-- ko if: startDate -->
                    <div class="divider"></div>

                    <div class="item">
                        <span class="label"><g:message code="project.details.plannedStartDate"/>:</span> <time
                            class="start-date"
                            data-bind="text: moment(startDate()).format('DD MMMM, YYYY'), attr: {datetime: startDate()}"
                            aria-label="Survey Start Date"></time>
                    </div>
                    <!-- /ko -->
                    <!-- ko if: endDate -->
                    <div class="divider"></div>

                    <div class="item">
                        <span class="label"><g:message code="project.details.plannedEndDate"/>:</span> <time
                            class="end-date"
                            data-bind="text: moment(endDate()).format('DD MMMM, YYYY'), attr: {datetime: endDate()}"
                            aria-label="Survey End Date"></time>
                    </div>
                    <!-- /ko -->
                </div>

                <div class="excerpt" data-bind="text:description"></div>

                <div class="controls btn-space">
                    <!-- ko if: $parent.userCanEdit($data) -->
                    <button class="btn btn-sm btn-primary-dark"
                            data-bind="click: addActivity"
                            title="<g:message code='project.survey.addRecord'/>">
                        <i class="fas fa-plus mr-1"></i>
                        <g:message code="project.survey.addRecord"/>
                    </button>
                    <!-- /ko -->
                    <button class="btn btn-sm btn-dark" data-bind="click: listActivityRecords"
                            title="<g:message code='project.survey.viewRecords'/>">
                        <i class="far fa-eye mr-1"></i>
                        <g:message code="project.survey.viewRecords"/>
                    </button>
                    <g:if test="${hubConfig?.content?.hideProjectSurveyDownloadXLSX != true}">
                        <a class="btn btn-sm btn-dark"
                           data-bind="attr: { href: downloadFormTemplateUrl, target: pActivityFormName }"
                           title="<g:message code="project.survey.downloadTemplate.title"/>">
                            <i class="fas fa-download mr-1"></i>
                            <g:message code="project.survey.downloadTemplate"/>
                        </a>
                    </g:if>
                    <g:if test="${grailsApplication.config.aekosEnabled}">
                        <!-- ko if: transients.isAekosData -->
                        <a href="#" class="btn btn-dark btn-sm" data-bind="
                                                            click: showAekosDetails,
                                                            text: transients.aekosToggleText"
                           title="View and send Data Submission to AEKOS"></a>
                        <!-- /ko -->
                    </g:if>
                    <button class="btn btn-sm btn-dark"
                            type="button" data-bind="attr: {'data-target': '#showMetadata' + $index()}"
                            data-toggle="collapse" aria-expanded="false">
                        <i class="fas fa-chevron-down mr-1"></i> Show metadata
                    </button>
                </div>
                <div class="collapse mt-3" data-bind="attr: {id: 'showMetadata' + $index()}">
                    <div class="row mb-2 no-gutters">
                        <div class="col-11 col-sm-5 col-md-2 mr-1 p-2 mt-1 mt-md-0" data-bind="css: spatialAccuracy, visible: spatialAccuracy">
                            <span>
                                <g:message code="project.survey.info.spatialAccuracy.text"/> -
                                <!-- ko if: spatialAccuracy() == 'low' --> <g:message
                                        code="facets.spatialAccuracy.low"/> <!-- /ko -->
                                <!-- ko if: spatialAccuracy() == 'moderate' --> <g:message
                                        code="facets.spatialAccuracy.moderate"/> <!-- /ko -->
                                <!-- ko if: spatialAccuracy() == 'high' --> <g:message
                                        code="facets.spatialAccuracy.high"/> <!-- /ko -->
                            </span>
                        </div>

                        <div class="col-11 col-sm-5 col-md-2 mr-1 p-2 mt-1 mt-md-0" data-bind="css: speciesIdentification, visible: speciesIdentification">
                            <span>
                                <g:message code="project.survey.info.speciesIdentification.text"/> -
                                <!-- ko if: speciesIdentification() == 'low' --> <g:message
                                        code="facets.speciesIdentification.low"/> <!-- /ko -->
                                <!-- ko if: speciesIdentification() == 'moderate' --> <g:message
                                        code="facets.speciesIdentification.moderate"/> <!-- /ko -->
                                <!-- ko if: speciesIdentification() == 'high' --> <g:message
                                        code="facets.speciesIdentification.high"/> <!-- /ko -->
                                <!-- ko if: speciesIdentification() == 'na' --> <g:message
                                        code="facets.speciesIdentification.na"/> <!-- /ko -->
                            </span>
                        </div>

                        <div class="col-11 col-sm-5 col-md-2 mr-1 p-2 mt-1 mt-md-0" data-bind="css: temporalAccuracy, visible: temporalAccuracy">
                            <span>
                                <g:message code="project.survey.info.temporalAccuracy.text"/> -
                                <!-- ko if: temporalAccuracy() == 'low' --> <g:message
                                        code="facets.temporalAccuracy.low"/> <!-- /ko -->
                                <!-- ko if: temporalAccuracy() == 'moderate' --> <g:message
                                        code="facets.temporalAccuracy.moderate"/> <!-- /ko -->
                                <!-- ko if: temporalAccuracy() == 'high' --> <g:message
                                        code="facets.temporalAccuracy.high"/> <!-- /ko -->
                            </span>
                        </div>

                        <div class="col-11 col-sm-5 col-md-2 p-2 mt-1 mt-md-0" data-bind="css: nonTaxonomicAccuracy, visible: nonTaxonomicAccuracy">
                            <span>
                                <g:message code="project.survey.info.nonTaxonomicAccuracy.text"/> -
                                <!-- ko if: nonTaxonomicAccuracy() == 'low' --> <g:message
                                        code="facets.nonTaxonomicAccuracy.low"/> <!-- /ko -->
                                <!-- ko if: nonTaxonomicAccuracy() == 'moderate' --> <g:message
                                        code="facets.nonTaxonomicAccuracy.moderate"/> <!-- /ko -->
                                <!-- ko if: nonTaxonomicAccuracy() == 'high' --> <g:message
                                        code="facets.nonTaxonomicAccuracy.high"/> <!-- /ko -->
                            </span>
                        </div>
                    </div>
                    <!-- ko if: transients.activityCount -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.activityCount"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.activityCount"/>', content:'<g:message
                                    code="project.survey.info.activityCount.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: transients.activityCount.formattedInteger"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: transients.speciesRecorded -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.speciesRecorded"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.speciesRecorded"/>', content:'<g:message
                                    code="project.survey.info.speciesRecorded.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: transients.speciesRecorded.formattedInteger"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: transients.activityLastUpdated -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.lastUpdated"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.lastUpdated"/>', content:'<g:message
                                    code="project.survey.info.lastUpdated.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: moment(transients.activityLastUpdated).format('DD MMMM, YYYY')"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.publicAccess"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.publicAccess"/>', content:'<g:message
                                    code="project.survey.info.publicAccess.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: transients.publicAccess"></span>
                        </div>
                    </div>

                    <!-- ko if: attribution -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.attribution"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.attribution"/>', content:'<g:message
                                    code="project.survey.info.attribution.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                        </div>

                        <div class="col-12 col-md-5">
                            <span data-bind="text: attribution"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: methodType -->
                    <div class="row mt-2 mb-2">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.methodType"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.methodType"/>', content:'<g:message
                                    code="project.survey.info.methodType.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <g:each in="${grailsApplication.config.methodType}" var="type">
                                <!-- ko if: methodType() === '${type}' -->
                                <div><g:message code="facets.methodType.${type}"/></div>
                                <!-- /ko -->
                            </g:each>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: methodName -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.methodName"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.methodName"/>', content:'<g:message
                                    code="project.survey.info.methodName.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: methodName"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: transients.isSystematicSurvey -->
                    <!-- ko if: methodAbstract -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.methodAbstract"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.methodAbstract"/>', content:'<g:message
                                    code="project.survey.info.methodAbstract.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: methodAbstract"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: methodUrl -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.methodUrl"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.methodUrl"/>', content:'<g:message
                                    code="project.survey.info.methodUrl.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <a data-bind="attr: {href: methodUrl}, text: methodUrl"
                               class="ellipsis-full-width" target="_blank"></a>
                        </div>
                    </div>
                    <!-- /ko -->


                    <!-- ko if: methodDocUrl -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.methodDoc"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.methodDoc"/>', content:'<g:message
                                    code="project.survey.info.methodDoc.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <div class="media">
                                <img class="media-object"
                                     data-bind="attr:{src: transients.getFileTypeForSurveyMethodDocument()}">

                                <div class="media-body">
                                    <h5></h5>
                                    <a href="#" data-bind="text: methodDocName, click: showDocument"
                                       data-document="method" target="_blank"></a>
                                </div>
                            </div>

                        </div>
                    </div>
                    <!-- /ko -->
                    <!-- /ko -->

                    <!-- ko if: dataSharingLicense -->
                    <div class="row  margin-top-10 margin-bottom-10">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataSharingLicense"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataSharingLicense"/>', content:'<g:message
                                    code="project.survey.info.dataSharingLicense.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <g:each in="${licences}">
                                <span data-bind="visible: dataSharingLicense() == '${it.url}'"><a
                                        href="${it.url}" target="_blank"><img
                                            src="${asset.assetPath(src: "licence/${it.logo}")} ">&nbsp;&nbsp;${it.name}
                                </a></span>
                            </g:each>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: legalCustodianOrganisation -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.legalCustodian"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.legalCustodian"/>', content:'<g:message
                                    code="project.survey.info.legalCustodian.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: legalCustodianOrganisation"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: dataQualityAssuranceMethods().length -->
                    <div class="row mt-2 mb-2">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataQualityAssuranceMethod"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataQualityAssuranceMethod"/>', content:'<g:message
                                    code="project.survey.info.dataQualityAssuranceMethod.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <g:each in="${grailsApplication.config.dataQualityAssuranceMethods}"
                                    var="dqMethod">
                                <!-- ko if: dataQualityAssuranceMethods().indexOf('${dqMethod}') > -1 -->
                                <div>
                                    <g:message code="facets.dataQualityAssuranceMethods.${dqMethod}"/>
                                </div>
                                <!-- /ko -->
                            </g:each>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: dataQualityAssuranceDescription -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataQualityAssuranceDescription"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataQualityAssuranceDescription"/>', content:'<g:message
                                    code="project.survey.info.dataQualityAssuranceDescription.content"
                                    encodeAs="JavaScript"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: dataQualityAssuranceDescription"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: dataAccessExternalURL -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataAccessExternalURL"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataAccessExternalURL"/>', content:'<g:message
                                    code="project.survey.info.dataAccessExternalURL.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>
                        </div>

                        <div class="col-12 col-md-5">
                            <a data-bind="attr: {href: dataAccessExternalURL}, text: dataAccessExternalURL"
                               target="_blank"></a>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: usageGuide -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.usageGuide"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.usageGuide"/>', content:'<g:message
                                    code="project.survey.info.usageGuide.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: usageGuide"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: transients.isDataManagementPolicyDocumented -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.isDataManagementPolicyDocumented"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.isDataManagementPolicyDocumented"/>', content:'<g:message
                                    code="project.survey.info.isDataManagementPolicyDocumented.content"
                                    encodeAs="JavaScript"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <!-- ko if: isDataManagementPolicyDocumented() -->
                            <span>
                                <g:message code="facets.isDataManagementPolicyDocumented.yes"/>
                            </span>
                            <!-- /ko -->
                            <!-- ko ifnot: isDataManagementPolicyDocumented() -->
                            <span>
                                <g:message code="facets.isDataManagementPolicyDocumented.no"/>
                            </span>
                            <!-- /ko -->
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: isDataManagementPolicyDocumented() && dataManagementPolicyDescription() -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataManagementPolicyDescription"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataManagementPolicyDescription"/>', content:'<g:message
                                    code="project.survey.info.dataManagementPolicyDescription.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <span data-bind="text: dataManagementPolicyDescription"></span>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: isDataManagementPolicyDocumented() && dataManagementPolicyURL() -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataManagementPolicyURL"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataManagementPolicyURL"/>', content:'<g:message
                                    code="project.survey.info.dataManagementPolicyURL.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <a data-bind="attr: {href: dataManagementPolicyURL}, text: dataManagementPolicyURL"
                               target="_blank" class="ellipsis-full-width"></a>
                        </div>
                    </div>
                    <!-- /ko -->

                    <!-- ko if: isDataManagementPolicyDocumented() && dataManagementPolicyDocument() -->
                    <div class="row">
                        <div class="col-12 col-md-5">
                            <g:message code="project.survey.info.dataManagementPolicyDocument"/>
                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message
                                    code="project.survey.info.dataManagementPolicyDocument"/>', content:'<g:message
                                    code="project.survey.info.dataManagementPolicyDocument.content"/>'}">
                                <i class="fas fa-info-circle"></i>
                            </a>

                        </div>

                        <div class="col-12 col-md-7">
                            <div class="media">
                                <img class="media-object"
                                     data-bind="attr:{src: transients.getFileTypeForDataManagementDocument()}">

                                <div class="media-body">
                                    <h5></h5>
                                    <a data-bind="text: transients.getFileNameForDataManagementDocument(), click: showDocument"
                                       data-document="management" href="#"></a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- /ko -->
                </div>
            </div>
        </div>
    </div>
    <!-- ko if: $parent.projectActivities() && $parent.projectActivities().length -->
    <hr/>
    <!-- /ko -->
    <!-- /ko -->
    <!-- /ko -->

</div>



<!-- /ko -->

<asset:script type="text/javascript">

    function initialiseProjectActivitiesList(pActivitiesVM){
        var pActivitiesListVM = new ProjectActivitiesListViewModel(pActivitiesVM);
        ko.applyBindings(pActivitiesListVM, document.getElementById('pActivitiesList'));
    };

</asset:script>