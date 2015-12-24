<g:if test="${!printView}">
    <div data-bind="visible:!site">
        No site has been selected.  To add photos to this activity, select a site.
    </div>

    <div data-bind="visible:site">
        <div data-bind="visible:photoPoints().length == 0">
            <p>There are no photo points defined for the selected site.  To create a photo point, use the "New Photo Point" button below.</p>
        </div>

        <table id="photoPointTable" class="table table-bordered photoPoints imageList">
            <thead>
            <tr>
                <th style="width:20%">Photo point location:</th>
                <th style="width:70%">Photo(s)</th>
            </tr>
            </thead>
            <tbody data-bind="foreach:photoPoints">
            <tr>
                <td data-bind="template:{name:template}">

                </td>
                <td>
                    <table class="table">
                        <tbody data-bind="foreach:photos">
                        <tr data-bind="visible:status() !== 'deleted'">
                            <td style="width:40%;">
                                <a data-bind="attr:{href:url, alt:name, title:'[click to expand] '+name}"
                                   target="_photo" rel="gallery"><img data-bind="attr:{src:thumbnailUrl}"></a>
                            </td>
                            <td style="width:45%;"
                                data-bind="template:{name:'${readOnly ? 'photoViewTemplate' : 'photoEditTemplate'}'}">

                            </td>
                            <td style="text-align: right; width:15%">
                                <g:if test="${!readOnly}">
                                    <a class="btn" data-bind="click:$parent.removePhoto"><i
                                            class="icon-remove"></i> Remove</a>
                                </g:if>
                            </td>
                        </tr>

                        </tbody>
                        <g:if test="${!readOnly}">
                            <tfoot data-bind="photoPointUpload:uploadConfig">
                            <tr data-bind="visible:!complete()">
                                <td style="border-bottom: 0px;">
                                    <span class="preview"></span>

                                </td>
                                <td>

                                    <label for="progress" class="control-label">Uploading Photo...</label>

                                    <div id="progress" class="controls progress progress-info active input-large"
                                         data-bind="visible:!error() && progress() <= 100, css:{'progress-info':progress()<100, 'progress-success':complete()}">
                                        <div class="bar" data-bind="style:{width:progress()+'%'}"></div>
                                    </div>

                                    <div id="successmessage" class="controls" data-bind="visible:complete()">
                                        <span class="alert alert-success">File successfully uploaded</span>
                                    </div>

                                    <div id="message" class="controls" data-bind="visible:error()">
                                        <span class="alert alert-error" data-bind="text:error"></span>
                                    </div>
                                </td>

                            </tr>

                            <tr>
                                <td colspan="3">
                                    <span class="btn fileinput-button"><i class="icon-plus"></i> <input type="file"
                                                                                                        name="files"><span>Attach Photo</span>
                                    </span>

                                </td>
                            </tr>

                            </tfoot>
                        </g:if>
                    </table>
                </td>

            </tr>
            </tbody>
            <g:if test="${!readOnly}">
                <tfoot>
                <tr>
                    <td colspan="2">
                        <button type="button" class="btn" data-bind="click:addPhotoPoint"><i
                                class="icon-plus"></i> New Photo Point</button>
                    </td>
                </tr>
                </tfoot>
            </g:if>

        </table>
    </div>
    <g:render template="/shared/imagerViewerModal"></g:render>

    <script type="text/html" id="readOnlyPhotoPoint">

    <div><b><span data-bind="text:photoPoint.name"/></b></div>

    <div><span data-bind="text:photoPoint.description"/></div>

    <div>Latitude : <b><span data-bind="text:photoPoint.geometry.decimalLatitude"/></b></div>

    <div>Longitude: <b><span data-bind="text:photoPoint.geometry.decimalLongitude"/></b></div>

    <div>Bearing  : <b><span data-bind="text:photoPoint.geometry.bearing"/></b></div>
    </script>

    <script type="text/html" id="editablePhotoPoint">
    <div class="floatright">
        <a class="btn" data-bind="click:$parent.removePhotoPoint"><i class="icon-remove"></i> Remove</a>
    </div>

    <div class="clearfix">
        <p><strong>Enter the details of the new photo point below.</strong></p>

        <p>If you attach a photo, the latitude and longitude will be populated from the information in the photo, if available.</p>
    </div>

    <div class="form-horizontal">
        <div class="control-group required">
            <label class="control-label">Name:</label>

            <div class="controls"><input type="text" data-bind="value:photoPoint.name"
                                         data-validation-engine="validate[required]"></div>
        </div>

        <div class="control-group">
            <label class="control-label">Description:</label>

            <div class="controls"><input type="text" data-bind="value:photoPoint.description"></div>
        </div>

        <div class="control-group required">
            <label class="control-label">Latitude:</label>

            <div class="controls"><input type="text" data-bind="value:photoPoint.geometry.decimalLatitude"
                                         data-validation-engine="validate[required,custom[number],min[-90],max[0]]">
            </div>
        </div>

        <div class="control-group required">
            <label class="control-label">Longitude:</label>

            <div class="controls"><input type="text" data-bind="value:photoPoint.geometry.decimalLongitude"
                                         data-validation-engine="validate[required,custom[number],min[-180],max[180]]">
            </div>
        </div>

        <div class="control-group required">
            <label class="control-label">Bearing:</label>

            <div class="controls"><input type="text" data-bind="value:photoPoint.geometry.bearing"
                                         data-validation-engine="validate[required]"></div>
        </div>

    </div>

    </script>
    <script id="photoEditTemplate" type="text/html">
    <div class="form-horizontal">
        <div class="control-group required">
            <label class="control-label">Title:</label>

            <div class="controls"><input type="text" data-bind="value:name" data-validation-engine="validate[required]">
            </div>
        </div>

        <div class="control-group required">
            <label class="control-label">Date Taken:</label>

            <div class="controls"><div class="input-append"><fc:datePicker size="input-small"
                                                                           targetField="dateTaken.date" name="dateTaken"
                                                                           data-validation-engine="validate[required]"/></div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">Attribution <i class="icon-question-sign"
                                                        data-bind="popover:{content:'The name of the photographer', placement:'top'}">&nbsp;</i>:
            </label>

            <div class="controls"><input type="text" data-bind="value:attribution"></div>
        </div>

        <div class="control-group">
            <label class="control-label">Notes:</label>

            <div class="controls"><input type="text" data-bind="value:notes"></div>
        </div>

        <div class="control-group readonly">
            <label class="control-label">File Name:</label>

            <div class="controls"><label style="padding-top:5px;" data-bind="text:filename"/></div>
        </div>

        <div class="control-group readonly">
            <label class="control-label">File Size:</label>

            <div class="controls"><label style="padding-top:5px;" data-bind="text:formattedSize"/></div>
        </div>
    </div>
    </script>

    <script id="photoViewTemplate" type="text/html">
    <div class="control-group">
        <label class="control-label">Title: <span data-bind="text:name"></span></label>
    </div>

    <div class="control-group">
        <label class="control-label">Date Taken: <span data-bind="text:dateTaken"></span></label>
    </div>

    <div class="control-group">
        <label class="control-label">Attribution : <span data-bind="text:attribution"></span></label>
    </div>

    <div class="control-group">
        <label class="control-label">Notes: <span data-bind="text:notes"></span></label>
    </div>

    <div class="control-group readonly">
        <label class="control-label">File Name: <span data-bind="text:filename"></span></label>
    </div>

    <div class="control-group readonly">
        <label class="control-label">File Size: <span data-bind="text:formattedSize"></span></label>
    </div>
    </script>
