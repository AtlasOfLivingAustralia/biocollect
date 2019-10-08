// export PATH=$PATH:/Users/sat01a/All/j2ee/mongodb_2.6.2/bin
// cd /Users/sat01a/All/j2ee/mongodb_2.6.2/bin
// ./mongo /Users/sat01a/All/sat01a_git/merged/biocollect-4/scripts/WABSI_ProjectLoad/import.js

// cd /usr/bin
// ./mongo ~/WABSI_ProjectLoad/import.js
print("Imported started");

var path = '/Users/sat01a/All/sat01a_git/merged/biocollect-4/scripts/WABSI_ProjectLoad/';

load(path+"projectTemplate.js");
load(path+'Deserts.js');
load(path+'Gascoyne_Murchison.js');
load(path+'Gascoyne_Murchison_Pilbara_Deserts_Kimberley.js');
load(path+'GreatWesternWoodlands_Pilbara_Deserts_Kimberley.js');
load(path+'GreatWesternWoodlands_Gascoyne_Murchison_Pilbara_Deserts_Kimberley.js');
load(path+'Great_Western_Woodlands.js');
load(path+'GreatWesternWoodlands_Gascoyne_Murchison_Pilbara_Deserts.js');
load(path+'GreatWesternWoodlands_Gascoyne_Murchison.js');
load(path+'Islands.js');
load(path+'Kimberley.js');
load(path+'Islands_Kimberley.js');
load(path+'Pilbara.js');
load(path+'Pilbara_Deserts.js');
load(path+'Pilbara_Deserts_Kimberley.js');
load(path+'Pilbara_Kimberley.js');
load(path+'South-West.js');
load(path+'SouthWest_Gascoyne_Murchison.js');
load(path+'SouthWest_GreatWesternWoodlands.js');
load(path+'SouthWest_GreatWesternWoodlands_Gascoyne_Murchison.js');
load(path+'Western_Australia.js');
load(path+'uuid.js');

// Not Found
// University of Queensland
// ARC Linkage
// Department of the Environment - Threatened Species Commissioner
// Rangelands NRM
// Millennium Seed Bank
print("Loaded all dependent files...");
var misingSiteIds = [];
var siteIds = [];
var projectIds = [];
var organisations =
    [
        ["Curtin University","0f65d21c-f876-4a01-ad81-2132094c8fb4"],
        ["Commonwealth Scientific and Industrial Research Organisation","cd3b5f63-86f6-4db1-821e-24b850ef29e3"],
        ["Department Biodiversity Conservation & Attractions","060592a4-5baf-4ad4-931a-13e97fe55290"],
        ["Murdoch University", "c23d36ed-2e4a-4b56-b807-fbff825b56ca"],
        ["Western Australian Museum","e7b093d2-d980-4017-bbc1-fe16849127c4"],
        ["The University of Western Australia","d1b73b53-1260-4a51-8d76-08a093cf4f91"],
        ["Botanic Gardens Parks Authority","7610f1b1-90ee-4ae2-a1cb-4fb103c68c79"],
        ["Edith Cowan University","6c43ecda-7740-4149-bb80-eabcfb5df564"],
        ["Department Biodiversity Conservation & Attractions","060592a4-5baf-4ad4-931a-13e97fe55290"],
        ["Edith Cowan University","6c43ecda-7740-4149-bb80-eabcfb5df564"],
        ["The Australian National University","84d7dba7-089d-4fa3-8780-13dba3fca6e0"],
        ["Department of Biodiversity Conservation and Attractions", "060592a4-5baf-4ad4-931a-13e97fe55290"],
        ["University of Adelaide","9f7fcc8e-9200-441d-88c6-40f118b1284b"]
    ];

var headers = ["projectType","Organisation","Name","Aim","Description","associatedOrganisationName",
                "sponsorOrganisation","Planned start date","Planned end date","ecoScienceType","isExternal",
                "status","externalFunds","inKindFunds","funding","manager","programName","subProgram","countries","uNRegions","site"];

var ecoScienceType = [
    "agroecology",
    "species composition",
    "bioregional inventory",
    "decomposition",
    "ecological succession",
    "ecotoxicology",
    "functional ecology",
    "landscape ecology",
    "macroecology",
    "other",
    "population dynamics",
    "restoration ecology",
    "species distribution modelling",
    "symbyotic interactions",
    "predator-prey interactions",
    "soil ecology",
    "paleoecology",
    "molecular ecology",
    "long-term community monitoring",
    "global ecology",
    "ecophysiology",
    "evolutionary ecology",
    "disease ecology",
    "chemical ecology",
    "structural assemblage",
    "behavioural ecology",
    "biodiversity inventory",
    "biogeography",
    "competition/resource partitioning",
    "disturbances",
    "ecosystem modelling",
    "fire ecology",
    "herbivory",
    "long-term species monitoring",
    "none",
    "pollination",
    "productivity",
    "species decline",
    "urban ecology"];

