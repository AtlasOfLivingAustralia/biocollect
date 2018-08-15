<!-- ko stopBinding: true -->
<g:set var="modalId" value="${ modalId?:'attachDocument' }"/>
<div id="${modalId}" class="modal fade" style="display:none;">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="title">Attach Document</h4>
            </div>

            <div class="modal-body">
                <form class="form-horizontal validationContainer" id="documentForm">

                    <div class="control-group">
                        <label class="control-label" for="documentName">Title</label>

                        <div class="controls">
                            <input id="documentName" type="text" data-bind="value:name"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="documentDescription">Description</label>

                        <div class="controls">
                            <input id="documentDescription" type="text" data-bind="value:description"/>

                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="documentAttribution">Attribution</label>

                        <div class="controls">
                            <input id="documentAttribution" type="text" data-bind="value:attribution"/>

                        </div>
                    </div>

                    <div class="control-group" data-bind="visible:roles.length > 1">
                        <label class="control-label" for="documentRole">Document type</label>

                        <div class="controls">
                            <select id="documentRole" style="width: 97%;" data-bind="options:roles, optionsText: 'name', optionsValue: 'id', value:role"></select>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="documentLicense">License</label>

                        <div class="controls">
                            <input id="documentLicense" type="text" data-bind="value:license"/>
                        </div>
                    </div>

                    <div data-bind="visible: embeddedVideoVisible()">
                        <label class="control-label" for="embeddedVideo">
                            Embed video
                        </label>
                        <div class="controls">
                            <textarea placeholder="Example: <iframe width='560' height='315' src='https://www.youtube.com/embed/j1bR-0XBfcs' frameborder='0' allowfullscreen></iframe> (Allowed host: Youtube, Vimeo, Ted, Wistia.)"
                                      data-bind="value: embeddedVideo,  valueUpdate: 'keyup'" style="width: 97%;" rows="3" id="embeddedVideo" type="text">
                            </textarea>
                        </div>
                    </div>

                    <div class="control-group" data-bind="visible:settings.showSettings">
                        <label class="control-label" for="public">Settings</label>
                        <div class="controls">
                            <label class="checkbox" for="public">
                                <input id="public" type="checkbox" data-bind="checked:public"/>
                                make this document public on the project "Resources" tab
                            </label>
                        </div>

                    </div>

                    <div class="control-group" data-bind="visible:thirdPartyConsentDeclarationRequired">
                        <label for="thirdPartyConsentDeclarationMade" class="control-label">Privacy declaration</label>
                        <div id="thirdPartyConsentDeclarationMade" class="controls">
                            <label id="thirdPartyDeclarationText" class="checkbox" for="thirdPartyConsentDeclarationMade">
                                <input id="thirdPartyConsentCheckbox" type="checkbox" name="thirdPartyConsentDeclarationMade" class="validate[required]" data-bind="checked:thirdPartyConsentDeclarationMade">
                                <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.THIRD_PARTY_PHOTO_CONSENT_DECLARATION}"/>
                            </label>
                        </div>
                    </div>


                    <div data-bind="visible: !embeddedVideoVisible()">
                        <div class="control-group">
                            <label class="control-label" for="documentFile">File</label>

                            <div class="controls">

                                <span class="btn fileinput-button">
                                    <i class="icon-plus"></i>
                                    <input id="documentFile" type="file" name="files"/>
                                    <span data-bind="text:fileButtonText">Attach file</span>
                                </span>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label" for="fileLabel"></label>

                            <div class="controls">

                                <span data-bind="visible:filename()">
                                    <input id="fileLabel" type="text" readonly="readonly" data-bind="value:fileLabel"/>
                                    <button class="btn" data-bind="click:removeFile">
                                        <span class="icon-remove"></span>
                                    </button>
                                </span>
                            </div>
                        </div>

                        <div class="control-group" data-bind="visible:hasPreview">
                            <label class="control-label">Preview</label>

                            <div id="preview" class="controls"></div>
                        </div>

                        <div class="control-group" data-bind="visible:progress() > 0">
                            <label for="progress" class="control-label">Progress</label>

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
                        </div>
                    </div>

                </form>
            </div>
            <div class="modal-footer control-group">
                <div class="controls">
                    <button type="button" class="btn btn-success"
                            data-bind="enable:saveEnabled, click:function () { save(); }, visible:!complete(), attr:{'title':saveHelp}">Save</button>
                    <button class="btn" data-bind="click:cancel, visible:!complete()">Cancel</button>
                    <button class="btn" data-bind="click:close, visible:complete()">Close</button>

                </div>
            </div>

        </div>
    </div>
</div>
<!-- /ko -->
