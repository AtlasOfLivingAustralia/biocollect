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
            <label class="control-label">Licence <i class="icon-question-sign"
                                                                  data-bind="popover:{content:'Creative Commons Attribution (CC BY), Creative Commons-Noncommercial (CC BY-NC), Creative Commons Attribution-Share Alike (CC BY-SA), Creative Commons Attribution-Noncommercial-Share Alike (CC BY-NC-SA)', placement:'top'}">&nbsp;</i>:
            </label>

            <div class="controls">
                <select id="licence" data-bind="value:licence" class="form-control input-sm">
                    <option>CC BY</option>
                    <option>CC BY-NC</option>
                    <option>CC BY-SA</option>
                    <option>CC BY-NC-SA</option>
                </select>
            </div>
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
        <label class="control-label">License : <span data-bind="text:license"></span></label>
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

