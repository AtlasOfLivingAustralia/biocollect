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
                                <div class="span3" data-bind="css: spatialAccuracy">
                                    <g:message code="project.survey.info.spatialAccuracy.text"/> - <!-- ko text: spatialAccuracy --> <!-- /ko -->
                                </div>
                                <div class="span3" data-bind="css: speciesIdentification">
                                    <g:message code="project.survey.info.speciesIdentification.text"/> - <!-- ko text: speciesIdentification --> <!-- /ko -->
                                </div>
                                <div class="span3" data-bind="css: temporalAccuracy">
                                    <g:message code="project.survey.info.temporalAccuracy.text"/> - <!-- ko text: temporalAccuracy --> <!-- /ko -->
                                </div>
                                <div class="span3" data-bind="css: nonTaxonomicAccuracy">
                                    <g:message code="project.survey.info.nonTaxonomicAccuracy.text"/> - <!-- ko text: nonTaxonomicAccuracy --> <!-- /ko -->
                                </div>
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
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: attribution"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    %{-- todo : public access to data--}%
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.publicAccess"/>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: transients.publicAccess"></span>
                                                        </div>
                                                    </div>

                                                    <!-- ko if: dataAccessMethod -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataAccessMethod"/>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: dataAccessMethod"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: dataAccessExternalURL -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataAccessExternalURL"/>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: dataAccessExternalURL"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    %{-- todo: last updated--}%
                                                    %{-- todo: Number of data recording events in the dataset--}%
                                                    %{-- todo: Number of species records in the dataset--}%

                                                    <!-- ko if: dataSharingLicense -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataSharingLicense"/>
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
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: transients.isDataManagementPolicyDocumented"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: isDataManagementPolicyDocumented() && dataManagementPolicyDescription() -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataManagementPolicyDescription"/>
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
                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="href: dataManagementPolicyURL, text: dataManagementPolicyURL"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    %{-- todo : dataManagementPolicyDocument --}%

                                                    <!-- ko if: dataQualityAssuranceMethod -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataQualityAssuranceMethod"/>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: dataQualityAssuranceMethod"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: dataQualityAssuranceDescription -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.dataQualityAssuranceDescription"/>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: dataQualityAssuranceDescription"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->

                                                    <!-- ko if: methodName -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodName"/>
                                                        </div>
                                                        <div class="span8">
                                                            <span data-bind="text: methodName"></span>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->


                                                    <!-- ko if: methodAbstract -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.methodAbstract"/>
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
                                                        </div>
                                                        <div class="span8">
                                                            <a data-bind="href: methodUrl, text: methodUrl"></a>
                                                        </div>
                                                    </div>
                                                    <!-- /ko -->


                                                    %{--<!-- ko if: methodDoc -->--}%
                                                    %{--<div class="row-fluid">--}%
                                                        %{--<div class="span4">--}%
                                                            %{--<g:message code="project.survey.info.methodDoc"/>--}%
                                                        %{--</div>--}%
                                                        %{--<div class="span8">--}%
                                                            %{--<a data-bind="text: methodDoc, href: methodDoc"></a>--}%
                                                        %{--</div>--}%
                                                    %{--</div>--}%
                                                    %{--<!-- /ko -->--}%

                                                    <!-- ko if: usageGuide -->
                                                    <div class="row-fluid">
                                                        <div class="span4">
                                                            <g:message code="project.survey.info.usageGuide"/>
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
                            </div>
                            <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                                <h4>SURVEY</h4>
                                <h4>ENDED</h4>
                            </div>
                            <div class="dayscount" data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() < 0">
                                <img src="${asset.assetPath(src:'infinity.png')}" />
                                <h4>SURVEY</h4>
                                <h4>ONGOING</h4>
                            </div>
                            <div class="dayscount" data-bind="visible:transients.daysSince() < 0">
                                <h4>STARTS IN</h4>
                                <h2 data-bind="text:-transients.daysSince()"></h2>
                                <h4>DAYS</h4>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div class="survey-row-layout survey-add-record">
                            <div><a href="#" class="btn btn-success btn-sm" data-bind="click: addActivity, visible: $parent.userCanEdit($data)" title="Click to add a record to this survey"> Add a record</a></div>
                            <div class="margin-top-1"><a href="#" class="btn btn-info btn-sm" data-bind="click: listActivityRecords" title="Click to view existing records from this survey"> View records</a></div>
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