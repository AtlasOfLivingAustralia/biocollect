
/**
 * A view model to capture metadata about a document and manage progress / feedback as a file is uploaded.
 *
 * NOTE that we are attempting to use this same model for document records that have an associated file
 * and those that do not (eg deferral reason docs). The mechanisms for handling these two types (esp saving)
 * are not well integrated at this point.
 *
 * @param doc any existing details of the document.
 * @param owner an object containing key and value properties identifying the owning entity for the document. eg. {key:'projectId', value:'the_id_of_the_owning_project'}
 * @constructor
 */
function DocumentViewModel (doc, owner, settings) {
    var self = this;

    var defaults = {
        //Information is the default option.
        roles:  [
            {id:'blogArticles', name: 'Blog Articles'},
            {id:'bookChapters', name: 'Book Chapters'},
            {id:'brochures', name: 'Brochures'},
            {id:'caseStudies', name: 'Case Studies'},
            {id:'datasets', name: 'Datasets'},
            {id:'documents', name: 'Documents'},
            {id:'embeddedVideo', name:'Embedded Video'},
            {id:'exceedanceReport', name:'Exceedance Report'},
            {id:'factsheets', name: 'Fact sheets'},
            {id:'information', name: 'Information'},
            {id:'journalArticles', name: 'Journal Articles'},
            {id:'magazines', name: 'Magazines'},
            {id:'maps', name: 'Maps'},
            {id:'models', name: 'Models'},
            {id:'other', name:'Other Project document'},
            {id:'photo', name:'Photo'},
            {id:'postersBanners', name: 'Posters and banners'},
            {id:'presentations', name: 'Presentations'},
            {id:'projectPlan', name:'Project Plan / Work plan'},
            {id:'projectVariation', name:'Project Variation'},
            {id:'projectHighlightReport', name:'Project Highlight Report'},
            {id:'reports', name: 'Reports'},
            {id:'thesis', name: 'Thesis'},
            {id:'toolsGuides', name: 'Tools and guides'},
            {id:'webPages', name: 'Web pages'},
            {id:'webinars', name: 'Webinars'}],
        showSettings: true,
        thirdPartyDeclarationTextSelector:'#thirdPartyDeclarationText',
        imageLocation: fcConfig.imageLocation
    };
    this.settings = $.extend({}, defaults, settings);

    // NOTE that attaching a file is optional, ie you can have a document record without a physical file
    this.projectId = ko.observable(doc ? doc.projectId : '');
    this.projectName = ko.observable(doc ? doc.projectName : '');
    this.filename = ko.observable(doc ? doc.filename : '');
    this.citation = ko.observable(doc ? doc.citation : '');
    this.doiLink = ko.observable(doc ? doc.doiLink : '');
    this.description = ko.observable(doc ? doc.description : '');
    this.labels = ko.observableArray(doc ? doc.labels : []);
    this.filesize = ko.observable(doc ? doc.filesize : '');
    this.name = ko.observable(doc.name);
    // the notes field can be used as a pseudo-document (eg a deferral reason) or just for additional metadata
    this.notes = ko.observable(doc.notes);
    this.filetypeImg = function () {
        return self.settings.imageLocation + 'filetypes/' + iconnameFromFilename(self.filename());
    };
    this.status = ko.observable(doc.status || 'active');
    this.attribution = ko.observable(doc ? doc.attribution : '');
    this.license = ko.observable(doc ? doc.license : '');
    this.type = ko.observable(doc.type);
    this.role = ko.observable(doc.role);
    this.roles = this.settings.roles;
    this.public = ko.observable(doc.public);
    this.url = doc.url;
    this.thumbnailUrl = doc.thumbnailUrl ? doc.thumbnailUrl : doc.url;
    this.documentId = doc.documentId;
    this.projectActivityId = doc.projectActivityId ? doc.projectActivityId : '';
    this.hasPreview = ko.observable(false);
    this.error = ko.observable();
    this.progress = ko.observable(0);
    this.complete = ko.observable(false);
    this.readOnly = doc && doc.readOnly ? doc.readOnly : false;
    this.contentType = ko.observable(doc ? doc.contentType : 'application/octet-stream');
    this.fileButtonText = ko.computed(function() {
        return (self.filename() ? "Change file" : "Attach file");
    });
    this.externalUrl = ko.observable(doc.externalUrl);

    self.transients = {};
    self.transients.dateCreated = "";
    self.transients.lastUpdated = "";

    if (doc.dateCreated)
        self.transients.dateCreated = moment(doc.dateCreated).format('DD MMM, YYYY');

    if (doc.lastUpdated)
        self.transients.lastUpdated = moment(doc.lastUpdated).format('DD MMM, YYYY');

    self.transients.isPreviewVisible = function() {
        return ((self.role() == 'journalArticles') || self.externalUrl());
    };

    self.transients.isDownloadVisible = function() {
        return ((self.role() == 'journalArticles') || self.externalUrl() || (self.role() == 'embeddedVideo'));
    };

    self.transients.projectUrl = ko.pureComputed(function () {
        var projectId = ko.unwrap(self.projectId)

        return fcConfig.projectIndexUrl + '/' + projectId +
            (fcConfig.version !== undefined ? "?version=" + fcConfig.version : '');
    });

    this.embeddedVideo = ko.observable(doc.embeddedVideo);
    this.embeddedVideoVisible = ko.computed(function() {
        return (self.role() == 'embeddedVideo');
    });

    this.thirdPartyConsentDeclarationMade = ko.observable(doc.thirdPartyConsentDeclarationMade);
    this.thirdPartyConsentDeclarationMade.subscribe(function(declarationMade) {
        // Record the text that the user agreed to (as it is an editable setting).
        if (declarationMade) {
            self.thirdPartyConsentDeclarationText = $(self.settings.thirdPartyDeclarationTextSelector).text();
        }
        else {
            self.thirdPartyConsentDeclarationText = null;
        }
        $("#thirdPartyConsentCheckbox").closest('form').validationEngine("updatePromptsPosition")
    });
    this.thirdPartyConsentDeclarationRequired = ko.computed(function() {
        return (self.type() == 'image' ||  self.role() == 'embeddedVideo')  && self.public();
    });
    this.thirdPartyConsentDeclarationRequired.subscribe(function(newValue) {
        if (newValue) {
            setTimeout(function() {$("#thirdPartyConsentCheckbox").validationEngine('validate');}, 100);
        }
    });
    this.fileReady = ko.computed(function() {
        return self.filename() && self.progress() === 0 && !self.error();
    });
    this.saveEnabled = ko.computed(function() {
        if (self.thirdPartyConsentDeclarationRequired() && !self.thirdPartyConsentDeclarationMade()) {
            return false;
        }
        else if(self.role() == 'embeddedVideo'){
            return buildiFrame(self.embeddedVideo()) != "" ;
        }
        else if((self.role() == 'journalArticles' && self.doiLink()) ||
            ((self.role() == 'bookChapters' || self.role() == 'webPages' || self.role() == 'webinars') && self.externalUrl())){
            return true;
        }
        return self.fileReady();
    });
    this.saveHelp = ko.computed(function() {
        if(self.role() == 'embeddedVideo' && !buildiFrame(self.embeddedVideo())){
            return 'Invalid embed video code';
        }
        else if(self.role() == 'embeddedVideo' && !self.saveEnabled()){
            return 'You must accept the Privacy Declaration before an embed video can be made viewable by everyone';
        }
        else if (!self.fileReady()) {
            return 'Attach a file using the "+ Attach file" button';
        }
        else if (!self.saveEnabled()) {
            return 'You must accept the Privacy Declaration before an image can be made viewable by everyone';
        }
        return '';
    });
    // make this support both the old key/value syntax and any set of props so we can define more than
    // one owner attribute
    if (owner !== undefined) {
        if (owner.key !== undefined) {
            self[owner.key] = owner.value;
        }
        for (var propName in owner) {
            if (owner.hasOwnProperty(propName) && propName !== 'key' && propName !== 'value') {
                self[propName] = owner[propName];
            }
        }
    }

    /**
     * Detaches an attached file and resets associated fields.
     */
    this.removeFile = function() {
        self.filename('');
        self.filesize('');
        self.hasPreview(false);
        self.error('');
        self.progress(0);
        self.complete(false);
        self.file = null;
    };
    // Callbacks from the file upload widget, these are attached manually (as opposed to a knockout binding).
    this.fileAttached = function(file) {
        self.filename(file.name);
        self.filesize(file.size);
        // Should be use just the mime type or include the mime type as well?
        if (file.type) {
            var type = file.type.split('/');
            if (type) {
                self.type(type[0]);
            }
        }
        else if (file.name) {

            var type = file.name.split('.').pop();

            var imageTypes = ['gif','jpeg', 'jpg', 'png', 'tif', 'tiff'];
            if ($.inArray(type.toLowerCase(), imageTypes) > -1) {
                self.type('image');
            }
            else {
                self.type('document');
            }
        }
    };
    this.filePreviewAvailable = function(file) {
        this.hasPreview(true);
    };
    this.uploadProgress = function(uploaded, total) {
        var progress = Math.round(uploaded/total*100);
        self.progress(progress);
    };
    this.fileUploaded = function(file) {
        self.complete(true);
        self.url = file.url;
        self.documentId = file.documentId;
        self.progress(100);
        setTimeout(self.close, 1000);
    };
    this.fileUploadFailed = function(error) {
        this.error(error);
    };

    /** Formatting function for the file name and file size */
    this.fileLabel = ko.computed(function() {
        var label = self.filename();
        if (self.filesize()) {
            label += ' ('+formatBytes(self.filesize())+')';
        }
        return label;
    });

    // This save method does not handle file uploads - it just deals with saving the doc record
    // - see below for the file upload save
    this.recordOnlySave = function (uploadUrl) {
        $.post(
            uploadUrl,
            {document:self.toJSONString()},
            function(result) {
                self.complete(true); // ??
                self.documentId = result.documentId;
            })
            .fail(function() {
                self.error('Error saving document record');
            });
    };

    this.toJSONString = function() {
        // These are not properties of the document object, just used by the view model.
        return JSON.stringify(self.modelForSaving());
    };

    this.modelForSaving = function() {
        return ko.mapping.toJS(self, {'ignore':['embeddedVideoVisible','iframe','helper', 'progress', 'hasPreview', 'error', 'fileLabel', 'file', 'complete', 'fileButtonText', 'roles', 'settings', 'thirdPartyConsentDeclarationRequired', 'saveEnabled', 'saveHelp', 'fileReady']});
    };

}


