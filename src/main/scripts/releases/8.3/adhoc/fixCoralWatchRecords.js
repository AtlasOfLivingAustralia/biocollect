// Migrate all records with "Dive centre" as participating as value to "Dive Centre"
load("../../../mongo/utils/audit.js");

var userId = "system";
var dryRun = false;

var FROM = "Dive centre";
var TO   = "Dive Centre";

var matched = 0;
var updated = 0;
var audited = 0;
var errors  = 0;

function getProjectIdFromActivity(activityId) {
    if (!activityId) return null;
    var a = db.activity.findOne({ activityId: activityId }, { projectId: 1 });
    return (a && a.projectId) ? a.projectId : null;
}

var query = {
    status: "active",
    "data.groupType": FROM
};

db.output.find(query, { outputId: 1, activityId: 1, data: 1 }).forEach(function (output) {
    matched++;

    try {
        if (!output.data || output.data.groupType !== FROM) return;

        if (!dryRun) {
            var result = db.output.updateOne(
                { outputId: output.outputId, "data.groupType": FROM },
                { $set: { "data.groupType": TO } }
            );

            if (result && result.modifiedCount) {
                updated++;

                var projectId = getProjectIdFromActivity(output.activityId);
                audit(output, output.outputId, "au.org.ala.ecodata.Output", userId, projectId, "Update");
                audited++;
            }
        }
        else {
            updated++;
        }
    }
    catch (e) {
        errors++;
        print("Error outputId=" + output.outputId + " : " + e);
    }
});

print("Matched outputs: " + matched);
print("Updated outputs: " + updated);
print("Audited outputs: " + audited);
print("Errors: " + errors);
print("Dry run: " + dryRun);