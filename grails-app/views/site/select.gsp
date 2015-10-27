<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta name="layout" content="${hubConfig.skin}"/>
  <title>Add existing site | Field Capture</title>
  <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <r:script disposition="head">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
            activityCreateUrl: "${createLink(controller: 'activity', action: 'create')}",
            spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
            spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
            sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
        },
        returnTo = "${params.returnTo}";
    </r:script>
  <r:require modules="knockout,mapWithFeatures,amplify"/>
</head>
<body>
    <div class="container-fluid">
        <h1>Add sites to <a href="${params.returnTo}">${project.name}</a></h1>

        <div class="row-fluid">

            <div class="well span6">

                <div class="row-fluid" style="margin-bottom:20px;">
                    <span class="span5">
                        <form class="form-search" data-bind="submit: searchSites">
                         <div class="input-append">
                            <input type="text" class="search-query" data-bind="value: currentSearch" placeholder="Filter..."/>
                            <button type="submit" class="btn"><i class="icon-search"></i></button>
                            <span><span data-bind="text: matchingSiteCount"></span></strong> sites matched.</span>
                          </div>
                        </form>
                    </span>
                    <span class="span5 pull-right">
                        <button class="btn btn-primary" data-bind="click: useSelectedSites">Update sites</button>
                        <button class="btn" data-bind="click: cancelUpdate">Cancel</button>
                    </span>
                </div>

                <ul data-bind="foreach: sites" style="margin: 0px;">
                    <li style="list-style: none;">
                        <div class="row-fluid">
                            <span class="span8">
                               <strong>
                                   <span data-bind="text:name"></span>
                               </strong>
                               <br/>
                               <span data-bind="visible:$data.extent === undefined">No georeference information available</span>
                               <span data-bind="visible:$data.extent !== undefined && extent.geometry != null && extent.geometry.state != null">State: </span><span data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.state : ''"></span>
                               <span data-bind="visible:$data.extent !== undefined && extent.geometry != null && extent.geometry.lga != null">LGA: </span><span data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.lga : ''"></span>
                            </span>
                            <span class="span2">
                                  <button class="viewOnMap btn btn-small" data-bind="click: $parent.mapSite, disable:$data.extent === undefined">
                                      <i class="icon-eye-open"></i>
                                      Preview
                                  </button>
                            </span>
                            <span class="span2 ">
                                  <button class="addSite btn btn-success btn-small pull-right" data-bind="click: $parent.addSite, visible: !isProjectSite()">
                                      <i class="icon-plus icon-white"></i>
                                      Add
                                  </button>
                                  <button class="removeSite btn btn-danger btn-small pull-right" data-bind="click: $parent.removeSite, visible: isProjectSite() ">
                                      <i class="icon-minus  icon-white"></i>
                                      Remove
                                  </button>
                            </span>
                        </div>
                    </li>
                </ul>

                <div id="paginateTable" class="hide" style="text-align:center;">
                    <span id="paginationInfo" style="display:inline-block;float:left;margin-top:4px;"></span>
                    <div class="btn-group">
                        <button class="btn btn-small prev"><i class="icon-chevron-left"></i>&nbsp;previous</button>
                        <button class="btn btn-small next">next&nbsp;<i class="icon-chevron-right"></i></button>
                    </div>
                    <g:if env="development">
                        total: <span id="total"></span>
                        offset: <span id="offset"></span>
                    </g:if>
                </div>

            </div>
            <div class="span6">
                <div id="map" style="height:500px;width:100%;"></div>
                <a href="" class="btn" data-bind="click: clearMap">Clear map</a>
            </div>
        </div>

        <g:if env="development">
        <div class="container-fluid">
            <div class="expandable-debug">
                <hr />
                <h3>Debug</h3>
                <div>
                    <h4>KO model</h4>
                    <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
                </div>
            </div>
        </div>
        </g:if>
    </div>
