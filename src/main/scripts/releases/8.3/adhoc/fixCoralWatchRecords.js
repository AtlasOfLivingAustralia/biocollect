// Migrate all records with "Dive centre" as participating as value to "Dive Centre"
load("utils/audit.js");

var userId = "system";
var dryRun = false;

var FROM = "Dive centre";
var TO = "Dive Centre";
var PROJECT_ID = "9c55416c-f56a-4917-a65e-da1d64a851f7";

var matched = 0;
var updated = 0;
var audited = 0;
var errors = 0;

var activityIds = db.activity.distinct("activityId", {
    projectId: PROJECT_ID,
    status: "active"
});

print("Activities found: " + activityIds.length);

var query = {
    activityId: { $in: activityIds },
    status: "active",
    "data.groupType": FROM
};

db.output.find(query, { outputId: 1, activityId: 1, data: 1 }).forEach(function (output) {
    matched++;

    try {
        if (!dryRun) {
            var result = db.output.updateOne(
                {
                    outputId: output.outputId,
                    activityId: output.activityId,
                    "data.groupType": FROM
                },
                {
                    $set: { "data.groupType": TO }
                }
            );

            if (result && result.modifiedCount) {
                updated++;

                audit(output, output.outputId, "au.org.ala.ecodata.Output", userId, PROJECT_ID, "Update");
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