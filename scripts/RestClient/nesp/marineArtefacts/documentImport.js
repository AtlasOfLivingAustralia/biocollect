//document upload scripts
var path = '';
load(path + "document.js")
load(path + 'uuid.js');

print("Loaded all dependent files...");

var hub_name = 0;
var projectId = hub_name + 1;
var title = projectId + 1;
var description = title + 1;
var documentUrl = description + 1;
var role = documentUrl + 1;
var citation = role + 1;
var keywords = citation + 1;

var csvData = cat(path+'NESP_MARINE_ARTEFACTS_FOR_TEST.txt');
print("Loaded csv file");
var csvRows = csvData.split('\r');
print("Total rows "+ csvRows.length);

for(var i = 1; i < csvRows.length; i++) {
    print("PRINT "+csvRows.length)

    var row = csvRows[i];
    var fields = row.split('\t');

    if(fields[projectId]) {
        document.projectId = fields[projectId]
        document.documentId = UUID.generate()
        document.description = ""
        document.name = ""
        document.filename = ""
        document.contentType = ""

        //When there are commas, tsv adds double quotes in the beginning and end of text, following string
        //manipulations are done to avoid that

        if (fields[title]) {
            if (fields[title].indexOf(',') != -1) {
                var tempTitle = fields[title].replace(/""/g, '"');
                document.name = tempTitle.substring(1, tempTitle.length - 1);
            }
            else {
                document.name = fields[title]
            }
        }

        if (fields[description]) {
            if (fields[description].indexOf(',') != -1) {
                var tempDescription = fields[description].replace(/""/g, '"');
                document.description = tempDescription.substring(1, tempDescription.length - 1);
            }
            else {
                document.description = fields[description]
            }
        }

        if (fields[documentUrl]) {
            var docUrl = fields[documentUrl]
            var urlSplitBySlash = docUrl.split('/')
            var fileName = urlSplitBySlash[urlSplitBySlash.length - 1]

            var contentType = ""

            if (fileName.endsWith(".pdf")) {
                contentType = "application/pdf"
            } else if (fileName.endsWith(".doc") || fileName.endsWith(".docx")) {
                contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            }

            document.filename = fileName
            document.contentType = contentType
        }

        if (fields[role]) {
            if (fields[role].indexOf(',') != -1) {
                var tempType = fields[role].replace(/""/g, '"');
                document.role = tempType.substring(1, tempType.length - 1);
            }
            else {
                document.role = fields[role]
            }
        }

        if (fields[citation]) {
            if (fields[citation].indexOf(',') != -1) {
                var tempCitation = fields[citation].replace(/""/g, '"');
                document.citation = tempCitation.substring(1, tempCitation.length - 1);
            }
            else {
                document.citation = fields[citation]
            }
        }

        if (fields[keywords]) {
            if (fields[keywords].indexOf(',') != -1) {
                var tempKeywords = fields[keywords].replace(/""/g, '"');
                document.keywords = tempKeywords.substring(1, tempKeywords.length - 1);
            }
            else {
                document.keywords = fields[keywords]
            }
        }

        var today = new ISODate();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        var dateUTC = yyyy + "-" + ("0" + mm).slice(-2) + "-" + ("0" + dd).slice(-2) + "T00:00:00Z";

        document.dateCreated = ISODate(dateUTC);
        document.lastUpdated = ISODate(dateUTC);

        var documentResult = db.document.insert(document);

        print("PROJECT ID: " + document.projectId)
        print("DOCUMENT ID: " + document.documentId)
        print("FILE NAME: " + document.filename)
        print("documentResult " + documentResult)
    }
}

print("Created " + (i-1) + " documents");
print("<<<<<<<<<<<<<<<<<<<")