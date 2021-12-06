print("Imported started");
var path = '';
load(path + "document.js")
load(path+"testExample.js");
load(path+'uuid.js');
load(path+'siteTemplate.js');

print("Loaded all dependent files...");

/*
//Prod
var projectSiteId = "75e5599b-44f2-4ffa-975a-e7900839ae35" //https://biocollect.ala.org.au/nesp/site/index/75e5599b-44f2-4ffa-975a-e7900839ae35
// https://biocollect.ala.org.au/nesp/project/index/e7e0fe1a-315d-4485-84ef-73276a812dac
*/

// Test
// Test Project https://biocollect-test.ala.org.au/nesp/project/index/a833ad82-bc3b-41f6-8d98-106df76a089c
// Test Site https://biocollect-test.ala.org.au/biocollect-all/site/index/6d9270aa-6cdd-4cce-a319-5226e0affefc
var hub_name = 0;
var associatedProgram = hub_name + 1;
var associatedSubProgram = associatedProgram + 1;
var projectSiteId = associatedSubProgram + 1;
var projectType = projectSiteId + 1;
var organisationId = projectType + 1;
var organisationUrl = organisationId + 1;
var organisationLogo = organisationUrl + 1;
var projectName = organisationLogo + 1;
var aim = projectName + 1;
var description = aim + 1;
var plannedStartDate = description + 1;
var plannedEndDate = plannedStartDate + 1;
var ecoScienceType = plannedEndDate + 1
var isExternal = ecoScienceType + 1;
var status = isExternal + 1;
var manager = status + 1;
var countries = manager + 1;
var uNRegions = countries + 1;
var banner_image = uNRegions + 1;
var projectUrl = banner_image + 1;
var associatedOrgs = projectUrl + 1;
var contactMail = associatedOrgs + 1;
var keywords = contactMail + 1;
var termsOfUseAgreement = keywords + 1;

var csvData = cat(path+'Marine_Biodiversity_Hub_Projects_tab.txt');
print("Loaded csv file");
var csvRows = csvData.split('\r');
print("Total rows "+ csvRows.length);

// Include name, organisationId pairs for all assoiated orgs
var organisations = [
    {name:"Curtin University", organisationId:"0f65d21c-f876-4a01-ad81-2132094c8fb4"},
    {name:"Murdoch University", organisationId:"c23d36ed-2e4a-4b56-b807-fbff825b56ca"}
];

