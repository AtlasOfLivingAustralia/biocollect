<%@ page import="grails.converters.JSON" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title> Upload | Sites | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'site', action: 'list')},Sites"/>
    <meta name="breadcrumb" content="Upload Sites"/>

    <asset:script type="text/javascript">
            var fcConfig = {
                serverUrl: "${grailsApplication.config.grails.serverURL}",
                spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
                spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
                spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
                sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
                sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
                saveSitesUrl: "${createLink(action: 'createSitesFromShapefile')}",
                siteUploadProgressUrl: "${createLink(action: 'siteUploadProgress')}"

            },
            returnTo = "${params.returnTo}";
    </asset:script>
    <asset:javascript src="common.js"/>
</head>
<body>
<div class="container-fluid">

    <g:if test="${!shapeFileId}">

        <h2>Upload a shape file</h2>

        <g:if test="${flash.errorMessage || flash.message}">
            <div class="row-fluid">
                <div class="span5">
                    <div class="alert alert-error">
                        <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                        ${flash.errorMessage?:flash.message}
                    </div>
                </div>
            </div>
        </g:if>

        <g:uploadForm id="shapeFileUpload" class="loadPlanData" controller="site" action="uploadShapeFile">
            <input type="hidden" name="returnTo" value="${returnTo}">
            <input type="hidden" name="projectId" value="${projectId}">
            <label for="shapefile">Attach shape file (zip format)</label>
            <input id="shapefile" type="file" accept="application/zip" name="shapefile"/>
            <button id="uploadShapeFile" type="button" class="btn btn-success" onclick="$(this).parent().submit();">Upload Shapefile</button>
            <button id="cancel" type="button" class="btn btn-default">Cancel</button>
        </g:uploadForm>
    </g:if>
    <g:else>


    <h3>Create project sites from the shape file</h3>

    <div class="row-fluid">
        <div class="well">
            You can select attributes from the uploaded shape file to be used for the name, description and ID for the sites to upload.
            De-select any sites you do not want to upload.
        </div>
    </div>
    <form id="sites">
        <div class="row-fluid">

        </div>
        <div class="row-fluid">

            <fieldset>
                <div class="span4">
                    <label for="nameAttribute">Shapefile attribute to use as the site name:</label>
                    <select id="nameAttribute" name="nameAttribute" data-bind="value:nameAttribute,options:attributeNames,optionsCaption:'Select an attribute'"></select>
                </div>
                <div class="span4">
                    <label for="nameAttribute">Shapefile attribute to use as the site description:</label>
                    <select id="descriptionAttribute" name="descriptionAttribute" data-bind="value:descriptionAttribute,options:attributeNames,optionsCaption:'Select an attribute'"></select>
                </div>
                <div class="span4">
                    <label for="nameAttribute">Shapefile attribute to use as the site ID:</label>
                    <select id="externalIdAttribute" name="externalIdAttribute" data-bind="value:externalIdAttribute,options:attributeNames,optionsCaption:'Select an attribute'"></select>
                </div>
            </fieldset>

        </div>
        <div class="row-fluid" style="margin-top:10px; margin-bottom: 20px;">
           <span class="span3"> <button class="btn btn-success" data-bind="click:save,disable:selectedCount()<=0">Create sites</button> <button class="btn" data-bind="click:cancel">Cancel</button></span>
        </div>
    </form>

    <div class="row-fluid">
    <form id="sites-container">
    <table>
      <thead>
      <tr>
          <th colspan="1"></th>
          <th colspan="3">Properties to include in uploaded sites</th>
          <th data-bind="attr:{colspan:attributeNames().length}">Attributes in uploaded shapefile</th>
      </tr>
      <tr>

          <th><input type="checkbox" name="selectAll" data-bind="checked:selectAll"></th>
          <th>Site name</th>
          <th>Site description</th>
          <th>Site ID</th>

          <!-- ko foreach: attributeNames -->
          <th data-bind="text:$data"></th>
          <!-- /ko -->

      </tr>
      </thead>
      <tbody>
      <!-- ko foreach: { data: sites, as: 'site'} -->
          <tr>
              <td><input type="checkbox" data-bind="checked:selected"></td>
              <td><input type="text" data-bind="value:site.name, enable:selected" data-validation-engine="validate[required]"></td>
              <td><input type="text" data-bind="value:site.description, enable:selected"></td>
              <td><input type="text" data-bind="value:site.externalId, enable:selected"></td>

          <!-- ko foreach: { data: $root.attributeNames, as: 'attributeNames' } -->
              <td data-bind="text:site.attributes[attributeNames]"></td>
          <!-- /ko -->

          </tr>
      <!-- /ko -->
      </tbody>
    </table>
    </form>
    </div>
    </g:else>
</div>

<div class="modal hide" id="uploadProgress">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title"><strong>Uploading sites...</strong></div>
            </div>
            <div class="modal-body">
                <div data-bind="text:progressText"></div>
                <div class="progress progress-popup">
                    <div class="bar" data-bind="style:{width:progress}"></div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>

