<%@ page import="grails.converters.JSON" contentType="text/html;charset=UTF-8" %>
<bc:koLoading>
    <div class="card">
        <div class="card-body">
            <h4 class="card-title">
                Project metadata
                <span class="float-right">
                    <g:if test="${project.projLifecycleStatus == 'published'}">
                        <span class="badge badge-success">Published</span>
                    </g:if>
                    <g:elseif test="${project.projLifecycleStatus == 'unpublished'}">
                        <span class="badge badge-info">Draft</span>
                    </g:elseif>
                </span>
            </h4>
            <div class="row form-group">
            <label class="col-from-label col-md-4"><g:message code="project.details.type"/><fc:iconHelp><g:message
                    code="project.details.type.help"/></fc:iconHelp><i class="req-field"></i></label>

            <div class="col-md-8">
                <select class="form-control"
                        data-bind="value:transients.kindOfProject, options:transients.availableProjectTypes, optionsText:'name', optionsValue:'value', optionsCaption:'Select...'"
                        <g:if test="${params.citizenScience || params.works || params.ecoScience}">disabled</g:if>
                        data-validation-engine="validate[required]"></select>
            </div>
        </div>

            <div class="row form-group" data-bind="visible:!isWorks()">

            <label class="col-from-label col-md-4" for="isExternal"><g:message
                    code="project.details.useALA"/><fc:iconHelp><g:message
                    code="project.details.useALA.help"/></fc:iconHelp><i class="req-field"></i></label>

            <div class="col-md-8">
                <select class="form-control" id="isExternal"
                        data-bind="booleanValue:isExternal, options:[{label:'Yes', value:'false'}, {label:'No', value:'true'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'"
                        data-validation-engine="validate[required]">
                </select>
            </div>
        </div>

            <div id="organisationSearch" data-bind="with: organisationSearch">
            <div class="row form-group">
                <label class="col-from-label col-md-4"><g:message
                        code="project.details.organisationNameSearch"/><fc:iconHelp><g:message
                        code="project.details.organisationName.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="col-md-8">
                    <div class="input-group">
                        <input class="form-control" id="searchText1"
                               data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup', disable: selection"
                               class="form-control" placeholder="Start typing a name here..." type="text"
                               data-validation-engine="validate[funcCall[validateOrganisationSelection]]"/>

                        <div class="input-group-append">
                            <button class="btn" type="button" data-bind="click:clearSelection, css: {'btn-dark': !searchTerm(), 'btn-danger': searchTerm()}"><i
                                    class='fas fa-search'
                                    data-bind="css:{'fas fa-search':!searchTerm(), 'far fa-trash-alt':searchTerm()}"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div data-bind="slideVisible:displayNavigationControls()">
                <div class="row form-group">
                    <div class="col-md-4"></div>

                    <div class="col-md-8">
                        <div><b>Organisation Search Results</b> (Click an organisation to select it)</div>

                        <div class="organisation-list">
                            <ul class="list-unstyled ml-2">
                                <!-- ko foreach : organisations -->
                                <li data-bind="css:{active:$parent.isSelected($data)}"><a class="btn btn-link text-left"
                                                                                          data-bind="click:$parent.select, text:name"></a>
                                </li>
                                <!-- /ko -->
                            </ul>
                        </div>

                        <div class="mt-2">
                            <g:render template="/shared/pagination" model="[bs: 4, classes: 'm-2']"/>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4"></div>

                    <div class="col-md-8">
                        <div class="custom-checkbox d-inline-block">
                            <input type="checkbox" id="organisationNotPresent" value="organisationNotOnList"
                                   data-bind="checked:organisationNotPresent, enable:displayNavigationControls() && allViewed()">
                            <label for="organisationNotPresent">
                                <g:message code="project.details.organisation.notInList"/>
                                <fc:iconHelp><g:message
                                        code="project.details.organisation.notInList.help"/></fc:iconHelp>
                            </label>
                        </div>

                        <div class="d-inline-block" style="display:none;"
                             data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                            <button class="btn btn-primary-dark"
                                    data-bind="enable: !selection() && allViewed() && organisationNotPresent(), click:function() {$parent.createOrganisation();}"><i
                                    class="fas fa-plus"></i> Register my organisation</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>

    <div class="card mt-3" data-bind="visible:isCitizenScience() || isEcoScience() || !isExternal()">
        <div class="card-body">
            <h4 class="card-title"><g:message code="project.details.tell"/></h4>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="name"><g:message
                        code="project.details.name"/><fc:iconHelp><g:message
                        code="project.details.name.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="col-md-8">
                    <g:textField class="form-control" name="name" data-bind="value:name"
                                 data-validation-engine="validate[required]"/>
                </div>
            </div>

            <div data-bind="visible:!isWorks()" class="row form-group">
                <label class="col-from-label col-md-4" for="aim"><g:message
                        code="project.details.aim"/><fc:iconHelp><g:message
                        code="project.details.aim.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="col-md-8">
                    <g:textArea class="form-control" name="aim" data-bind="value:aim"
                                data-validation-engine="validate[required]" maxlength="300" rows="3"/>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="description"><g:message
                        code="project.details.description"/><fc:iconHelp><g:message
                        code="project.details.description.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="col-md-8">
                    <g:textArea class="form-control" name="description" data-bind="value:description"
                                data-validation-engine="validate[required]" rows="3"/>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="manager"><g:message
                        code="project.details.manager"/><fc:iconHelp><g:message
                        code="project.details.manager.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textField class="form-control" type="email" data-bind="value:manager" name="manager"/>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="managerEmail"><g:message
                        code="project.details.managerEmail"/><fc:iconHelp><g:message
                        code="project.details.managerEmail.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textField class="form-control" type="text" data-bind="value:managerEmail" name="managerEmail"/>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="plannedStartDate"><g:message
                        code="project.details.plannedStartDate"/>
                    <fc:iconHelp><g:message code="project.details.plannedStartDate.help"/></fc:iconHelp><i
                        class="req-field"></i></label>

                <div class="col-12 col-md-4 col-xl-3">
                    <div class="input-group">
                        <fc:datePicker class="form-control" targetField="plannedStartDate.date" name="plannedStartDate"
                                       id="plannedStartDate" data-validation-engine="validate[required]" bs4="true"
                                       theme="btn-dark"/>
                    </div>
                </div>
            </div>

            <div class="row form-group" data-bind="visible:!isWorks()">
                <label class="col-from-label col-md-4" for="plannedEndDate"><g:message
                        code="project.details.plannedEndDate"/>
                <fc:iconHelp><g:message code="project.details.plannedEndDate.help"/></fc:iconHelp>
                </label>

                <div class="col-12 col-md-5 col-xl-4">
                    <div class="input-group">
                        <fc:datePicker class="form-control" targetField="plannedEndDate.date" name="plannedEndDate"
                                       clearBtn="true"
                                       id="plannedEndDate" data-validation-engine="validate[future[plannedStartDate]]"
                                       bs4="true" theme="btn-dark"/>
                    </div>
                    <small id="emailHelp" class="form-text text-muted"><g:message
                            code="project.details.plannedEndDate.extra"/></small>
                </div>
            </div>

            <div class="row form-group" data-bind="visible:isWorks()">
                <label class="col-from-label col-md-4" for="plannedEndDate"><g:message
                        code="project.details.plannedEndDate"/>
                    <fc:iconHelp><g:message code="project.details.plannedEndDate.help"/></fc:iconHelp><i
                        class="req-field"></i>
                </label>

                <div class="col-12 col-md-4 col-xl-2">
                    <div class="input-group">
                        <fc:datePicker class="form-control" targetField="plannedEndDate.date" name="plannedEndDate"
                                       id="plannedEndDate"
                                       data-validation-engine="validate[required,future[plannedStartDate]]"
                                       data-errormessage-value-missing="Works projects must have an end date" bs4="true"
                                       theme="btn-dark"/>
                    </div>
                </div>
            </div>


            <div id="associatedOrgs">
                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="associatedOrgList">
                        <g:message code="project.details.associatedOrgs"/>:
                        <fc:iconHelp><g:message code="project.details.associatedOrgs.help"/></fc:iconHelp>
                    </label>

                    <div class="col-md-8">
                        <p><g:message code="project.details.associatedOrgs.extra"/></p>

                        <div id="associatedOrgList">
                            <g:set var="noImageUrl" value="${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}"/>
                            <!-- ko foreach: associatedOrgs -->
                            <div class="row">
                                <div class="col-4" data-bind="text: name"></div>

                                <div class="col-4 d-flex justify-content-center align-content-center">
                                    <!-- ko if: logo -->
                                        <img src="" data-bind="attr: {src: logo}" alt="Organisation logo"
                                             class="small-logo" onerror="imageError(this, '${noImageUrl}');"
                                             onload="addClassForImage(this, '${noImageUrl}', 'w-25')">
                                    <!-- /ko -->
                                </div>

                                <div class="col-4">
                                    <a href="#" data-bind="click: $parent.removeAssociatedOrganisation"
                                       class="btn btn-danger">
                                        <i class="far fa-trash-alt"></i>
                                        <g:message code="project.details.associatedOrgs.remove"/>
                                    </a>
                                </div>
                            </div>
                            <!-- /ko -->
                        </div>
                    </div>
                </div>

                <div data-bind="with: associatedOrganisationSearch">
                    <div id="addAssociatedOrgPanel">
                        <div class="row form-group">
                            <label class="col-form-label col-md-4"
                                   for="associatedOrgName"><g:message
                                    code="project.details.associatedOrgs.name"/><i class="req-field"
                                                                                   data-bind="visible: $parent.transients.associatedOrgNotInList()"></i>
                            </label>

                            <div class="col-md-8">
                                <div class="input-group">
                                    <input id="associatedOrgName" class="form-control" type="text"
                                           placeholder="Start typing a name here" maxlength="256"
                                           data-validation-engine="validate[condRequired[associatedOrgNotPresent],maxSize[256]]"
                                           data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup'">

                                    <div class="input-group-append">
                                        <button
                                                class="btn" type="button" data-bind="click:clearSelection, css: {'btn-dark': !searchTerm(), 'btn-danger': searchTerm()}">
                                            <i
                                                    class='fas fa-search'
                                                    data-bind="css:{'fas fa-search':!searchTerm(), 'far fa-trash-alt':searchTerm()}"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="organisation-search" data-bind="slideVisible: navigationShouldBeVisible()">
                            <div data-bind="slideVisible: !$parent.transients.associatedOrgNotInList()">
                                <div class="row form-group">
                                    <div class="col-md-4"></div>

                                    <div class="col-md-8">
                                        <p>
                                            <b>Organisation Search Results</b> (Click an organisation to select it)
                                        </p>

                                        <div class="organisation-list">
                                            <ul class="list-unstyled ml-1">
                                                <!-- ko foreach : organisations -->
                                                <li data-bind="css:{active:$parent.isSelected($data)}">
                                                    <a class="btn btn-link text-left"
                                                       data-bind="click:$parent.select, text:name"></a>
                                                </li>
                                                <!-- /ko -->
                                            </ul>
                                        </div>

                                        <g:render template="/shared/pagination" model="[bs: 4, classes: 'my-1']"/>
                                    </div>
                                </div>
                            </div>

                            <div class="row form-group">
                                <div class="col-md-4"></div>

                                <div class="col-md-8">
                                    <div class="custom-checkbox">
                                        <input type="checkbox" id="associatedOrgNotPresent"
                                               value="organisationNotOnList"
                                               data-bind="checked: $parent.transients.associatedOrgNotInList, enable:displayNavigationControls() && allViewed()"/>
                                        <label class="form-check-label" for="associatedOrgNotPresent">
                                            <g:message code="project.details.associatedOrgs.notInList"/>&nbsp;
                                            <fc:iconHelp><g:message
                                                code="project.details.organisation.notInList.help"/></fc:iconHelp>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="row form-group" data-bind="visible: $parent.transients.associatedOrgNotInList()">
                                <div class="col-md-4"></div>

                                <div class="col-md-8">
                                    <p>
                                        <g:message code="project.details.associatedOrgs.notInList.extra"/>
                                    </p>

                                    <div class="row form-group">
                                        <label class="col-form-label col-md-4"
                                               for="associatedOrgUrl"><g:message
                                                code="project.details.associatedOrgs.url"/></label>

                                        <div class="col-md-8">
                                            <input id="associatedOrgUrl" class="form-control" type="text"
                                                   data-bind="value: $parent.transients.associatedOrgUrl">
                                        </div>
                                    </div>

                                    <div class="row form-group">
                                        <label class="col-form-label col-md-4"
                                               for="associatedOrgLogo"><g:message
                                                code="project.details.associatedOrgs.logo"/></label>

                                        <div class="col-md-8">
                                            <input id="associatedOrgLogo" class="form-control" type="text"
                                                   data-validation-engine="validate[custom[httpsUrl]]"
                                                   data-bind="value: $parent.transients.associatedOrgLogoUrl">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row form-group">
                                <div class="offset-md-4 col-md-8">
                                    <div id="orgAlreadyAddedMessage"></div>
                                </div>
                            </div>

                            <div class="row form-group">
                                <div class="offset-md-4 col-md-8">
                                    <button class="btn btn-primary-dark"
                                            data-bind="click: addSelectedOrganisation, enable: selection() || searchTerm() && $parent.transients.associatedOrgNotInList() ">
                                        <i class="fas fa-plus"></i><g:message
                                            code="project.details.associatedOrgs.add"/></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <config:optionalContent key="${au.org.ala.biocollect.merit.hub.HubSettings.CONTENT_INDUSTRIES}">
                    <div class="row form-group">
                            <label class="col-from-label col-md-4"><g:message
                                    code="project.details.industries.label"/>:<fc:iconHelp><g:message
                                    code="project.details.industries.help"/></fc:iconHelp></label>

                            <div class="col-md-8">
                                <!-- ko foreach: transients.industries -->
                                <!-- ko template: { name:'industryTemplate'} -->
                                <!-- /ko -->
                                <!-- /ko -->
                            </div>
                    </div>
                </config:optionalContent>

                <g:if test="${!hubConfig.content?.hideProjectEditCountries}">
                    <div class="row form-group">
                            <label class="col-from-label col-md-4" for="associatedOrgList"><g:message
                                    code="project.details.countries.label"/>:<fc:iconHelp><g:message
                                    code="project.details.countries.help"/></fc:iconHelp><i class="req-field"></i></label>

                            <div class="col-md-8">
                                <div class="row">
                                    <div class="col-md-4">
                                        <!-- ko foreach: countries -->
                                        <div class="row mb-1">
                                            <div class="col-12">
                                                <div class="input-group">
                                                    <input data-bind="value: $data" readonly>
                                                    <div class="input-group-append">
                                                        <a class="btn btn-danger btn-sm" href="#" data-bind="click: $root.transients.removeCountry">
                                                            <i class="far fa-trash-alt"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- /ko -->
                                        <select class="form-control" id="countries"
                                                data-bind="options: $root.transients.countries, event:{change: $root.transients.selectCountry}, optionsCaption: '<g:message
                                                        code="project.details.countries.placeholder"/>'"></select>
                                    </div>

                                    <div class="col-md-8">
                                        <div class="row form-group">
                                            <label class="col-from-label col-md-3"><g:message
                                                        code="project.details.uNRegions.label"/>:<fc:iconHelp><g:message
                                                        code="project.details.uNRegions.help"/></fc:iconHelp><i
                                                        class="req-field"></i></label>

                                                <div class="col-md-9">
                                                    <!-- ko foreach: uNRegions -->
                                                    <div class="row mb-1">
                                                        <div class="col-12">
                                                        <div class="input-group">
                                                            <input data-bind="value: $data" readonly>
                                                            <div class="input-group-append">
                                                                <a class="btn btn-danger btn-sm" href="#" data-bind="click: $root.transients.removeUNRegion">
                                                                    <i class="far fa-trash-alt"></i>
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    </div>
                                                    <!-- /ko -->
                                                    <select class="form-control" id="uNRegionsId"
                                                            data-bind="options: $root.transients.uNRegions, event:{change: $root.transients.selectUNRegion}, optionsCaption: '<g:message
                                                                    code="project.details.uNRegions.placeholder"/>'"></select>
                                                </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                    </div>
                </g:if>
                <g:if test="${hubConfig.content?.showIndigenousCulturalIPMetadata}">
                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="indigenousCulturalIP"><g:message
                            code="project.details.indigenousCulturalIP"/><fc:iconHelp><g:message
                            code="project.details.indigenousCulturalIP.help"/></fc:iconHelp><i class="req-field"></i></label>

                    <div class="col-md-8">
                        <select class="form-control" id="indigenousCulturalIP"
                                data-bind="value:customMetadata.indigenousCulturalIP" data-validation-engine="validate[required]">
                            <option value="">Please Select</option>
                            <option value="Yes">Yes</option>
                            <option value="No">No</option>
                            <option value="Not Applicable">Not Applicable</option>
                        </select>
                    </div>
                </div>

                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="ethicsApproval"><g:message
                            code="project.details.ethicsApproval"/></label>

                    <div class="col-md-8">
                        <select class="form-control" id="ethicsApproval"
                                data-bind="value:customMetadata.ethicsApproval">
                            <option value="">Please Select</option>
                            <option value="Yes">Yes</option>
                            <option value="No">No</option>
                            <option value="Exempt">Exempt</option>
                        </select>
                    </div>
                </div>

                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="ethicsNumber"><g:message
                            code="project.details.ethicsNumber"/></label>

                    <div class="col-md-8">
                        <input type="text" class="form-control" id="ethicsNumber"
                               data-bind="value:customMetadata.ethicsApprovalNumber"
                               placeholder="Ethics Approval Number  (if available)"/>
                    </div>
                </div>

                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="ethicsContact"><g:message
                            code="project.details.ethicsContact"/></label>

                    <div class="col-md-8">
                        <input type="text" class="form-control" id="ethicsContact"
                               data-bind="value:customMetadata.ethicsContactDetails"
                               placeholder="Ethics office contact details (if available)"/>
                    </div>
                </div>
                </g:if>

                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="bushfire"><g:message
                            code="project.details.bushfire"/><fc:iconHelp><g:message
                            code="project.details.bushfire.help"/></fc:iconHelp></label>

                    <div class="col-md-8">
                        <select class="form-control" id="bushfire"
                              data-bind="booleanValue:isBushfire, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Please Select'"></select>
                    </div>
                </div>

                <config:optionalContent key="${au.org.ala.biocollect.merit.hub.HubSettings.CONTENT_BUSHFIRE_CATEGORIES}">
                    <div class="row form-group">
                        <label class="col-from-label col-md-4"><g:message
                                code="project.details.bushfireCategories.label"/>:<fc:iconHelp><g:message
                                code="project.details.bushfireCategories.help"/></fc:iconHelp></label>

                        <div class="col-md-8">
                            <!-- ko foreach: transients.bushfireCategories -->
                            <!-- ko template: { name:'bushfireCategoriesTemplate'} -->
                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                    </div>
                </config:optionalContent>

                <g:if test="${!hubConfig.content?.hideProjectEditScienceTypes}">
                    <div class="row form-group" data-bind="if:isEcoScience()">
                        <label class="col-from-label col-md-4"><g:message
                                code="project.details.scienceType"/><fc:iconHelp><g:message
                                code="project.details.scienceType.help"/></fc:iconHelp></label>

                        <div class="col-md-8">
                            <div class="row">
                                <!-- ko foreach: transients.availableEcoScienceTypes -->
                                <div class="col-12 col-md-4">

                                    <!-- ko template: { name:'ecoScienceTypeTemplate', if: ($index() +1) % 3 == 1 }-->

                                    <!-- /ko -->
                                </div>
                                <!-- /ko -->
                            </div>
                        </div>
                    </div>
                </g:if>
            </div>
        </div>
    </div>

    <div class="card mt-3">
        <div class="card-body">
            <h4 class="card-title"><g:message code="project.details.associations"/></h4>

            <div data-bind="visible:!isCitizenScience() && (isEcoScience() || !isExternal())" class="row form-group">
                <label class="col-from-label col-md-4" for="externalId"><g:message
                        code="project.details.externalId"/><fc:iconHelp><g:message
                        code="project.details.externalId.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textField class="form-control" name="externalId" data-bind="value:externalId"/>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && (isEcoScience() || !isExternal())" class="row form-group">
                <label class="col-from-label col-md-4" for="grantId"><g:message
                        code="project.details.grantId"/><fc:iconHelp><g:message
                        code="project.details.grantId.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textField class="form-control" name="grantId" data-bind="value:grantId"/>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && (isEcoScience() || !isExternal())" class="row form-group">
                <label class="col-from-label col-md-4" for="fundingSourceAmount"><g:message
                        code="project.details.funding"/><fc:iconHelp><g:message
                        code="project.details.funding.help"/></fc:iconHelp></label>

                <div class="col-md-8 table-responsive" name="fundings">
                    <table class="table borderless not-stacked-table">
                        <thead>
                        <td>Funding Source<fc:iconHelp><g:message
                                code="project.details.funding.fundingSource.help"/></fc:iconHelp><i
                                class="req-field"></i></td>
                        <td>Funding Type<fc:iconHelp><g:message
                                code="project.details.funding.fundingType.help"/></fc:iconHelp></td>
                        <td>Funding Amount<fc:iconHelp><g:message
                                code="project.details.funding.fundingSourceAmount.help"/></fc:iconHelp></td>
                        <td>Action</td>
                        </thead>
                        <tbody>
                        <!-- ko foreach: fundings -->
                        <tr>
                            <td><g:textField class="form-control" name="fundingSource" data-bind="value:fundingSource"
                                             data-validation-engine="validate[required]"></g:textField></td>
                            <td><select class="form-control" name="fundingType"
                                        data-bind="options:$parent.fundingTypes,value:fundingType"></select></td>
                            <td><g:field class="form-control"  type="number" step="any" min="0" name="fundingSourceAmount"
                                         data-bind="value:fundingSourceAmount"
                                         data-validation-engine="validate[custom[number]]"></g:field></td>
                            <td><button class="btn btn-danger btn-sm main-image-button" data-bind="click:$parent.removeFunding">
                                <i class="far fa-trash-alt"></i> Remove</button></td>
                        </tr>
                        <!-- /ko -->
                        <tr>
                            <td colspan="2"></td>
                            <td colspan="1">
                                <fc:iconHelp><g:message
                                        code="project.details.funding.fundingTotal.help"/></fc:iconHelp><b>Total amount: <span
                                    name="totalFundingsAmount" data-bind="text:funding.formattedCurrency"/></b>
                            </td>
                        </tr>
                        <tr><td colspan="3"></td>
                            <td colspan="1"><button class="btn btn-primary-dark btn-sm main-image-button" data-bind="click:addFunding">
                                <i class="fas fa-plus"></i> Add funding</button></td></tr>
                        </tbody>
                    </table>

                </div>
            </div>


            <div class="row form-group">
                <label class="col-from-label col-md-4" for="program"><g:message
                        code="project.details.program"/><fc:iconHelp><g:message
                        code="project.details.program.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="col-md-8">
                    <select class="form-control" id="program"
                            data-bind="disable: transients.programs.length == 1,  value:associatedProgram,options:transients.programs,optionsCaption: 'Choose...'"
                            data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="subProgram"><g:message
                        code="project.details.subprogram"/><fc:iconHelp><g:message
                        code="project.details.subprogram.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <select class="form-control" id="subProgram"
                            data-bind="value:associatedSubProgram,options:transients.subprogramsToDisplay,optionsCaption: 'Choose...'"></select>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && !isWorks() && (isEcoScience() || !isExternal()), with: granteeOrganisation">
                <div class="row form-group">
                    <label class="col-from-label col-md-4"><g:message
                            code="project.details.orgGrantee"/><fc:iconHelp><g:message
                            code="project.details.orgGrantee.help"/></fc:iconHelp></label>

                    <div class="col-md-8">
                        <div class="input-group">
                            <input id="searchText2"
                                   data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup', disable: selection"
                                   class="form-control" placeholder="Start typing a name here..." type="text"/>
                            <div class="input-group-append">
                                <button class="btn" type="button" data-bind="click:clearSelection, css: {'btn-dark': !searchTerm(), 'btn-danger': searchTerm()}">
                                    <i class='fas fa-search'
                                        data-bind="css:{'fas fa-search':!searchTerm(), 'far fa-trash-alt':searchTerm()}"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div data-bind="slideVisible:displayNavigationControls()">
                    <div class="row form-group">
                        <div class="col-md-4"></div>

                        <div class="col-md-8">
                            <p><b>Organisation Search Results</b> (Click an organisation to select it)</p>

                            <div class="organisation-list">
                                <ul class="list-unstyled ml-1">
                                    <!-- ko foreach : organisations -->
                                    <li data-bind="css:{active:$parent.isSelected($data)}"><a class="btn btn-link text-left"
                                            data-bind="click:$parent.select, text:name"></a></li>
                                    <!-- /ko -->
                                </ul>
                            </div>

                            <g:render template="/shared/pagination" model="[bs:4, classes: 'my-1']"/>
                        </div>
                    </div>

                    <div class="row form-group">
                        <div class="col-md-4"></div>

                        <div class="col-md-8">
                            <div class="custom-checkbox">
                                <input type="checkbox" id="granteeOrganisationNotPresent" value="organisationNotOnList"
                                       data-bind="checked:organisationNotPresent, enable:displayNavigationControls() && allViewed()"/>
                                <label for="granteeOrganisationNotPresent"><g:message
                                        code="project.details.organisation.notInList"/><fc:iconHelp><g:message
                                        code="project.details.organisation.notInList.help"/></fc:iconHelp></label>
                            </div>

                            <div style="display:none;"
                                 data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                                <button class="btn btn-primary-dark" style="float:right"
                                        data-bind="enable: !selection() && allViewed() && organisationNotPresent(), click:function() {$parent.createOrganisation();}"><i class="fas fa-plus"></i> Register my organisation</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && !isWorks() && (isEcoScience() || !isExternal()), with: sponsorOrganisation">
                <div class="row form-group">
                    <label class="col-from-label col-md-4"><g:message
                            code="project.details.orgSponsor"/><fc:iconHelp><g:message
                            code="project.details.orgSponsor.help"/></fc:iconHelp></label>

                    <div class="col-md-8">
                        <div class="input-group">
                            <input id="searchText3"
                                   data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup', disable: selection"
                                   class="form-control" placeholder="Start typing a name here..." type="text"/>
                            <div class="input-group-append">
                                <button class="btn" type="button" data-bind="click:clearSelection, css: {'btn-dark': !searchTerm(), 'btn-danger': searchTerm()}">
                                    <i class='fas fa-search'
                                        data-bind="css:{'fas fa-search':!searchTerm(), 'far fa-trash-alt':searchTerm()}"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div data-bind="slideVisible:displayNavigationControls()">
                    <div class="row form-group">
                        <div class="col-md-4"></div>

                        <div class="col-md-8">
                            <p><b>Organisation Search Results</b> (Click an organisation to select it)</p>

                            <div class="organisation-list">
                                <ul class="list-unstyled ml-1">
                                    <!-- ko foreach : organisations -->
                                    <li data-bind="css:{active:$parent.isSelected($data)}">
                                        <a class="btn btn-link text-left" data-bind="click:$parent.select, text:name"></a>
                                    </li>
                                    <!-- /ko -->
                                </ul>
                            </div>

                            <g:render template="/shared/pagination" model="[bs:4, classes: 'my-1']"/>
                        </div>
                    </div>

                    <div class="row form-group">
                        <div class="col-md-4"></div>

                        <div class="col-md-8">
                            <div class="custom-checkbox">
                                <input type="checkbox" id="sponsoringOrganisationNotPresent"
                                       value="organisationNotOnList"
                                       data-bind="checked:organisationNotPresent, enable:displayNavigationControls() && allViewed()"/>
                                <label for="sponsoringOrganisationNotPresent"><span></span>&nbsp;<g:message
                                        code="project.details.organisation.notInList"/><fc:iconHelp><g:message
                                        code="project.details.organisation.notInList.help"/></fc:iconHelp></label>
                            </div>

                            <div style="display:none;"
                                 data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                                <button class="btn btn-primary-dark"
                                        data-bind="enable: !selection() && allViewed() && organisationNotPresent(), click:function() {$parent.createOrganisation();}"><i class="fas fa-plus"></i> Register my organisation</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            %{--When is the service provider organisation going to show?--}%
            <div data-bind="visible:!isCitizenScience() && !isWorks() && !isEcoScience()" class="row form-group">
                <label class="col-from-label col-md-4"
                       for="orgSvcProvider"><g:message code="project.details.orgSvcProvider"/></label>

                <div class="col-md-8">
                    <select class="form-control" id="orgSvcProvider"
                            data-bind="options:transients.organisations, optionsText:'name', optionsValue:'uid', value:orgIdSvcProvider, optionsCaption: 'Choose...'"></select>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="if:(isCitizenScience() || !isExternal()) && !isWorks() && !isEcoScience()" class="card mt-3">
        <div class="card-body">
            <h4 class="card-title"><g:message code="project.details.involved"/></h4>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="getInvolved"><g:message
                        code="project.details.involved"/><fc:iconHelp><g:message
                        code="project.details.involved.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textArea class="form-control" name="getInvolved" data-bind="value:getInvolved"
                                rows="2"/>
                </div>
            </div>
            <g:if test="${!hubConfig.content?.hideProjectEditScienceTypes}">
                <div id="scienceTypeControlGroup" class="row form-group">
                    <label class="col-from-label col-md-4"><g:message
                            code="project.details.scienceType"/><fc:iconHelp><g:message
                            code="project.details.scienceType.help"/></fc:iconHelp><i class="req-field"></i></label>

                    <div class="col-md-8">
                        <div class="row form-group">
                            <!-- ko foreach: transients.availableScienceTypes -->
                            <div class="col-12 col-md-4">

                                <!-- ko template: { name:'scienceTypeTemplate' }-->

                                <!-- /ko -->

                            </div>
                            <!-- /ko -->
                        </div>
                    </div>
                </div>
            </g:if>
            <div class="row form-group">
                <label class="col-from-label col-md-4"><g:message
                        code="project.details.difficulty"/><fc:iconHelp><g:message
                        code="project.details.difficulty.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <div class="row form-group">
                        <div class="col-md-4">
                            <select class="form-control" data-bind="value:difficulty, options:transients.difficultyLevels, optionsCaption:'Select...'"></select>
                        </div>

                        <div class="col-md-8">
                            <div class="row form-group">
                                <label class="col-form-label col-md-4" for="isHome"><g:message
                                        code="project.details.isHome"/><fc:iconHelp><g:message
                                        code="project.details.isHome.help"/></fc:iconHelp></label>

                                <div class="col-md-8">
                                    <select class="form-control" id="isHome"
                                            data-bind="booleanValue:isHome, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="hasParticipantCost"><g:message
                        code="project.details.hasParticipantCost"/><fc:iconHelp><g:message
                        code="project.details.hasParticipantCost.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <div class="row form-group">
                        <div class="col-md-4">
                            <select class="form-control" id="hasParticipantCost"
                                    data-bind="booleanValue:hasParticipantCost, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                            </select>
                        </div>

                        <div class="col-md-8">
                            <div class="row form-group">
                                <label class="col-form-label col-md-4" for="isSuitableForChildren"><g:message
                                        code="project.details.isSuitableForChildren"/><fc:iconHelp><g:message
                                        code="project.details.isSuitableForChildren.help"/></fc:iconHelp></label>

                                <div class="col-md-8">
                                    <select class="form-control" id="isSuitableForChildren"
                                            data-bind="booleanValue:isSuitableForChildren, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="hasTeachingMaterials"><g:message
                        code="project.details.hasTeachingMaterials"/><fc:iconHelp><g:message
                        code="project.details.hasTeachingMaterials.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <div class="row form-group">
                        <div class="col-md-4">
                            <select class="form-control" id="hasTeachingMaterials"
                                    data-bind="booleanValue:hasTeachingMaterials, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                            </select>
                        </div>

                        <div class="col-md-8">
                            <div class="row form-group">
                                <label class="col-form-label col-md-4" for="isDIY"><g:message
                                        code="project.details.isDIY"/><fc:iconHelp><g:message
                                        code="project.details.isDIY.help"/></fc:iconHelp></label>

                                <div class="col-md-8">
                                    <select class="form-control" id="isDIY"
                                            data-bind="booleanValue:isDIY, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row form-group" data-bind="visible:!isEcoScience()">
                <label class="col-from-label col-md-4"><g:message code="project.details.gear"/><fc:iconHelp><g:message
                        code="project.details.gear.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textArea class="form-control" name="gear" data-bind="value:gear" rows="2"/>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4"><g:message code="project.details.task"/><fc:iconHelp><g:message
                        code="project.details.task.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="col-md-8">
                    <g:textArea class="form-control" name="task" data-bind="value:task" rows="2"
                                data-validation-engine="validate[required]"/>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || isEcoScience() || !isExternal()" class="card mt-3">
        <div class="card-body">
            <h4 class="card-title"><g:message code="project.details.find"/></h4>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="urlWeb"><g:message
                        code="project.details.website"/><fc:iconHelp><g:message
                        code="project.details.website.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <div class="input-group">
                        <g:textField class="form-control" type="url" name="urlWeb" data-bind="value:urlWeb"
                                     data-validation-engine="validate[custom[url]]"/>
                        <div class="input-group-append">
                            <button class="btn btn-danger" type="button" data-bind="click:removeUrlWeb">
                                <i class="far fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <g:render template="/shared/editDocumentLinks"
                      model="${[entity: 'project', imageUrl: asset.assetPath(src: 'filetypes'), isProject: true]}"/>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="keywords"><g:message
                        code="project.details.keywords"/><fc:iconHelp><g:message
                        code="project.details.keywords.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textArea class="form-control" name="keywords" data-bind="value:keywords" rows="2"/>
                </div>
            </div>

        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || isEcoScience() || !isExternal()" class="card mt-3">
        <div class="card-body">
            <h4 class="card-title"><g:message code="project.details.image"/></h4>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="logo"><g:message
                        code="project.details.logo"/><fc:iconHelp><g:message
                        code="project.details.logo.help"/></fc:iconHelp></label>

                <div class="col-md-4" style="text-align:center;background:white">
                    <small class="form-text"><g:message code="project.details.logo.extra"/></small>

                    <div class="col d-inline-block p-0" style="width:200px;height:150px;line-height:146px;">
                        <img class="mw-100 mh-100 img-thumbnail" alt="No image provided"
                             data-bind="attr:{src:logoUrl}">
                    </div>

                    <small class="form-text" data-bind="visible:logoUrl()"><g:message code="project.details.logo.visible"/></small>
                </div>
                <div class="col-md-4 d-flex justify-content-center">
                    <div class="mt-1">
                        <button class="btn btn-dark fileinput-button"
                              data-url="${createLink(controller: 'image', action: 'upload')}"
                              data-role="logo"
                              data-owner-type="projectId"
                              data-owner-id="${project?.projectId}"
                              data-bind="stagedImageUpload:documents, visible:!logoUrl()"><i class="fas fa-file-upload"></i> <input
                                id="logo" type="file" name="files"> Attach</button>

                        <button class="btn btn-danger main-image-button" data-bind="click:removeLogoImage, visible:logoUrl()">
                            <i class="far fa-trash-alt"></i> Remove
                        </button>
                    </div>
                </div>
            </div>

            <div class="row form-group" data-bind="visible: logoUrl()">
                <label class="col-from-label col-md-4" for="logoCredit"><g:message
                        code="project.details.logo.attribution"/><fc:iconHelp><g:message
                        code="project.details.logo.attribution.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textField class="form-control" name="logoCredit" data-bind="value:logoAttribution"/>
                </div>
            </div>

            <div class="row form-group">
                <label class="col-from-label col-md-4" for="mainImage"><g:message
                        code="project.details.mainImage"/><fc:iconHelp><g:message
                        code="project.details.mainImage.help"/></fc:iconHelp></label>

                <div class="col-md-4" style="text-align:center;background:white">
                    <small class="form-text"><g:message code="project.details.mainImage.extra"/></small>

                    <div class="col d-inline-block p-0" style="width:200px;height:150px;line-height:146px;">
                        <img class="mw-100 mh-100 img-thumbnail" alt="No image provided" data-bind="attr:{src:mainImageUrl}">
                    </div>
                </div>
                <span class="col-md-4 d-flex justify-content-center">
                    <div class="mt-1">
                        <button class="btn btn-dark fileinput-button "
                              data-url="${createLink(controller: 'image', action: 'upload')}"
                              data-role="mainImage"
                              data-owner-type="projectId"
                              data-owner-id="${project?.projectId}"
                              data-bind="stagedImageUpload:documents, visible:!mainImageUrl()">
                            <i class="fas fa-file-upload"></i>  <input
                                id="mainImage" type="file" name="files">Attach
                        </button>

                        <button class="btn btn-danger main-image-button" data-bind="click:removeMainImage,  visible:mainImageUrl()">
                            <i class="far fa-trash-alt"></i> Remove
                        </button>
                    </div>
                </span>
            </div>

            <div class="row form-group" data-bind="visible: mainImageUrl()">
                <label class="col-from-label col-md-4" for="mainImageCredit"><g:message
                        code="project.details.mainImage.attribution"/><fc:iconHelp><g:message
                        code="project.details.mainImage.attribution.help"/></fc:iconHelp></label>

                <div class="col-md-8">
                    <g:textField class="form-control" name="mainImageCredit" data-bind="value:mainImageAttribution"/>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:(isCitizenScience() || isEcoScience() || !isExternal())" class="card mt-3">
        <div class="card-body">
            <!-- ko stopBinding: true -->
            <div id="sitemap">
                <h4 class="card-title"><g:message code="project.details.site"/><i class="req-field"></i></h4>

                <p>
                    <g:message code="project.projectarea.title"/>
                </p>
                <g:render template="/site/siteDefinition"/>
            </div>
            <!-- /ko -->
        </div>
    </div>

    <div class="card mt-3">
        <div class="card-body">
            <h4 class="card-title"><g:message code="project.details.configuration"/></h4>
            <map-config-selector
                    params="allBaseLayers: fcConfig.allBaseLayers, allOverlays: fcConfig.allOverlays, mapLayersConfig: mapLayersConfig"></map-config-selector>
        </div>
    </div>

    <g:if test="${grailsApplication.config.termsOfUseUrl}">
        <div class="card mt-3" style="display: none" data-bind="visible: !isExternal()">
            <div class="card-body">
                <h4 class="card-title"><g:message code="project.details.termsOfUseAgreement"/></h4>

                <div class="row form-group">
                    <label class="col-from-label col-md-4" for="termsOfUseAgreement"><g:message
                            code="project.details.termsOfUseAgreement"/><fc:iconHelp><g:message
                            code="project.details.termsOfUseAgreement.help"/></fc:iconHelp></label>

                    <div class="col-md-8">
                        <div class="custom-checkbox">
                        <input data-bind="checked:termsOfUseAccepted, disable: !transients.termsOfUseClicked()"
                               type="checkbox" id="termsOfUseAgreement" name="termsOfUseAgreement"
                               data-validation-engine="validate[required]"
                               title="<g:message code="project.details.termsOfUseAgreement.checkboxTip"/>"/>
                        <label for="termsOfUseAgreement"><span></span> I confirm that have read and accept the <a
                                href="${grailsApplication.config.termsOfUseUrl}" data-bind="click: clickTermsOfUse"
                                target="_blank">Terms of Use</a>.</label>
                        </div>

                        <p class="mt-3"><g:message code="project.details.termsOfUseAgreement.help"/></p>

                        <p><img src="${asset.assetPath(src: 'cc.png')}" alt="Creative Commons Attribution 3.0"></p>
                    </div>
                </div>
            </div>
        </div>
    </g:if>

    <script id="scienceTypeTemplate" type="text/html">
    <div class="custom-checkbox">
        <input type="checkbox" name="scienceType" class="validate[required]"
               data-validation-engine="validate[minCheckbox[1]]"
               data-bind="value: $data, attr:{id:'checkbox'+$index()}, checked: $root.transients.isScienceTypeChecked($data), event:{change:$root.transients.addScienceType}"/>
        <label data-bind="text: $data, attr:{for:'checkbox'+$index()}"></label>
    </div>
    </script>
    <script id="ecoScienceTypeTemplate" type="text/html">
    <div class="custom-checkbox">
        <input type="checkbox" name="ecoScienceType"
               data-bind="value: $data.toLowerCase(), attr:{id:'checkbox'+$index()}, checked: $root.transients.isEcoScienceTypeChecked($data), event:{change:$root.transients.addEcoScienceType}"/>
        <label data-bind="text: $data, attr:{for:'checkbox'+$index()}"></label>
    </div>
    </script>

    <script id="industryTemplate" type="text/html">
    <div class="custom-checkbox">
        <input type="checkbox" name="industries"
               data-bind="value: $data, attr:{id:'industry-'+$index()}, checked: $root.industries"/>
        <label data-bind="text: $data, attr:{for:'industry-'+$index()}"></label>
    </div>
    </script>

    <script id="bushfireCategoriesTemplate" type="text/html">
    <div class="custom-checkbox">
        <input type="checkbox" name="bushfireCategories"
               data-bind="value: $data, attr:{id:'bushfireCategories-'+$index()}, checked: $root.bushfireCategories"/>
        <label data-bind="text: $data, attr:{for:'bushfireCategories-'+$index()}"></label>
    </div>
    </script>
</bc:koLoading>
