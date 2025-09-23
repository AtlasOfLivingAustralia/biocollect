print("Imported started");
//load("./data/projects.js")
load("/Users/var03f/Documents/ala/NESP/NPIL for CSIRO August 2025.json")
load("./templates/organisationTemplate.js")
load("./templates/projectTemplate.js");
load('../../utils/uuid.js');
load('./templates/siteTemplate.js');
load('./templates/documentTemplate.js');
load('../../utils/audit.js');

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

var hubToLogoMap = {
    "RL": {
        filepath: "2025-06",
        filename: "712066-2.1.jpg",
        name : "712066-2.1.jpg",
        fileSize: 6694415,
        contentType: "image/jpeg"
    },
    "SCaW": {
        filepath: "2025-06",
        filename: "709144-2.1.jpg",
        name : "709144-2.1.jpg",
        fileSize: 206619,
        contentType: "image/jpeg"
    },
    "MaC": {
        filepath: "2025-06",
        filename: "709532-2.1.jpg",
        name : "709532-2.1.jpg",
        fileSize: 680431,
        contentType: "image/jpeg"
    },
    "CS":{
        filepath: "2025-06",
        filename: "709498-2.1.jpg",
        name : "709498-2.1.jpg",
        fileSize: 340563,
        contentType: "image/jpeg"
    }
}

var forceCreateProject = true; //Set to true to delete existing projects and re-create them

for(var i = 0; i < projects.length; i++) {
    var project = projects[i];
    var mappedProject = Object.assign({}, projectMap);
    project[projectName] = (project[projectName] || "" ).trim();
    var checkIfProjectExists = db.project.findOne({name: project[projectName], externalId: project[externalId], status: "active"});
    if (checkIfProjectExists) {
        print("Project already exists: " + project[projectName]);
        if (forceCreateProject) {
            var existingProjects = db.project.find({name: project[projectName], externalId: project[externalId], status: "active"});
            while (existingProjects.hasNext()) {
                var p = existingProjects.next();
                audit(p, p.projectId, 'au.org.ala.ecodata.Project', "system", p.projectId, 'Delete');
                db.project.deleteOne({projectId: p.projectId});
                var deleteSite = db.site.findOne({projects: p.projectId});
                if (deleteSite) {
                    audit(deleteSite, deleteSite.siteId, 'au.org.ala.ecodata.Site', "system", p.projectId, 'Delete');
                    db.site.deleteOne({siteId: deleteSite.siteId});
                }

                var deleteDocument = db.document.findOne({projectId: p.projectId});
                if(deleteDocument) {
                    audit(deleteDocument, deleteDocument.documentId, 'au.org.ala.ecodata.Document', "system", p.projectId, 'Delete');
                    db.document.deleteOne({documentId: deleteDocument.documentId});
                }
                var userPermissions = db.userPermission.find({entityId: p.projectId});
                while (userPermissions.hasNext()) {
                    var up = userPermissions.next();
                    audit(up, up._id, 'au.org.ala.ecodata.UserPermission', "system", up.entityId, 'Delete');
                    db.userPermission.deleteOne({_id: up._id});
                }
            }
        }
        else
            continue;
    }

    print("Import "+ (i+1) + " of " + projects.length + " " + project[projectName]);
    var projectId = UUID.generate();
    var siteId = UUID.generate();
    var documentId = UUID.generate();

    mappedProject.projectId = projectId;
    mappedProject.projectSiteId = siteId;
    var organisation = createOrFindOrganisation(project[hub_name], "", "");
    mappedProject.organisationId = organisation.organisationId;
    mappedProject.organisationName = organisation.name;
    mappedProject.managerEmail = (project[managerEmail]|| "" ).trim();
    mappedProject.manager = (project[manager]|| "" ).trim();
    mappedProject.description = (project[description]|| "" ).trim();
    mappedProject.aim = (project[aim]|| "" ).trim();
    mappedProject.name = project[projectName]
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

    if (document) {
        document.documentId = documentId;
        document.projectId = projectId;
        document.dateCreated = today;
        document.lastUpdated = today;
        document.filepath = hubToLogoMap[project[hub_name]].filepath;
        document.filename = hubToLogoMap[project[hub_name]].filename;
        document.name = hubToLogoMap[project[hub_name]].name;
        document.filesize = hubToLogoMap[project[hub_name]].fileSize;
        document.contentType = hubToLogoMap[project[hub_name]].contentType;
    }

    var userPermission = {};
    userPermission.accessLevel = 'admin';
    userPermission.entityId = mappedProject.projectId;
    userPermission.userId = userId;
    userPermission.entityType = 'au.org.ala.ecodata.Project';

    var siteResult = db.site.insert(siteMap);
    checkInsertResult(siteResult, "site");
    audit(siteMap, siteMap.siteId, 'au.org.ala.ecodata.Site', "system", siteMap.projects[0], 'Insert');
    var documentResult = db.document.insert(document);
    checkInsertResult(documentResult, "document");
    audit(document, document.documentId, 'au.org.ala.ecodata.Document', "system", document.projectId, 'Insert');
    var projectResult = db.project.insert(mappedProject);
    checkInsertResult(projectResult, "project");
    audit(mappedProject, mappedProject.projectId, 'au.org.ala.ecodata.Project', "system", mappedProject.projectId, 'Insert');
    var permissionResult = db.userPermission.insert(userPermission);
    checkInsertResult(permissionResult, "userPermission");
    var createdUserPermission = db.userPermission.findOne({userId:userId, entityId:mappedProject.projectId, accessLevel:'admin'});
    audit(userPermission, createdUserPermission._id, 'au.org.ala.ecodata.UserPermission', "system", userPermission.entityId, 'Insert');
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