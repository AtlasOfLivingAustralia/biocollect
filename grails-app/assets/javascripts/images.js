function ImageViewModel(prop, skipFindingDocument) {
    var self = this, document;
    var documents

    // used by image gallery plugin. document is passed to the function.
    if (!skipFindingDocument) {
        // activityLevelData is a global variable
        documents = activityLevelData.activity.documents;
        // dereferencing the document using documentId
        documents && documents.forEach(function (doc) {
            // newer implementation is passing document object.
            var docId = prop.documentId || prop;
            if (doc.documentId === docId) {
                prop = doc;
            }
        });
    }

    if (typeof prop !== 'object') {
        console.error('Could not find the required document.')
        return;
    }

    self.dateTaken = ko.observable(prop.dateTaken || (new Date()).toISOStringNoMillis()).extend({simpleDate: false});
    self.contentType = ko.observable(prop.contentType);
    self.url = ko.observable(prop.url);
    self.filesize = prop.filesize;
    self.thumbnailUrl = ko.observable(prop.thumbnailUrl || prop.url);
    self.filename = prop.filename;
    self.attribution = ko.observable(prop.attribution);
    self.licence = ko.observable(prop.licence);
    self.licenceDescription = prop.licenceDescription;
    self.notes = ko.observable(prop.notes || '');
    self.name = ko.observable(prop.name);
    self.formattedSize = formatBytes(prop.filesize);
    self.staged = prop.staged || false;
    self.documentId = prop.documentId || '';
    self.status = ko.observable(prop.status || 'active');
    self.projectName = prop.projectName;
    self.projectId = prop.projectId;
    self.activityName = prop.activityName;
    self.activityId = prop.activityId;
    self.isEmbargoed = prop.isEmbargoed;
    self.identifier = prop.identifier;
    new Emitter(self);


    self.remove = function (images, data, event) {
        if (data.documentId) {
            // change status when image is already in ecodata
            data.status('deleted')
        } else {
            images.remove(data);
        }
    }

    self.getActivityLink = function () {
        return fcConfig.activityViewUrl + '/' + self.activityId;
    }

    self.getProjectLink = function () {
        return fcConfig.projectIndexUrl + '/' + self.projectId;
    }

    self.getImageViewerUrl = function () {
        // Let the image viewer render high res image.
        var url = self.url() ? self.url().split("/image/proxyImageThumbnailLarge?imageId=").join("/image/proxyImage?imageId=") : self.url()
        self.url(url);
        return fcConfig.imageLeafletViewer + '?file=' + encodeURIComponent(self.url());
    }

    self.summary = function () {
        var picBy = 'Picture by ' + self.attribution() + '. ';
        var takenOn = 'Taken on ' + self.dateTaken.formattedDate() + '.';
        var message = '';
        if (self.attribution()) {
            message += picBy;
        }

        message += takenOn;
        return "<p>" + self.notes() + '</p><i>' + message + '</i>';
    }

    self.load = function(prop){
        self.dateTaken(prop.dateTaken || (new Date()).toISOStringNoMillis());
        self.contentType(prop.contentType);
        self.url(prop.url);
        self.thumbnailUrl(prop.thumbnailUrl || prop.url);
        self.filename = prop.filename;
        prop.attribution && self.attribution(prop.attribution);
        prop.licence && self.licence(prop.licence);
        prop.notes && self.notes(prop.notes || '');
        prop.name && self.name(prop.name);
        prop.status && self.status(prop.status || 'active');
        if(prop.filesize)
            self.filesize = prop.filesize
        if(prop.licenceDescription)
            self.licenceDescription = prop.licenceDescription;
        if(prop.filesize)
            self.formattedSize = formatBytes(prop.filesize);
        if(prop.staged !== undefined)
            self.staged = prop.staged || false;
        if(prop.documentId)
            self.documentId = prop.documentId || '';
        if(prop.projectName)
            self.projectName = prop.projectName;
        if(prop.projectId)
            self.projectId = prop.projectId;
        if(prop.activityName)
            self.activityName = prop.activityName;
        if(prop.activityId)
            self.activityId = prop.activityId;
        if(prop.isEmbargoed)
            self.isEmbargoed = prop.isEmbargoed;
        if(prop.identifier)
            self.identifier = prop.identifier;
    }

    /**
     * any document that is in index db. Their url will be prefixed with blob:.
     */
    self.isBlobDocument = function(){
        return !!(document && !!document.blob);
    }

    self.getBlob = function(){
        return document && document.blobObject;
    }

    self.isBlobUrl = function(url){
        return url && url.indexOf('blob:') === 0;
    }

    self.getDocument = function() {
        return document
    }

    /**
     * Check if the url is a valid object url.
     */
    self.fetchImage = function() {
        if (entities.utils.isDexieEntityId(self.documentId)) {
            var documentId = parseInt(self.documentId);
            entities.offlineGetDocument(documentId).then(function(result) {
                document = result.data;
                if (self.isBlobDocument()) {
                    var url = self.url();
                    if (self.isBlobUrl(url)) {
                        URL.revokeObjectURL(url);
                    }

                    url = ImageViewModel.createObjectURL(document);
                    self.url(url);
                    self.thumbnailUrl(url);
                }

                document && self.emit('image-fetched', document);
            });
        }
    }

    self.fetchImage();
}


ImageViewModel.createObjectURL = function addObjectURL(document){
    if (document.blob) {
        var blob = document.blobObject = new Blob([document.blob], {type: document.contentType});
        var url = URL.createObjectURL(blob);
        return url;
    }
}