</body>
<r:script>
    var siteModel = null;
    $(function(){
        function SiteSelectModel () {
            var self = this;
            self.projectId = "${project.projectId?:'1'}";
            self.projects = ["${project.projectId?:'1'}"];
            self.currentSearch = ko.observable('');
            self.sites = ko.observableArray([]);
            self.matchingSiteCount = ko.observable(0);
            self.currentProjectSites = ko.observableArray([
                <g:each in="${project.sites}" var="site" status="siteStatus">
                    <g:if test="${siteStatus>0}">,</g:if>'${site.siteId}'
                </g:each>
            ]);
            self.cancelUpdate = function(){
                document.location.href = "${params.returnTo}";
            }
            self.sitesToAdd = ko.observableArray([]);
            self.addAllMatched = function(){
              //alert('Not implemented. This should add all the sites in the search results');
              $.each(self.sites(), function(idx, site){
                  self.currentProjectSites.push(site.siteId);
              });
            },
            self.clearSites = function(){
              self.currentProjectSites.removeAll();
              $.each(self.sites(), function(idx,site){
                 site.isProjectSite(false);
              });
            }
            self.useSelectedSites = function(){
                var dataToPost = {
                    projectId:self.projectId,
                    sites:self.currentProjectSites()
                };
                $.ajax({
                   url: "${createLink(controller: 'site', action: 'ajaxUpdateProjects')}",
                   type: 'POST',
                   data:  JSON.stringify({
                    projectId: self.projectId,
                    sites: self.currentProjectSites()
                   }),
                   contentType: 'application/json',
                   success: function (data) {
                      document.location.href = "${params.returnTo}";
                   },
                   error: function () {
                      alert('There was a problem saving this site');
                   }
                });
            }
            self.mapSite = function(site){
                console.log('Now mapping ' + site);
                mapSite(site);

            }
            self.clearMap = function(){
                clearMap();
            },
            self.cancel = function(){
                document.location.href = "${params.returnTo}";
            }
            self.addSite = function(site){
                //get
                console.log("Index of" + self.sites.indexOf(site));
                var idxOfSite = self.sites.indexOf(site);
                var _site = self.sites()[idxOfSite];
                _site.isProjectSite(true);
                self.currentProjectSites.push(_site.siteId);
                //self.sitesToAdd.push(site);

            }
            self.removeSite = function(site){
                var idxOfSite = self.sites.indexOf(site);
                var _site = self.sites()[idxOfSite];
                _site.isProjectSite(false);
                self.currentProjectSites.remove(_site.siteId);

            }
            self.searchSites = function(){
                var max = 10;
                var offset = 0;
                queryForSites(self.currentSearch(), max, offset, function(data){
                   $('#total').html(data.hits.total);
                   $('#offset').html(0);

                   if(data.hits.total > 10){
                     initialisePagination(self.currentSearch(), 10, 0, data.hits.total);
                   } else {
                     $('#paginateTable').hide();
                   }
                });
            }
            self.submitSites = function(){
                alert('Not done - needs to save sites against the project.');
            }
        }

        function initialisePagination(query, pageSize, offset, total){
           $('#paginateTable').show();
           $('#paginateTable').data('query', query)
           $('#paginateTable').data('max', pageSize);
           $('#paginateTable').data('offset', offset);
           $('#paginateTable').data('total', total);
           $('#paginateTable .prev').addClass("disabled");
        }

        function paginateNext(){

          if($('#paginateTable').data('offset')  + $('#paginateTable').data('max')> $('#paginateTable').data('total')){
            return;
          }

          var query = $('#paginateTable').data('query');
          var max   = $('#paginateTable').data('max');
          var total = $('#paginateTable').data('total');
          var newOffset = $('#paginateTable').data('offset') + max;

          console.log('newOffset: ' + newOffset + ', total: ' + total +', max: ' + max);
          //increment the stored offset
          $('#paginateTable').data('offset', newOffset);

          //debug
          $('#offset').html(newOffset);

          queryForSites(query, max, newOffset, function(data){
              if(newOffset > 0){
                 $('#paginateTable .prev').removeClass("disabled");
              }

              if(newOffset + max >= total){
                $('#paginateTable .next').addClass("disabled");
              }
          });
        }

        function queryForSites(query, max, offset, callbackFcn){
          $.ajax({
               url: "${createLink(controller: 'site', action: 'search')}?query=" + query + "&max=" + max + "&offset=" + offset,
               type: 'GET',
               contentType: 'application/json',
               success: function (data) {
                   //get results
                   siteModel.sites.removeAll();
                   siteModel.matchingSiteCount(data.hits.total);

                   $.each(data.hits.hits, function(idx,hit){
                      console.log(hit._source);
                      var isProjectSite =($.inArray(hit._source.siteId, siteModel.currentProjectSites()) >=0 );
                      hit._source.isProjectSite = ko.observable(isProjectSite);
                      siteModel.sites.push(hit._source);
                      callbackFcn(data);
                   })
               },
               error: function () {
                   alert('There was a problem searching for sites.');
               }
          });
        }

        function paginatePrev(){

          var offset = $('#paginateTable').data('offset') - $('#paginateTable').data('max');
          if($('#paginateTable').data('offset') == 0 ){
            return;
          }
          $('#paginateTable').data('offset', offset);

          var query = $('#paginateTable').data('query');
          var max   = $('#paginateTable').data('max');

          queryForSites(query, max, offset, function(data){
               if(offset <= 0){
                 $('#paginateTable .prev').addClass("disabled");
               }
               $('#paginateTable .next').removeClass("disabled");
          });
        }

        var mapOptions = {
            zoomToBounds:true,
            zoomLimit:16,
            highlightOnHover:true,
            features:[],
            featureService: "${createLink(controller: 'proxy', action:'feature')}",
            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
        };

        window.alaMap = new MapWithFeatures({mapContainer:'map'}, mapOptions);

        siteModel = new SiteSelectModel();
        ko.applyBindings(siteModel);

        siteModel.searchSites();

        //pagination event handlers
        $('#paginateTable .next').click(paginateNext)
        $('#paginateTable .prev').click(paginatePrev)
    });

</r:script>

</html>