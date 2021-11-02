<div class="row">
    <div class="col-12">
        <h6>b. Who do you want to be notified?</h6>
    </div>
</div>

<div class="row mt-2">
    <div class="col-12">
        <div class="row form-group">
            <label class="col-form-label col-12 col-md-4" for="alertEmailAddress">
                Email address:
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message
                           code="project.survey.alert.emailaddress"/>', content:'<g:message
                           code="project.survey.alert.emailaddress.content"/>'}">
                    <i class="fas fa-info-circle"></i>
                </a>
            </label>

            <div class="col-12 col-md-4">
                <input id="alertEmailAddress" class="form-control" type="text"
                       data-bind="value: alert.transients.emailAddress, valueUpdate:'afterkeyup'"
                       placeholder="Enter email address"/>
                <button class="btn-dark btn btn-sm m-1" data-toggle="tooltip" title="Enter valid email address"
                        data-bind="click: alert.addEmail, disable: alert.transients.disableAddEmail"><i
                        class="fas fa-plus"></i>  Add</button>
            </div>
        </div>
    </div>

    <!-- ko if: alert.emailAddresses().length > 0 -->
    <div class="col-12">
        <div class="row">
            <label class="col-12 col-md-4">Email Addresses:</label>

            <div class="col-12 col-md-8">
                <!-- ko foreach: alert.emailAddresses -->
                <div class="row mt-1">
                    <div class="col-10">
                        <span data-bind="text: $index()+1">.</span>
                        <span data-bind="text: $data"></span>
                    </div>

                    <div class="col-2">
                        <button class="btn btn-sm btn-danger" data-bind="click: $parent.alert.deleteEmail"><i
                                class="far fa-trash-alt"></i></button>
                    </div>
                </div>
                <!-- /ko -->
            </div>
        </div>
    </div>
    <!-- /ko -->

</div>