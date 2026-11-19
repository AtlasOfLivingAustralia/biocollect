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

var csvData = cat(path+'NESP_tropical_projects.txt');
print("Loaded csv file");
var csvRows = csvData.split('\r');
print("Total rows "+ csvRows.length);

// Include name, organisationId pairs for all associated orgs
var organisations = [
    {name:"Australian National University", organisationId:"e3a71de2-1266-4740-afff-7fb66d94e7af"},
    {name:"Australian Land Conservation Alliance", organisationId:"aa886565-f115-4adc-9d9b-68d196db2f30"},
    {name:"Bush Heritage Australia", organisationId:"cbdee359-e5f3-455f-b9fe-82a8f4018195"},
    {name:"Charles Darwin University", organisationId:"9fe1c64f-ad8c-487d-b7f7-b975563d5e4b"},
    {name:"Cooperative Research Centre for Developing Northern Australia", organisationId:"781b398d-e367-48dc-ab24-0dc049f9860e"},
    {name:"CSIRO", organisationId:"98250704-d244-42d3-abdb-a15e95107560"},
    {name:"Curtin University", organisationId:"0f65d21c-f876-4a01-ad81-2132094c8fb4"},
    {name:"Department of Agriculture Water and the Environment", organisationId:"0f65d21c-f876-4a01-ad81-2132094c8fb4"},
    {name:"Geoscience Australia", organisationId:"19c473e2-9add-49b9-bb78-903114e4cddc"},
    {name:"Government of Western Australia", organisationId:"c1dc5075-affb-4427-b401-ebe5fcebb386"},
    {name:"Griffith University", organisationId:"d7ec26b1-bf35-4499-bfe3-b86fd9b2e971"},
    {name:"James Cook University", organisationId:"4b037317-9813-41b3-b8bc-6225033c479d"},
    {name:"Kimberley Land Council", organisationId:"32be3f2b-d845-407d-a6bd-6cf8e2b25499"},
    {name:"Max Plank Institute", organisationId:"3619c9b9-a1a0-48aa-9026-b6d392eaa7b6"},
    {name:"Monash University", organisationId:"179d9e3b-5e40-410c-a2b6-be01144df89e"},
    {name:"Murdoch University", organisationId:"c23d36ed-2e4a-4b56-b807-fbff825b56ca"},
    {name:"NAILSMA", organisationId:"7e3ddaf9-5a16-4a16-8a64-3d767b49e118"},
    {name:"National Indigenous Australians Agency", organisationId:"176a8283-a416-4bd7-b486-fc670d8af4c4"},
    {name:"Northern Land Council", organisationId:"316ba939-8931-48ee-8375-4a8c9161b885"},
    {name:"Northern Territory Government", organisationId:"15fbf132-27b2-4010-88b9-d75dffab8191"},
    {name:"Parks Australia", organisationId:"87ea0fad-6587-4ad9-8cd8-5cb0c3dc2e47"},
    {name:"Queensland State Government", organisationId:"eb3706c2-df24-4647-bc64-ae8ad9e58ab7"},
    {name:"The Australian Institute of Marine Science", organisationId:"9596b6f2-193d-4c8b-aa06-926f24abfbf2"},
    {name:"The Nature Conservancy", organisationId:"d44d2f0c-d262-4e2a-b0af-b74dc8aa6cfd"},
    {name:"The University of Queensland", organisationId:"8e595164-0ad8-48b7-aefe-473a6e97259e"},
    {name:"University of Western Australia", organisationId:"8c3a7806-6d5e-4b60-97d7-b76ba495750e"},
    {name:"University of Melbourne", organisationId:"d0728e03-5944-4faf-8742-fbb72d06caeb"},
    {name:"University of Tasmania", organisationId:"a5e86f4e-553a-4144-b77c-cadbe60a3a0b"},
    {name:"Central Queensland University (CQU)", organisationId:"e6ae3769-fd68-44d1-80eb-3a3c445f9b0e"},
    {name:"AgriTech Solutions", organisationId:"556b4fff-0f62-48f3-9837-c2ea80d44474"},
    {name:"REEF AND RAINFOREST RESEARCH CENTRE LTD", organisationId:"0a831a1e-9890-4381-88a3-e23834ec3325"}
];

for(var i = 1; i < csvRows.length; i++) {
    print("PRINT "+csvRows.length)
    var projectId = UUID.generate();
    var siteId = UUID.generate();
    var row = csvRows[i];
    var fields = row.split('\t');

    project.projectId = projectId;
    project.urlWeb = fields[projectUrl];
    project.projectSiteId = siteId
    project.projectType = "ecoScience"
    project.organisationId = "57e7d1ff-ed58-4e18-a9e1-a91e7b815630" // hub's organisation id

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

    if(fields[associatedProgram]){
        project.associatedProgram = fields[associatedProgram]
    }

    if(fields[associatedSubProgram]){
        project.associatedSubProgram = fields[associatedSubProgram]
    }

    //Handle associated orgs
    project.associatedOrgs = []

    var tempAssociatedOrgsArr = []
    var tempAssociatedOrgs = "";
    var tempStr = "";

    //assign organisationId for the main organisation from excel sheet first
    if (fields[organisationId]) {
        project.associatedOrgs.push({organisationId: fields[organisationId]});
    }

    //get comma separated values from associatedOrgs field in excelsheet
    if(fields[associatedOrgs].indexOf(',') != -1) {
        tempAssociatedOrgs = fields[associatedOrgs].replace(/""/g, '"');
        tempStr = tempAssociatedOrgs.substring(1, tempAssociatedOrgs.length - 1);
    }
    else {
        var organisation = organisations.find(obj => obj.name === fields[associatedOrgs]);
        project.associatedOrgs.push({organisationId: organisation.organisationId});
    }

    if (tempStr) {
        tempAssociatedOrgsArr = tempStr.split(',');
    }

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

        var documentResult = db.document.insert(document);
    }

    var userPermission = {};
    userPermission.accessLevel = 'admin';
    userPermission.entityId = project.projectId;
    userPermission.userId = '130548';
    userPermission.entityType = 'au.org.ala.ecodata.Project';

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
