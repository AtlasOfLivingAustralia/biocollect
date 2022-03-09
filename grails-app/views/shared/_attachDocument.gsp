<!-- ko stopBinding: true -->
<g:set var="modalId" value="${ modalId?:'attachDocument' }"/>
<div id="${modalId}" class="modal fade">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="title">Attach Document</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <form class="validationContainer" id="documentForm">

                    <div class="row form-group">
                        <label class="col-form-label col-sm-3" for="documentName">Title</label>

                        <div class="col-sm-9">
                            <input class="form-control" id="documentName" type="text" data-bind="value:name"/>
                        </div>
                    </div>

                    <div class="row form-group">
                        <label class="col-form-label col-sm-3" for="documentDescription">Description</label>

                        <div class="col-sm-9">
                            <input class="form-control" id="documentDescription" type="text" data-bind="value:description"/>
                        </div>
                    </div>

                    <div class="row form-group">
                        <label class="col-form-label col-sm-3" for="documentAttribution">Attribution</label>

                        <div class="col-sm-9">
                            <input class="form-control" id="documentAttribution" type="text" data-bind="value:attribution"/>

                        </div>
                    </div>

                    <div class="row form-group" data-bind="visible:roles.length > 1">
                        <label class="col-form-label col-sm-3" for="documentRole">Document type</label>

                        <div class="col-sm-9">
                            <select class="form-control" id="documentRole" data-bind="options:roles, optionsText: 'name', optionsValue: 'id', value:role"></select>
                        </div>
                    </div>

                    <div class="row form-group">
                        <label class="col-form-label col-sm-3" for="documentLicense">License</label>

                        <div class="col-sm-9">
                            <input class="form-control" id="documentLicense" type="text" data-bind="value:license"/>
                        </div>
                    </div>

                    <div class="row form-group" data-bind="visible: embeddedVideoVisible()">
                        <label class="col-sm-3" for="embeddedVideo">
                            Embed video
                        </label>
                        <div class="col-sm-9">
                            <textarea class="form-control w-100" placeholder="Example: <iframe width='560' height='315' src='https://www.youtube.com/embed/j1bR-0XBfcs' frameborder='0' allowfullscreen></iframe> (Allowed host: Youtube, Vimeo, Ted, Wistia.)"
                                      data-bind="value: embeddedVideo,  valueUpdate: 'keyup'" rows="3" id="embeddedVideo" type="text">
                            </textarea>
                        </div>
                    </div>

                    <div class="row form-group" data-bind="visible:settings.showSettings">
                        <label class="col-form-label col-sm-3" for="public">Settings</label>
                        <div class="col-sm-9">
                            <div class="form-check">
                                <input class="form-check-input" id="public" type="checkbox" data-bind="checked:public"/>
                                <label class="checkbox form-check-label" for="public">make this document public on the project "Resources" tab</label>
                            </div>
                        </div>

                    </div>

                    <div class="row form-group" data-bind="visible:thirdPartyConsentDeclarationRequired">
                        <label for="thirdPartyConsentDeclarationMade" class="col-sm-3 col-form-label">Privacy declaration</label>
                        <div id="thirdPartyConsentDeclarationMade" class="col-sm-9">
                            <div class=" form-check">
                                <input class="validate[required] form-check-input" id="thirdPartyConsentCheckbox" type="checkbox" name="thirdPartyConsentDeclarationMade" data-bind="checked:thirdPartyConsentDeclarationMade">
                                <label class="form-check-label" id="thirdPartyDeclarationText" for="thirdPartyConsentCheckbox">
                                    <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.THIRD_PARTY_PHOTO_CONSENT_DECLARATION}"/>
                                </label>
                            </div>
                        </div>
                    </div>


                    <div data-bind="visible: !embeddedVideoVisible()">
                        <div class="row form-group">
                            <label class="col-sm-3 col-form-label" for="documentFile">File</label>

                            <div class="col-sm-9">

                                <span class="btn btn-dark fileinput-button">
                                    <i class="fas fa-file-upload"></i>
                                    <input id="documentFile" type="file" name="files"/>
                                    <span data-bind="text:fileButtonText">Attach file</span>
                                </span>
                            </div>
                        </div>

                        <div class="row form-group">
                            <label class="col-form-label col-sm-3" for="fileLabel"></label>

                            <div class="col-sm-9">

                                <span data-bind="visible:filename()">
                                    <input id="fileLabel" type="text" readonly="readonly" data-bind="value:fileLabel"/>
                                    <button class="btn btn-sm btn-danger" data-bind="click:removeFile">
                                        <i class="far fa-trash-alt"></i>
                                    </button>
                                </span>
                            </div>
                        </div>

                        <div class="row form-group" data-bind="visible:hasPreview">
                            <label class="col-form-group col-sm-3">Preview</label>

                            <div class="col-sm-9">
                                <div id="preview" class="controls"></div>
                            </div>
                        </div>

                        <div class="row form-group" data-bind="visible:progress() > 0">
                            <label class="col-form-label col-sm-3" for="progress">Progress</label>

%{--                            <div class="col-sm-9 progress progress-info active input-large" id="progress"--}%
%{--                                 data-bind="visible:!error() && progress() <= 100, css:{'progress-info':progress()<100, 'progress-success':complete()}">--}%
%{--                                <div class="bar" data-bind="style:{width:progress()+'%'}"></div>--}%
%{--                            </div>--}%
                            <div class="col-sm-9 progress" id="progress" data-bind="visible:!error() && progress() <= 100">
                                <div class="progress-bar bg-info" role="progressbar"
                                     data-bind="css:{'width': progress}, attr:{'aria-valuenow': progress }"
                                     aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>

                            <div class="col-sm-9" id="successmessage" data-bind="visible:complete()">
                                <span class="alert alert-success">File successfully uploaded</span>
                            </div>

                            <div class="col-sm-9" id="message" data-bind="visible:error()">
                                <span class="alert alert-danger" data-bind="text:error"></span>
                            </div>
                        </div>
                    </div>

                </form>
            </div>
            <div class="modal-footer ">
                <button type="button" class="btn btn-primary-dark"
                        data-bind="enable:saveEnabled, click:function () { save(); }, visible:!complete(), attr:{'title':saveHelp}"><i class="fas fa-hdd"></i> Save</button>
                <button class="btn btn-dark" data-bind="click:cancel, visible:!complete()"><i class="far fa-times-circle"></i> Cancel</button>
                <button class="btn btn-dark" data-bind="click:close, visible:complete()"><i class="fas fa-times"></i> Close</button>
            </div>

        </div>
    </div>
</div>
<!-- /ko -->
