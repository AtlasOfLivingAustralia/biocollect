<bc:koLoading>
    <div class="well">
        <h4 class="block-header">Project metadata</h4>
        <div class="row-fluid">

            <div class="clearfix control-group">
                <label class="control-label span3"><g:message code="project.details.type"/><fc:iconHelp><g:message code="project.details.type.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <select data-bind="value:transients.kindOfProject, options:transients.availableProjectTypes, optionsText:'name', optionsValue:'value', optionsCaption:'Select...'"  <g:if test="${params.citizenScience || params.works || params.ecoScience}">disabled</g:if> data-validation-engine="validate[required]"></select>
                </div>
            </div>
        </div>
        <div data-bind="visible:!isWorks()" class="row-fluid">

            <div class="clearfix control-group">
                <label class="control-label span3" for="isExternal"><g:message code="project.details.useALA"/><fc:iconHelp><g:message code="project.details.useALA.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span4">
                    <select id="isExternal" data-bind="booleanValue:isExternal, options:[{label:'Yes', value:'false'}, {label:'No', value:'true'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'" data-validation-engine="validate[required]">
                    </select>
                </div>
            </div>
        </div>
        <div id="organisationSearch" data-bind="with: organisationSearch">
            <div class="row-fluid">
                <div class="clearfix control-group">
                    <label class="control-label span3"><g:message code="project.details.organisationNameSearch"/><fc:iconHelp><g:message code="project.details.organisationName.help"/></fc:iconHelp><i class="req-field"></i></label>
                    <div class="span6 controls">
                        <div class="input-append">
                            <input id="searchText1" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup', disable: selection" class="input-xxlarge" placeholder="Start typing a name here..." type="text" data-validation-engine="validate[funcCall[validateOrganisationSelection]]"/>
                            <button class="btn" type="button" data-bind="click:clearSelection"><i class='icon-search' data-bind="css:{'icon-search':!searchTerm(), 'icon-remove':searchTerm()}"></i></button>
                        </div>
                    </div>
                </div>
            </div>

            <div data-bind="slideVisible:displayNavigationControls()">
                <div class="row-fluid">
                    <div class="span3"></div>
                    <div class="span8">
                        <div><b>Organisation Search Results</b> (Click an organisation to select it)</div>
                        <div class="organisation-list" >
                            <ul class="nav nav-list">
                                <!-- ko foreach : organisations -->
                                <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                                <!-- /ko -->
                            </ul>
                        </div>
                        <div class="margin-top-2"></div>
                        <div class="row-fluid">
                            <g:render template="/shared/pagination"/>
                        </div>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span3"></div>
                    <div class="span8">
                        <div class="control-label span12 large-checkbox">
                            <input type="checkbox" id="organisationNotPresent" value="organisationNotOnList" data-bind="checked:organisationNotPresent, enable:displayNavigationControls() && allViewed()" />
                            <label for="organisationNotPresent"><span></span>&nbsp;<g:message code="project.details.organisation.notInList"/><fc:iconHelp><g:message code="project.details.organisation.notInList.help"/></fc:iconHelp></label>
                        </div>
                        <div style="display:none;" data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                            <button class="btn btn-success" style="float:right" data-bind="enable: !selection() && allViewed() && organisationNotPresent(), click:function() {$parent.createOrganisation();}">Register my organisation</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || isEcoScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.tell"/></h4>

            <div class="clearfix control-group">
                <label class="control-label span3" for="name"><g:message code="project.details.name"/><fc:iconHelp><g:message code="project.details.name.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <g:textField style="width:90%;" name="name" data-bind="value:name"
                                 data-validation-engine="validate[required]"/>
                </div>
            </div>

            <div data-bind="visible:!isWorks()" class="clearfix control-group">
                <label class="control-label span3" for="aim"><g:message code="project.details.aim"/><fc:iconHelp><g:message code="project.details.aim.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <g:textArea style="width:90%;" name="aim" data-bind="value:aim"
                                data-validation-engine="validate[required]" maxlength="300" rows="3"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="description"><g:message code="project.details.description"/><fc:iconHelp><g:message code="project.details.description.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <g:textArea style="width:90%;" name="description" data-bind="value:description"
                                data-validation-engine="validate[required]" rows="3"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="manager"><g:message code="project.details.manager"/><fc:iconHelp><g:message code="project.details.manager.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textField style="width:90%;" type="email" data-bind="value:manager" name="manager"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="managerEmail"><g:message code="project.details.managerEmail"/><fc:iconHelp><g:message code="project.details.managerEmail.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textField style="width:90%;" type="text" data-bind="value:managerEmail" name="managerEmail"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="plannedStartDate"><g:message code="project.details.plannedStartDate"/>
                <fc:iconHelp><g:message code="project.details.plannedStartDate.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <fc:datePicker class="input-small" targetField="plannedStartDate.date" name="plannedStartDate"
                                   id="plannedStartDate" data-validation-engine="validate[required]"/>
                </div>
            </div>

            <div class="clearfix control-group" data-bind="visible:!isWorks()">
                <label class="control-label span3" for="plannedEndDate"><g:message code="project.details.plannedEndDate"/>
                <fc:iconHelp><g:message code="project.details.plannedEndDate.help"/></fc:iconHelp>
                </label>

                <div class="controls span9">
                    <fc:datePicker class="input-small" targetField="plannedEndDate.date" name="plannedEndDate" clearBtn="true"
                                   id="plannedEndDate" data-validation-engine="validate[future[plannedStartDate]]"/>
                    <g:message code="project.details.plannedEndDate.extra"/>
                </div>
            </div>
            <div class="clearfix control-group" data-bind="visible:isWorks()">
                <label class="control-label span3" for="plannedEndDate"><g:message code="project.details.plannedEndDate"/>
                <fc:iconHelp><g:message code="project.details.plannedEndDate.help"/></fc:iconHelp><i class="req-field"></i>
                </label>

                <div class="controls span9">
                    <fc:datePicker class="input-small" targetField="plannedEndDate.date" name="plannedEndDate"
                                   id="plannedEndDate" data-validation-engine="validate[required,future[plannedStartDate]]" data-errormessage-value-missing="Works projects must have an end date"/>
                </div>
            </div>

            <div id="associatedOrgs">
                <div class="row-fluid">
                    <div class="clearfix control-group">
                        <label class="control-label span3" for="associatedOrgList"><g:message code="project.details.associatedOrgs"/>:<fc:iconHelp><g:message code="project.details.associatedOrgs.help"/></fc:iconHelp></label>
                        <div class="span9"><g:message code="project.details.associatedOrgs.extra"/></div>
                        <div class="span6" id="associatedOrgList">
                            <g:set var="noImageUrl" value="${asset.assetPath(src: "no-image-2.png")}"/>
                            <!-- ko foreach: associatedOrgs -->
                            <div class="span12 margin-left-0 margin-bottom-1">
                                <div class="span6 margin-left-0" data-bind="text: name"></div>
                            <div class="span3">
                                <div data-bind="if: logo && logo.startsWith('https')">
                                    <img src="" data-bind="attr: {src: logo}" alt="Organisation logo"
                                         class="small-logo">
                                </div>

                                <div data-bind="if: !logo || !logo.startsWith('https')">
                                    <img src="${noImageUrl}" alt="Organisation logo" class="small-logo">
                                </div>
                            </div>
                            <div class="span3"><a href="#" data-bind="click: $parent.removeAssociatedOrganisation" class="btn btn-primary"><i class="fa fa-remove">&nbsp;</i><g:message code="project.details.associatedOrgs.remove"/></a></div>
                            </div>
                            <!-- /ko -->
                        </div>
                    </div>
                </div>

                <div data-bind="with: associatedOrganisationSearch">
                    <div id="addAssociatedOrgPanel" class="span12">
                        <div class="row-fluid">
                            <div class="span3"></div>

                            <div class="span9">
                                <div class="clearfix control-group">
                                    <label class="control-label left-aligned-label span3"
                                           for="associatedOrgName"><g:message
                                            code="project.details.associatedOrgs.name"/><i class="req-field"
                                                                                           data-bind="visible: $parent.transients.associatedOrgNotInList()"></i>
                                    </label>

                                    <div class="controls span12 margin-left-0">
                                        <input id="associatedOrgName" class="input-xxlarge" type="text"
                                               placeholder="Start typing a name here" maxlength="256"
                                               data-validation-engine="validate[condRequired[associatedOrgNotPresent],maxSize[256]]"
                                               data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup'"><button
                                            class="btn" type="button" data-bind="click:clearSelection"><i
                                                class='icon-search'
                                                data-bind="css:{'icon-search':!searchTerm(), 'icon-remove':searchTerm()}"></i>
                                    </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="organisation-search" data-bind="slideVisible: navigationShouldBeVisible()">
                            <div data-bind="slideVisible: !$parent.transients.associatedOrgNotInList()">
                                <div class="row-fluid">
                                    <div class="span3"></div>

                                    <div class="span8">
                                        <div><b>Organisation Search Results</b> (Click an organisation to select it)
                                        </div>

                                        <div class="organisation-list">
                                            <ul class="nav nav-list">
                                                <!-- ko foreach : organisations -->
                                                <li data-bind="css:{active:$parent.isSelected($data)}"><a
                                                        data-bind="click:$parent.select, text:name"></a></li>
                                                <!-- /ko -->
                                            </ul>
                                        </div>

                                        <div class="margin-top-2"></div>

                                        <div class="row-fluid">
                                            <g:render template="/shared/pagination"/>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row-fluid">
                                <div class="span3"></div>

                                <div class="span8">
                                    <div class="span12 large-checkbox">
                                        <input type="checkbox" id="associatedOrgNotPresent"
                                               value="organisationNotOnList"
                                               data-bind="checked: $parent.transients.associatedOrgNotInList, enable:displayNavigationControls() && allViewed()"/><label
                                            class="pull-right" for="associatedOrgNotPresent"><span></span> <g:message
                                                code="project.details.associatedOrgs.notInList"/>&nbsp;<fc:iconHelp><g:message code="project.details.organisation.notInList.help"/></fc:iconHelp></label>
                                    </div>
                                </div>
                            </div>
                            <div class="row-fluid" data-bind="visible: $parent.transients.associatedOrgNotInList()">
                                <div class="span3"></div>

                                <div class="span9">
                                    <div class="margin-bottom-1">
                                        <g:message code="project.details.associatedOrgs.notInList.extra"/>
                                    </div>

                                    <div class="clearfix control-group">
                                        <label class="control-label left-aligned-label span3"
                                               for="associatedOrgUrl"><g:message
                                                code="project.details.associatedOrgs.url"/></label>

                                        <div class="controls span12 margin-left-0">
                                            <input id="associatedOrgUrl" class="input-xxlarge" type="text"
                                                   data-bind="value: $parent.transients.associatedOrgUrl">
                                        </div>
                                    </div>

                                    <div class="clearfix control-group">
                                        <label class="control-label left-aligned-label span3"
                                               for="associatedOrgLogo"><g:message
                                                code="project.details.associatedOrgs.logo"/></label>

                                        <div class="controls span12 margin-left-0">
                                            <input id="associatedOrgLogo" class="input-xxlarge" type="text"
                                                   data-validation-engine="validate[custom[httpsUrl]]"
                                                   data-bind="value: $parent.transients.associatedOrgLogoUrl">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row-fluid">
                                <div class="span3"></div>

                                <div class="span9">
                                    <div id="orgAlreadyAddedMessage"></div>
                                </div>
                            </div>

                            <div class="row-fluid">
                                <div class="span3"></div>
                                <div class="span9">
                                    <button class="btn btn-primary"
                                            data-bind="click: addSelectedOrganisation, enable: selection() || searchTerm() && $parent.transients.associatedOrgNotInList() "><i class="fa fa-check">&nbsp;</i><g:message code="project.details.associatedOrgs.add"  /></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <div class="margin-top-2"></div>
            <config:optionalContent key="${au.org.ala.biocollect.merit.hub.HubSettings.CONTENT_INDUSTRIES}">
            <div class="row-fluid">
                <div class="clearfix control-group">
                    <label class="control-label span3"><g:message code="project.details.industries.label"/>:<fc:iconHelp><g:message code="project.details.industries.help"/></fc:iconHelp></label>

                        <div class="span9">
                        <!-- ko foreach: transients.industries -->
                        <!-- ko template: { name:'industryTemplate'} -->
                        <!-- /ko -->
                        <!-- /ko -->
                        </div>
                </div>
            </div>
            </config:optionalContent>
            <div class="row-fluid">
                <div class="clearfix control-group">
                    <label class="control-label span3" for="associatedOrgList"><g:message code="project.details.countries.label"/>:<fc:iconHelp><g:message code="project.details.countries.help"/></fc:iconHelp><i class="req-field"></i></label>
                    <div class="span9">
                        <div class="row-fluid">
                            <div class="span4">
                                <!-- ko foreach: countries -->
                                <div class="span12 margin-left-0 margin-bottom-1">
                                    <input data-bind="value: $data" readonly>
                                    <a href="#" data-bind="click: $root.transients.removeCountry"><i class="icon-remove"></i></a>
                                </div>
                                <!-- /ko -->
                                <select class="span12" id="countries"
                                        data-bind="options: $root.transients.countries, event:{change: $root.transients.selectCountry}, optionsCaption: '<g:message code="project.details.countries.placeholder"/>'"
                                        ></select>
                            </div>
                            <div class="span8">
                                <div class="row-fluid">
                                    <div class="clearfix control-group">
                                        <label class="control-label span3" ><g:message code="project.details.uNRegions.label"/>:<fc:iconHelp><g:message code="project.details.uNRegions.help"/></fc:iconHelp><i class="req-field"></i></label>
                                        <div class="span9">
                                            <!-- ko foreach: uNRegions -->
                                            <div class="span12 margin-left-0 margin-bottom-1" >
                                                <input data-bind="value: $data" readonly>
                                                <a href="#" data-bind="click: $root.transients.removeUNRegion"><i class="icon-remove"></i></a>
                                            </div>
                                            <!-- /ko -->
                                            <select class="span12" id="uNRegionsId"
                                                    data-bind="options: $root.transients.uNRegions, event:{change: $root.transients.selectUNRegion}, optionsCaption: '<g:message code="project.details.uNRegions.placeholder"/>'"
                                            ></select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="clearfix control-group" data-bind="if:isEcoScience()">
                <label class="control-label span3"><g:message code="project.details.scienceType"/><fc:iconHelp><g:message code="project.details.scienceType.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <div class="row-fluid" >
                        <div class="span4">
                            <!-- ko foreach: transients.availableEcoScienceTypes -->
                            <!-- ko template: { name:'ecoScienceTypeTemplate', if: ($index() +1) % 3 == 1 }-->

                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                        <div class="span4">
                            <!-- ko foreach: transients.availableEcoScienceTypes -->
                            <!-- ko template: { name:'ecoScienceTypeTemplate', if: ($index() +1) % 3 == 2 }-->

                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                        <div class="span4">
                            <!-- ko foreach: transients.availableEcoScienceTypes -->
                            <!-- ko template: { name:'ecoScienceTypeTemplate', if: ($index() +1) % 3 == 0 }-->

                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>

    <div class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.associations"/></h4>

            <div data-bind="visible:!isCitizenScience() && (isEcoScience() || !isExternal())" class="clearfix control-group">
                <label class="control-label span3" for="externalId"><g:message code="project.details.externalId"/><fc:iconHelp><g:message code="project.details.externalId.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textField class="span12" name="externalId" data-bind="value:externalId"/>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && (isEcoScience() || !isExternal())" class="clearfix control-group">
                <label class="control-label span3" for="grantId"><g:message code="project.details.grantId"/><fc:iconHelp><g:message code="project.details.grantId.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textField class="span12" name="grantId" data-bind="value:grantId"/>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && (isEcoScience() || !isExternal())" class="clearfix control-group" class="clearfix control-group">
                <label class="control-label span3"  for="fundingSourceAmount" ><g:message code="project.details.funding"/><fc:iconHelp><g:message code="project.details.funding.help"/></fc:iconHelp></label>
                <div class="span9 " name="fundings">
                    <table class="table borderless">
                        <thead>
                            <td>Funding Source<fc:iconHelp><g:message code="project.details.funding.fundingSource.help"/></fc:iconHelp><i class="req-field"></i></td>
                            <td>Funding Type<fc:iconHelp><g:message code="project.details.funding.fundingType.help"/></fc:iconHelp></td>
                            <td>Funding Amount<fc:iconHelp><g:message code="project.details.funding.fundingSourceAmount.help"/></fc:iconHelp></td>
                            <td>Action</td>
                        </thead>
                        <tbody>
                        <!-- ko foreach: fundings -->
                        <tr >
                            <td ><g:textField name="fundingSource" data-bind="value:fundingSource" data-validation-engine="validate[required]"></g:textField></td>
                            <td ><select  name="fundingType" data-bind="options:$parent.fundingTypes,value:fundingType"></select></td>
                            <td ><g:field type="number" step="any" min="0" name="fundingSourceAmount" data-bind="value:fundingSourceAmount" data-validation-engine="validate[custom[number]]"></g:field></td>
                            <td><button class="btn main-image-button" data-bind="click:$parent.removeFunding"><i class="icon-minus"></i> Remove</button></td>
                        </tr>
                        <!-- /ko -->
                        <tr>
                            <td colspan="2" ></td>
                            <td colspan="1">
                                <fc:iconHelp><g:message code="project.details.funding.fundingTotal.help"/></fc:iconHelp><b>Total amount: <span name="totalFundingsAmount" data-bind="text:funding.formattedCurrency"/></b>
                            </td>
                            </tr>
                        <tr><td colspan="3" ></td>
                            <td colspan="1"><button class="btn main-image-button" data-bind="click:addFunding"><i class="icon-plus"></i> Add funding</button></td></tr>
                        </tbody>
                    </table>



                </div>
            </div>


            <div class="clearfix control-group">
                <label class="control-label span3" for="program"><g:message code="project.details.program"/><fc:iconHelp><g:message code="project.details.program.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <select class="span12" id="program"
                            data-bind="disable: transients.programs.length == 1,  value:associatedProgram,options:transients.programs,optionsCaption: 'Choose...'"
                            data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="subProgram"><g:message code="project.details.subprogram"/><fc:iconHelp><g:message code="project.details.subprogram.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <select class="span12" id="subProgram"
                            data-bind="value:associatedSubProgram,options:transients.subprogramsToDisplay,optionsCaption: 'Choose...'"></select>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && !isWorks() && (isEcoScience() || !isExternal()), with: granteeOrganisation">
                <div class="row-fluid">
                    <div class="clearfix control-group">
                        <label class="control-label span3" ><g:message code="project.details.orgGrantee"/><fc:iconHelp><g:message code="project.details.orgGrantee.help"/></fc:iconHelp></label>
                        <div class="span6 controls">
                            <div class="input-append">
                                <input id="searchText2" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup', disable: selection" class="input-xxlarge" placeholder="Start typing a name here..." type="text"/>
                                <button class="btn" type="button" data-bind="click:clearSelection"><i class='icon-search' data-bind="css:{'icon-search':!searchTerm(), 'icon-remove':searchTerm()}"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div data-bind="slideVisible:displayNavigationControls()">
                    <div class="row-fluid">
                        <div class="span3"></div>
                        <div class="span8">
                            <div><b>Organisation Search Results</b> (Click an organisation to select it)</div>
                            <div class="organisation-list" >
                                <ul class="nav nav-list">
                                    <!-- ko foreach : organisations -->
                                    <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                                    <!-- /ko -->
                                </ul>
                            </div>
                            <div class="margin-top-2"></div>
                            <div class="row-fluid">
                                <g:render template="/shared/pagination"/>
                            </div>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span3"></div>
                        <div class="span8">
                            <div class="control-label span12 large-checkbox">
                                <input type="checkbox" id="granteeOrganisationNotPresent" value="organisationNotOnList" data-bind="checked:organisationNotPresent, enable:displayNavigationControls() && allViewed()" />
                                <label for="granteeOrganisationNotPresent"><span></span>&nbsp;<g:message code="project.details.organisation.notInList"/><fc:iconHelp><g:message code="project.details.organisation.notInList.help"/></fc:iconHelp></label>
                            </div>
                            <div style="display:none;" data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                                <button class="btn btn-success" style="float:right" data-bind="enable: !selection() && allViewed() && organisationNotPresent(), click:function() {$parent.createOrganisation();}">Register my organisation</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div data-bind="visible:!isCitizenScience() && !isWorks() && (isEcoScience() || !isExternal()), with: sponsorOrganisation">
                <div class="row-fluid">
                    <div class="clearfix control-group">
                        <label class="control-label span3" ><g:message code="project.details.orgSponsor"/><fc:iconHelp><g:message code="project.details.orgSponsor.help"/></fc:iconHelp></label>
                        <div class="span6 controls">
                            <div class="input-append">
                                <input id="searchText3" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup', disable: selection" class="input-xxlarge" placeholder="Start typing a name here..." type="text"/>
                                <button class="btn" type="button" data-bind="click:clearSelection"><i class='icon-search' data-bind="css:{'icon-search':!searchTerm(), 'icon-remove':searchTerm()}"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div data-bind="slideVisible:displayNavigationControls()">
                    <div class="row-fluid">
                        <div class="span3"></div>
                        <div class="span8">
                            <div><b>Organisation Search Results</b> (Click an organisation to select it)</div>
                            <div class="organisation-list" >
                                <ul class="nav nav-list">
                                    <!-- ko foreach : organisations -->
                                    <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                                    <!-- /ko -->
                                </ul>
                            </div>
                            <div class="margin-top-2"></div>
                            <div class="row-fluid">
                                <g:render template="/shared/pagination"/>
                            </div>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span3"></div>
                        <div class="span8">
                            <div class="control-label span12 large-checkbox">
                                <input type="checkbox" id="sponsoringOrganisationNotPresent" value="organisationNotOnList" data-bind="checked:organisationNotPresent, enable:displayNavigationControls() && allViewed()" />
                                <label for="sponsoringOrganisationNotPresent"><span></span>&nbsp;<g:message code="project.details.organisation.notInList"/><fc:iconHelp><g:message code="project.details.organisation.notInList.help"/></fc:iconHelp></label>
                            </div>
                            <div style="display:none;" data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                                <button class="btn btn-success" style="float:right" data-bind="enable: !selection() && allViewed() && organisationNotPresent(), click:function() {$parent.createOrganisation();}">Register my organisation</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            %{--When is the service prodider organisatioh going to show?--}%
            <div data-bind="visible:!isCitizenScience() && !isWorks() && !isEcoScience()" class="clearfix control-group">
                <label class="control-label span3"
                       for="orgSvcProvider"><g:message code="project.details.orgSvcProvider"/></label>

                <div class="controls span9">
                    <select class="span12" id="orgSvcProvider"
                            data-bind="options:transients.organisations, optionsText:'name', optionsValue:'uid', value:orgIdSvcProvider, optionsCaption: 'Choose...'"></select>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="if:(isCitizenScience() || !isExternal()) && !isWorks() && !isEcoScience()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.involved"/></h4>

            <div class="clearfix control-group">
                <label class="control-label span3" for="getInvolved"><g:message code="project.details.involved"/><fc:iconHelp><g:message code="project.details.involved.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textArea style="width:90%;" name="getInvolved" data-bind="value:getInvolved"
                                rows="2"/>
                </div>
            </div>

            <div id="scienceTypeControlGroup" class="clearfix control-group">
                <label class="control-label span3"
                       ><g:message code="project.details.scienceType"/><fc:iconHelp><g:message code="project.details.scienceType.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <div class="row-fluid" >
                        <div class="span4">
                            <!-- ko foreach: transients.availableScienceTypes -->
                            <!-- ko template: { name:'scienceTypeTemplate', if: ($index() +1) % 3 == 1 }-->

                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                        <div class="span4">
                            <!-- ko foreach: transients.availableScienceTypes -->
                            <!-- ko template: { name:'scienceTypeTemplate', if: ($index() +1) % 3 == 2 }-->

                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                        <div class="span4">
                            <!-- ko foreach: transients.availableScienceTypes -->
                            <!-- ko template: { name:'scienceTypeTemplate', if: ($index() +1) % 3 == 0 }-->

                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                    </div>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"><g:message code="project.details.difficulty"/><fc:iconHelp><g:message code="project.details.difficulty.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <div class="row-fluid">
                        <div class="span3">
                            <select data-bind="value:difficulty, options:transients.difficultyLevels, optionsCaption:'Select...'"></select>
                        </div>
                        <div class="span9">
                            <div class="clearfix control-group">
                                <label class="control-label span8" for="isHome"><g:message code="project.details.isHome"/><fc:iconHelp><g:message code="project.details.isHome.help"/></fc:iconHelp></label>
                                <div class="controls span4">
                                    <select id="isHome" data-bind="booleanValue:isHome, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="hasParticipantCost"><g:message code="project.details.hasParticipantCost"/><fc:iconHelp><g:message code="project.details.hasParticipantCost.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <div class="row-fluid">
                        <div class="span3">
                            <select id="hasParticipantCost" data-bind="booleanValue:hasParticipantCost, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                            </select>
                        </div>
                        <div class="span9">
                            <div class="clearfix control-group">
                                <label class="control-label span8" for="isSuitableForChildren"><g:message code="project.details.isSuitableForChildren"/><fc:iconHelp><g:message code="project.details.isSuitableForChildren.help"/></fc:iconHelp></label>
                                <div class="controls span4">
                                    <select id="isSuitableForChildren" data-bind="booleanValue:isSuitableForChildren, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="hasTeachingMaterials"><g:message code="project.details.hasTeachingMaterials"/><fc:iconHelp><g:message code="project.details.hasTeachingMaterials.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <div class="row-fluid">
                        <div class="span3">
                            <select id="hasTeachingMaterials" data-bind="booleanValue:hasTeachingMaterials, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                            </select>
                        </div>
                        <div class="span9">
                            <div class="clearfix control-group">
                                <label class="control-label span8" for="isDIY"><g:message code="project.details.isDIY"/><fc:iconHelp><g:message code="project.details.isDIY.help"/></fc:iconHelp></label>
                                <div class="controls span4">
                                    <select id="isDIY" data-bind="booleanValue:isDIY, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="clearfix control-group" data-bind="visible:!isEcoScience()">
                <label class="control-label span3"><g:message code="project.details.gear"/><fc:iconHelp><g:message code="project.details.gear.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <g:textArea style="width:90%;" name="gear" data-bind="value:gear" rows="2"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"><g:message code="project.details.task"/><fc:iconHelp><g:message code="project.details.task.help"/></fc:iconHelp><i class="req-field"></i></label>
                <div class="controls span9">
                    <g:textArea style="width:90%;" name="task" data-bind="value:task" rows="2" data-validation-engine="validate[required]"/>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || isEcoScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.find"/></h4>

            <div class="control-group">
                <label class="control-label span3" for="urlWeb"><g:message code="project.details.website"/><fc:iconHelp><g:message code="project.details.website.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textField style="width:90%;" type="url" name="urlWeb" data-bind="value:urlWeb" data-validation-engine="validate[custom[url]]"/>
                </div>
            </div>

            <g:render template="/shared/editDocumentLinks"
                      model="${[entity:'project',imageUrl:asset.assetPath(src:'filetypes')]}"/>

            <div class="control-group">
                <label class="control-label span3" for="keywords"><g:message code="project.details.keywords"/><fc:iconHelp><g:message code="project.details.keywords.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textArea style="width:90%;" name="keywords" data-bind="value:keywords" rows="2"/>
                </div>
            </div>

        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || isEcoScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.image"/></h4>

            <div class="control-group">
                <label class="control-label span3" for="logo"><g:message code="project.details.logo"/><fc:iconHelp><g:message code="project.details.logo.help"/></fc:iconHelp></label>
                <div class="span6" style="text-align:center;background:white">
                    <g:message code="project.details.logo.extra"/><br/>
                    <div class="well" style="padding:0;width:200px;height:150px;line-height:146px;display:inline-block">
                        <img style="max-width:100%;max-height:100%" alt="No image provided" data-bind="attr:{src:logoUrl}">
                    </div>
                    <div data-bind="visible:logoUrl()"><g:message code="project.details.logo.visible"/></div>
                </div>
                <span class="span3">
                    <span class="btn fileinput-button pull-right"
                          data-url="${createLink(controller: 'image', action: 'upload')}"
                          data-role="logo"
                          data-owner-type="projectId"
                          data-owner-id="${project?.projectId}"
                          data-bind="stagedImageUpload:documents, visible:!logoUrl()"><i class="icon-plus"></i> <input
                            id="logo" type="file" name="files"><span>Attach</span></span>

                    <button class="btn main-image-button" data-bind="click:removeLogoImage, visible:logoUrl()"><i class="icon-minus"></i> Remove</button>
                </span>
            </div>
            <div class="control-group" data-bind="visible: logoUrl()">
                <label class="control-label span3" for="logoCredit"><g:message code="project.details.logo.attribution"/><fc:iconHelp><g:message code="project.details.logo.attribution.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <g:textField class="input-xxlarge" name="logoCredit" data-bind="value:logoAttribution"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label span3" for="mainImage"><g:message code="project.details.mainImage"/><fc:iconHelp><g:message code="project.details.mainImage.help"/></fc:iconHelp></label>
                <div class="span6" style="text-align:center;background:white">
                    <g:message code="project.details.mainImage.extra"/><br/>
                    <div class="well" style="padding:0;max-height:512px;display:inline-block;overflow:hidden">
                        <img style="width:100%" alt="No image provided" data-bind="attr:{src:mainImageUrl}">
                    </div>
                </div>
                <span class="span3">
                    <span class="btn fileinput-button pull-right"
                          data-url="${createLink(controller: 'image', action: 'upload')}"
                          data-role="mainImage"
                          data-owner-type="projectId"
                          data-owner-id="${project?.projectId}"
                          data-bind="stagedImageUpload:documents, visible:!mainImageUrl()"><i class="icon-plus"></i> <input
                            id="mainImage" type="file" name="files"><span>Attach</span></span>

                    <button class="btn main-image-button" data-bind="click:removeMainImage,  visible:mainImageUrl()"><i class="icon-minus"></i> Remove</button>
                </span>
            </div>
            <div class="control-group" data-bind="visible: mainImageUrl()">
                <label class="control-label span3" for="mainImageCredit"><g:message code="project.details.mainImage.attribution"/><fc:iconHelp><g:message code="project.details.mainImage.attribution.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <g:textField class="input-xxlarge" name="mainImageCredit" data-bind="value:mainImageAttribution"/>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:(isCitizenScience() || isEcoScience() || !isExternal())" class="row-fluid">
        <!-- ko stopBinding: true -->
        <div class="well" id="sitemap">
            <h4 class="block-header"><g:message code="project.details.site"/><i class="req-field"></i></h4>
            <p>
                A project area should represent the smallest area which contains all of the data collected in a single activity or survey event.
            </p>
            <g:render template="/site/siteDefinition" />
        </div>
        <!-- /ko -->
    </div>

    <g:if test="${grailsApplication.config.termsOfUseUrl}">
        <div class="row-fluid" style="display: none" data-bind="visible: !isExternal()">
            <div class="well">
                <h4 class="block-header"><g:message code="project.details.termsOfUseAgreement"/></h4>

                <div class="clearfix">
                    <label class="control-label span3" for="termsOfUseAgreement"><g:message code="project.details.termsOfUseAgreement"/><fc:iconHelp><g:message code="project.details.termsOfUseAgreement.help"/></fc:iconHelp></label>
                    <div class="controls span9 large-checkbox">
                        <input data-bind="checked:termsOfUseAccepted, disable: !transients.termsOfUseClicked()" type="checkbox" id="termsOfUseAgreement" name="termsOfUseAgreement" data-validation-engine="validate[required]" title="<g:message code="project.details.termsOfUseAgreement.checkboxTip"/>"/>
                        <label for="termsOfUseAgreement"><span></span> I confirm that have read and accept the <a href="${grailsApplication.config.termsOfUseUrl}" data-bind="click: clickTermsOfUse" target="_blank">Terms of Use</a>.</label>
                        <div class="margin-bottom-1"></div>
                        <p><g:message code="project.details.termsOfUseAgreement.help"/></p>
                        <p><img src="${asset.assetPath(src:'cc.png')}" alt="Creative Commons Attribution 3.0"></p>
                    </div>
                </div>
            </div>
        </div>
    </g:if>

    <script id="scienceTypeTemplate" type="text/html">
        <div class="large-checkbox">
            <input type="checkbox" name="scienceType" class="validate[required]"
                   data-validation-engine="validate[minCheckbox[1]]"
                   data-bind="value: $data, attr:{id:'checkbox'+$index()}, checked: $root.transients.isScienceTypeChecked($data), event:{change:$root.transients.addScienceType}"/>
            <label data-bind="html: '<span></span> ' + $data, attr:{for:'checkbox'+$index()}"></label>
        </div>
    </script>
    <script id="ecoScienceTypeTemplate" type="text/html">
    <div class="large-checkbox">
        <input type="checkbox" name="ecoScienceType"
               data-bind="value: $data.toLowerCase(), attr:{id:'checkbox'+$index()}, checked: $root.transients.isEcoScienceTypeChecked($data), event:{change:$root.transients.addEcoScienceType}"/>
        <label data-bind="html: '<span></span> ' + $data, attr:{for:'checkbox'+$index()}"></label>
    </div>
    </script>
    <script id="industryTemplate" type="text/html">
    <div class="large-checkbox">
        <input type="checkbox" name="industries"
               data-bind="value: $data, attr:{id:'industry-'+$index()}, checked: $root.industries"/>
        <label data-bind="html: '<span></span> ' + $data, attr:{for:'industry-'+$index()}"></label>
    </div>
    </script>
</bc:koLoading>