let dryRun = true; // set to false to perform actual inserts

let hub = db.hub.findOne({urlPath: 'nesp-sustainablecommunities'});

if (!hub) {
    print("ERROR: Hub not found");
} else if (!hub.defaultProgram) {
    print("ERROR: Hub found but defaultProgram is missing");
} else {
    const userToInsert = '247098';
    const role = 'admin';

    print("Running for hub: " + hub.urlPath + " | program: " + hub.defaultProgram);

    let projects = db.project.find({
        associatedProgram: hub.defaultProgram,
        status: 'active'
    });

    let totalProjects = 0;
    let inserted = 0;
    let alreadyExists = 0;

    while (projects.hasNext()) {
        let project = projects.next();
        totalProjects++;

        const existingPermission = db.userPermission.findOne({
            userId: userToInsert,
            entityId: project.projectId,
            entityType: 'au.org.ala.ecodata.Project'
        });

        if (!existingPermission) {
            if (dryRun) {
                print("WOULD INSERT: userId=" + userToInsert +
                    ", role=" + role +
                    ", projectId=" + project.projectId +
                    " | " + (project.name || "(no name)"));
            } else {
                db.userPermission.insertOne({
                    userId: userToInsert,
                    entityType: 'au.org.ala.ecodata.Project',
                    entityId: project.projectId,
                    accessLevel: role,
                    status: 'active'
                });
                print("INSERTED: userId=" + userToInsert +
                    ", role=" + role +
                    ", projectId=" + project.projectId +
                    " | " + (project.name || "(no name)"));
                inserted++;
            }
        } else {
            alreadyExists++;
            print("ALREADY EXISTS: userId=" + userToInsert +
                ", role=" + (existingPermission.accessLevel || "unknown") +
                ", projectId=" + project.projectId +
                " | " + (project.name || "(no name)"));
        }
    }

    print("");
    print(dryRun ? "Dry run complete" : "Execution complete");
    print("User: " + userToInsert + " | Role to insert: " + role);
    print("Projects checked: " + totalProjects);
    print(dryRun ? "Would insert: " + (totalProjects - alreadyExists) : "Inserted: " + inserted);
    print("Already existed: " + alreadyExists);
}