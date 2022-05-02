// This script will soft delete existing NESP TSR hub's documents

var projectIdArr = ['d748bd95-0b4d-450c-8fa4-20a7bcfd9c19','08e07841-764c-4fcd-8bbc-7dc38e6fbd5f']


var numOfDocumentsToBeUpdated = db.document.find({$and:[{"projectId": {$in: projectIdArr}},{"contentType": "application/pdf"}]}).count()
print("Number of documents to be updated: " + numOfDocumentsToBeUpdated)

var numOfDocumentsUpdated = db.document.update({$and:[{"projectId": {$in: projectIdArr}},{"contentType": "application/pdf"}]},{$set:{"status": "active"}},{multi: true})
print("Number of documents updated: " + numOfDocumentsUpdated)

var documents = db.document.find({$and:[{"projectId": {$in: projectIdArr}},{"contentType": "application/pdf"}]})

var doc = "";
var documentId = "";
var filepath = "";
var filename = "";

print("DOCUMENT ID, FULL PATH");

while (documents.hasNext()) {
    filepath = "/data/ecodata/uploads/"

    doc = documents.next();

    documentId = doc.documentId;
    filename = doc.filename;
    filepath += doc.filepath + "/" + filename;

    print(documentId+", "+filepath);
}