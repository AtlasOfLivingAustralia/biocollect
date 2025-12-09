
let hub = db.hub.findOne({urlPath:'nesp-resilientlandscapes'});
let projects = db.project.find({associatedProgram:hub.defaultProgram})

const userToInsert = '212180';
const role = "admin";

while (projects.hasNext()) {
    let project = projects.next();

    const exists = db.userPermission.findOne({userId: userToInsert, entityId: project.projectId, entityType: 'au.org.ala.ecodata.Project'});

    if (!exists) {
        db.userPermission.insert({userId: userToInsert, entityType: 'au.org.ala.ecodata.Project', entityId: project.projectId, accessLevel: role, status: 'active'
        });
    }

}