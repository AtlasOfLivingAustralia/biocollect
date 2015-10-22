<style type="text/css">
    .projectLogo {
        width: 200px;
        height: 150px;
        line-height: 146px;
        overflow: hidden;
        padding: 1px;
        text-align: center;
    }
    .projectType {
        padding-right: 10px;
        padding-left: 10px;
        background: grey;
        color: white;
        white-space: pre-line;
        display: inline-block;
        text-align: center;
    }
    input[type=checkbox] {
        margin-right: 5px;
    }
    #pt-downloadLink {
        margin-bottom: 10px;
    }
</style>
<div id="pt-table">
    <ul class="nav nav-tabs">
    <li>
    <a data-bind="click:hideshow"><g:message code="g.search.hideShow"/></a>
    </li>
    </ul>
<div id="pt-selectors" class="well" style="display:none">
    <g:if test="${fc.userIsAlaOrFcAdmin()}">
        <div class="row-fluid">
            <a href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning span2 pull-right"
               title="${message(code:'project.download.tooltip')}">
                <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download" /></a>
        </div>
    </g:if>
    <div class="row-fluid">
        <span class="span2" id="pt-resultsReturned"></span>
        <div class="span8 input-append">
            <input class="span12" type="text" name="pt-search" id="pt-search" placeholder="${message(code:'g.search.placeHolder')}"/>
        </div>
        <div class="pull-right">
            <a href="javascript:void(0);" title="${message(code:'project.search.term.tooltip')}" id="pt-search-link" class="btn"><g:message code="g.search" /></a>
            <a href="javascript:void(0);" title="${message(code:'g.resetSearch.tooltip')}" id="pt-reset" class="btn"><g:message code="g.resetSearch" /></a>
        </div>
    </div>
    <div id="pt-searchControls" class="row-fluid">
        <div id="pt-sortWidgets">
            <div class="span3">
                <label for="pt-per-page"><g:message code="g.projects"/>&nbsp;<g:message code="g.perPage"/></label>
                <g:select name="pt-per-page" from="[20,50,100,500]"/>
            </div>
            <div class="span3">
                <label for="pt-sort"><g:message code="g.sortBy" /></label>
                <select id="pt-sort" data-bind="options:sortKeys, optionsText:'name', optionsValue:'value'"></select>
            </div>
            <div class="span3">
                <label for="pt-dir"><g:message code="g.sortOrder" /></label>
                <g:select name="pt-dir" from="['Ascending','Descending']" keys="[1,-1]"/>
            </div>
<g:if test="${controllerName == 'organisation'}">
            <div class="span3">
                <label for="pt-search-projecttype"><g:message code="project.search.projecttype" /></label>
                <select id="pt-search-projecttype" multiple data-bind="options:availableProjectTypes, optionsText:'name', optionsValue:'value'" style="width:100%"></select>
                <label><g:message code="g.multiselect.help" /></label>
            </div>
</g:if>
<g:else>
            <div class="span3">
                <label for="pt-search-difficulty"><g:message code="project.search.difficulty" /></label>
                <g:select name="pt-search-difficulty" from="['Any','Easy','Medium','Hard']"/>
            </div>
</g:else>
        </div>
    </div><!--drop downs-->
<g:if test="${controllerName != 'organisation'}">
    <div class="row-fluid">
        <div class="span4">
            <label class="checkbox"><input id="pt-search-active" type="checkbox" checked /><g:message code="project.search.active" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-diy" type="checkbox" /><g:message code="project.tag.diy" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-noCost" type="checkbox" /><g:message code="project.tag.noCost" /></label>
        </div>
    </div>
    <div class="row-fluid">
        <div class="span4">
            <label class="checkbox"><input id="pt-search-teach" type="checkbox" /><g:message code="project.tag.teach" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-children" type="checkbox" /><g:message code="project.tag.children" /></label>
        </div>
        <div class="span4">
            <label class="checkbox"><input id="pt-search-mobile" type="checkbox" /><g:message code="g.mobileApps" /></label>
        </div>
    </div>
