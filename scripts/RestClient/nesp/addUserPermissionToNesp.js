//Add hub permission

var userPermission = {};
userPermission.accessLevel = 'admin';
userPermission.entityId = "a0c69ce5-a2fc-4dfe-a387-468a4c916685"; //hubId
userPermission.userId = '135151';
userPermission.entityType = 'au.org.ala.ecodata.Hub';
userPermission.status = "active";

var hubUserPermissionResult = db.userPermission.insert(userPermission);
print("hubUserPermissionResult " + hubUserPermissionResult)

//Add project permissions

var programs = db.hub.findOne({hubId:"a0c69ce5-a2fc-4dfe-a387-468a4c916685"}).supportedPrograms;

for (i =0;i<programs.length;i++) {
    let program = programs[i];

    var projects = db.project.find({associatedProgram: program, status:"active"},{projectId:1, _id:0});

    while (projects.hasNext()) {
        let project = projects.next();
        print(project.projectId)

        var userPermission = {};
        userPermission.accessLevel = 'admin';
        userPermission.entityId = project.projectId;
        userPermission.userId = '135151';
        userPermission.entityType = 'au.org.ala.ecodata.Project';
        userPermission.status = "active";

        var projectUserPermissionResult = db.userPermission.insert(userPermission);
        print("projectUserPermissionResult " + projectUserPermissionResult)
    }
}