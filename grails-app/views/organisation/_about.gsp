<div id="carousel" class="slider-pro row-fluid" data-bind="visible:mainImageUrl()" style="margin-bottom:20px;">
    <div class="sp-slides">
        <div class="sp-slide">
            <img class="sp-image" data-bind="attr:{'data-src':mainImageUrl}"/>
            <p class="sp-layer sp-white sp-padding"
               data-position="topLeft" data-width="100%" data-bind="visible:url"
               data-show-transition="down" data-show-delay="0" data-hide-transition="up">
                <strong>Visit us at <a data-bind="attr:{href:url}"><span data-bind="text:url"></span></a></strong>
            </p>
        </div>
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