</g:if>
</div>
<p/>
<table class="table table-hover">
    <tbody data-bind="foreach:pageProjects">
    <tr style="border-bottom: 2px solid grey">
        <td style="width:200px">
            <div class="projectLogo well">
                <img style="max-width:100%;max-height:100%" alt="${message(code:'g.noImage')}" data-bind="attr:{title:name,src:transients.imageUrl}"/>
            </div>
        </td>
        <td>
            <a data-bind="attr:{href:transients.indexUrl}">
                <span data-bind="text:name" style="font-size:150%;font-weight:bold"></span>
            </a>
            <div data-bind="visible:transients.orgUrl">
                <span data-bind="visible:transients.daysSince() >= 0" style="font-size:80%;color:grey">Started <!--ko text:transients.since--><!--/ko-->&nbsp;</span>
                <g:if test="${controllerName != 'organisation'}">
                    <a data-bind="text:organisationName,attr:{href:transients.orgUrl}"></a>
                </g:if>
            </div>
            <div data-bind="text:aim"></div>
            <div style="padding: 4px">
                <i class="icon-info-sign"></i>&nbsp;<span data-bind="html:transients.links"/>
            </div>
            <div style="line-height:2.2em">
                TAGS:&nbsp;<g:render template="/project/tags"/>
            </div>
            <br/>
            <div data-bind="visible:transients.daysSince() >= 0">
                <b><g:message code="project.display.status" /></b>
                <g:render template="/project/daysline"/>
            </div>
            <div data-bind="visible:transients.daysSince() >= 0 && transients.daysRemaining() == 0">
                <g:message code="project.display.concluded" /> <a data-bind="attr:{href:transients.indexUrl}">
                <span style="font-weight:bold"><g:message code="project.display.view" /></span></a>
            </div>
        </td>
        <td style="width:10em;text-align:center">
            <g:render template="/project/dayscount"/>
<g:if test="${controllerName == 'organisation'}">
            <span class="projectType" data-bind="text:transients.kindOfProjectDisplay"></span>
</g:if>
        </td>
    </tr>
    </tbody>
</table>

<div id="pt-searchNavBar" class="clearfix">
    <div id="pt-navLinks"></div>
</div>

</div>
<r:script>
var paramsFuc;

