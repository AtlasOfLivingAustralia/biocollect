<div class="row-fluid" data-bind="visible:mainImageUrl">
    <div class="span12 banner-image-container">
        <img src="" data-bind="attr: {src: mainImageUrl}" class="banner-image"/>
        <div data-bind="visible:url" class="banner-image-caption"><strong><g:message code="g.visitUsAt" /> <a data-bind="attr:{href:url}"><span data-bind="text:url"></span></a></strong></div>
    </div>
</div>

<div id="weburl" data-bind="visible:!mainImageUrl()">
    <div data-bind="visible:url()"><strong>Visit us at <a data-bind="attr:{href:url}"><span data-bind="text:url"></span></a></strong></div>
</div>

<div data-bind="visible:description">
    <div class="span12 well">
        <div class="well-title">About ${organisation.name}</div>

        <span data-bind="html:description.markdownToHtml()"></span>
    </div>
</div>

<g:if test="${includeProjectList}">

    <div class="well-header"><h2>Projects</h2></div>

    <!-- ko stopBinding: true -->
    <div id="pt-root" class="row-fluid">
        <g:render template="/project/projectsList"/>
    </div>
    <!-- /ko -->

    <r:script>
        $(function() {

            var organisation =<fc:modelAsJavascript model="${organisation}"/>;
            var projectVMs = [];
            $.each(organisation.projects, function(i, project) {
                projectVMs.push(new ProjectViewModel(project, false, organisation));
            });
            window.pago.init(projectVMs);
        });
    </r:script>
</g:if>