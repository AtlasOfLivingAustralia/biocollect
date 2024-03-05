<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="config" value="${grailsApplication.config.refAssess}" />
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${config.title}</title>

    <asset:javascript src="requestAssessmentRecordsModel.js"/>
    <asset:stylesheet src="reference-assessment.css" />
</head>
<body>
<content tag="bannertitle">
    ${config.title}
</content>

<div class="container" id="hubRequestAssessmentRecords">
    <div class="row my-4">
        <div class="col-12">
            <div class="f-flex flex-column h-100 p-3">
                <h2 class="text-secondary">Select the ${config.reference.filterName} you&apos;d like to assess</h2>
                <div class="d-flex flex-column card bg-white ref-assess-filters-list">
                    <!-- ko foreach: filters -->
                    <div data-bind="click: $parent.onFilterSelect, css: { disabled: $parent.isLoading() }" class="d-flex flex-row dropdown-item align-items-center">
                        <span data-bind="style: { opacity: $parent.isFilterSelected($data) ? 1 : 0 }" class="fa fa-check mr-3"></span>
                        <p data-bind="text: $data" style="text-wrap: wrap; margin-bottom: 0px"></p>
                    </div>
                    <!-- /ko -->
                </div>
            </div>
        </div>
        <div class="col-6">
            <div class="py-3 pl-3">
                <button type="button" data-bind="click: function() { deIdentify(false) }, css: { 'bg-secondary': !deIdentify() }, enable: !isLoading()" class="card w-100 d-flex flex-column px-4 py-3 ref-assess-identify-card">
                    <span data-bind="css: { 'text-white': !deIdentify() }" class="fa fa-user fa-2x"></span>
                    <span data-bind="css: { 'text-white': !deIdentify() }" class="mt-3 ref-assess-identify-text">Identify my data</span>
                </button>
            </div>
        </div>
        <div class="col-6">
            <div class="py-3 pr-3">
                <button type="button" data-bind="click: function() { deIdentify(true) }, css: { 'bg-secondary': deIdentify() }, enable: !isLoading()" class="card w-100 d-flex flex-column px-4 py-3 ref-assess-identify-card">
                    <span data-bind="css: { 'text-white': deIdentify() }" class="fa fa-user-secret fa-2x"></span>
                    <span data-bind="css: { 'text-white': deIdentify() }" class="mt-3 ref-assess-identify-text">De-identify my data</span>
                </button>
            </div>
        </div>
        <div class="col-12 pt-2">
            <div class="d-flex justify-content-center p-3">
                <button data-bind="click: onRequestRecords, css: {disabled: selected().length === 0 || isLoading()}, enable: selected().length > 0 && !isLoading()" class="btn btn-primary justify-self-end full-width">
                    <i data-bind="visible: !isLoading()" class="far fa-copy mr-2"></i>
                    <span data-bind="visible: isLoading()" class="fa fa-spin fa-spinner mr-2"></span>
                    Request Records
                </button>
            </div>
        </div>
    </div>
    <asset:script type="text/javascript">
        const requestAssessmentRecordsVM = new RequestAssessmentRecordsModel(
            <fc:modelAsJavascript model="${config.reference.filterTypes}" />
        );

        ko.applyBindings(requestAssessmentRecordsVM);
    </asset:script>
</body>
</html>