$(document).ready(function () {
    /* holds all projects */
    var allProjects = [];

    /* holds current filtered list */
    var projects;

    /* pagination offset into the record set */
    var offset = 0;

    /* size of current filtered list */
    var total = 0;

    var searchTerm = '', perPage = 20, sortBy = 'name', sortOrder = 1;

    /* window into current page */
    function pageVM() {
        this.pageProjects = ko.observableArray();
        this.availableProjectTypes = ko.observableArray();
        this.sortKeys = ko.observableArray();
        this.hideshow = function() {
          $("#pt-selectors").toggle();
        }
    }
    var pageWindow = new pageVM();
    ko.applyBindings(pageWindow, document.getElementById('pt-table'));

    function getParams(){
        var params = {
                'isSuitableForChildren': $('#pt-search-children').prop('checked'), // child friendly
                'difficulty': $('#pt-search-difficulty').val(), // difficulty level
                'isDIY': $('#pt-search-diy').prop('checked'), // DIY
                'status': $('#pt-search-active').prop('checked'), // active check field status
                'hasParticipantCost': $('#pt-search-noCost').prop('checked'), // no cost
                'hasTeachingMaterials': $('#pt-search-teach').prop('checked'), // teaching material
                'isMobile': $('#pt-search-mobile').prop('checked'), // mobile uses links to find it out
                'pageSize': perPage, // page size
                'sortOrder': sortOrder, // sort order
                'sortBy': sortBy,
                'searchTerm':$('#pt-search').val().toLowerCase()
        }
        return params;
    }


    /*************************************************\
     *  Filter projects by search term
     \*************************************************/
    function doSearch(force) {
      var showActiveOnly = $('#pt-search-active').prop('checked'),
          showSuitableForChildrenOnly = $('#pt-search-children').prop('checked'),
          showDifficultyOnly = $('#pt-search-difficulty').val(),
          showProjectTypeOnly = $('#pt-search-projecttype').val(),
          showDIYOnly = $('#pt-search-diy').prop('checked'),
          showNoCostOnly = $('#pt-search-noCost').prop('checked'),
          showTeachOnly = $('#pt-search-teach').prop('checked'),
          showWithMobileAppsOnly = $('#pt-search-mobile').prop('checked'),
          val = $('#pt-search').val().toLowerCase();
        if (showDifficultyOnly === "Any") showDifficultyOnly = null;
        if (!force && val == searchTerm) return;
        searchTerm = val;
        projects = [];
        for (var i = 0; i < allProjects.length; i++) {
            var item = allProjects[i];
            if (!item) continue;
            if (showActiveOnly && item.daysStatus() != 'active') continue;
            if (showSuitableForChildrenOnly && !item.isSuitableForChildren()) continue;
            if (showDifficultyOnly && item.difficulty() != showDifficultyOnly) continue;
            // not used in citizen science project finder.
            if (showProjectTypeOnly && showProjectTypeOnly.indexOf(item.transients.kindOfProject()) < 0) continue;
            if (showDIYOnly && !item.isDIY()) continue;
            if (showTeachOnly && !item.hasTeachingMaterials()) continue;
            if (showNoCostOnly && item.hasParticipantCost()) continue;
            if (showWithMobileAppsOnly && !item.transients.mobileApps().length) continue;
            if (item.transients.searchText.indexOf(searchTerm) >= 0)
                projects.push(item);
        }
        offset = 0;
        updateTotal();
        populateTable();
    }
    function doSearchForce() {
        doSearch(true);
    }

    /*************************************************\
     *  Show filtered projects on current page
     \*************************************************/
    function populateTable() {
        pageWindow.pageProjects(projects.slice(offset, offset + perPage));
        pageWindow.pageProjects.valueHasMutated();
        showPaginator();
    }

    /** display the current size of the filtered list **/
    function updateTotal() {
        total = projects.length;
        $('#pt-resultsReturned').html("Found <strong>" + total + "</strong> " + (total == 1 ? 'project.' : 'projects.'));
    }

    /*************************************************\
     *  Pagination
     \*************************************************/
    /** build and append the pagination widget **/
    function showPaginator() {
        if (total <= perPage) {
            // no pagination required
            $('div#pt-navLinks').html("");
            return;
        }
        var currentPage = Math.floor(offset / perPage) + 1;
        var maxPage = Math.ceil(total / perPage);
        var $ul = $("<ul></ul>");
        // add prev
        if (offset > 0)
            $ul.append('<li><a href="javascript:pago.prevPage();">&lt;</a></li>');
        for (var i = currentPage - 3, n = 0; i <= maxPage && n < 7; i++) {
            if (i < 1) continue;
            n++;
            if (i == currentPage)
                $ul.append('<li><a href="#" class="currentStep">' + i + '</a></li>');
            else
                $ul.append('<li><a href="javascript:pago.gotoPage(' + i + ');">' + i + '</a></li>');
        }
        // add next
        if ((offset + perPage) < total)
            $ul.append('<li><a href="javascript:pago.nextPage();">&gt;</a></li>');

        var $pago = $("<div class='pagination'></div>");
        $pago.append($ul);
        $('div#pt-navLinks').html($pago);
    }

    var meritProjectLogo;
<g:if test="${grailsApplication.config.merit.projectLogo}">
    meritProjectLogo = fcConfig.imageLocation + "/" + "${grailsApplication.config.merit.projectLogo}";
</g:if>

    function augmentVM(vm) {
        var x, urls = [];
        if (vm.urlWeb()) urls.push('<a href="' + vm.urlWeb() + '">Website</a>');
        for (x = "", docs = vm.transients.mobileApps(), i = 0; i < docs.length; i++)
          x += '&nbsp;<a href="' + docs[i].link.url + '"><img class="logo-small" src="' + docs[i].logo(fcConfig.logoLocation) + '"/></a>';
        if (x) urls.push("Mobile Apps&nbsp;" + x);
        for (x = "", docs = vm.transients.socialMedia(), i = 0; i < docs.length; i++)
          x += '&nbsp;<a href="' + docs[i].link.url + '"><img class="logo-small" src="' + docs[i].logo(fcConfig.logoLocation) + '"/></a>';
        if (x) urls.push("Social Media&nbsp;" + x);
        vm.transients.links = urls.join('&nbsp;&nbsp;|&nbsp;&nbsp;') || '';
        vm.transients.searchText = (vm.name() + ' ' + vm.aim() + ' ' + vm.description() + ' ' + vm.keywords() + ' ' + vm.transients.scienceTypeDisplay() + ' ' + vm.transients.locality + ' ' + vm.transients.state + ' ' + vm.organisationName()).toLowerCase();
        vm.transients.indexUrl = "${createLink(controller:'project',action:'index')}/" + vm.transients.projectId;
        vm.transients.orgUrl = vm.organisationId() && ("${createLink(controller:'organisation',action:'index')}/" + vm.organisationId());
        vm.transients.imageUrl = meritProjectLogo && vm.isMERIT()? meritProjectLogo: vm.logoUrl();
        if (!vm.transients.imageUrl) {
          x = vm.primaryImages();
          if (x && x.length > 0) vm.transients.imageUrl = x[0].url;
        }
        return vm;
    }

    window.pago = {
        init: function(projs) {
            var hasPrograms = false;
            projects = allProjects = [];
            $.each(projs, function(i, project) {
                allProjects.push(augmentVM(project));
                if (project.associatedProgram()) hasPrograms = true;
            });
            if (projects.length > 0) {
                pageWindow.availableProjectTypes(projects[0].transients.availableProjectTypes);
                pageWindow.availableProjectTypes.valueHasMutated();
                $('#pt-search-projecttype option').prop('selected', true);
                var sortKeys = [
                    {name:'Name', value:'name'},
                    {name:'Aim', value:'aim'},
                    {name:'Organisation Name', value:'organisationName'},
                    {name:'Status', value:'daysStatus'}
                ];
                if (hasPrograms)
                    sortKeys.push({name:'Programme', value:'associatedProgram'},{name:'Sub Programme', value:'associatedSubProgram'});
                pageWindow.sortKeys(sortKeys);
                pageWindow.sortKeys.valueHasMutated();
            }
            allProjects.sort(comparator); // full list is sorted by name
            doSearchForce();
        },
        gotoPage: function(pageNum) {
            offset = (pageNum - 1) * perPage;
            populateTable();
            $('html,body').scrollTop(0);
        },
        prevPage: function() {
            offset -= perPage;
            populateTable();
            $('html,body').scrollTop(0);
        },
        nextPage: function() {
            offset += perPage;
            populateTable();
            $('html,body').scrollTop(0);
        }
    }

    /* comparator for data projects */
    function comparator(a, b) {
        var va = a[sortBy](), vb = b[sortBy]();
        va = va? va.toLowerCase(): '';
        vb = vb? vb.toLowerCase(): '';
        if (va == vb && sortBy != 'name') { // sort on name
            va = a.name().toLowerCase();
            vb = b.name().toLowerCase();
        }
        return (va < vb ? -1 : (va > vb ? 1 : 0)) * sortOrder;
    }

    $('#pt-per-page').change(function () {
        perPage = $(this).val();
        offset = 0;
        populateTable();
    });
    $('#pt-sort').change(function () {
        sortBy = $(this).val();
        projects.sort(comparator);
        populateTable();
    });
    $('#pt-dir').change(function () {
        sortOrder = $(this).val();
        projects.sort(comparator);
        populateTable();
    });
    $('#pt-search-link').click(function () {
        doSearch();
    });
    $('#pt-search').keypress(function (event) {
        if (event.which == 13) {
            event.preventDefault();
            doSearch();
        }
    });
    $('#pt-reset').click(function () {
        $('#pt-search').val('');
        doSearchForce();
    });
    $('#pt-search-active').on('change', doSearchForce);
    $('#pt-search-children').on('change', doSearchForce);
    $('#pt-search-difficulty').change(doSearchForce);
    $('#pt-search-projecttype').change(doSearchForce);
    $('#pt-search-diy').on('change', doSearchForce);
    $('#pt-search-noCost').on('change', doSearchForce);
    $('#pt-search-teach').on('change', doSearchForce);
    $('#pt-search-mobile').on('change', doSearchForce);
    <g:if test="${controllerName != 'organisation'}">
        $('#pt-selectors').show();
    </g:if>
    initialiseProjectFinder(getParams());
});
</r:script>
