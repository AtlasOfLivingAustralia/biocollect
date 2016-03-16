<div class="row-fluid">
    <div class="span12 text-left">
        <h4>b. Who do you want to be notified?</h4>
    </div>
</div>
<div class="margin-bottom-1"></div>
<div class="row-fluid">
    <div class="span6 text-left">
        <label for="alertEmailAddress">
            Email address:
            <a href="#" class="helphover" data-bind="popover: {title:'<g:message code="project.survey.alert.emailaddress"/>', content:'<g:message code="project.survey.alert.emailaddress.content"/>'}">
                <i class="icon-question-sign"></i>
            </a>
        </label>
        <input id="alertEmailAddress" class="input-xlarge" type="text" data-bind="value: alert.transients.emailAddress, valueUpdate:'afterkeyup'" placeholder="Enter email address"/>
        <div class="margin-bottom-5"></div>
        <button class="btn-default btn block btn-small" data-toggle="tooltip" title="Enter valid email address"
                data-bind="click: alert.addEmail, disable: alert.transients.disableAddEmail"><i class="icon-plus" ></i>  Add</button>
    </div>

    <!-- ko if: alert.emailAddresses().length > 0 -->
    <div class="span6 text-left">
        <label>Email Addresses:</label>
        <!-- ko foreach: alert.emailAddresses -->
        <div class="span10 text-left">
            <div class="span6 text-left">
                <span data-bind="text: $index()+1">. </span>
                <span data-bind="text: $data"></span>
            </div>

            <div class="span2 text-left">
                <a href="#" data-bind="click: $parent.alert.deleteEmail"><span class="fa fa-close"></span></a>
            </div>
        </div>
        <!-- /ko -->
    </div>
    <!-- /ko -->

</div>

<div class="margin-bottom-2"></div>