<asset:script type="text/javascript">
<g:if test="${shapeFileId}">
var SiteViewModel = function(shape) {
    var self = this;

    self.id = shape.id;
    self.name = ko.observable();
    self.description = ko.observable();
    self.externalId = ko.observable();
    self.selected = ko.observable(true);

    self.attributes = shape.values;

    self.toJS = function() {
        return {
            id: self.id,
            name: self.name(),
            description: self.description(),
            externalId: self.externalId()
        };
    };
};

var SiteUploadViewModel = function() {
    var self = this;
    var attributeNames = $.parseJSON('${(attributeNames as JSON).encodeAsJavaScript()}');
    var shapes = $.parseJSON('${(shapes as JSON).encodeAsJavaScript()}');

    self.nameAttribute = ko.observable('');
    self.descriptionAttribute = ko.observable('');
    self.externalIdAttribute = ko.observable('');

    self.attributeNames = ko.observableArray(attributeNames);
    self.sites = ko.observableArray([]);
    self.selectAll = ko.observable(true);
    self.progress = ko.observable('0%');
    self.progressText = ko.observable('');
    self.selectedCount = ko.observable(0);
    self.selectAll.subscribe(function(newValue) {
        $.each(self.sites(), function(i, site) {site.selected(newValue);});
    });

    self.nameAttribute.subscribe(function(newValue) {
        $.each(self.sites(), function(i, site) {
            if (newValue) {
                site.name(site.attributes[newValue]);
            }
            else {
                site.name('Site '+(i+1));
            }
        });
    });
    self.descriptionAttribute.subscribe(function(newValue) {
        $.each(self.sites(), function(i, site) {site.description(site.attributes[newValue]);});
    });
    self.externalIdAttribute.subscribe(function(newValue) {
        $.each(self.sites(), function(i, site) {site.externalId(site.attributes[newValue]);});
    });

    self.save = function() {
        if (!$('#sites-container').validationEngine('validate')) {
            return;
        }
        var payload = {};
        payload.shapeFileId = '${shapeFileId.encodeAsJavaScript()}';
        payload.projectId = '${projectId}';
        payload.sites = [];
        $.each(self.sites(), function(i, site) {
            if (site.selected()) {
                payload.sites.push(site.toJS());
            }
        });

        $.ajax({
               url: fcConfig.saveSitesUrl,
               type: 'POST',
               contentType: 'application/json',
               data: JSON.stringify(payload),
               success: function (data) {
                    self.progressText('Uploaded '+payload.sites.length+' of '+payload.sites.length+' sites');
                    self.progress('100%');
                    setTimeout(function() {
                        $('#uploadProgress').modal('hide');
                        document.location.href = "${params.returnTo}";
                    }, 1000);

               },
               error: function () {
                   $('#uploadProgress').modal('hide');

                   alert('There was a problem uploading sites.');
               }
          });
          self.progressText('Uploaded 0 of '+payload.sites.length+' sites');
          $('#uploadProgress').modal({backdrop:'static'});
          setTimeout(self.showProgress, 2000);


    };

    self.showProgress = function() {
        $.get(fcConfig.siteUploadProgressUrl, function(progress) {
            var finished = false;
            if (progress && progress.uploaded !== undefined) {
                var progressPercent = Math.round(progress.uploaded/progress.total * 100)+'%';
                self.progress(progressPercent);
                self.progressText('Uploaded '+progress.uploaded+' of '+progress.total+' sites '+progressPercent);

                finished = progress.finished;
            }
            if (!finished) {
                setTimeout(self.showProgress, 2000);
            }
        });
    }

    self.countSelectedSites = function() {
        var count = 0;
        $.each(self.sites(), function(i, site) {
            if (site.selected()) {
                count++;
            }
        });
        self.selectedCount(count);
    };

    self.cancel = function() {
        document.location.href = "${params.returnTo}";
    }

    $.each(shapes, function(i, obj) {
        var site = new SiteViewModel(obj);
        site.selected.subscribe(self.countSelectedSites);
        self.sites.push(site);
    });
     $.each(attributeNames, function(i, name) {
        if (name.toUpperCase() === 'NAME') {
            self.nameAttribute(name);
        }
    });

    $.each(attributeNames, function(i, name) {
        if (name.toUpperCase() === 'DESCRIPTION') {
            self.descriptionAttribute(name);
        }
    });
    self.countSelectedSites();

}
$('#uploadProgress').modal({backdrop:'static', show:false});
$('#sites-container').validationEngine();
ko.applyBindings(new SiteUploadViewModel());
</g:if>
<g:else>

    $('#uploadShapeFile').click(function() {
        $(this).attr('disabled','disabled');
        $('#shapeFileUpload').submit();
    });
    $("#shapefile").change(function() {
        if ($("#shapefile").val()) {
            $("#uploadShapeFile").removeAttr("disabled");
        }
        else {
            $("#uploadShapeFile").attr("disabled", "disabled");
        }

    }).trigger('change');
    $('#cancel').click(function(){
        document.location.href = returnTo;
    })
</g:else>
</asset:script>

</html>