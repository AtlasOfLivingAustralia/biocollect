<%@ page import="groovy.time.TimeCategory" %>
<div id="pActivityVisibility">

    <!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row mt-4">
        <div class="col-12">
            <h5 class="d-inline">Step 2 of 7 - Set visibility constraints on survey data</h5>
            <g:render template="/projectActivity/status"/>
        </div>
    </div>
    <g:render template="/projectActivity/warning"/>
    <div class="row">
        <div class="col-12">
            <p>Setting visibility constraints will withhold data from public view for the specified period. These can be changed,
            but once data has been published to the public domain it cannot be withdrawn via this tool.
            Please contact <a
                    href="mailto:support@ala.org.au?subject=BioCollect enquiry - data">support@ala.org.au</a> if you have further questions.
            </p>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="form-check">
                <input class="form-check-input" type="radio" value="NONE" data-bind="checked: visibility.embargoOption"
                          name="embargoOptionNone"/>
                <label class="form-check-text">Records publicly visible on submission</label>
            </div>
            <div class="form-check">
                <input class="form-check-input" type="radio" value="DAYS" data-bind="checked: visibility.embargoOption"
                       name="embargoOptionDays"/>
                <label class="form-check-text">
                    Records publicly visible after
                    <input class="input-small" data-bind="value:visibility.embargoForDays"
                       data-validation-engine="validate[custom[number],min[1],max[180]]" type="number" min="1"
                       max="180"> days. Choose between 1 and 180.
                </label>
            </div>

            <div class="form-check">
                <input class="form-check-input" type="radio" value="DATE" data-bind="checked: visibility.embargoOption"
                       name="embargoOptionDate" id="embargoOptionDate"/>
                <label class="form-check-text">Embargo publishing all records until
                    <span class="input-group display">
                        <input class="form-control" name="embargoUntilDate" id="embargoUntilDate"
                               data-bind="datepicker: visibility.embargoUntil.date, datePickerOptions: {endDate: '+12m', startDate: '+1d'}, disable: transients.disableEmbargoUntil"
                               data-validation-engine="validate[funcCall[isEmbargoDateRequired]]" type="text"/>

                        <div class="input-group-append">
                            <button class="btn btn-dark open-datepicker"><i class="far fa-calendar-alt"></i></button>
                        </div>
                </label>
            </span>
            </div>
        </div>

    </div>

    <g:if test="${fc.userIsAlaOrFcAdmin()}">
        <hr>
        <h6>ALA ADMIN Only:</h6>

        <div class="form-check">
            <input class="form-check-input" type="checkbox" data-bind="checked: visibility.alaAdminEnforcedEmbargo"/>
            <label class="form-check-text"><g:message code="project.survey.visibility.adminEmbargo"/></label>
        </div>
        <hr>
    </g:if>
<!-- ko if: visibility.alaAdminEnforcedEmbargo() -->
    <span class="text-muted"><g:message code="project.survey.visibility.adminEmbargo.important"/><a
            href='${grailsApplication.config.biocollect.support.email.address}'>${grailsApplication.config.biocollect.support.email.address}</a>
    </span>
    <!-- /ko -->
    <g:render template="/projectActivity/indexingNote"/>
    <!-- /ko -->
    <!-- /ko -->
</div>

<div class="row">
    <div class="col-12">
        <button class="btn-primary-dark btn btn-sm" data-bind="click: saveVisibility"><i class="fas fa-hdd"></i> Save
        </button>
        <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-info-tab'}"><i
                class="far fa-arrow-alt-circle-left"></i> Back</button>
        <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-alert-tab'}"><i
                class="far fa-arrow-alt-circle-right"></i> Next</button>
    </div>
</div>


