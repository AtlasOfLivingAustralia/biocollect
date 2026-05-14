let dryRun = false;

let hub = db.hub.findOne({ urlPath: 'nesp-sustainablecommunities' });

if (!hub) {
    print("ERROR: Hub not found");
} else if (!hub.defaultProgram) {
    print("ERROR: Hub found but defaultProgram is missing");
} else {
    const userToInsert = '247098';   // new user
    const userToRemove = '241798';   // current admin to remove
    const role = 'admin';

    print("Running for hub: " + hub.urlPath + " | program: " + hub.defaultProgram);

    let projects = db.project.find({
        associatedProgram: hub.defaultProgram,
        status: 'active'
    });

    let totalProjects = 0;

    let addInserted = 0;
    let addAlreadyExists = 0;

    let removeDeleted = 0;
    let removeNotFound = 0;

    while (projects.hasNext()) {
        let project = projects.next();
        totalProjects++;

        const projectName = project.name || "(no name)";
        const projectId = project.projectId;

        // ----------------------------
        // ADD NEW USER
        // ----------------------------
        const existingInsertPermission = db.userPermission.findOne({
            userId: userToInsert,
            entityId: projectId,
            entityType: 'au.org.ala.ecodata.Project'
        });

        if (!existingInsertPermission) {
            if (dryRun) {
                print("WOULD INSERT: userId=" + userToInsert +
                    ", role=" + role +
                    ", projectId=" + projectId +
                    " | " + projectName);
            } else {
                db.userPermission.insertOne({
                    userId: userToInsert,
                    entityType: 'au.org.ala.ecodata.Project',
                    entityId: projectId,
                    accessLevel: role,
                    status: 'active'
                });
                print("INSERTED: userId=" + userToInsert +
                    ", role=" + role +
                    ", projectId=" + projectId +
                    " | " + projectName);
                addInserted++;
            }
        } else {
            addAlreadyExists++;
            print("ALREADY EXISTS: userId=" + userToInsert +
                ", role=" + (existingInsertPermission.accessLevel || "unknown") +
                ", projectId=" + projectId +
                " | " + projectName);
        }

        // ----------------------------
        // REMOVE OLD USER
        // ----------------------------
        const existingRemovePermission = db.userPermission.findOne({
            userId: userToRemove,
            entityId: projectId,
            entityType: 'au.org.ala.ecodata.Project'
        });

        if (existingRemovePermission) {
            if (dryRun) {
                print("WOULD REMOVE: userId=" + userToRemove +
                    ", role=" + (existingRemovePermission.accessLevel || "unknown") +
                    ", projectId=" + projectId +
                    " | " + projectName);
            } else {
                db.userPermission.deleteOne({
                    _id: existingRemovePermission._id
                });
                print("REMOVED: userId=" + userToRemove +
                    ", role=" + (existingRemovePermission.accessLevel || "unknown") +
                    ", projectId=" + projectId +
                    " | " + projectName);
                removeDeleted++;
            }
        } else {
            removeNotFound++;
            print("NOT FOUND FOR REMOVAL: userId=" + userToRemove +
                ", projectId=" + projectId +
                " | " + projectName);
        }
    }

    print("");
    print(dryRun ? "Dry run complete" : "Execution complete");
    print("Projects checked: " + totalProjects);

    print("");
    print("ADD USER SUMMARY");
    print("User: " + userToInsert + " | Role: " + role);
    print(dryRun ? "Would insert: " + (totalProjects - addAlreadyExists) : "Inserted: " + addInserted);
    print("Already existed: " + addAlreadyExists);

    print("");
    print("REMOVE USER SUMMARY");
    print("User: " + userToRemove);
    print(dryRun ? "Would remove: " + (totalProjects - removeNotFound) : "Removed: " + removeDeleted);
    print("Not found: " + removeNotFound);
}