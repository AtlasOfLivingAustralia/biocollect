<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta name="layout" content="${hubConfig.skin}"/>
  <title>${site?.name?.encodeAsHTML()} | Field Capture</title>
  <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <r:script disposition="head">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            activityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
            spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
            spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
            sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
            },
            here = "${createLink(controller:'site', action:'index', id:site.siteId)}";
    </r:script>
  <r:require modules="knockout,mapWithFeatures,amplify"/>
</head>
<body>
    <div class="container-fluid">
    <ul class="breadcrumb">
        <li>
            <g:link controller="home">Home</g:link> <span class="divider">/</span>
        </li>
        <li class="active">Sites <span class="divider">/</span></li>
        <li class="active">${site.name?.encodeAsHTML()}</li>
    </ul>
    <div class="row-fluid space-after">
        <div class="span6"><!-- left block of header -->
            <g:if test="${flash.errorMessage || flash.message}">
                <div>
                    <div class="alert alert-error">
                        <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                        ${flash.errorMessage?:flash.message}
                    </div>
                </div>
            </g:if>

            <div>
                <div class="clearfix">
                    <h1 class="pull-left">${site?.name?.encodeAsHTML()}</h1>
                    <g:link style="margin-bottom:10px;" action="edit" id="${site.siteId}" class="btn pull-right title-edit">Edit site</g:link>
                </div>
                <g:if test="${site.description?.encodeAsHTML()}">
                    <div class="clearfix well well-small">
                        <p>${site.description?.encodeAsHTML()}</p>
                    </div>
                </g:if>
            </div>

            <p>
                <span class="label label-info">External Id:</span> ${site.externalId?:'Not specified'}
                <span class="label label-info">Type:</span> ${site.type?:'Not specified'}
                <span class="label label-info">Area:</span>
                <g:if test="${site?.extent?.geometry?.area}">
                    ${site.extent.geometry.area} square km
                </g:if>
                <g:else>
                    Not specified
                </g:else>
                </span>
            </p>

            <g:if test="${site.extent?.geometry}">
            <p>
                <span class="label label-success">State/territory:</span> ${site.extent.geometry.state?:'Not specified'}
                <span class="label label-success">Local government area:</span> ${site.extent.geometry.lga?:'Not specified'}
                <span class="label label-success">NRM:</span> ${site.extent.geometry.nrm?:'Not specified'}
            </p>

            <p>
                <span class="label label-success">Locality:</span> ${site.extent.geometry.locality?:'Not specified'}
            </p>
            <p>
                <span class="label label-success">NVIS major vegetation group:</span> ${site.extent.geometry.mvg?:'Not specified'}
            </p>
            <p>
                <span class="label label-success">NVIS major vegetation subgroup:</span> ${site.extent.geometry.mvs?:'Not specified'}
            </p>
            </g:if>

            <div>
                <span class="label label-info">Notes:</span>
                ${site.notes?.encodeAsHTML()}
            </div>

            <g:if test="${site.projects}">
            <div>
                <h2>Projects associated with this site</h2>
                <ul style="list-style: none;margin:13px 0;">
                    <g:each in="${site.projects}" var="p" status="count">
                        <li>
                            <g:link controller="project" action="index" id="${p.projectId}">${p.name?.encodeAsHTML()}</g:link>
                            <g:if test="${count < site.projects.size() - 1}">, </g:if>
                        </li>
                    </g:each>
                </ul>
            </div>
            </g:if>

        </div>
        <div class="span6">
            <div id="siteNotDefined" class="hide pull-right">
                <span class="label label-important">This site does not have a geoference associated with it.</span>
            </div>
            <div id="smallMap" style="width:100%;height:500px;"></div>
            <g:if test="${site?.extent?.geometry?.pid}">
                <div style="margin-top:20px;" class="pull-right">
                    <a href="${grailsApplication.config.spatial.layersUrl}/shape/shp/${site.extent.geometry.pid}" class="btn">
                        <i class="icon-download"></i>
                        Download ShapeFile
                    </a>
                    <a href="${grailsApplication.config.spatial.baseURL}/?pid=${site.extent.geometry.pid}" class="btn">View in Spatial Portal</a>
                </div>
            </g:if>
        </div>
    </div>
    <g:if test="${site.poi}">
        <h2>Points of interest at this site</h2>
        <div class="row-fluid">
              <ul>
              <g:each in="${site.poi}" var="poi">
                <li>${poi.name?.encodeAsHTML()}</li>
              </g:each>
              </ul>
        </div>
    </g:if>

    <g:if test="${site.activities}">
        <h2>Activities at this site</h2>
        <div class="row-fluid">
            <!-- ACTIVITIES -->
            <div class="tab-pane active" id="activity">
                <g:render template="/shared/activitiesListReadOnly"
                          model="[activities:site.activities ?: [], sites:[], showSites:false]"/>
            </div>
        </div>
    </g:if>

    <div class="row-fluid">
        <div class="span12 metadata">
            <span class="span6">
                <p><span class="label">Created:</span> ${site.dateCreated}</p>
                <p><span class="label">Last updated:</span> ${site.lastUpdated}</p>
            </span>
        </div>
    </div>
    <g:if env="development">
    <div class="expandable-debug">
        <hr />
        <h3>Debug</h3>
        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
            <h4>Activities</h4>
            <pre>${site.activities?.encodeAsHTML()}</pre>
            <h4>Site</h4>
            <pre>${site}</pre>
            <h4>Projects</h4>
            <pre>${projects?.encodeAsHTML()}</pre>
            <h4>Features</h4>
            <pre>${mapFeatures}</pre>
        </div>
    </div>
    </g:if>
    </div>
    <r:script>

        var isodatePattern = /\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/,
            activitiesObject = ${site.activities + site.assessments};

        $(function(){

            // change toggle icon when expanding and collapsing and track open state
            $('#activities').
            on('show', 'div.collapse', function() {
                $(this).parents('tr').prev().find('td:first-child i').
                    removeClass('icon-plus').addClass('icon-minus');
            }).
            on('hide', 'div.collapse', function() {
                $(this).parents('tr').prev().find('td:first-child i').
                    removeClass('icon-minus').addClass('icon-plus');
            }).
            on('shown', 'div.collapse', function() {
                trackState();
            }).
            on('hidden', 'div.collapse', function() {
                trackState();
            });

            // determines which project an activity belongs to
            ko.bindingHandlers.projectName =  {
                init: function(element, valueAccessor, allBindingsAccessor, model, bindingContext) {
                    var activity = ko.utils.unwrapObservable(valueAccessor()),
                        projects = [];
                    if (activity.projectId) {
                        $(element).html(activity.projectId);
                    }
                    // no directly linked project so use the site's project(s)
                    ko.utils.arrayForEach(viewModel.projects, function (p) {
                        projects.push(p.name);
                    });
                    $(element).html(projects.join(','));
                }
            };

            function ViewModel(projects, site, activities) {
                var self = this;
                this.loadActivities = function (activities) {
                    var acts = ko.observableArray([]);
                    $.each(activities, function (i, act) {
                        var activity = {
                            activityId: act.activityId,
                            siteId: act.siteId,
                            type: act.type,
                            startDate: ko.observable(act.startDate).extend({simpleDate:false}),
                            endDate: ko.observable(act.endDate).extend({simpleDate:false}),
                            outputs: ko.observableArray([]),
                            collector: act.collector,
                            metaModel: act.model || {},
                            edit: function () {
                                document.location.href = fcConfig.activityEditUrl + '/' + this.activityId +
                                    "?returnTo=" + here;
                            }
                        };
                        $.each(act.outputs, function (j, out) {
                            activity.outputs.push({
                                outputId: out.outputId,
                                name: out.name,
                                collector: out.collector,
                                assessmentDate: out.assessmentDate,
                                scores: out.scores
                            });
                        });
                        acts.push(activity);
                    });
                    return acts;
                };
                self.name = ko.observable(site.name);
                self.description = ko.observable(site.description);
                self.externalId = ko.observable(site.externalId);
                self.startDate = ko.observable(site.startDate).extend({simpleDate: false});
                self.endDate = ko.observable(site.endDate).extend({simpleDate: false});
                self.projects = ko.toJS(site.projects);
                self.activities = self.loadActivities(activities);
                // Animation callbacks for the lists
                self.showElement = function(elem) { if (elem.nodeType === 1) $(elem).hide().slideDown() };
                self.hideElement = function(elem) { if (elem.nodeType === 1) $(elem).slideUp(function() { $(elem).remove(); }) };
                self.newActivity = function () {
                    document.location.href = fcConfig.activityCreateUrl +
                    "?siteId=${site.siteId}&returnTo=" + here;
                };
                self.notImplemented = function () {
                    alert("Not implemented yet.")
                };
                self.expandActivities = function () {
                    $('#activityList div.collapse').collapse('show');
                };
                self.collapseActivities = function () {
                    $('#activityList div.collapse').collapse('hide');
                }
            }

            var viewModel = new ViewModel(${projects || []},${site},${site.activities ?: []});

            ko. applyBindings(viewModel);

            // retain tab state for future re-visits
            $('a[data-toggle="tab"]').on('shown', function (e) {
                var tab = e.currentTarget.hash;
                amplify.store('project-tab-state', tab);
                // only init map when the tab is first shown
                if (tab === '#site' && map === undefined) {
                    init_map_with_features({
                            featureService: "${createLink(controller: 'proxy', action:'feature')}",
                            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}",
                            mapContainer: "map",
                            scrollwheel: false
                        },
                        $.parseJSON('${mapFeatures?.encodeAsJavaScript()}')
                    );
                }
            });

            // re-establish the previous tab state
            if (amplify.store('project-tab-state') === '#site') {
                $('#site-tab').tab('show');
            }

            var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');

            init_map_with_features({
                    mapContainer: "smallMap",
                    zoomToBounds:true,
                    zoomLimit:16,
                    featureService: "${createLink(controller:'proxy', action:'feature')}",
                    wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
                },
                mapFeatures
            );

            if(mapFeatures.features === undefined || mapFeatures.features.length == 0){
                $('#siteNotDefined').show();
            }
        });

    </r:script>
</body>
</html>