var subProgram = ["WABSI Theme", "Restoration and Conservation", "Processes and Threat Mitigation", "Information management", "Biodiversity Survey"];
var PROJECT_TYPE        = 0;
var ORGANISATION_NAME   = PROJECT_TYPE + 1;
var PROJECT_NAME        = ORGANISATION_NAME + 1;
var AIM                 = PROJECT_NAME + 1;
var DESCRIPTION         = AIM + 1;
var ASSOCIATED_ORG_NAME = DESCRIPTION + 1;
var SPONSOR_ORG         = ASSOCIATED_ORG_NAME + 1;
var START_DATE          = SPONSOR_ORG + 1;
var END_DATE            = START_DATE + 1;
var ECOSCIENCE_TYPE     = END_DATE + 1;
var STATUS              = ECOSCIENCE_TYPE + 1;
var EXTERNAL_FUNDS      = STATUS + 1;
var IN_KIND_FUNDS       = EXTERNAL_FUNDS + 1;
var FUNDING             = IN_KIND_FUNDS + 1;
var MANAGER             = FUNDING + 1;
var PROGRAM_NAME        = MANAGER + 1;
var SUB_PROGRAM         = PROGRAM_NAME + 1;
var COUNTRIES           = SUB_PROGRAM + 1;
var UN_REGIONS          = COUNTRIES + 1;
var SITES               = UN_REGIONS + 1;

var csvData = cat(path+'wabsi_9.csv');
print("Loaded csv file");
var csvRows = csvData.split('\r');
print("Total rows "+ csvRows.length);


