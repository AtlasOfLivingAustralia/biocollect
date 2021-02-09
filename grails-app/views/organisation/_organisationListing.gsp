<div class="container-fluid">
    <g:if test="${allowOrganisationRegistration}">
        <div>
            <h2 style="display:inline">Registered

            Organisations</h2>

            <g:if test="${user}">
                <button class="btn btn-success pull-right"
                        data-bind="click:addOrganisation">Register new organisation</button>
            </g:if>
        </div>
    </g:if>
    <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.ORGANISATION_LIST_PAGE_HEADER}"/>
    <h2>Organisations</h2>

    <div class="row-fluid well">
        <div class="span8 input-append">
            <input id="searchText" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup'"
                   class="input-xxlarge" placeholder="Search organisations..." type="text"/>
            <br>
            <button class="btn btn-primary btn-sm"><i class="fa fa-search"></i> <g:message code='g.search'/></button>
        </div>

        <div class="span4">
            <g:if test="${fc.userIsAlaOrFcAdmin()}">
                <a href="${g.createLink(action: 'create')}"><button
                        class="btn btn-info pull-right">Create Organisation</button></a>
            </g:if>
        </div>
    </div>

    <div class="well">
        <h4>Found <span data-bind="text:pagination.totalResults"></span> organisations</h4>
        <br>
        <!-- ko foreach : organisations -->
        <div class="row-fluid organisation">
            <div class="organisation-logo"><img class="logo"
                                                data-bind="attr:{'src': logoUrl() ? logoUrl():fcConfig.noLogoImageUrl}">
            </div>

            <div class="organisation-text">
                <h4>
                    <a data-bind="visible:organisationId,attr:{href:fcConfig.viewOrganisationUrl+'/'+organisationId}"><span
                            data-bind="text:name"></span></a>
                    <span data-bind="visible:!organisationId,text:name"></span>
                </h4>

                <div data-bind="html:description.markdownToHtml()"></div>
            </div>
        </div>
        <hr/>
        <!-- /ko -->
    </div>

    <div class="row-fluid">
        <g:render template="/shared/pagination"/>
    </div>
</div>


<asset:script type="text/javascript">

    $(function () {
        var organisationsViewModel = new OrganisationsViewModel();
        ko.applyBindings(organisationsViewModel);
    });

</asset:script>