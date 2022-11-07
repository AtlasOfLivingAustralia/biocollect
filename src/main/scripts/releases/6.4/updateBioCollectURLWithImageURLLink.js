var BIOCOLLECT_URL = "https://biocollect.ala.org.au"
var BIOCOLLECT_HTTP_URL = "http://biocollect.ala.org.au"
var IMAGE_URL = "https://images.ala.org.au"
var counter = 0;
var records = db.record.find({$or: [{"multimedia.identifier": {$regex: '^' + BIOCOLLECT_URL}}, {"multimedia.identifier": {$regex: '^' + BIOCOLLECT_HTTP_URL}}], "multimedia.imageId": {$ne: null}});
print("records update")
print('occcurrence_id')
while (records.hasNext()) {
    var record = records.next();
    var changed = false;
    for(var i = 0; i < record.multimedia.length; i++) {
        var multimedia = record.multimedia[i];
        if (((multimedia.identifier.indexOf(BIOCOLLECT_URL) == 0) || (multimedia.identifier.indexOf(BIOCOLLECT_HTTP_URL) == 0)) && multimedia.imageId) {
            multimedia.identifier = IMAGE_URL + "/image/proxyImageThumbnailLarge?imageId=" + multimedia.imageId
            changed = true
        }
    }

    if (changed) {
        db.record.save(record);
        print(record.occurrenceID);
        counter ++
    }
}


print("Total records modified - " + counter);

var documents = db.document.find({$or: [{"identifier": {$regex: '^' + BIOCOLLECT_URL}}, {"identifier": {$regex: '^' + BIOCOLLECT_HTTP_URL}}], "imageId": {$ne: null}});
print("records update")
print('documentId')
while (documents.hasNext()) {
    var document = documents.next();
    var changed = false;
    if (((document.identifier.indexOf(BIOCOLLECT_URL) == 0) || (document.identifier.indexOf(BIOCOLLECT_HTTP_URL) == 0)) && document.imageId) {
        document.identifier = IMAGE_URL + "/image/proxyImageThumbnailLarge?imageId=" + document.imageId
        changed = true
    }

    if (changed) {
        db.document.save(document);
        print(document.documentId);
        counter ++
    }
}


print("Total documents modified - " + counter);