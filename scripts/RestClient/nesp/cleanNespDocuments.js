// This script will soft delete existing NESP TSR hub's documents

var projectIdArr = ['d748bd95-0b4d-450c-8fa4-20a7bcfd9c19','08e07841-764c-4fcd-8bbc-7dc38e6fbd5f']

db.document.update({$and:[{"projectId": {$in: projectIdArr}},{"contentType": "application/pdf"}]},{$set:{"status": "deleted"}},{multi: true})

var documents = db.document.find({"projectId":{$in:projectIdArr}})

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