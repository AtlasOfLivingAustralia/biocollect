<g:render template="/aekosSubmission/aekosWorkflowModal"/>
<!-- ko stopBinding: true -->
<div class="container-fluid" id="pActivitiesList">

    <!-- ko if: projectActivities().length == 0 -->
    <div class="row-fluid">
        <div class="span12 text-left">
            <h2>Surveys yet to be published.</h2>
        </div>
    </div>
    <!-- /ko -->


    <!-- ko if: projectActivities().length > 1 -->
    <div class="row-fluid  survey-list-actions">

        <div class="span2">
            <span data-bind="click: toggleFilter" class="btn btn-default btn-small">Sort</span>
        </div>
        <div class="span3">
            <!-- ko if: filter -->
            <label class="muted" for="sort"> Sort by:</label>
            <select id="sort" style="width:50%;" data-bind="options: sortOptions, optionsText:'name', optionsValue:'id', value: sortBy" ></select>
            <!-- /ko -->
        </div>
        <div class="span3">
            <!-- ko if: filter -->
            <label class="muted" for="sortOrder"> Sort order:</label>
            <select id="sortOrder" style="width:50%;" data-bind="options: sortOrderOptions, optionsText:'name', optionsValue:'id', value: sortOrder" ></select>
            <!-- /ko -->
        </div>

    </div>
    <br><br>
    <!-- /ko -->
    <g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>

    <table data-table-list class="survey-finder-table">
        <tbody>
        <!-- ko foreach: projectActivities -->
            <!-- ko if: published() -->
                <tr>
                    <td>
                        <div class="survey-logo survey-row-layout">
                            <img alt="No image" class="image-logo" data-bind="attr:{alt:name, src: transients.logoUrl()}" src="" onload="findLogoScalingClass(this)"/>
                        </div>
                    </td>
                    <td>
                        <div class="survey-row-layout">
                            <!-- ko if: $parent.userCanEdit($data) -->
                            <a href="#" data-bind="click: addActivity" title="Click to add a record for this survey"><span data-bind="text:name" class="survey-listing-title"></span></a>
                            <!-- /ko -->
                            <!-- ko if: !$parent.userCanEdit($data) -->
                            <span data-bind="text:name" class="survey-listing-title"></span>
                            <!-- /ko -->
                            <br/><br/>
                            <div data-bind="text:description"></div>
                            <br/>
                            <div class="row-fluid space-after">
                                <span class="span3" data-bind="css: spatialAccuracy, visible: spatialAccuracy">
                                    <g:message code="project.survey.info.spatialAccuracy.text"/> - <!-- ko text: spatialAccuracy --> <!-- /ko -->
                                </span>
                                <span class="span3" data-bind="css: speciesIdentification, visible: speciesIdentification">
                                    <g:message code="project.survey.info.speciesIdentification.text"/> - <!-- ko text: speciesIdentification --> <!-- /ko -->
                                </span>
                                <span class="span3" data-bind="css: temporalAccuracy, visible: temporalAccuracy">
                                    <g:message code="project.survey.info.temporalAccuracy.text"/> - <!-- ko text: temporalAccuracy --> <!-- /ko -->
                                </span>
                                <span class="span3" data-bind="css: nonTaxonomicAccuracy, visible: nonTaxonomicAccuracy">
                                    <g:message code="project.survey.info.nonTaxonomicAccuracy.text"/> - <!-- ko text: nonTaxonomicAccuracy --> <!-- /ko -->
                                </span>
                            </div>
                            <div class="row-fluid">
                                <div class="span12">
                                    <div class="accordion" id="accordion2">
                                        <div class="accordion-group">
                                            <div class="accordion-heading">
                                                <div class="row-fluid">
                                                    <div class="span8">
                                                        <div data-bind="visible:transients.status()" class="accordion-toggle">
                                                            <span>Status: <span data-bind="text: transients.status"></span></span>
                                                        </div>
                                                    </div>
                                                    <div class="span4 text-right">
                                                        <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion2" href="#collapseOne">
                                                            Show more
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                            <div id="collapseOne" class="accordion-body collapse">
                                                <div class="accordion-inner">
                                                    <!-- ko if: attribution -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.attribution"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.attribution"/>', content:'<g:message code="project.survey.info.attribution.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: attribution"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: transients.activityCount -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.activityCount"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.activityCount"/>', content:'<g:message code="project.survey.info.activityCount.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: transients.activityCount"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: transients.speciesRecorded -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.speciesRecorded"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.speciesRecorded"/>', content:'<g:message code="project.survey.info.speciesRecorded.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: transients.speciesRecorded"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.publicAccess"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.publicAccess"/>', content:'<g:message code="project.survey.info.publicAccess.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: transients.publicAccess"></span>
                                                        </div>
                                                    </div>

                                                    <!-- ko if: dataAccessMethod -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataAccessMethod"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataAccessMethod"/>', content:'<g:message code="project.survey.info.dataAccessMethod.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <g:each in="${grailsApplication.config.dataAccessMethods}" var="daMethod">
                                                                <!-- ko if: dataAccessMethod() === '${daMethod}' -->
                                                                <div>
                                                                    <g:message code="project.facets.dataAccessMethod.${daMethod}"/>
                                                                </div>
                                                                <!-- /ko -->
                                                            </g:each>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: dataAccessExternalURL -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataAccessExternalURL"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataAccessExternalURL"/>', content:'<g:message code="project.survey.info.dataAccessExternalURL.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="attr: {href: dataAccessExternalURL}, text: dataAccessExternalURL" target="_blank"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: transients.activityLastUpdated -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.lastUpdated"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.lastUpdated"/>', content:'<g:message code="project.survey.info.lastUpdated.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: moment(transients.activityLastUpdated).format('DD MMMM, YYYY')"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: dataSharingLicense -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataSharingLicense"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataSharingLicense"/>', content:'<g:message code="project.survey.info.dataSharingLicense.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <g:each in="${licences}">
                                                                <span data-bind="visible: dataSharingLicense() == '${it.url}'"><a href="${it.url}" target="_blank"><img src="${asset.assetPath(src:"licence/${it.logo}")} ">&nbsp;&nbsp;${it.name}</a> </span>
                                                            </g:each>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: legalCustodianOrganisation -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.legalCustodian"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.legalCustodian"/>', content:'<g:message code="project.survey.info.legalCustodian.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: legalCustodianOrganisation"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: transients.isDataManagementPolicyDocumented -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.isDataManagementPolicyDocumented"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.isDataManagementPolicyDocumented"/>', content:'<g:message code="project.survey.info.isDataManagementPolicyDocumented.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <!-- ko if: isDataManagementPolicyDocumented() -->
                                                            <span>
                                                                <g:message code="project.facets.isDataManagementPolicyDocumented.yes"/>
                                                            </span>
                                                            <!-- /ko -->
                                                            <!-- ko ifnot: isDataManagementPolicyDocumented() -->
                                                            <span>
                                                                <g:message code="project.facets.isDataManagementPolicyDocumented.no"/>
                                                            </span>
                                                            <!-- /ko -->
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: isDataManagementPolicyDocumented() && dataManagementPolicyDescription() -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataManagementPolicyDescription"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataManagementPolicyDescription"/>', content:'<g:message code="project.survey.info.dataManagementPolicyDescription.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: dataManagementPolicyDescription"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: isDataManagementPolicyDocumented() && dataManagementPolicyURL() -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataManagementPolicyURL"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataManagementPolicyURL"/>', content:'<g:message code="project.survey.info.dataManagementPolicyURL.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="attr: {href: dataManagementPolicyURL}, text: dataManagementPolicyURL" target="_blank"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: dataManagementPolicyDocument -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataManagementPolicyDocument"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataManagementPolicyDocument"/>', content:'<g:message code="project.survey.info.dataManagementPolicyDocument.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="attr: {href: transients.dataManagementPolicyDocumentURL}, text: transients.dataManagementPolicyDocumentURL" target="_blank"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->


                                                    <!-- ko if: dataQualityAssuranceMethods -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataQualityAssuranceMethod"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataQualityAssuranceMethod"/>', content:'<g:message code="project.survey.info.dataQualityAssuranceMethod.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <g:each in="${grailsApplication.config.dataQualityAssuranceMethods}" var="dqMethod">
                                                                <!-- ko if: dataQualityAssuranceMethods().indexOf('${dqMethod}') > -1 -->
                                                                <div>
                                                                    <g:message code="project.facets.dataQualityAssuranceMethod.${dqMethod}"/>
                                                                </div>
                                                                <!-- /ko -->
                                                            </g:each>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: dataQualityAssuranceDescription -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataQualityAssuranceDescription"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.dataQualityAssuranceDescription"/>', content:'<g:message code="project.survey.info.dataQualityAssuranceDescription.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: dataQualityAssuranceDescription"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: methodType -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodType"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodType"/>', content:'<g:message code="project.survey.info.methodType.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <g:each in="${grailsApplication.config.methodType}" var="type">
                                                                <!-- ko if: methodType() === '${type}' -->
                                                                <div><g:message code="project.facets.methodType.${type}"/></div>
                                                                <!-- /ko -->
                                                            </g:each>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: methodName -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodName"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodName"/>', content:'<g:message code="project.survey.info.methodName.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: methodName"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: transients.isSystematicSurvey -->
                                                    <!-- ko if: methodAbstract -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodAbstract"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodAbstract"/>', content:'<g:message code="project.survey.info.methodAbstract.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: methodAbstract"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: methodUrl -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodUrl"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodUrl"/>', content:'<g:message code="project.survey.info.methodUrl.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="attr: {href: methodUrl}, text: methodUrl"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->


                                                    <!-- ko if: methodDocUrl -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodDoc"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.methodDoc"/>', content:'<g:message code="project.survey.info.methodDoc.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="text: methodDocName, attr: {href: methodDocUrl}" target="_blank"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->
                                                    <!-- /ko -->

                                                    <!-- ko if: usageGuide -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.usageGuide"/>
                                                            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.info.usageGuide"/>', content:'<g:message code="project.survey.info.usageGuide.content"/>'}">
                                                                <i class="icon-question-sign"></i>
                                                            </a>

                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: usageGuide"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <g:if test="${grailsApplication.config.aekosEnabled? Boolean.parseBoolean(grailsApplication.config.aekosEnabled): false}">

                                <br/>
                                <br/>
                                <div data-bind="visible: transients.showAekosDetailsState">
                                    <div class="table-responsive">
                                        <span style="color: #f85e20"><b>Submission to AEKOS</b></span>
                                        <br/>
                                        <table class="table" data-toggle="table" data-striped="true">
                                            <thead style="color: #1B82C6">
                                                <tr>
                                                    <td>
                                                        <g:message code="project.survey.info.submissionPublicationDate"/>
                                                        <a href="#" class="helphover"
                                                           data-bind="popover: {title:'<g:message code="project.survey.info.submissionPublicationDate"/>',
                                                                                content:'<g:message code="project.survey.info.submissionPublicationDate.content"/>'}">
                                                            <i class="icon-question-sign"></i>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <g:message code="project.survey.info.submitter"/>
                                                        <a href="#" class="helphover"
                                                           data-bind="popover: {title:'<g:message code="project.survey.info.submitter"/>',
                                                                                content:'<g:message code="project.survey.info.submitter.content"/>'}">
                                                            <i class="icon-question-sign"></i>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <g:message code="project.survey.info.datasetVersion"/>
                                                        <a href="#" class="helphover"
                                                           data-bind="popover: {title:'<g:message code="project.survey.info.datasetVersion"/>',
                                                                                content:'<g:message code="project.survey.info.datasetVersion.content"/>'}">
                                                            <i class="icon-question-sign"></i>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <g:message code="project.survey.info.submissionId"/>
                                                        <a href="#" class="helphover"
                                                           data-bind="popover: {title:'<g:message code="project.survey.info.submissionId"/>',
                                                                                content:'<g:message code="project.survey.info.submissionId.content"/>'}">
                                                            <i class="icon-question-sign"></i>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <g:message code="project.survey.info.submissionDoi"/>
                                                        <a href="#" class="helphover"
                                                           data-bind="popover: {title:'<g:message code="project.survey.info.submissionDoi"/>',
                                                                                content:'<g:message code="project.survey.info.submissionDoi.content"/>'}">
                                                            <i class="icon-question-sign"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <!-- ko foreach: submissionRecords -->
                                                    <tr style="border-bottom: none !important;">
                                                        <td><span data-bind="text: displayDate()"></span></td>
                                                        <td><span data-bind="text: datasetSubmitterUser() ? datasetSubmitterUser().displayName : ''"></span></td>
                                                        <td><span data-bind="text: datasetVersion"></span></td>
                                                        <td><span data-bind="text: submissionId"></span></td>

                                                        <!-- ko if: submissionDoi() == 'Draft' || submissionDoi() == 'Pending' || submissionDoi() == 'Cancelled' -->
                                                            <td><span data-bind="text: submissionDoi"></span></td>
                                                        <!-- /ko -->
                                                        <!-- ko ifnot: submissionDoi() == 'Draft' || submissionDoi() == 'Pending' || submissionDoi() == 'Cancelled' -->
                                                            <td><a data-bind='attr: { href: "${grailsApplication.config.aekosMintedDoi.url}/" + submissionId(),
                                                                              title:  "${grailsApplication.config.aekosMintedDoi.url}/" + submissionId()}', target="_blank"><span data-bind="text: submissionDoi"></span></a></td>
                                                        <!-- /ko -->
                                                    </tr>
                                                <!-- /ko -->
                                            </tbody>
                                        </table>

                                    </div>

                                    <g:if test="${grailsApplication.config.aekosSubmission?.url? true: false}">
                                    <div>
                                        <br/>
                                        <!-- ko if: $parent.userIsAdmin() -->
                                        <span><a href="#" data-bind="click:function() {showAekosModal($parent.projectActivities, $parent.currentUser, $parent.vocabList, $parent.projectArea);}"
                                                 class="btn btn-success btn-sm">Submit current version to AEKOS</a></span>
                                        <!-- /ko -->
                                    </div>
                                    </g:if>
                                </div>
                            </g:if>
                        </div>

                    </td>
                    <td>
                        <div class="survey-row-layout">
                            <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() > 0">
                                <h2 data-bind="text:transients.daysRemaining"></h2>
                                <h4>DAYS TO GO</h4>
                                <div class="header-dates" data-bind="visible: startDate">
                                    Start date:
                                    <!-- ko text: moment(startDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                                <div class="header-dates" data-bind="visible: endDate">
                                    End date:
                                    <!-- ko text: moment(endDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                            </div>
                            <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                                <h4>SURVEY</h4>
                                <h4>ENDED</h4>
                                <div class="header-dates" data-bind="visible: startDate">
                                    Start date:
                                    <!-- ko text: moment(startDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                                <div class="header-dates" data-bind="visible: endDate">
                                    End date:
                                    <!-- ko text: moment(endDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                            </div>
                            <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
                                <h4>SURVEY</h4>
                                <h4>ONGOING</h4>
                                <div class="header-dates" data-bind="visible: startDate">
                                    Start date:
                                    <!-- ko text: moment(startDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                                <div class="header-dates" data-bind="visible: endDate">
                                    End date:
                                    <!-- ko text: moment(endDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                            </div>
                            <div class="dayscount" data-bind="visible:transients.daysSince() < 0">
                                <h4>STARTS IN</h4>
                                <h2 data-bind="text:-transients.daysSince()"></h2>
                                <h4>DAYS</h4>
                                <div class="header-dates" data-bind="visible: startDate">
                                    Start date:
                                    <!-- ko text: moment(startDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                                <div class="header-dates" data-bind="visible: endDate">
                                    End date:
                                    <!-- ko text: moment(endDate()).format('DD MMMM, YYYY') --> <!-- /ko -->
                                </div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div class="survey-row-layout survey-add-record">
                            <div><button class="btn btn-success btn-sm" data-bind="click: addActivity, visible: $parent.userCanEdit($data)" title="Click to add a record to this survey"> Add a record</button></div>
                            <div class="margin-top-1"><button class="btn btn-info btn-sm" data-bind="click: listActivityRecords" title="Click to view existing records from this survey"> View records</button></div>
                            <br><br>
                            %{--<div class="margin-top-1"><a href="#" class="btn btn-primary btn-sm" data-bind="click: bulkDataLoad, visible: $parent.userCanEdit($data)" title="Opens bulk data loading page"> Load Data</a></div>--}%
                            <div><a data-bind="attr: { href: downloadFormTemplateUrl, title: 'Download survey form template for bulk data upload (.xlsx)', target: pActivityFormName }"  >
                                Download form template (.xlsx)
                            </a></div>
                            <g:if test="${grailsApplication.config.aekosEnabled? Boolean.parseBoolean(grailsApplication.config.aekosEnabled): false}">
                                <br><br><br>
                                <div><a href="#" data-bind="visible: transients.isAekosData,
                                                            click: showAekosDetails,
                                                            text: transients.aekosToggleText"
                                        title="View and send Data Submission to AEKOS"></a>
                                </div>
                            </g:if>
                        </div>
                    </td>
                </tr>

            <!-- /ko -->
        <!-- /ko -->
        </tbody>
    </table>

</div>



<!-- /ko -->

<asset:script type="text/javascript">

    function initialiseProjectActivitiesList(pActivitiesVM){
        var pActivitiesListVM = new ProjectActivitiesListViewModel(pActivitiesVM);
        ko.applyBindings(pActivitiesListVM, document.getElementById('pActivitiesList'));
    };

</asset:script>