<div class="container">
    <g:if test="${allowOrganisationRegistration}">
        <div class="row">
            <div class="col-12">
                <h2 class="d-inline">Registered Organisations</h2>

                <g:if test="${user}">
                    <button class="btn btn-success float-right"
                            data-bind="click:addOrganisation">Register new organisation</button>
                </g:if>
            </div>
        </div>
    </g:if>
    <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.ORGANISATION_LIST_PAGE_HEADER}"/>
    <h2>Organisations</h2>

    <div class="row mb-3 justify-content-between">
        <div class="col-md-6">
            <div class="input-group">
                <input class="form-control" id="searchText" type="text" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup'"
                       placeholder="Search organisations..." aria-label="Search organisations..." aria-describedby="org-search-button"/>

                <div class="input-group-append">
                    <button class="btn btn-primary btn-sm" id="org-search-button"><i class="fa fa-search"></i> Search</button>
                </div>
            </div>
        </div>

        <div class="col-md-4 text-right mt-2 mt-md-0">
            <g:if test="${fc.userIsAlaOrFcAdmin()}">
            <a class="btn btn-info" href="${g.createLink(action: 'create')}" role="button">Create Organisation</a>
            </g:if>
        </div>
    </div>

    <div class="row mb-2">
        <div class="col-12">
            <div class="border-top border-bottom border-dark py-3">
                <h6 class="m-0">Found <!-- ko text:pagination.totalResults --> <!-- /ko --> organisations</h6>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- ko foreach : organisations -->
        <div class="col-12 col-md-6 col-xl-4 organisation project-item">
%{--            <div class="organisation-logo"><img class="logo"--}%
%{--                                                data-bind="attr:{'src': logoUrl() ? logoUrl():fcConfig.noLogoImageUrl}">--}%
%{--            </div>--}%
            <a class="project-image" data-bind="attr: {href: fcConfig.viewOrganisationUrl+'/'+organisationId, title: name}">
                <div class="project-image-inner">
    %{--                <img src="assets/img/example1.jpg" alt="Project Title">--}%
                    <img class="logo"
                         data-bind="attr:{'src': logoUrl() ? logoUrl():fcConfig.noLogoImageUrl, 'alt': 'Logo of ' + name()}">
                </div>
            </a>
            <a class="project-link" data-bind="visible:organisationId,attr:{href:fcConfig.viewOrganisationUrl+'/'+organisationId}, title: name">
                <h4 data-bind="text: name"></h4>
            </a>
            <div class="excerpt" data-bind="html:description.markdownToHtml()"></div>
%{--            <div class="organisation-text">--}%
%{--                <h4>--}%
%{--                    <a data-bind="visible:organisationId,attr:{href:fcConfig.viewOrganisationUrl+'/'+organisationId}"><span--}%
%{--                            data-bind="text:name"></span></a>--}%
%{--                    <span data-bind="visible:!organisationId,text:name"></span>--}%
%{--                </h4>--}%

%{--                <div data-bind="html:description.markdownToHtml()"></div>--}%
%{--            </div>--}%
        </div>
        <!-- /ko -->
    </div>

    <g:render template="/shared/pagination" model="[bs: 4]"/>
</div>


<asset:script type="text/javascript">

    $(function () {
        var organisationsViewModel = new OrganisationsViewModel();
        ko.applyBindings(organisationsViewModel);
    });

</asset:script>