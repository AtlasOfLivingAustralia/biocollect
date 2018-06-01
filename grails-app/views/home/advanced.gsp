<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Advanced | Field Capture</title>
    <asset:script type="text/javascript">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
    }
    </asset:script>
    <asset:javascript src="common.js"/>
</head>
<body>
<div id="wrapper" class="container-fluid">

    <div class="row-fluid large-space-after large-space-before button-set">
        <g:link controller="project" action="create" class="btn btn-medium"><img src="${asset.assetPath(src:'icons/project.png')}" /> Add a project</g:link>
        <g:link controller="site" action="create" class="btn btn-medium"><img src="${asset.assetPath(src:'icons/site.png')}" /> Add a site</g:link>
        <g:link controller="activity" action="create" class="btn btn-medium"><img src="${asset.assetPath(src:'icons/activity.png')}"/> Add an activity</g:link>
        <g:link controller="assessment" action="create" class="btn btn-medium"><img src="${asset.assetPath(src:'icons/assessment.png')}"/> Add an assessment</g:link>
        <form action="search" class="form-search pull-right">
            <div class="control-group">
                <div class="controls">
                    <g:textField class="search-query input-medium" name="search"/>
                    <button type="submit" class="btn">Search</button>
                </div>
            </div>
        </form>
    </div>

    <g:if test="${flash.error}">
        <div class="row-fluid">
            <div class="alert alert-error">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <span>${flash.error}</span>
            </div>
        </div>
    </g:if>

    <div class="row-fluid">

        <div class="span4 well list-box">
            <h2>Projects</h2>
            <span id="project-filter-warning" class="label filter-label label-warning"
                  style="display:none;">Filtered</span>
            <div class="control-group">
                <div class="input-append">
                    <g:textField class="filterinput input-medium" data-target="project"
                                 title="Type a few characters to restrict the list." name="projects"
                                 placeholder="filter"/>
                    <button type="button" class="btn clearFilterBtn"
                            title="clear"><i class="icon-remove"></i></button>
                </div>
            </div>
            <div class="scroll-list"><ul id="projectList">
                <g:each in="${projects}" var="p">
                    <li>
                        <g:link controller="project" action="index" id="${p.projectId}" params="[returnTo:'']">${p.name}</g:link>
                    </li>
                </g:each>
            </ul></div>
        </div>

        <div class="span4 well list-box">
            <h2>Sites</h2>
            <span id="site-filter-warning" class="label filter-label label-warning"
                  style="display:none;"
            %{--data-bind="visible:isSitesFiltered,valueUpdate:'afterkeyup'"--}%>Filtered</span>
            <div class="control-group">
                <div class="input-append">
                    <g:textField class="filterinput input-medium" data-target="site"
                                 title="Type a few characters to restrict the list." name="sites"
                                 placeholder="filter"/>
                    <button type="button" class="btn clearFilterBtn"
                            title="clear"><i class="icon-remove"></i></button>
                </div>
            </div>
            <div class="scroll-list">
                <ul id="siteList"
                %{--data-bind="template: {foreach:filteredSites,
                                      beforeRemove: hideElement,
                                      afterAdd: showElement}"--}%>
                %{--<li>
                    <a data-bind="text: name, attr: {href:'${createLink(controller: "site", action: "index")}' + '/' + siteId}"></a>
                </li>--}%
                    <g:each in="${sites}" var="p">
                        <li>
                            <g:link controller="site" action="index" id="${p.siteId}" data-id="${p.siteId}" params="[returnTo:'']">${p.name?:'No name specified'}</g:link>
                            <g:if test="${p.nrm}">${p.nrm}</g:if>
                            <g:if test="${p.state}"> - <fc:initialiseState>${p.state}</fc:initialiseState></g:if>
                        </li>
                    </g:each>
                </ul>
            </div>
        </div>

        <div class="span4">
            <div class="well list-box" style="height:300px;">
                <h2>Activities</h2>
                <span id="activity-filter-warning" class="label filter-label label-warning"
                      style="display:none;">Filtered</span>
                <div class="control-group">
                    <div class="input-append">
                        <g:textField class="filterinput input-medium" data-target="activity"
                                     title="Type a few characters to restrict the list." name="activities"
                                     placeholder="filter"/>
                        <button type="button" class="btn clearFilterBtn"
                                title="clear"><i class="icon-remove"></i></button>
                    </div>
                </div>
                <div class="scroll-list" style="height:170px;"><ul id="activityList">
                    <g:each in="${activities}" var="p">
                        <g:if test="${!p.assessment}">
                            <li>
                                <g:link controller="activity" action="index" id="${p.activityId}" params="[returnTo:'']">${p.name}</g:link>
                            </li>
                        </g:if>
                    </g:each>
                </ul></div>
            </div>

            <div class="well list-box" style="height:300px;">
                <h2>Assessments</h2>
                <span id="assessment-filter-warning" class="label filter-label label-warning"
                      style="display:none;">Filtered</span>
                <div class="control-group">
                    <div class="input-append">
                        <g:textField class="filterinput input-medium" data-target="assessment"
                                     title="Type a few characters to restrict the list." name="assessments"
                                     placeholder="filter"/>
                        <button type="button" class="btn clearFilterBtn"
                                title="clear"><i class="icon-remove"></i></button>
                    </div>
                </div>
                <div class="scroll-list" style="height:170px;"><ul id="assessmentList">
                    <g:each in="${assessments}" var="p">
                        <g:if test="${p.assessment}">
                            <li>
                                <g:link controller="activity" action="index" id="${p.activityId}" params="[returnTo:'']">${p.name}</g:link>
                            </li>
                        </g:if>
                    </g:each>
                </ul></div>
            </div>
        </div>
    </div>
    <g:if env="development">
    <hr/>
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <!--h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre-->
            <h4>Activities</h4>
            <pre>${activities}</pre>
            <h4>Sites</h4>
            <pre>${sites}</pre>
            <h4>Projects</h4>
            <pre>${projects}</pre>
        </div>
    </div>
    </g:if>
