<bc:koLoading>
    <div class="well">
        <h4 class="block-header">Project metadata</h4>
        <div class="row-fluid">

            <div class="clearfix control-group">
                <label class="control-label span3"><g:message code="project.details.type"/><fc:iconHelp><g:message code="project.details.type.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <select data-bind="value:transients.kindOfProject, options:transients.availableProjectTypes, optionsText:'name', optionsValue:'value', optionsCaption:'Select...'"  <g:if test="${params.citizenScience}">disabled</g:if> data-validation-engine="validate[required]"></select>
                </div>
            </div>
        </div>
        <div class="row-fluid">

            <div class="clearfix control-group">
                <label class="control-label span3" for="isExternal"><g:message code="project.details.useALA"/><fc:iconHelp><g:message code="project.details.useALA.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <select id="isExternal" data-bind="booleanValue:isExternal, options:[{label:'Yes', value:'false'}, {label:'No', value:'true'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'" data-validation-engine="validate[required]">
                    </select>
                </div>
            </div>
        </div>
        <div id="organisationSearch" data-bind="with: organisationSearch">
            <div class="row-fluid">

                <div class="clearfix control-group">

                    <label class="control-label span3" for="organisationName"><g:message code="project.details.organisationNameSearch"/><fc:iconHelp><g:message code="project.details.organisationName.help"/></fc:iconHelp><i class="req-field"></i></label>
                    <div class="span6 controls">
                        <div class="input-append">
                            <input id="organisationName" class="input-xxlarge" type="text" placeholder="Start typing a name here" data-bind="value:term, valueUpdate:'afterkeydown', disable:selection"><button class="btn" type="button" data-bind="click:clearSelection"><i class='icon-search' data-bind="css:{'icon-search':!term(), 'icon-remove':term()}"></i></button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row-fluid" data-bind="slideVisible:!selection()">
                <div class="span3"></div>
                <div class="span9">
                    <div class="control-label span12 large-checkbox" style="display:none;" data-bind="visible:!selection() && allViewed()">
                        <input type="checkbox" id="organisationNotPresent" value="organisationNotOnList" data-bind="checked:organisationNotPresent"><label for="organisationNotPresent"><span></span> My organisation is not on the list &nbsp;</label>
                    </div>
                    <div style="display:none;" data-bind="visible:!selection() && allViewed() && organisationNotPresent()">
                        <button class="btn btn-success" id="registerOrganisation" style="float:right" data-bind="click:function() {createOrganisation();}">Register my organisation</button>
                    </div>
                </div>

                <div class="span3"></div>
                <div class="span8 organisation-search">

                    <div><b>Organisation Search Results</b> (Click an organisation to select it)</div>
                    <div class="organisation-list" data-bind="event:{scroll:scrolled}">
                        <ul id="organisation-list" class="nav nav-list">
                            <li class="nav-header" style="display:none;" data-bind="visible:userOrganisationResults().length">Your organisations</li>
                            <!-- ko foreach:userOrganisationResults -->
                            <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                            <!-- /ko -->
                            <li class="nav-header" style="display:none;" data-bind="visible:userOrganisationResults().length && otherResults().length">Other organisations</li>
                            <!-- ko foreach:otherResults -->
                            <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                            <!-- /ko -->
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <div data-bind="visible:isCitizenScience() || !isExternal()" class="row-fluid">
            <p/>
            <div class="control-group">
                <label class="control-label span3" for="isMetadataSharing"><g:message code="project.details.isMetadataSharing"/><fc:iconHelp><g:message code="project.details.isMetadataSharing.help"/></fc:iconHelp></label>
                <div class="controls span9 large-checkbox">
                    <input data-bind="checked:isMetadataSharing" type="checkbox" id="isMetadataSharing"/>
                    <label for="isMetadataSharing"> <span></span> <g:message code="project.details.isMetadataSharing.extra"/> </label>
                </div>
            </div>
        </div>

    </div>

    <div data-bind="visible:isCitizenScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.tell"/></h4>

            <div class="clearfix control-group">
                <label class="control-label span3" for="name"><g:message code="project.details.name"/><fc:iconHelp><g:message code="project.details.name.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <g:textField style="width:90%;" name="name" data-bind="value:name"
                                 data-validation-engine="validate[required]"/>
                </div>
            </div>

            <div class="clearfix control-group">
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
                <label class="control-label span3" for="plannedStartDate"><g:message code="project.details.plannedStartDate"/>
                <fc:iconHelp><g:message code="project.details.plannedStartDate.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <fc:datePicker class="input-small" targetField="plannedStartDate.date" name="plannedStartDate"
                                   id="plannedStartDate" data-validation-engine="validate[required]"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="plannedEndDate"><g:message code="project.details.plannedEndDate"/>
                <fc:iconHelp><g:message code="project.details.plannedEndDate.help"/></fc:iconHelp>
                </label>

                <div class="controls span9">
                    <fc:datePicker class="input-small" targetField="plannedEndDate.date" name="plannedEndDate"
                                   id="plannedEndDate" data-validation-engine="validate[future[plannedStartDate]]"/>
                    <g:message code="project.details.plannedEndDate.extra"/>
                </div>
            </div>

            <div id="associatedOrgs">
                <div class="row-fluid">
                    <div class="clearfix control-group">
                        <label class="control-label span3" for="associatedOrgList"><g:message code="project.details.associatedOrgs"/>:<fc:iconHelp><g:message code="project.details.associatedOrgs.help"/></fc:iconHelp></label>
                        <div class="span9"><g:message code="project.details.associatedOrgs.extra"/></div>
                        <div class="span6" id="associatedOrgList">
                            <!-- ko foreach: associatedOrgs -->
                            <div class="span12 margin-left-0 margin-bottom-1">
                                <div class="span6 margin-left-0" data-bind="text: name"></div>
                                <div class="span3"><img src="" data-bind="visible: logo, attr: {src: logo}" alt="Organisation logo" class="small-logo"></div>
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
                                    <label class="control-label left-aligned-label span3" for="associatedOrgName"><g:message code="project.details.associatedOrgs.name"/><i class="req-field" data-bind="visible: $parent.transients.associatedOrgNotInList()"></i></label>

                                    <div class="controls span12 margin-left-0">
                                        <input id="associatedOrgName" class="input-xxlarge" type="text" placeholder="Start typing a name here" data-bind="value:term, valueUpdate:'afterkeydown'"><button class="btn" type="button" data-bind="click:clearSelection"><i class='icon-search' data-bind="css:{'icon-search':!term(), 'icon-remove':term()}"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="organisation-search">
                            <div class="row-fluid">
                                <div class="span3"></div>
                                <div class="span8">
                                    <div class="span12 large-checkbox">
                                        <input type="checkbox" id="associatedOrgNotPresent" value="organisationNotOnList" data-bind="checked: $parent.transients.associatedOrgNotInList, disable: !term"><label class="pull-right" for="associatedOrgNotPresent"><span></span> <g:message code="project.details.associatedOrgs.notInList"/>&nbsp;</label>
                                    </div>
                                    <div data-bind="visible: !$parent.transients.associatedOrgNotInList()">
                                        <div><b>Organisation Search Results</b> (Click an organisation to select it)</div>
                                        <div class="organisation-list" data-bind="event:{scroll:scrolled}">
                                            <ul id="associated-org-list" class="nav nav-list">
                                                <li class="nav-header" style="display:none;" data-bind="visible:userOrganisationResults().length">Your organisations</li>
                                                <!-- ko foreach:userOrganisationResults -->
                                                <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                                                <!-- /ko -->
                                                <li class="nav-header" style="display:none;" data-bind="visible:userOrganisationResults().length && otherResults().length">Other organisations</li>
                                                <!-- ko foreach:otherResults -->
                                                <li data-bind="css:{active:$parent.isSelected($data)}"><a data-bind="click:$parent.select, text:name"></a></li>
                                                <!-- /ko -->
                                            </ul>
                                        </div>
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
                                        <label class="control-label left-aligned-label span3" for="associatedOrgUrl"><g:message code="project.details.associatedOrgs.url"/></label>

                                        <div class="controls span12 margin-left-0">
                                            <input id="associatedOrgUrl" class="input-xxlarge" type="text" data-bind="value: $parent.transients.associatedOrgUrl">
                                        </div>
                                    </div>
                                    <div class="clearfix control-group">
                                        <label class="control-label left-aligned-label span3" for="associatedOrgLogo"><g:message code="project.details.associatedOrgs.logo"/></label>

                                        <div class="controls span12 margin-left-0">
                                            <input id="associatedOrgLogo" class="input-xxlarge" type="text" data-bind="value: $parent.transients.associatedOrgLogoUrl">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row-fluid">
                        <div class="span3"></div>
                        <div class="span9">
                            <a href="#" data-bind="click: addSelectedOrganisation, visible: term" class="margin-top-2 btn btn-primary"><i class="fa fa-check">&nbsp;</i><g:message code="project.details.associatedOrgs.add"/></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:!isCitizenScience() && !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.associations"/></h4>

            <div class="clearfix control-group">
                <label class="control-label span3" for="externalId"><g:message code="project.details.externalId"/></label>

                <div class="controls span9">
                    <g:textField class="span12" name="externalId" data-bind="value:externalId"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="grantId"><g:message code="project.details.grantId"/></label>

                <div class="controls span9">
                    <g:textField class="span12" name="grantId" data-bind="value:grantId"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="funding"><g:message code="project.details.funding"/></label>

                <div class="controls span9">
                    <g:textField class="span12" name="funding" data-bind="value:funding"
                                 data-validation-engine="validate[custom[number]]"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="program"><g:message code="project.details.program"/><i class="req-field"></i></label>

                <div class="controls span9">
                    <select class="span12" id="program"
                            data-bind="value:associatedProgram,options:transients.programs,optionsCaption: 'Choose...'"
                            data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="subProgram"><g:message code="project.details.subprogram"/></label>

                <div class="controls span9">
                    <select class="span12" id="subProgram"
                            data-bind="value:associatedSubProgram,options:transients.subprogramsToDisplay,optionsCaption: 'Choose...'"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"
                       for="orgGrantee"><g:message code="project.details.orgGrantee"/></label>

                <div class="controls span9">
                    <select class="span12" id="orgGrantee"
                            data-bind="options:transients.organisations, optionsText:'name', optionsValue:'uid', value:orgIdGrantee, optionsCaption: 'Choose...'"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"
                       for="orgSponsor"><g:message code="project.details.orgSponsor"/></label>

                <div class="controls span9">
                    <select class="span12" id="orgSponsor"
                            data-bind="options:transients.organisations, optionsText:'name', optionsValue:'uid', value:orgIdSponsor, optionsCaption: 'Choose...'"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"
                       for="orgSvcProvider"><g:message code="project.details.orgSvcProvider"/></label>

                <div class="controls span9">
                    <select class="span12" id="orgSvcProvider"
                            data-bind="options:transients.organisations, optionsText:'name', optionsValue:'uid', value:orgIdSvcProvider, optionsCaption: 'Choose...'"></select>
                </div>
            </div>
        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.involved"/></h4>

            <div class="clearfix control-group">
                <label class="control-label span3" for="getInvolved"><g:message code="project.details.involved"/><fc:iconHelp><g:message code="project.details.involved.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textArea style="width:90%;" name="getInvolved" data-bind="value:getInvolved"
                                rows="2"/>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"
                       for="scienceType"><g:message code="project.details.scienceType"/><fc:iconHelp><g:message code="project.details.scienceType.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <select id="scienceType" data-bind="value:scienceType, options:transients.availableScienceTypes, optionsText:'name', optionsValue:'value', optionsCaption:'Select...'" data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3"><g:message code="project.details.difficulty"/><fc:iconHelp><g:message code="project.details.difficulty.help"/></fc:iconHelp><i class="req-field"></i></label>

                <div class="controls span9">
                    <select data-bind="value:difficulty, options:transients.difficultyLevels, optionsCaption:'Select...'" data-validation-engine="validate[required]"></select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="hasParticipantCost"><g:message code="project.details.hasParticipantCost"/><fc:iconHelp><g:message code="project.details.hasParticipantCost.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <select id="hasParticipantCost" data-bind="booleanValue:hasParticipantCost, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                    </select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="hasTeachingMaterials"><g:message code="project.details.hasTeachingMaterials"/><fc:iconHelp><g:message code="project.details.hasTeachingMaterials.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <select id="hasTeachingMaterials" data-bind="booleanValue:hasTeachingMaterials, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                    </select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="isDIY"><g:message code="project.details.isDIY"/><fc:iconHelp><g:message code="project.details.isDIY.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <select id="isDIY" data-bind="booleanValue:isDIY, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                    </select>
                </div>
            </div>

            <div class="clearfix control-group">
                <label class="control-label span3" for="isSuitableForChildren"><g:message code="project.details.isSuitableForChildren"/><fc:iconHelp><g:message code="project.details.isSuitableForChildren.help"/></fc:iconHelp></label>
                <div class="controls span9">
                    <select id="isSuitableForChildren" data-bind="booleanValue:isSuitableForChildren, options:[{label:'Yes', value:'true'}, {label:'No', value:'false'}], optionsText:'label', optionsValue:'value', optionsCaption:'Select...'">
                    </select>
                </div>
            </div>

            <div class="clearfix control-group">
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

    <div data-bind="visible:isCitizenScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.find"/></h4>

            <div class="control-group">
                <label class="control-label span3" for="urlWeb"><g:message code="project.details.website"/><fc:iconHelp><g:message code="project.details.website.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textField style="width:90%;" type="url" name="urlWeb" data-bind="value:urlWeb" data-validation-engine="validate[custom[url]]"/>
                </div>
            </div>

            <g:render template="/shared/editDocumentLinks"
                      model="${[entity:'project',imageUrl:resource(dir:'/images/filetypes')]}"/>

            <div class="control-group">
                <label class="control-label span3" for="keywords"><g:message code="project.details.keywords"/><fc:iconHelp><g:message code="project.details.keywords.help"/></fc:iconHelp></label>

                <div class="controls span9">
                    <g:textArea style="width:90%;" name="keywords" data-bind="value:keywords" rows="2"/>
                </div>
            </div>

        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || !isExternal()" class="row-fluid">
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

            <div class="control-group">
                <label class="control-label span3" for="mainImage"><g:message code="project.details.mainImage"/><fc:iconHelp><g:message code="project.details.mainImage.help"/></fc:iconHelp></label>
                <div class="span6" style="text-align:center;background:white">
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
        </div>
    </div>

    <div data-bind="visible:isCitizenScience() || !isExternal()" class="row-fluid">
        <div class="well">
            <h4 class="block-header"><g:message code="project.details.site"/></h4>
            <p>
                A project area should represent the smallest area which contains all of the data collected in a single activity or survey event.
            </p>
            <!-- ko stopBinding: true -->
            <g:render template="/site/siteDefinition" />
            <!-- /ko -->
        </div>
    </div>
</bc:koLoading>