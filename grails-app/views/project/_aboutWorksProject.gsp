%{--To be removed once #595 and related tickets are finalised--}%

<!-- OVERVIEW -->
<div class="row-fluid">
    <div class="clearfix" data-bind="visible:organisationId()||organisationName()">
        <h4>
            Recipient:
            <a data-bind="visible:organisationId(),text:organisationName,attr:{href:fcConfig.organisationLinkBaseUrl + '/' + organisationId()}"></a>
            <span data-bind="visible:!organisationId(),text:organisationName"></span>
        </h4>
    </div>
    <div class="clearfix" data-bind="visible:serviceProviderName()">
        <h4>
            Service provider:
            <span data-bind="text:serviceProviderName"></span>
        </h4>
    </div>
    <div class="clearfix" data-bind="visible:associatedProgram()">
        <h4>
            Programme:
            <span data-bind="text:associatedProgram"></span>
            <span data-bind="text:associatedSubProgram"></span>
        </h4>
    </div>
    <div class="clearfix" data-bind="visible:funding()">
        <h4>
            Approved funding (GST inclusive): <span data-bind="text:funding.formattedCurrency"></span>
        </h4>

    </div>

    <div class="clearfix" data-bind="visible:plannedStartDate()">
        <h4>
            Project start: <span data-bind="text:plannedStartDate.formattedDate"></span>
            <span data-bind="visible:plannedEndDate()">Project finish: <span data-bind="text:plannedEndDate.formattedDate"></span></span>
        </h4>
    </div>

    <div class="clearfix" style="font-size:14px;">
        <div class="span3" data-bind="visible:status" style="margin-bottom: 0">
            <span data-bind="if: status().toLowerCase() == 'active'">
                Project Status:
                <span style="text-transform:uppercase;" data-bind="text:status" class="badge badge-success" style="font-size: 13px;"></span>
            </span>
            <span data-bind="if: status().toLowerCase() == 'completed'">
                Project Status:
                <span style="text-transform:uppercase;" data-bind="text:status" class="badge badge-info" style="font-size: 13px;"></span>
            </span>

        </div>
        <div class="span4" data-bind="visible:grantId" style="margin-bottom: 0">
            Grant Id:
            <span data-bind="text:grantId"></span>
        </div>
        <div class="span4" data-bind="visible:externalId" style="margin-bottom: 0">
            External Id:
            <span data-bind="text:externalId"></span>
        </div>
        <div class="span4" data-bind="visible:manager" style="margin-bottom: 0">
            Manager:
            <span data-bind="text:manager"></span>
        </div>
    </div>
    <g:render template="/shared/listDocumentLinks"
              model="${[transients:transients,imageUrl:asset.assetPath(src:'filetypes')]}"/>

    <div class="clearfix" data-bind="visible:description()">
        <p class="well well-small more" data-bind="text:description"></p>
    </div>
</div>
<div class="row-fluid">
    <!-- show any primary images -->
    <div data-bind="visible:primaryImages() !== null,foreach:primaryImages,css:{span5:primaryImages()!=null}">
        <div class="thumbnail with-caption space-after">
            <img class="img-rounded" data-bind="attr:{src:url, alt:name}" alt="primary image"/>
            <p class="caption" data-bind="text:name"></p>
            <p class="attribution" data-bind="visible:attribution"><small><span data-bind="text:attribution"></span></small></p>
        </div>
    </div>

    <div class="span10">
        <h4>Project Blog</h4>
        <div class="well">
            <g:render template="/shared/blog" model="${[blog:project.blog?:[]]}"/>
        </div>
        <div data-bind="visible:newsAndEvents()">
            <h4>News and events</h4>
            <div id="newsAndEventsDiv" data-bind="html:newsAndEvents" class="well"></div>
        </div>
        <div data-bind="visible:projectStories()">
            <h4>Project stories</h4>
            <div id="projectStoriesDiv" data-bind="html:projectStories" class="well"></div>
        </div>
    </div>
</div>