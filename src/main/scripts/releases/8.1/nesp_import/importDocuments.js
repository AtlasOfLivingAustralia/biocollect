//document upload scripts
var path = '';
load(path + "documentTemplate.js")
load('../../utils/uuid.js');
load(path + 'documents.js');

print("Loaded all dependent files...");
var today = new ISODate();
var dd = today.getDate();
var mm = today.getMonth() + 1; //January is 0!
var yyyy = today.getFullYear();
var dateUTC = yyyy + "-" + ("0" + mm).slice(-2) + "-" + ("0" + dd).slice(-2) + "T00:00:00Z";
var date  = ISODate(dateUTC);
var filepath = yyyy + "-" + ("0" + mm).slice(-2);
print ("filepath: " + filepath);
print ("date: " + dateUTC);
print("Loaded csv file");

for(var i = 0; i < documents.length; i++) {
    print("Loading document "+ (i + 1) + " of " + documents.length);
    var fields = documents[i];
    if(fields.projectId) {
        document.projectId = fields.projectId
        document.documentId = UUID.generate()
        document.description = ""
        document.name = ""
        document.filename = ""
        document.filepath = filepath
        document.contentType = ""
        document.doiLink = ""
        document.role = ""
        document.citation = ""
        document.labels = []
        document.embeddedVideo = ""
        document.dateCreated = date;
        document.lastUpdated = date;

        //When there are commas/ double quotations, tsv adds double quotes in the beginning and end of text, following string
        //manipulations are done to avoid that

        if (fields.title) {
            if ((fields.title.indexOf(',') != -1) || (fields.title.indexOf('"') != -1)) {
                var tempTitle = fields.title.replace(/""/g, '"');
                document.name = tempTitle.substring(1, tempTitle.length - 1);
            }
            else {
                document.name = fields.title
            }
        }

        if (fields.description) {
            if ((fields.description.indexOf(',') != -1) || (fields.description.indexOf('"') != -1)) {
                var tempDescription = fields.description.replace(/""/g, '"');
                document.description = tempDescription.substring(1, tempDescription.length - 1);
            }
            else {
                document.description = fields.description
            }
        }

        if (fields.documentUrl) {
            var docUrl = fields.documentUrl
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

        if (fields.doiLink) {
            if ((fields.doiLink.indexOf(',') != -1) || (fields.doiLink.indexOf('"') != -1)) {
                var tempDoi = fields.doiLink.replace(/""/g, '"');
                document.doiLink = tempDoi.substring(1, tempDoi.length - 1);
            }
            else {
                document.doiLink = fields.doiLink
            }
        }

        if (fields.role) {
            document.role = fields.role
        }

        if (fields.citation) {
            if ((fields.citation.indexOf(',') != -1) || (fields.citation.indexOf('"') != -1)) {
                var tempCitation = fields.citation.replace(/""/g, '"');
                document.citation = tempCitation.substring(1, tempCitation.length - 1);
            }
            else {
                document.citation = fields.citation
            }
        }

        if (fields.keywords) {
            if ((fields.keywords.indexOf(',') != -1) || (fields.keywords.indexOf('"') != -1)) {
                var tempKeywords = fields.keywords.replace(/""/g, '"');
                var tempKeywordsStr  = tempKeywords.substring(1, tempKeywords.length - 1);
                var tempKeywordsArr = tempKeywordsStr.split(',');

                document.labels = tempKeywordsArr;
            }
            else {
                document.labels.push(fields.keywords);
            }
        }

        if (fields.embeddedVideo) {
            if ((fields.embeddedVideo.indexOf(',') != -1) || (fields.embeddedVideo.indexOf('"') != -1)) {
                var tempEmbeddedVideo = fields.embeddedVideo.replace(/""/g, '"');
                document.embeddedVideo = tempEmbeddedVideo.substring(1, tempEmbeddedVideo.length - 1);
            }
            else {
                document.embeddedVideo = fields.embeddedVideo
            }
        }

        var documentResult = db.document.insertOne(document);

        print("PROJECT ID: " + document.projectId)
        print("DOCUMENT ID: " + document.documentId)
        print("FILE NAME: " + document.filename)
        print("insert result: " + JSON.stringify(documentResult));
    }
}

print("Created " + i + " documents");
print("<<<<<<<<<<<<<<<<<<<")