/**
 * Attaches the jquery.fileupload plugin to the element identified by the uiSelector parameter and
 * configures the callbacks to the appropriate methods of the supplied documentViewModel.
 * @param uploadUrl the URL to upload the document to.
 * @param documentViewModel The view model to attach to the file upload.
 * @param uiSelector the ui element to bind the file upload functionality to.
 * @param previewElementSelector selector for a ui element to attach an image preview when it is generated.
 */
function attachViewModelToFileUpload(uploadUrl, documentViewModel, uiSelector, previewElementSelector) {

    var fileUploadHelper;

    $(uiSelector).fileupload({
        url:uploadUrl,
        formData:function(form) {
            return [{name:'document', value:documentViewModel.toJSONString()}]
        },
        autoUpload:false,
        getFilesFromResponse: function(data) { // This is to support file upload on pages that include the fileupload-ui which expects a return value containing an array of files.
            return data;
        }
    }).on('fileuploadadd', function(e, data) {
        fileUploadHelper = data;
        documentViewModel.fileAttached(data.files[0]);
    }).on('fileuploadprocessalways', function(e, data) {
        if (data.files[0].preview) {
            documentViewModel.filePreviewAvailable(data.files[0]);
            if (previewElementSelector !== undefined) {
                $(uiSelector).find(previewElementSelector).append(data.files[0].preview);
            }

        }
    }).on('fileuploadprogressall', function(e, data) {
        documentViewModel.uploadProgress(data.loaded, data.total);
    }).on('fileuploaddone', function(e, data) {
        var result;

        // Because of the iframe upload, the result will be returned as a query object wrapping a document containing
        // the text in a <pre></pre> block.  If the fileupload-ui script is included, the data will be extracted
        // before this callback is invoked, thus the check.*
        if (data.result instanceof jQuery) {
            var resultText = $('pre', data.result).text();
            result = JSON.parse(resultText);
        }
        else {
            result = data.result;
        }

        if (!result) {
            result = {};
            result.error = 'No response from server';
        }

        if (result.documentId) {
            documentViewModel.fileUploaded(result);
        }
        else {
            documentViewModel.fileUploadFailed(result.error);
        }

    }).on('fileuploadfail', function(e, data) {
        documentViewModel.fileUploadFailed(data.errorThrown);
    });

    // We are keeping the reference to the helper here rather than the view model as it doesn't serialize correctly
    // (i.e. calls to toJSON fail).
    documentViewModel.save = function() {
        //when saving a new document keywords arrive as a comma separated string, hence splitting to an array
        if (typeof(documentViewModel.labels()) == 'string')
            documentViewModel.labels(documentViewModel.labels().split(','))

        if (documentViewModel.filename() && fileUploadHelper !== undefined) {
            fileUploadHelper.submit();
            fileUploadHelper = null;
        }
        else {
            // There is no file attachment but we can save the document anyway.
            $.post(
                uploadUrl,
                {document:documentViewModel.toJSONString()},
                function(result) {
                    var resp;
                    if (typeof result == "string") {
                        resp = JSON.parse(result).resp
                    } else {
                        resp = result.resp
                    }

                    documentViewModel.fileUploaded(resp);
                })
                .fail(function() {
                    documentViewModel.fileUploadFailed('Error uploading document');
                });
        }
    }
}


