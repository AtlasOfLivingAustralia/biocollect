<r:require modules="imageDataType"></r:require>
<g:set var="carouselName" value="carousel1"></g:set>
<div id="" class="fileupload-buttonbar" data-bind="template:{name:'${readOnly ? 'imageViewTemplate1' : 'imageEditTemplate'}'}">

</div>

<script id="imageEditTemplate" type="text/html">
<table class="table">
    <tbody>
    <!-- ko foreach: ${name} -->
    <tr data-bind="visible: $data.status() != 'deleted'">
        <td class="images-image-width">
            <a data-bind="attr:{href:url, title:'[click to expand] '+name()}"
               target="_photo" rel="gallery"><img data-bind="attr:{src:thumbnailUrl,  alt:name}"></a>
        </td>
        <td class="images-form-width">
            <div class="form-horizontal">
                <div class="control-group required">
                    <label class="control-label">Title:</label>

                    <div class="controls"><input type="text" data-bind="value:name" data-validation-engine="validate[required]">
                    </div>
                </div>

                <div class="control-group required">
                    <label class="control-label">Date Taken:</label>

                    <div class="controls"><div class="input-append"><fc:datePicker size="input-small"
                                                                                   targetField="dateTaken" name="dateTaken"
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

                    <div class="controls"><label class="padding-top-5" data-bind="text:filename"/></div>
                </div>

                <div class="control-group readonly">
                    <label class="control-label">File Size:</label>

                    <div class="controls"><label class="padding-top-5" data-bind="text:formattedSize"/></div>
                </div>
            </div>
        </td>
        <td class="images-action-btns">
            <g:if test="${!readOnly}">
                <a class="btn" data-bind="click: remove.bind($data,$parent.${name})"><i
                        class="icon-remove"></i> Remove</a>
            </g:if>
        </td>
    </tr>
    <!-- /ko -->
    </tbody>
    <g:if test="${!readOnly}">
        <tfoot data-bind="${databindAttrs}" data-url="<g:createLink controller='image' action='upload'/>">
        <tr data-bind="visible:!complete()">
            <td class="images-preview-width">
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
</script>

<script id="imageViewTemplate" type="text/html">
<div class="control-group" data-bind="visible: name">
    <label class="control-label">Title: <span data-bind="text:name"></span></label>
</div>

<div class="control-group" data-bind="visible: dateTaken">
    <label class="control-label">Date Taken: <span data-bind="text:dateTaken"></span></label>
</div>

<div class="control-group"  data-bind="visible: attribution">
    <label class="control-label">Attribution : <span data-bind="text:attribution"></span></label>
</div>

<div class="control-group" data-bind="visible: notes">
    <label class="control-label">Notes: <span data-bind="text:notes"></span></label>
</div>

<div class="control-group readonly">
    <label class="control-label">File Name: <span data-bind="text:filename"></span></label>
</div>

<div class="control-group readonly"  data-bind="visible: formattedSize">
    <label class="control-label">File Size: <span data-bind="text:formattedSize"></span></label>
</div>
</script>

<script id="imageViewTemplate1" type="text/html">
<div id="${carouselName}" class="carousel slide images-carousel-size" >
    <ol class="carousel-indicators">
        <!-- ko foreach: ${name} -->
        <li data-target="#${carouselName}" data-bind="attr:{'data-slide-to':$index}"></li>
        <!-- /ko -->
    </ol>
    <!-- Carousel items -->
    <div class="carousel-inner text-center">
        <!-- ko foreach: ${name} -->
        <div class="item" data-bind="css:{active:$index()==0}">
            <img data-bind="attr:{src:url}">
            <div class="carousel-caption">
                <h4 data-bind="text:name"></h4>
                <p data-bind="html:summary()"></p>
            </div>
        </div>
        <!-- /ko -->
    </div>
    <!-- Carousel nav -->
    <a class="carousel-control left" href="#${carouselName}" data-slide="prev">&lsaquo;</a>
    <a class="carousel-control right" href="#${carouselName}" data-slide="next">&rsaquo;</a>
</div>
</script>