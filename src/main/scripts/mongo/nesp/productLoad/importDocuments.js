//document upload scripts
var path = './';
load(path + "templates/documentTemplate.js")
load('../../utils/uuid.js');
load(path + 'data/documents.js');
// load("/Users/var03f/Documents/ala/NESP/NESP 2 Products/NESP2 Product Register - for csiro.js");
var projectIdField = "Project ID",
    projectTitleField = "Project name/title",
    titleField = "Product title",
    fileNameField = "Sharepoint file name",
    citationField = "Citation",
    descriptionField = "Synopsis",
    keywordsField = "Keywords",
    productType = "Type of research product ",
    web = "web link",
    doiField = "DOI",
    associatedProgramField = "Hub full name";
print("Loaded all dependent files...");
var today = new ISODate();
var dd = today.getDate();
var mm = today.getMonth() + 1; //January is 0!
var yyyy = today.getFullYear();
var dateUTC = yyyy + "-" + ("0" + mm).slice(-2) + "-" + ("0" + dd).slice(-2) + "T00:00:00Z";
var date  = ISODate(dateUTC);
var filepath = yyyy + "-" + ("0" + mm).slice(-2);
var projectsNotFound = [], projectsFound = [];
print ("filepath: " + filepath);
print ("date: " + dateUTC);
print("Loaded csv file");

for(var i = 0; i < documents.length; i++) {
    print("Loading document "+ (i + 1) + " of " + documents.length);
    var fields = documents[i];
    fields[projectIdField] = fields[projectIdField].trim();
    fields[projectTitleField] = fields[projectTitleField].trim();
    var project = db.project.findOne({externalId: fields[projectIdField],  associatedProgram: fields[associatedProgramField], organisationName: /NESP 2/, status: {$ne: 'deleted'}})
    if (!project) {
        // throw new Error("Project with externalId: " + fields[projectIdField] + " and name: " + fields[projectTitleField] + " not found.");
        if (projectsNotFound.indexOf(fields[projectIdField] + " - " + fields[projectTitleField]) == -1)
            projectsNotFound.push(fields[projectIdField] + " - " + fields[projectTitleField]);
        continue;
    }

    if(db.document.findOne({projectId: project.projectId, name: fields[titleField],  status: {$ne: 'deleted'}})) {
        db.document.deleteMany({projectId: project.projectId, name: fields[titleField], status: {$ne: 'deleted'}});
    }


    if(project) {
        projectsFound.push(project.projectId);
        document = Object.assign({}, documentTemplate);
        document.projectId = project.projectId
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
        document.status = "active"
        document.dateCreated = date;
        document.lastUpdated = date;

        //When there are commas/ double quotations, tsv adds double quotes in the beginning and end of text, following string
        //manipulations are done to avoid that

        if (fields[titleField]) {
            document.name = fields[titleField];
        }

        if (fields[descriptionField]) {
            document.description = fields[descriptionField];
        }

        if (fields[fileNameField] != "use URL Link") {
            var fileName = fields[fileNameField];
            var contentType = ""

            if (fileName.endsWith(".pdf")) {
                contentType = "application/pdf"
            } else if (fileName.endsWith(".doc") || fileName.endsWith(".docx")) {
                contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            } else if (fileName.endsWith(".pptx")) {
                contentType = "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            }

            document.filename = fileName
            document.contentType = contentType
        }

        if (fields[doiField]) {
                document.doiLink = fields[doiField];
        }

        if (fields[productType]) {
            switch (fields[productType]) {
                case "video":
                case "Video":
                    document.role = "embeddedVideo";
                    document.embeddedVideo = embedInIframe(fields[web]);
                    break;
                case "Journal article":
                    document.role = "journalArticles";
                    break;
                case "Report":
                    document.role = "reports";
                    break;
                case "webinar":
                    document.role = "webinars";
                    break;
                case "Website":
                    document.role = "webPages";
                    document.externalUrl = fields[web];
                    break;
                case "Presentation":
                    document.role = "presentations";
                    break;
                case "Poster":
                    document.role = "postersBanners";
                    break;
                case "newsletter":
                    document.role = "magazines";
                    break;
                case "Fact sheet":
                    document.role = "factsheets";
                    break;
                case "calendar":
                    document.role = "documents";
                    break;
                case "Book or book chapter":
                    document.role = "bookChapters";
                    break;
            }
        }

        if (fields[citationField]) {
                document.citation = fields[citationField];
        }

        if (fields[keywordsField]) {
            if (fields[keywordsField].indexOf(',') != -1) {
                var tempKeywords = fields[keywordsField];
                document.labels = tempKeywords.split(',');
            }
            else if (fields[keywordsField]) {
                document.labels.push(fields.keywords);
            }
        }

        if(fields[doiField]) {
            document.doiLink = fields[doiField]
        }

        var documentResult = db.document.insertOne(document);

        print("PROJECT ID: " + document.projectId)
        print("DOCUMENT ID: " + document.documentId)
        print("FILE NAME: " + document.filename)
        print("insert result: " + JSON.stringify(documentResult));
    }
}

function embedInIframe(url) {
    if (!url) {
        return;
    }

    if (url.indexOf("youtube") != -1) {
        return '<iframe width="560" height="315" src="' + url + '" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>'
    }
    else if (url.indexOf("vimeo") != -1) {
        return '<iframe title="Vimeo player" src="' + url + '" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>'
    }

}
print(">>>>>>>>>>>>>>>>> Projects");
printjson(projectsFound);
print("Created " + i + " documents");
print("<<<<<<<<<<<<<<<<<<<");
print("Projects not found: " + projectsNotFound.length);
printjson(projectsNotFound);