</g:if>

<r:script>


    var PhotoPointViewModel = function(site, activity) {

        var self = this;

        self.site = site;
        self.photoPoints = ko.observableArray();

        if (site && site.poi) {

            $.each(site.poi, function(index, obj) {
                var photos = ko.utils.arrayFilter(activity.documents, function(doc) {
                    return doc.siteId === site.siteId && doc.poiId === obj.poiId;
                });
                self.photoPoints.push(photoPointPhotos(site, obj, activity.activityId, photos));
            });
        }

        self.removePhotoPoint = function(photoPoint) {
            self.photoPoints.remove(photoPoint);
        }

        self.addPhotoPoint = function() {
            self.photoPoints.push(photoPointPhotos(site, null, activity.activityId, []));
        };

        self.modelForSaving = function() {
            var siteId = site?site.siteId:''
            var toSave = {siteId:siteId, photos:[], photoPoints:[]};

            $.each(self.photoPoints(), function(i, photoPoint) {

                if (photoPoint.isNew()) {
                    var newPhotoPoint = photoPoint.photoPoint.modelForSaving();
                    toSave.photoPoints.push(newPhotoPoint);
                    $.each(photoPoint.photos(), function(i, photo) {
                        if (!newPhotoPoint.photos) {
                            newPhotoPoint.photos = [];
                        }
                        newPhotoPoint.photos.push(photo.modelForSaving());
                    });
                }
                else {
                    $.each(photoPoint.photos(), function(i, photo) {
                        toSave.photos.push(photo.modelForSaving());
                    });
                }

            });
            return toSave;
        };

        self.isDirty = function() {
            var isDirty = false;
            $.each(self.photoPoints(), function(i, photoPoint) {
                isDirty = isDirty || photoPoint.isDirty();
            });
            return isDirty;
        };

        self.reset = function() {};


    };

    var photoPointPOI = function(data) {
        if (!data) {
            data = {
                geometry:{}
            };
        }
        var name = ko.observable(data.name);
        var description = ko.observable(data.description);
        var lat = ko.observable(data.geometry.decimalLatitude);
        var lng = ko.observable(data.geometry.decimalLongitude);
        var bearing = ko.observable(data.geometry.bearing);


        return {
            poiId:data.poiId,
            name:name,
            description:description,
            geometry:{
                type:'Point',
                decimalLatitude:lat,
                decimalLongitude:lng,
                bearing:bearing,
                coordinates:[lng, lat]
            },
            type:'photopoint',
            modelForSaving:function() { return ko.toJS(this); }
        }
    };

    var photoPointPhotos = function(site, photoPoint, activityId, existingPhotos) {

        var files = ko.observableArray();
        var photos = ko.observableArray();
        var isNewPhotopoint = !photoPoint;
        var isDirty = isNewPhotopoint;

        var photoPoint = photoPointPOI(photoPoint);

        $.each(existingPhotos, function(i, photo) {
            photos.push(photoPointPhoto(photo));
        });


        files.subscribe(function(newValue) {
            var f = newValue.splice(0, newValue.length);
            for (var i=0; i < f.length; i++) {

                var data = {
                    thumbnailUrl:f[i].thumbnail_url,
                    url:f[i].url,
                    contentType:f[i].contentType,
                    filename:f[i].name,
                    filesize:f[i].size,
                    dateTaken:f[i].isoDate,
                    lat:f[i].decimalLatitude,
                    lng:f[i].decimalLongitude,
                    poiId:photoPoint.poiId,
                    siteId:site.siteId,
                    activityId:activityId,
                    name:site.name+' - '+photoPoint.name(),
                    type:'image'


                };
                isDirty = true;
                if (isNewPhotopoint && data.lat && data.lng && !photoPoint.geometry.decimalLatitude() && !photoPoint.geometry.decimalLongitude()) {
                    photoPoint.geometry.decimalLatitude(data.lat);
                    photoPoint.geometry.decimalLongitude(data.lng);
                }

                photos.push(photoPointPhoto(data));
            }
        });


        return {
            photoPoint:photoPoint,
            photos:photos,
            files:files,

            uploadConfig : {
                url: '${createLink(controller: 'image', action: 'upload')}',
                target: files
            },
            removePhoto : function (photo) {
                if (photo.documentId) {
                    photo.status('deleted');
                }
                else {
                    photos.remove(photo);
                }
            },
            template : function(photoPoint) {
                return isNewPhotopoint ? 'editablePhotoPoint' : 'readOnlyPhotoPoint'
            },
            isNew : function() { return isNewPhotopoint },
            isDirty: function() {
                if (isDirty) {
                    return true;
                };
                var tmpPhotos = photos();
                for (var i=0; i < tmpPhotos.length; i++) {
                    if (tmpPhotos[i].dirtyFlag.isDirty()) {
                        return true;
                    }
                }
                return false;
            }

        }
    }

    var photoPointPhoto = function(data) {
        if (!data) {
            data = {};
        }
        data.role = 'photoPoint';
        var result = new DocumentViewModel(data);
        result.dateTaken = ko.observable(data.dateTaken).extend({simpleDate:false});
        result.formattedSize = formatBytes(data.filesize);

        for (var prop in data) {
            if (!result.hasOwnProperty(prop)) {
                result[prop]= data[prop];
            }
        }
        var docModelForSaving = result.modelForSaving;
        result.modelForSaving = function() {
            var js = docModelForSaving();
            delete js.lat;
            delete js.lng;
            delete js.thumbnailUrl;
            delete js.formattedSize;

            return js;
        };
        result.dirtyFlag = ko.dirtyFlag(result, false);

        return result;
    };

</r:script>