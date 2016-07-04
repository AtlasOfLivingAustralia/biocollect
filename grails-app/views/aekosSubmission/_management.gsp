<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 9 of 9 - Dataset Conditions of Use and Management</h4>
        </div>
    </div>

    <br/>
    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="dataSharingLicense"><g:message code="aekos.management.datasharing.license"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.management.datasharing.license"/>',
                              content:'<g:message code="aekos.management.datasharing.license.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                %{--<span class="req-field"></span></label>--}%
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="dataSharingLicense" data-bind="text: dataSharingLicense"></span>
                %{--<select id="dataSharingLicense" data-bind="options: dataSharingLicenseOptions,--}%
                                                      %{--value: aekosModalView().dataSharingLicense,--}%
                                                      %{--optionsCaption: '--Please select--'"></select>--}%
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="acknowledgement"><g:message code="aekos.acknowledgement"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.acknowledgement"/>',
                              content:'<g:message code="aekos.acknowledgement.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="acknowledgement" data-bind="value: aekosModalView().acknowledgement" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="embargoOption"><g:message code="aekos.embargoOption"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.embargoOption"/>',
                              content:'<g:message code="aekos.embargoOption.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="embargoOption" data-bind="text: aekosModalView().embargoOption" ></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        %{--<div class="container">--}%
            <div class="panel panel-default" class="well">
                <div class="panel-heading"><h5 class="strong">Dataset Custodian(s)</h5></div>
                  <div class="panel-body">
                      <div class="row-fluid">
                          <div class="span4 text-right">
                              <label class="control-label" for="legalCustodianOrganisation"><g:message code="aekos.legalCustodianOrganisation"/>
                                  <a href="#" class="helphover"
                                     data-bind="popover: {title:'<g:message code="aekos.legalCustodianOrganisation"/>',
                                  content:'<g:message code="aekos.legalCustodianOrganisation.help"/>'}">
                                      <i class="icon-question-sign"></i>
                                  </a>
                              </label>
                          </div>

                          <div class="span8">
                              <div class="controls">
                                  <span id="legalCustodianOrganisation" data-bind="text: aekosModalView().legalCustodian" ></span>
                              </div>
                          </div>
                      </div>

                      <div class="row-fluid">
                          <div class="span4 text-right">
                              <label class="control-label" for="legalCustodianOrganisationType"><g:message code="aekos.legalCustodianOrganisationType"/>
                                  <a href="#" class="helphover"
                                     data-bind="popover: {title:'<g:message code="aekos.legalCustodianOrganisationType"/>',
                                  content:'<g:message code="aekos.legalCustodianOrganisationType.help"/>'}">
                                      <i class="icon-question-sign"></i>
                                  </a>
                              </label>
                          </div>

                          <div class="span8">
                              <div class="controls">
                                  %{--<span id="legalCustodianOrganisationType" data-bind="text: aekosModalView().legalCustodianOrganisationType" ></span>--}%
                                  <select id="legalCustodianOrganisationType" data-bind="options: aekosModalView().legalCustodianOrganisationTypeList,
                                                      value: aekosModalView().legalCustodianOrganisationType,
                                                      optionsCaption: 'N/A'"></select>
                              </div>
                          </div>
                      </div>

                  </div>
               </div>
            </div>
        %{--</div>--}%
    </div>

    <br/>

    <div class="panel panel-default" class="well">
         <div class="panel-heading"><h5 class="strong">Dataset Management</h5></div>
           <div class="panel-body">

                <div class="row-fluid">
                    <div class="span4 text-right">
                        <label class="control-label" for="curationStatus"><g:message code="aekos.management.curation.status"/>
                            <a href="#" class="helphover"
                               data-bind="popover: {title:'<g:message code="aekos.management.curation.status"/>',
                                              content:'<g:message code="aekos.management.curation.status.help"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                        </label>
                    </div>

                    <div class="span8">
                        <div class="controls">
                            <select id="curationStatus" data-bind="options: aekosModalView().curationStatusList,
                                                                  value: aekosModalView().curationStatus,
                                                                  optionsCaption: 'N/A'"></select>
                        </div>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-right">
                        <label class="control-label" for="curationActivitiesOther"><g:message code="aekos.management.curation.other"/>
                            <a href="#" class="helphover"
                               data-bind="popover: {title:'<g:message code="aekos.management.curation.other"/>',
                                                  content:'<g:message code="aekos.management.curation.other.help"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                        </label>
                    </div>

                    <div class="span8">
                        <div class="controls">
                            <select id="curationActivitiesOther" data-bind="options: aekosModalView().curationActivitiesOtherList,
                                                                      value: aekosModalView().curationActivitiesOther,
                                                                      optionsCaption: 'N/A'"></select>
                        </div>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-right">
                        <label class="control-label" for="lastUpdated"><g:message code="aekos.management.lastUpdated"/>
                            <a href="#" class="helphover"
                               data-bind="popover: {title:'<g:message code="aekos.management.lastUpdated"/>',
                                                      content:'<g:message code="aekos.management.lastUpdated.help"/>'}">
                                <i class="icon-question-sign"></i>
                            </a>
                        </label>
                    </div>

                    <div class="span8">
                        <div class="controls">
                            %{--<input id="lastUpdated" data-bind="value: aekosModalView().lastUpdated">--}%
                            <div class="controls input-append">
                                <input id="lastUpdated" data-bind="datepicker:aekosModalView().lastUpdated.date" type="text"/>
                                <span class="add-on open-datepicker"><i class="icon-calendar"></i> </span>
                            </div>
                        </div>
                    </div>
                </div>

           </div>
        </div>

</div>