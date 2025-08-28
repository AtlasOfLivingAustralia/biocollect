print("Imported started");
load("./data/projects.js")
load("./templates/organisationTemplate.js")
load("./templates/projectTemplate.js");
load('../../utils/uuid.js');
load('./templates/siteTemplate.js');

print("Loaded all dependent files...");

var userId = "229308";
var hub_name = "Hub";
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
var traditionalPlaceName = "Traditional place name";
var locationOfResearch = "Location of research"
var nationwide = "Scale of research";
var category = "Indigenous consultation and engagement";
var raid = "RAID"

var engagementCategories = {
    "1": "Category 1: Indigenous-led",
    "2": "Category 2: Co-design",
    "3": "Category 3: Communicate",
    "": "Not Applicable"
}

var forceCreateProject = false; //Set to true to delete existing projects and re-create them

for(var i = 0; i < projects.length; i++) {
    var project = projects[i];
    var mappedProject = Object.assign({}, projectMap);
    var checkIfProjectExists = db.project.findOne({name: project[projectName], externalId: project[externalId], status: "active"});
    if (checkIfProjectExists) {
        print("Project already exists: " + project[projectName]);
        if (forceCreateProject) {
            db.project.deleteOne({_id: checkIfProjectExists._id});
            db.site.deleteOne({siteId: checkIfProjectExists.projectSiteId});
        }
        else
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
    mappedProject.managerEmail = (project[managerEmail]|| "" ).trim();
    mappedProject.manager = (project[manager]|| "" ).trim();
    mappedProject.description = (project[description]|| "" ).trim();
    mappedProject.aim = (project[aim]|| "" ).trim();
    mappedProject.name = (project[projectName]|| "" ).trim();
    mappedProject.associatedProgram = (hubToOrgMap[project[hub_name]]|| "" ).trim();
    mappedProject.externalId = (project[externalId]|| "" ).trim();
    mappedProject.keywords = (project[keywords]|| "" ).trim();

    if (project[locationOfResearch]) {
        project[locationOfResearch] = project[locationOfResearch].trim();
        if (mappedProject.keywords)
            mappedProject.keywords += ", " + project[locationOfResearch];
        else
            mappedProject.keywords = project[locationOfResearch];
    }

    if (project[traditionalPlaceName]) {
        project[traditionalPlaceName] = project[traditionalPlaceName].trim();
        if (mappedProject.keywords)
            mappedProject.keywords += ", " + project[traditionalPlaceName];
        else
            mappedProject.keywords = project[traditionalPlaceName];
    }

    if (project[raid]) {
        mappedProject.externalIds = [{idType: "ARDC_RAID", externalId: project[raid].trim()}];
    }

    if(isNational(project[nationwide])) {
        mappedProject.geographicInfo = {
            nationwide: true
        };
    }

    mappedProject.customMetadata = {
        category: engagementCategories[(project[category]|| "" ).trim()]
    }

    //Handle associated orgs
    mappedProject.associatedOrgs = []
    var tempAssociatedOrgs;
    var tempStr = project[associatedOrgs];

    print("Processing associated orgs: " + tempStr);
    if (tempStr) {
        print("Associated orgs: " + tempStr);
        tempAssociatedOrgs = tempStr.split("/");

        for (var j = 0; j < tempAssociatedOrgs.length; j++) {
            var orgName = (tempAssociatedOrgs[j]|| "" ).trim();
            if (orgName) {
                var org = createOrFindOrganisation(orgName, "", "");
                print("Found or created organisation: " + org.name);
                mappedProject.associatedOrgs.push({name: org.name, organisationId: org.organisationId, url: org.url});
            }
        }
    }

    mappedProject.keywords = (project[keywords]|| "" ).trim();
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
    return (value || "").trim() === "National";
}


print(">>>>>>>>>>>>>>>>>>>>")
print("Created " + i + " projects");
print("<<<<<<<<<<<<<<<<<<<")