/**
 * Creates a bootstrap modal from the supplied UI element to collect and upload a document and returns a
 * jquery Deferred promise to provide access to the uploaded Document.
 * @param uploadUrl the URL to upload the document to.
 * @param documentViewModel default model for the document.  can be used to populate role, etc.
 * @param modalSelector a selector identifying the ui element that contains the markup for the bootstrap modal dialog.
 * @param fileUploadSelector a selector identifying the ui element to attach the file upload functionality to.
 * @param previewSelector a selector identifying an element to attach a preview of the file to (optional)
 * @returns an instance of jQuery.Deferred - the uploaded document will be supplied to a chained 'done' function.
 */
function showDocumentAttachInModal(uploadUrl, documentViewModel, modalSelector, fileUploadSelector, previewSelector) {

    if (fileUploadSelector === undefined) {
        fileUploadSelector = '#attachDocument';
    }
    if (previewSelector === undefined) {
        previewSelector = '#preview';
    }
    var $fileUpload = $(fileUploadSelector);
    var $modal = $(modalSelector);

    attachViewModelToFileUpload(uploadUrl, documentViewModel, fileUploadSelector, previewSelector);

    // Used to communicate the result back to the calling process.
    var result = $.Deferred();

    // Decorate the model so it can handle the button presses and close the modal window.
    documentViewModel.cancel = function() {
        result.reject();
        closeModal();
    };


    documentViewModel.close = function() {
        result.resolve(ko.toJS(documentViewModel));
        closeModal();
    };

    // Close the modal and tidy up the bindings.
    var closeModal = function() {
        $modal.modal('hide');
    };

    ko.applyBindings(documentViewModel, $fileUpload[0]);

    // Do the binding from the model to the view?  Or assume done already?
    $modal.modal({backdrop:'static'});
    $modal.on('shown.bs.modal', function() {
        $modal.find('form').validationEngine({'custom_error_messages': {
            '#thirdPartyConsentCheckbox': {
                'required': {'message':'The privacy declaration is required for images viewable by everyone'}
            }
        }, 'autoPositionUpdate':true, promptPosition:'inline'});
    });

    $modal.on('hidden.bs.modal', function (event) {
        $fileUpload.find(previewSelector).empty();
        ko.cleanNode($fileUpload[0]);
    });

    return result;
}