for(var i = 0; i < csvRows.length; i++) {
        var projectId = UUID.generate();
        var siteId = UUID.generate();
        var row = csvRows[i];
        var fields = row.split(',');
        project.name = fields[PROJECT_NAME] ? fields[PROJECT_NAME].replace("||", ",") : 'Not Available';
        project.aim = fields[AIM] ? fields[AIM].replace("||", ",") : '';
        project.description = fields[DESCRIPTION] ? fields[DESCRIPTION].replace("||", ",") : '';
        project.funding = fields[FUNDING];
        project.managerEmail = fields[MANAGER] ? fields[MANAGER].replace("||", ",") : '';;
        project.organisationId = "";
        project.organisationName = "";
        project.projectId = projectId;
        project.projectSiteId = siteId;
        project.plannedStartDate = fields[START_DATE];
        project.associatedOrgs = [];
        project.orgIdSponsor = "";
        project.ecoScienceType = [];

        // Include associated program in to project description.
        if(fields[ASSOCIATED_ORG_NAME]) {
                project.description = project.description + "\n" + "Associated Organisations: " +  fields[ASSOCIATED_ORG_NAME];
        }

        if(fields[SPONSOR_ORG]){
            for (var m = 0; m < organisations.length; m++) {
                var temp = organisations[m];
                if (fields[SPONSOR_ORG].toLowerCase() == temp[0].toLowerCase()) {
                    project.orgSponsor = temp[0];
                    project.orgIdSponsor = temp[1];
                    break;
                }
            }
            if(project.orgSponsor) {
                // Use the orgSponsor with the id.
            } else {
                project.orgSponsor = fields[SPONSOR_ORG]
            }
        }

        //Organisation
        if(fields[ORGANISATION_NAME]){

                for (var m = 0; m < organisations.length; m++) {
                        var temp = organisations[m];
                        if (fields[ORGANISATION_NAME].toLowerCase() == temp[0].toLowerCase()) {
                                project.organisationName = temp[0];
                                project.organisationId = temp[1];
                                break;
                        }
                }
        } else {
                print("Organisation not found - row " + (i+1) + fields[ORGANISATION_NAME]);
        }

        if(fields[ECOSCIENCE_TYPE]) {
                for (var j = 0; j < ecoScienceType.length; j++) {
                        if (fields[ECOSCIENCE_TYPE].toLowerCase() == ecoScienceType[j]) {
                                project.ecoScienceType.push(ecoScienceType[j]);
                                break;
                        }
                }
        } else {
                //print("EcoScience type missing - row "+ (i+1));
        }

        project.associatedSubProgram = fields[SUB_PROGRAM];
        try {
            project.funding = fields[FUNDING] ? parseDouble(fields[FUNDING]) : 0.0;
        }
        catch(err){
            project.funding = 0.0;
        }
        var fundingMap = {};
        fundingMap.fundingSource = fields[SPONSOR_ORG];
        fundingMap.fundingSourceAmount = project.funding;
        fundingMap.fundingType = "Private - in-kind";
        project.fundings = [];
        project.fundings.push(fundingMap);
        project.projectSiteId = siteId;

        var startDate = fields[START_DATE] ? fields[START_DATE].split('/') : '';
        var endDate = fields[END_DATE]  ? fields[END_DATE].split('/') : '';
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

        var siteMap = '';
        fields[SITES] = fields[SITES] ? fields[SITES].trim() : '';
        if(fields[SITES] == "Western Australia"){
            siteMap = westernAustralia;
        }
        else if(fields[SITES] == "Deserts") {
            siteMap = deserts;
        }

        else if(fields[SITES] == "Pilbara") {
            siteMap = pilbara;
        }
        else if(fields[SITES] == "South West-Great Western Woodlands-Gascoyne/Murchison") {
            siteMap = swgwwgm;
        }

        else if(fields[SITES] == "South West") {
            siteMap = southWest;
        }

        else if(fields[SITES] == "Gascoyne/Murchison-Pilbara-Deserts-Kimberley") {
            siteMap = gmpdk;
        }

        else if(fields[SITES] == "Great Western Woodlands-Gascoyne/Murchison-Pilbara-Deserts-Kimberley") {
            siteMap = gwwgmpdk;
        }

        else if(fields[SITES] == "Great Western Woodlands-Pilbara-Deserts-Kimberley") {
            siteMap = gwwpdk;
        }

        else if(fields[SITES] == "Pilbara-Deserts-Kimberley") {
            siteMap = pdk;
        }

        else if(fields[SITES] == "Great Western Woodlands-Gascoyne/Murchison") {
            siteMap = gwwgm;
        }

        else if(fields[SITES] == "Islands") {
            siteMap = islands;
        }

        else if(fields[SITES] == "Kimberley") {
            siteMap = kimberley;
        }

        else if(fields[SITES] == "Islands-Kimberley") {
            siteMap = islandKimberly;
        }

        else if(fields[SITES] == "Pilbara-Kimberley") {
            siteMap = pk;
        }

        else if(fields[SITES] == "Gascoyne/Murchison") {
            siteMap = gm;
        }

        else if(fields[SITES] == "Pilbara-Deserts") {
            siteMap = pd;
        }

        else if(fields[SITES] == "South West-Gascoyne/Murchison") {
            siteMap = swgm;
        }
        else if(fields[SITES] == "Great Western Woodlands") {
            siteMap = gww;
        }

        else if(fields[SITES] == "South West-Great Western Woodlands") {
            siteMap = swgww;
        }

        else if(fields[SITES] == "Great Western Woodlands-Gascoyne/Murchison-Pilbara-Deserts") {
            siteMap = gwwgmpd;
        }
        else {
            misingSiteIds.push(((i+1) +". " +fields));
        }
        if(siteMap) {
            siteMap.projects = [];
            siteMap.projects.push(projectId);
            siteMap.siteId = siteId;
            var today = new ISODate();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();
            var dateUTC = yyyy+"-"+("0" + mm).slice(-2)+"-"+("0" + dd).slice(-2)+"T00:00:00Z";
            siteMap.lastUpdated = ISODate(dateUTC);
            siteMap.dateCreated = ISODate(dateUTC);

            project.lastUpdated = ISODate(dateUTC);
            project.dateCreated = ISODate(dateUTC);

        }

    //siteMap = JSON.stringify(siteMap,null, "\t");
    //siteMap.replace(/\\"/g,"\uFFFF"); //U+ FFFF
    //siteMap = siteMap.replace(/\"([^"]+)\":/g,"$1:").replace(/\uFFFF/g,"\\\"");

    //project = JSON.stringify(project,null, "\t");
    //project.replace(/\\"/g,"\uFFFF"); //U+ FFFF
    //project = project.replace(/\"([^"]+)\":/g,"$1:").replace(/\uFFFF/g,"\\\"");

    //siteMap = JSON.stringify(siteMap);
    //siteMap = siteMap.replace(/\\"/g,"\uFFFF");
    //siteMap = siteMap.replace(/\"([^"]+)\":/g,"$1:").replace(/\uFFFF/g,"\\\"");
    //print(siteMap);
    //print(JSON.stringify(project,null, "\t"));

    //var siteObj = JSON.parse(siteMap);
    var dbConn = new Mongo();
    var ecodataDb = dbConn.getDB("ecodata");
    var result = ecodataDb.site.insert(siteMap);
    var projectResult = ecodataDb.project.insert(project);

    var userPermission = {};
    userPermission.accessLevel = 'admin';
    userPermission.entityId = projectId;
    userPermission.userId = '70866';
    userPermission.entityType = 'au.org.ala.ecodata.Project';
    var projectResult = ecodataDb.userPermission.insert(userPermission);
    print("siteId     >> " + siteId);
    print("projectId  >> " + projectId);
}


for(var error = 0; error < misingSiteIds.length; error++) {
    print(misingSiteIds[error]);
}

