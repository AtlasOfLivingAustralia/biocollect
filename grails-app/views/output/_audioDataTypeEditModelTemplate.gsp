<div id="audioPanel" class="audio-input-panel">
    <div id="filesPanel">
        <div data-bind="foreach: ${name}.files">
            <div class="row-fluid" data-bind="if: status() != 'deleted'">
                <div class="span3">
                    <audio data-bind="attr: {src: url, id: id()}" controls="controls">
                        <p class="small"><i class="fa fa-music">&nbsp;</i>Your browser does not support audio playback for this type of file</p>
                    </audio>

                    <div>
                        <a href="" data-bind="attr: {href: transients.downloadUrl()}" class="download"><i class="fa fa-download">&nbsp;</i>Download</a>
                    </div>
                </div>

                <div class="span7">
                    <div class="form-horizontal">
                        <div class="control-group required">
                            <label class="control-label" for="name">Title:</label>

                            <div class="controls">
                                <input id="name" type="text" data-bind="value: name" data-validation-engine="validate[required]">
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="attribution">
                                Attribution <i class="icon-question-sign"
                                               data-bind="popover: {content: 'The name of the individual(s) who recorded the sound', placement: 'top'}">&nbsp;</i>:
                            </label>

                            <div class="controls">
                                <input id="attribution" class="input-xlarge" type="text" data-bind="value: attribution">
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="notes">Notes:</label>

                            <div class="controls">
                                <textarea rows="4" class="input-xlarge" id="notes"  data-bind="value: notes"></textarea>
                                %{--<input id="notes"  class="input-xxlarge"type="text" data-bind="value: notes">--}%
                            </div>
                        </div>

                        <div class="control-group readonly">
                            <label class="control-label padding-top-none">File Name:</label>

                            <div class="controls">
                                <span class="padding-top-5" data-bind="text: filename"></span>
                            </div>
                        </div>

                        <div class="control-group readonly">
                            <label class="control-label padding-top-none">File Size:</label>

                            <div class="controls">
                                <span class="padding-top-5" data-bind="text: formattedSize"></span>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="span2">
                    <a class="btn btn-danger" data-bind="click: $parent.${name}.remove">
                        <i class="fa fa-times"></i> Remove
                    </a>
                </div>
            </div>
            <hr/>
        </div>
    </div>

    <div id="recordingControls" data-bind="visible: ${name}.transients.html5AudioSupport()" class="inline-block" style="display: none">
        <span data-bind="click: ${name}.startRecording, visible: !${name}.transients.recording()" class="btn"><span
                class="fa fa-circle red">&nbsp;</span>Start recording</span>
        <span data-bind="click: ${name}.stopRecording, visible: ${name}.transients.recording()" class="btn"><span
                class="fa fa-square">&nbsp;</span>Stop recording</span>

        <div class="vertical-button-divider">- OR -</div>
    </div>

    <div data-bind="${databindAttrs}" data-url="${g.createLink(controller: "bioActivity", action: "uploadFile")}">
        <span id="uploadControls">
            <span class="btn fileinput-button float-none">
                <i class="icon-plus"></i> <input type="file" name="files" accept="audio/*"><span>Attach Audio</span>
            </span>
        </span>

        <div data-bind="visible: !complete()">
            <label for="progress" class="control-label">Uploading file...</label>

            <div id="progress" class="controls progress progress-info active input-large"
                 data-bind="visible: !error() && progress() <= 100, css: {'progress-info': progress()<100, 'progress-success': complete()}">
                <div class="bar" data-bind="style: {width: progress() + '%'}"></div>
            </div>

            <div id="successmessage" class="controls" data-bind="visible: complete()">
                <span class="alert alert-success">File successfully uploaded</span>
            </div>

            <div id="message" class="controls" data-bind="visible: error()">
                <span class="alert alert-error" data-bind="text: error"></span>
            </div>
        </div>
    </div>
</div>