function findDocumentByRole(documents, role) {
    for (var i=0; i<documents.length; i++) {
        var docRole = ko.utils.unwrapObservable(documents[i].role);
        var status = ko.utils.unwrapObservable(documents[i].status);

        if (docRole === role && status !== 'deleted') {
            return documents[i];
        }
    }
    return null;
};

function findDocumentById(documents, id) {
    if (documents) {
        for (var i=0; i<documents.length; i++) {
            var docId = ko.utils.unwrapObservable(documents[i].documentId);
            var status = ko.utils.unwrapObservable(documents[i].status);
            if (docId === id && status !== 'deleted') {
                return documents[i];
            }
        }
    }
    return null;
}

function DocListViewModel(documents) {
    var self = this;
    this.documents = ko.observableArray($.map(documents, function(doc) { return new DocumentViewModel(doc)} ));
}
function AllDocListViewModel(projectId) {
    var self = $.extend(this, new Documents());

    self.pagination = new PaginationViewModel({}, self);
    self.loading = ko.observable(false);
    self.searchHasFocus = ko.observable(false);
    self.allDocuments = ko.observableArray([]);
    self.documentFilterField = ko.observable('name');
    self.documentFilterField.subscribe(function(type) {
        self.refreshPage(0);
    });
    self.roleFilterField.subscribe(function(type) {
        self.refreshPage(0);
    });
    self.searchDoc = ko.observable('');
    self.sortBy = ko.observable('dateCreated');
    self.sortBy.subscribe(function(by) {
        self.refreshPage(0);
    });

    self.isProject = function(projectId) {
        !!projectId;
    }

    self.refreshPage = function(offset) {
        var params = {offset: offset, max: self.pagination.resultsPerPage()};

        if (self.searchDoc()) {
            let query = this.getQuery(true, self.searchDoc());
            params.searchTerm = query;
        }

        if (self.roleFilterField()) {
            if (self.roleFilterField().id != 'none')
                params.searchInRole = self.roleFilterField()
        }

        if (self.sortBy()) {
            params.sort = self.sortBy();
            params.order = 'desc';
        }

        if (self.documentFilterField())
            params.searchType = self.documentFilterField().fun;

        if (projectId)
            params.projectId = projectId;

        $.ajax({
            url:fcConfig.documentSearchUrl,
            data:params,
            beforeSend: function () {
                self.loading(true);
            },
            success:function(data) {
                if (data.hits) {
                    var docs = data.hits.hits || [];
                    self.allDocuments($.map(docs, function (hit) {
                        return new DocumentViewModel(hit._source);
                    }));

                    if (offset == 0) {
                        self.pagination.loadPagination(0, data.hits.total);
                    }
                }
            },
            complete: function () {
                self.loading(false);
            }
        });
    };

    this.getQuery = function (partialSearch, queryText) {
        var query = queryText.toLowerCase();

        if (partialSearch && ((query.length >= 3) && (query.indexOf('*') == -1))) {
            query = '*' + query + '*';
        }

        return query;
    };

    self.refreshPage(0);

    self.mapDocumentForSearch = function (data) {
        let text = data.toLowerCase();

        switch (text) {
            case "blog articles":
                return roleName = "blogArticles";
                break;
            case "book chapters":
                return roleName = "bookChapters";
                break;
            case "brochures":
                return roleName = "brochures";
                break;
            case "case studies":
                return roleName = "caseStudies";
                break;
            case "datasets":
                return roleName = "datasets";
                break;
            case "documents":
                return roleName = "documents";
                break;
            case "embedded video":
                return roleName = "embeddedVideo";
                break;
            case "exceedance report":
                return roleName = "exceedanceReport";
                break;
            case "factsheets":
                return roleName = "factsheets";
                break;
            case "information":
                return roleName = "information";
                break;
            case "journal articles":
                return roleName = "journalArticles";
                break;
            case "magazines":
                return roleName = "magazines";
                break;
            case "maps":
                return roleName = "maps";
                break;
            case "models":
                return roleName = "models";
                break;
            case "other":
                return roleName = "other";
                break;
            case "photo":
                return roleName = "photo";
                break;
            case "posters and banners":
                return roleName = "postersBanners";
                break;
            case "presentations":
                return roleName = "presentations";
                break;
            case "project plan":
                return roleName = "projectPlan";
                break;
            case "work plan":
                return roleName = "projectPlan";
                break;
            case "project variation":
                return roleName =  "projectVariation";
                break;
            case "project highlight report":
                return roleName = "projectHighlightReport";
                break;
            case "reports":
                return roleName = "reports";
                break;
            case "thesis":
                return roleName = "thesis";
                break;
            case "tools and guides":
                return roleName = "toolsGuides";
                break;
            case "webPages":
                return roleName = "webPages";
                break;
            case "webinars":
                return roleName = "webinars";
                break;
            default:
                return roleName = text;
        }
    }
}

function iconnameFromFilename(filename) {
    if (filename === undefined) { return "blank.png"; }
    var ext = filename.split('.').pop(),
        types = ['aac','ai','aiff','avi','bmp','c','cpp','css','dat','dmg','doc','dotx','dwg','dxf',
            'eps','exe','flv','gif','h','hpp','html','ics','iso','java','jpg','key','mid','mp3','mp4',
            'mpg','odf','ods','odt','otp','ots','ott','pdf','php','png','ppt','psd','py','qt','rar','rb',
            'rtf','sql','tga','tgz','tiff','tif','txt','wav','xls','xlsx'];
    ext = ext.toLowerCase();
    if (ext === 'docx') { ext = 'doc' }
    if ($.inArray(ext, types) >= 0) {
        return ext + '.png';
    } else {
        return "blank.png";
    }
}
