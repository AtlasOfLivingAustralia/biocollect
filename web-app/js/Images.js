function ImageViewModel(prop){
    var self = this, document;

    // activityLevelData is a global variable
    var documents = activityLevelData.activity.documents;
    // dereferencing the document using documentId
    documents && documents.forEach(function(doc){
        if(doc.documentId === prop){
            prop = doc;
        }
    });

    if(typeof prop !== 'object'){
        console.error('Could not find the required document.')
        return;
    }

    self["dateTaken"] = ko.observable(prop.dateTaken || (new Date()).toISOStringNoMillis()).extend({simpleDate:false});
    self["contentType"] = ko.observable(prop.contentType);
    self['url'] = prop.url;
    self['filesize'] = prop.filesize;
    self["thumbnailUrl"] = prop.thumbnailUrl;
    self["filename"] = prop.filename;
    self["attribution"] = ko.observable(prop.attribution);
    self.licence = ko.observable(prop.licence);
    self["notes"] = ko.observable(prop.notes || '');
    self["name"] = ko.observable(prop.name);
    self["formattedSize"] = formatBytes(prop.filesize);
    self['staged'] = prop.staged || false;
    self['documentId'] = prop.documentId || '';
    self['status'] = ko.observable(prop.status || 'active')

    self.remove = function(images, data, event){
        if(data.documentId){
            // change status when image is already in ecodata
            data.status('deleted')
        } else {
            images.remove(data);
        }
    }

    self.summary = function(){
        return "<p>" + self.notes() + '</p><i>Picture by ' + self.attribution() + ' on ' + self.dateTaken.formattedDate() +'</i>';
    }
}