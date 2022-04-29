var projectIdArr = ['c713e4f1-c57f-4040-9093-24f9aed39ac5','17e82227-aee5-4fbf-adaa-50a0469847e7']

db.document.update({$and:[{"projectId": {$in: projectIdArr}},{"contentType": "application/pdf"}]},{$set:{"status": "deleted"}},{multi: true})

var documents = db.document.find({"projectId":{$in:projectIdArr}})

var document = ""
var projectId = ""
var documentId = ""
var path = ""
var record = ""

var rows = []

while (documents.hasNext()) {
    document = documents.next();

    projectId = document.projectId;
    documentId = document.documentId;
    path = document.filepath;

    record = projectId + "," + documentId + "," + path

    rows.push(record)
}

let csvContent = "data:text/csv;charset=utf-8,";

rows.forEach(function(row) {
    csvContent += row.join(',');
    csvContent += "\n";
});

console.log(csvContent);

var encodedUri = encodeURI(csvContent);
window.open(encodedUri);

print("documentResult"+documentResult)