<r:require modules="imageDataType"/>
<div id="" class="fileupload-buttonbar">

    <!-- ko foreach: ${name} -->
    <!-- Images -->
    <div data-bind="visible: $data.status() != 'deleted'">
        <div class="row-fluid">
            <div class="span12 text-left">
                <a data-bind="attr:{href:url, title:'[click to expand] '+name()}"
                   target="_photo" rel="gallery"><img data-bind="attr:{src:thumbnailUrl,  alt:name}"></a>
            </div>

        </div>
        <div class="margin-bottom-10"></div>
        <div class="row-fluid">
            <div class="span12 text-left control-group required">


                    <label class="control-label" for="name">Title:</label>
                    <input id="name" type="text" data-bind="value:name"
                           data-validation-engine="validate[required]">

            </div>
        </div>

        <div class="row-fluid">
            <div class="span12 text-left control-group required">
                <label class="control-label" >Date Taken:</label>
                <fc:datePicker size="input-small"
                               targetField="dateTaken"
                               name="dateTaken"
                               data-validation-engine="validate[required]"/>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span12 text-left">
                <label class="control-label">Licence <i class="icon-question-sign"
                                                        data-bind="popover:{content:'Creative Commons Attribution (CC BY), Creative Commons-Noncommercial (CC BY-NC), Creative Commons Attribution-Share Alike (CC BY-SA), Creative Commons Attribution-Noncommercial-Share Alike (CC BY-NC-SA)', placement:'top'}">&nbsp;</i>:
                </label>
                <select id="licence" data-bind="value:licence" class="form-control input-sm">
                    <option>CC BY</option>
                    <option>CC BY-NC</option>
                    <option>CC BY-SA</option>
                    <option>CC BY-NC-SA</option>
                </select>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span12 text-left">
                <label class="control-label" for="attribution">
                    Attribution <i class="icon-question-sign" data-bind="popover:{content:'The name of the photographer', placement:'top'}">&nbsp;</i>:
                </label>

                <input id="attribution" type="text" data-bind="value:attribution">

            </div>
        </div>


        <div class="row-fluid">
            <div class="span12 text-left">
            <label class="control-label" for="notes">Notes:</label>
            <input id="notes" type="text" data-bind="value:notes">
            </div>
        </div>

        <div class="row-fluid readonly ">
            <div class="span12 text-left">
            <label class="control-label">File Name:</label>
            <small class="padding-top-5" data-bind="text:filename"></small> (<small class="padding-top-5" data-bind="text:formattedSize"></small>)
            </div>
        </div>
        <div class="margin-bottom-10"></div>
        <div class="row-fluid">
            <div class="span12 text-left">
            <a class="btn btn-danger" data-bind="click: remove.bind($data,$parent.${name})"><i
                class="icon-remove icon-white"></i> Remove</a>
            </div>
        </div>
        <div class="margin-bottom-10"></div>


    </div>
    <!-- /ko -->

    <table class="table">
        <tbody>

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
            <td class="pull-right">
                <span class="btn btn-success fileinput-button"><i class="fa fa-plus"></i> <input type="file" accept="image/*" name="files"><span>Attach Photo</span>
                </span>
            </td>
        </tr>

        </tfoot>
    </table>
</div>