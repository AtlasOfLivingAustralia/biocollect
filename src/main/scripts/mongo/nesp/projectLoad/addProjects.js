print("Imported started");
load("./data/projects.js")
load("./templates/organisationTemplate.js")
load("./templates/projectTemplate.js");
load('../../utils/uuid.js');
load('./templates/siteTemplate.js');

print("Loaded all dependent files...");

var userId = "229308";
var hub_name = "Hub";
var associatedProgram ;
var projectSiteId  ;
var organisationId ;
var organisationUrl;
var organisationLogo;
var projectName = "Project name/title";
var externalId = "Project ID";
var aim = "Project outcomes";
var description = "Project summary";
var plannedStartDate = "Start date";
var plannedEndDate = "Completion date";
var manager = "Project leader email";
var managerEmail = "Project leader";
var associatedOrgs = "Lead organisation";
var keywords = "Project keywords";
var nationwide = "Scale of research";


// Include name, organisationId pairs for all associated orgs
var organisations = [
    {name:"CSIRO", organisationId:"98250704-d244-42d3-abdb-a15e95107560"},
    {name:"Curtin University", organisationId:"0f65d21c-f876-4a01-ad81-2132094c8fb4"},
    {name:"Murdoch University", organisationId:"c23d36ed-2e4a-4b56-b807-fbff825b56ca"}
];

for(var i = 0; i < projects.length; i++) {
    var project = projects[i];
    var mappedProject = Object.assign({}, projectMap);
    var checkIfProjectExists = db.project.findOne({name: project[projectName], externalId: project[externalId], status: "active"});
    if (checkIfProjectExists) {
        print("Project already exists: " + project[projectName]);
        continue;
    }

    print("Import "+ (i+1) + " of " + projects.length + " " + project[projectName]);
    var projectId = UUID.generate();
    var siteId = UUID.generate();

    mappedProject.projectId = projectId;
    mappedProject.projectSiteId = siteId;
    var organisation = createOrFindOrganisation(project[hub_name], "", "");
    mappedProject.organisationId = organisation.organisationId;
    mappedProject.organisationName = organisation.name;

    mappedProject.managerEmail = project[managerEmail];
    mappedProject.manager = project[manager];
    mappedProject.description = project[description];
    mappedProject.aim = project[aim];
    mappedProject.name = project[projectName];
    mappedProject.associatedProgram = hubToOrgMap[hub_name];
    mappedProject.externalId = project[externalId];
    mappedProject.keywords = project[keywords];
    mappedProject.geographicInfo.nationwide = isNational(project[nationwide]);
    //Handle associated orgs
    mappedProject.associatedOrgs = []
    var tempAssociatedOrgs;
    var tempStr = project[associatedOrgs];

    print("Processing associated orgs: " + tempStr);
    if (tempStr) {
        print("Associated orgs: " + tempStr);
        tempAssociatedOrgs = tempStr.split("/");

        for (var j = 0; j < tempAssociatedOrgs.length; j++) {
            var orgName = tempAssociatedOrgs[j].trim();
            if (orgName) {
                var org = createOrFindOrganisation(orgName, "", "");
                print("Found or created organisation: " + org.name);
                mappedProject.associatedOrgs.push({name: org.name, organisationId: org.organisationId, url: org.url});
            }
        }
    }

    mappedProject.keywords = project[keywords];
    var startDate = project[plannedStartDate];
    var endDate = project[plannedEndDate];
    mappedProject.plannedStartDate = convertDateToISODate(startDate);
    mappedProject.plannedEndDate = convertDateToISODate(endDate);

    var today = ISODate(getTodayDate());
    mappedProject.dateCreated = today;
    mappedProject.lastUpdated = today;

    if (siteMap) {
        siteMap.projects = [];
        siteMap.projects.push(projectId);
        siteMap.siteId = siteId;
        siteMap.description = siteMap.name = "Project area for "  + project[projectName];
        siteMap.lastUpdated = today;
        siteMap.dateCreated = today;
    }

    var userPermission = {};
    userPermission.accessLevel = 'admin';
    userPermission.entityId = mappedProject.projectId;
    userPermission.userId = userId;
    userPermission.entityType = 'au.org.ala.ecodata.Project';

    var siteResult = db.site.insert(siteMap);
    checkInsertResult(siteResult, "site");
    var projectResult = db.project.insert(mappedProject);
    checkInsertResult(projectResult, "project");
    var permissionResult = db.userPermission.insert(userPermission);
    checkInsertResult(permissionResult, "userPermission");
}

function checkInsertResult(result, entityName) {
    if (result && !result.insertedIds) {
        throw new Error("Failed to insert " + entityName + ". Result: " + JSON.stringify(result));
    }
}
function getTodayDate() {
    var today = new ISODate();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!
    var yyyy = today.getFullYear();
    return yyyy+"-"+("0" + mm).slice(-2)+"-"+("0" + dd).slice(-2)+"T00:00:00Z";
}

function convertDateToISODate(date) {
    if (date && date.length === 10) {
        var parts = date.split("/");
        if (parts.length === 3) {
            return ISODate(parts[2] + "-" + parts[1] + "-" + parts[0] + "T00:00:00Z");
        }
    }

    return null;
}

function isNational (value) {
    return value === "National";
}


print(">>>>>>>>>>>>>>>>>>>>")
print("Created " + i + " projects");
print("<<<<<<<<<<<<<<<<<<<")