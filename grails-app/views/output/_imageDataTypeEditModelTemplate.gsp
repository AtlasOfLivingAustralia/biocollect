<r:require modules="imageDataType"/>
<div id="" class="fileupload-buttonbar">
    <!-- ko foreach: ${name} -->
    <!-- Images -->
    <div data-bind="visible: $data.status() != 'deleted'" class="margin-bottom-20">
        <div class="row-fluid">
            <div class="span2 text-left">
                <div class="row-fluid">
                    <div class="span12">
                        <a data-bind="attr:{href:url, title:'[click to expand] '+name()}"
                           target="_photo" rel="gallery">
                            <img data-bind="attr:{src:thumbnailUrl,  alt:name}"
                                 class="imageDataTypePreview margin-bottom-10">
                        </a>
                    </div>
                </div>
            </div>
            <div class="span5">
                <div class="row-fluid">
                    <div class="span4 text-left control-group required">
                        <label class="control-label" for="name">Title:</label>
                    </div>
                    <div class="span8">
                        <input id="name" type="text" data-bind="value:name"
                               data-validation-engine="validate[required]" class="form-control input-xlarge">
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-left control-group required">
                        <label class="control-label" >Date Taken:</label>
                    </div>
                    <div class="span8">
                        <fc:datePicker size="input-xlarge"
                                       targetField="dateTaken"
                                       name="dateTaken"
                                       data-validation-engine="validate[required]" class="form-control"/>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-left">
                        <label class="control-label">Licence <i class="icon-question-sign"
                                                                data-bind="popover:{content:'Creative Commons Attribution (CC BY), Creative Commons-Noncommercial (CC BY-NC), Creative Commons Attribution-Share Alike (CC BY-SA), Creative Commons Attribution-Noncommercial-Share Alike (CC BY-NC-SA)', placement:'top'}">&nbsp;</i>:
                        </label>
                    </div>
                    <div class="span8">
                        <select id="licence" data-bind="value:licence" class="form-control input-xlarge">
                            <option value="CC BY 3.0">Creative Commons Attribution 3.0</option>
                            <option value="CC BY 0">Creative Commons Attribution 0</option>
                            <option value="CC BY 4.0">Creative Commons Attribution 4.0</option>
                            <option value="CC BY-NC">Creative Commons Attribution-Noncommercial</option>
                        </select>
                    </div>
                </div>

                <div class="row-fluid">
                    <div class="span4 text-left">
                        <label class="control-label" for="attribution">
                            Attribution <i class="icon-question-sign" data-bind="popover:{content:'The name of the photographer', placement:'top'}">&nbsp;</i>:
                        </label>
                    </div>
                    <div class="span8">
                        <input id="attribution" class="form-control input-xlarge" type="text" data-bind="value:attribution">
                    </div>
                </div>


                <div class="row-fluid">
                    <div class="span4 text-left">
                        <label class="control-label" for="notes">Notes:</label>
                    </div>
                    <div class="span8">
                        <input id="notes" class="form-control input-xlarge" type="text" data-bind="value:notes">
                    </div>
                </div>

                <div class="row-fluid readonly ">
                    <div class="span4 text-left">
                        <label class="control-label">File Name:</label>
                    </div>
                    <div class="span8">
                        <small class="padding-top-5" data-bind="text:filename"></small>
                        (<small class="padding-top-5" data-bind="text:formattedSize"></small>)
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span4 text-left">
                    </div>
                    <div class="span8">
                        <a class="btn btn-danger btn-small" data-bind="click: remove.bind($data,$parent.${name})"><i
                                class="icon-remove icon-white"></i> Remove</a>
                    </div>
                </div>

            </div>
            <div class="span5">

            </div>
        </div>
    </div>
    <!-- /ko -->

    <table class="table table-custom-border borderless" data-bind="${databindAttrs}" data-url="<g:createLink controller='image' action='upload'/>">
        <tbody>
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
            <td class="span4">
                <span class="btn-small btn-success fileinput-button"><i class="fa fa-plus"></i> <input type="file" accept="image/*" name="files" multiple><span>Add files</span>
                </span>
            </td>
            <td>
                <div class="dropzone span4" id="${dropZone}">
                    Or, drop files here
                </div>
            </td>
        </tr>
        </tbody>
        <tfoot>

        </tfoot>
    </table>
</div>