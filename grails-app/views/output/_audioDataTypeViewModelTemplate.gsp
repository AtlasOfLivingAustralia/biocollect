<div id="audioPanel" class="audio-output-panel">
    <div id="filesPanel">
        <div class="row-fluid">
            <div data-bind="foreach: ${name}.files">
                <div class="audio-thumbnail" data-bind="if: status() != 'deleted'">
                    <div class="control-group required">
                        <span class="output-label">Title:</span>

                        <div class="controls">
                            <span class="padding-top-5" data-bind="text: name"></span>
                        </div>
                    </div>

                    <g:if test="${!hideFile}">
                        <div class="margin-bottom-2">
                            <audio data-bind="attr: {src: url, id: id()}" controls="controls">
                                <p class="small"><i class="fa fa-music">&nbsp;</i>Your browser does not support audio playback for this type of file</p>
                            </audio>

                            <div>
                                <a href="" data-bind="attr: {href: transients.downloadUrl()}" class="download"><i class="fa fa-download">&nbsp;</i>Download</a>
                            </div>
                        </div>
                        <div class="clearfix"></div>
                    </g:if>

                    <div class="control-group readonly">
                        <span class="output-label padding-top-none">File Name:</span>

                        <div class="controls">
                            <span class="padding-top-5" data-bind="text: filename"></span>
                        </div>
                    </div>

                    <div class="control-group" data-bind="visible: attribution">
                        <span class="output-label">
                            Attribution:
                        </span>

                        <div class="controls">
                            <span class="padding-top-5" data-bind="text: attribution"></span>
                        </div>
                    </div>

                    <div class="control-group" data-bind="visible: notes">
                        <span class="output-label">Notes:</span>

                        <div class="controls">
                            <span class="padding-top-5" data-bind="text: notes"></span>
                        </div>
                    </div>

                    <div class="control-group readonly">
                        <span class="output-label padding-top-none">File Size:</span>

                        <div class="controls">
                            <span class="padding-top-5" data-bind="text: formattedSize"></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>