</div>

<asset:script type="text/javascript">
    $(window).load(function () {

        // bind filters
        $('.filterinput').keyup(function() {
            var a = $(this).val(),
                target = $(this).attr('data-target'),
                $target = $('#' + target + 'List li');
            if (a.length > 1) {
                // this finds all links in the list that contain the input,
                // and hide the ones not containing the input while showing the ones that do
                var containing = $target.filter(function () {
                    var regex = new RegExp('\\b' + a, 'i');
                    return regex.test($('a', this).text());
                }).slideDown();
                $target.not(containing).slideUp();
                $('#' + target + '-filter-warning').show();
            } else {
                $('#' + target + '-filter-warning').hide();
                $target.slideDown();
            }
            return false;
        });
        $('.clearFilterBtn').click(function () {
            var $filterInput = $(this).prev(),
                target = $filterInput.attr('data-target');
            $filterInput.val('');
            $('#' + target + '-filter-warning').hide();
            $('#' + target + "List li").slideDown();
        });

        // asynch loading of state information
        $('#siteList a').each(function (i, site) {
            var id = $(site).data('id');
            $.getJSON("${createLink(controller: 'site', action: 'locationLookup')}/" + id, function (data) {
                if (data.error) {
                    console.log(data.error);
                } else {
                    $(site).append(' (' + initialiseState(data.state) + ')');
                }
            });
        });
    });

    function initialiseState(state) {
        switch (state) {
            case 'Queensland': return 'QLD'; break;
            case 'Victoria': return 'VIC'; break;
            case 'Tasmania': return 'TAS'; break;
            default:
                var words = state.split(' '), initials = '';
                for(var i=0; i < words.length; i++) {
                    initials += words[i][0]
                }
                return initials;
        }
    }
    /* This implementation of list filtering is not used but is left for reference.
       The jQuery implementation is quicker and cleaner in this case. This may
       not be true if the data model is needed for other purposes.
    var data = {};
    data.sites = /$/{sites};

    function ViewModel (data) {
        var self = this;
        self.sitesFilter = ko.observable("");
        self.sites = ko.observableArray(data.sites);
        self.isSitesFiltered = ko.observable(false);
        // Animation callbacks for the lists
        self.showElement = function(elem) { if (elem.nodeType === 1) $(elem).hide().slideDown() };
        self.hideElement = function(elem) { if (elem.nodeType === 1) $(elem).slideUp(function() { $(elem).remove(); }) };

        self.filteredSites = ko.computed(function () {
            var filter = self.sitesFilter().toLowerCase();
            var regex = new RegExp('\\b' + filter, 'i');
            if (!filter || filter.length === 1) {
                self.isSitesFiltered(false);
                return self.sites();
            } else {
                self.isSitesFiltered(true);
                return ko.utils.arrayFilter(self.sites(), function (item) {
                    return regex.test(item.name);
                })
            }
        });
        self.clearSiteFilter = function () {
            self.sitesFilter("");
        }
    }
    var viewModel = new ViewModel(data);
    ko.applyBindings(viewModel);*/

</asset:script>
</body>
</html>