for(var i = 1; i < 3; i++) {
    print("PRINT "+csvRows.length)
    var projectId = UUID.generate();
    var siteId = UUID.generate();
    var row = csvRows[i];
    var fields = row.split('\t');

    project.projectId = projectId;
    project.urlWeb = fields[projectUrl];
    project.projectSiteId = siteId
    project.projectType = "ecoScience"
    project.organisationId = "8a53da29-bbbe-4a76-81c8-13f0bafd2f85" // hub's organisation id

    //When there are commas, tsv adds double quotes in the beginning and end of text, following string
    //manipulations are done to avoid that
    if(fields[contactMail].indexOf(',') != -1){
        var tempManagerEmail = fields[contactMail].replace(/""/g, '"');
        project.manager = tempManagerEmail.substring(1, tempManagerEmail.length-1);
    }
    else {
        project.manager = fields[contactMail]
    }

    if(fields[manager].indexOf(',') != -1){
        var tempManager = fields[manager].replace(/""/g, '"');
        project.managerEmail = tempManager.substring(1, tempManager.length-1);
    }
    else {
        project.managerEmail = fields[manager]
    }

    if(fields[description].indexOf(',') != -1){
        var tempDescription = fields[description].replace(/""/g, '"');
        project.description = tempDescription.substring(1, tempDescription.length-1);
    }
    else {
        project.description = fields[description]
    }

    if(fields[aim].indexOf(',') != -1){
        var tempAim = fields[aim].replace(/""/g, '"');
        project.aim = tempAim.substring(1, tempAim.length-1);
    }
    else {
        project.aim = fields[aim]
    }

    if(fields[projectName].indexOf(',') != -1){
        var tempProjectName = fields[projectName].replace(/""/g, '"');;
        project.name = tempProjectName.substring(1, tempProjectName.length-1);
    }
    else {
        project.name = fields[projectName]
    }

    if(fields[associatedProgram].indexOf(',') != -1){
        var tempAssociatedProgram = fields[associatedProgram].replace(/""/g, '"');;
        project.associatedProgram = tempAssociatedProgram.substring(1, tempAssociatedProgram.length-1);
    }
    else {
        project.associatedProgram = fields[associatedProgram]
    }

    if(fields[associatedSubProgram].indexOf(',') != -1){
        var tempAssociatedSubProgram = fields[associatedSubProgram].replace(/""/g, '"');;
        project.associatedSubProgram = tempAssociatedSubProgram.substring(1, tempAssociatedSubProgram.length-1);
    }
    else {
        project.associatedSubProgram = fields[associatedSubProgram]
    }

    //Handle associated orgs
    project.associatedOrgs = []

    var tempAssociatedOrgsArr = []
    var tempAssociatedOrgs = "";
    var tempStr = "";

    //get comma separated values from associatedOrgs field in excelsheet
    if(fields[associatedOrgs]) {
        tempAssociatedOrgs = fields[associatedOrgs].replace(/""/g, '"');
        tempStr = tempAssociatedOrgs.substring(1, tempAssociatedOrgs.length - 1);
    }

    if (tempStr) {
        tempAssociatedOrgsArr = tempStr.split(',');
    }

    //assign organisationId for the main organisation from excel sheet
    project.associatedOrgs.push({organisationId: fields[organisationId]});

    for (var k = 0; k < tempAssociatedOrgsArr.length; k++) {
        if (organisations.find(obj => obj.name === tempAssociatedOrgsArr[k])) {
            var org = organisations.find(obj => obj.name === tempAssociatedOrgsArr[k]);
            project.associatedOrgs.push({organisationId: org.organisationId});
        }
        else {
            print("Could not find org id for: "+tempAssociatedOrgsArr[k]);
        }
    }

    var tempKeywords = fields[keywords].replace(/""/g, '"');
    project.keywords = tempKeywords.substring(1, tempKeywords.length-1);

    var startDate = fields[plannedStartDate] ? fields[plannedStartDate].split('/') : '';
    var endDate = fields[plannedEndDate]  ? fields[plannedEndDate].split('/') : '';

    if(!startDate || startDate == undefined || startDate == "" || startDate.length == 0 || startDate.length < 3) {
        var dd = "01";
        var mm = "01";
        var yy = "2000";
        startDate = ""+yy+"-"+mm+"-"+dd+"T00:00:00Z"+"";
        project.plannedStartDate = ISODate(startDate);
    } else {
        startDate = ""+startDate[2]+"-"+("0" + startDate[1]).slice(-2)+"-"+("0" + startDate[0]).slice(-2)+"T00:00:00Z"+"";
        project.plannedStartDate = ISODate(startDate);
    }

    if(!endDate || endDate == undefined || endDate == "" || endDate.length == 0 || endDate.length < 3) {
        //print("Invalid project end date");
    } else {
        endDate = endDate[2] + "-" + ("0" + endDate[1]).slice(-2)+"-"+("0" + endDate[0]).slice(-2)+"T00:00:00Z"+"";
        project.plannedEndDate = ISODate(endDate);
    }

    project.ecoScienceType = [];
    if(fields[ecoScienceType]) {
        project.ecoScienceType << fields[ecoScienceType]
    }

    var today = new ISODate();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!
    var yyyy = today.getFullYear();
    var dateUTC = yyyy+"-"+("0" + mm).slice(-2)+"-"+("0" + dd).slice(-2)+"T00:00:00Z";

    project.dateCreated = ISODate(dateUTC);
    project.lastUpdated = ISODate(dateUTC);

    if(siteMap) {
        siteMap.projects = [];
        siteMap.projects.push(projectId);
        siteMap.siteId = siteId;
        siteMap.lastUpdated = ISODate(dateUTC);
        siteMap.dateCreated = ISODate(dateUTC);
    }

    if(fields[banner_image]) {
        var imageUrl = fields[banner_image]
        var urlSplitBySlash = imageUrl.split('/')
        var fileName = urlSplitBySlash[urlSplitBySlash.length-1]

        var contentType = "image/jpg"

        if(fileName.endsWith(".png")) {
            contentType = "image/png"
        }

        document.filename = fileName
        document.name = fileName
        document.documentId = UUID.generate()
        document.projectId = project.projectId
        document.contentType = contentType
        document.fileLabel = fileName
        document.dateCreated = ISODate(dateUTC);
        document.lastUpdated = ISODate(dateUTC);
    }

    var userPermission = {};
    userPermission.accessLevel = 'admin';
    userPermission.entityId = project.projectId;
    userPermission.userId = '130548';
    userPermission.entityType = 'au.org.ala.ecodata.Project';

    var documentResult = db.document.insert(document);
    var siteResult = db.site.insert(siteMap);
    var projectResult = db.project.insert(project);
    var permissionResult = db.userPermission.insert(userPermission);

    //print(JSON.stringify(project,null,"\t"));
    print("Project is "+project.projectId + "," + project.name);
    print("siteResult"+siteResult)
    print("projectResult"+projectResult)
    print("permissionResult"+permissionResult)
    print("documentResult"+documentResult)
}


print(">>>>>>>>>>>>>>>>>>>>")
print("Created " + (i-1) + " projects");
print("<<<<<<<<<<<<<<<<<<<")
