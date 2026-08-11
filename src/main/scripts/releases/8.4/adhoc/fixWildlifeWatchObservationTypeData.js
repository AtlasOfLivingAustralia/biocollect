load("../../../mongo/utils/audit.js");

/**
 * The script fixes historical Observation Type values for the
 * North Sydney Wildlife Watch project.
 *
 * Historical records contain values such as:
 *   "Observed"
 *   "Heard call"
 *
 * The current form expects coded values such as:
 *   "O - Observed"
 *   "W - Heard call"
 *
 */
const dryRun = false;

const adminUserId = "system";
const projectId = "da35ca9a-d725-4cb6-ae2e-d1cedebab1ba";
const activityType = "North Sydney Wildlife Watch";

const observationTypeMapping = {
    "Dead": "K - Dead",
    "Hair, feathers or skin": "H - Hair, feathers or skin",
    "Heard call": "W - Heard call",
    "Nest/roost": "E - Nest/roost/mound",
    "Nest/roost/mound": "E - Nest/roost/mound",
    "Observed": "O - Observed",
    "Observed and Heard call": "OW - Observed and Heard call",
    "Scat": "P - Scat",
    "Tracks, scratchings": "F - Tracks, scratchings"
};

const historicalValues = Object.keys(observationTypeMapping);

print("===================================================================");
print("North Sydney Wildlife Watch Observation Type fix");
print("Project ID: " + projectId);
print("Activity type: " + activityType);
print("Dry run: " + dryRun);
print("===================================================================");

const activityIds = db.activity.distinct("activityId", {
    projectId: projectId,
    type: activityType
});

print("Matching activities: " + activityIds.length);

if (activityIds.length === 0) {
    throw new Error(
        "No matching activities found. Check the project ID and activity type."
    );
}

const outputQuery = {
    activityId: {$in: activityIds},
    "data.observationType": {$in: historicalValues}
};

const affectedCount = db.output.countDocuments(outputQuery);

print("Outputs requiring correction: " + affectedCount);
print("");

print("Breakdown by historical value:");
let expectedTotal = 0;
historicalValues.forEach(function (historicalValue) {
    const count = db.output.countDocuments({
        activityId: {$in: activityIds},
        "data.observationType": historicalValue
    });
    if (count > 0) {
        expectedTotal += count;
        print("  " + historicalValue + " -> " + observationTypeMapping[historicalValue] + ": " + count);
    }
});

print("");
print("Expected total updates: " + expectedTotal);

if (expectedTotal !== affectedCount) {
    throw new Error(
        "Count verification failed: affectedCount=" +
        affectedCount +
        ", expectedTotal=" +
        expectedTotal
    );
}

let examined = 0;
let changed = 0;
let updated = 0;

db.output.find(outputQuery).forEach(function (output) {
    examined++;

    const oldValue = output.data.observationType;
    const newValue = observationTypeMapping[oldValue];

    if (!newValue) {
        throw new Error(
            "No mapping found for Observation Type: " + oldValue
        );
    }

    changed++;

    if (dryRun) {
        return;
    }

    const result = db.output.updateOne(
        {
            outputId: output.outputId,
            "data.observationType": oldValue
        },
        {
            $set: {
                "data.observationType": newValue,
                lastUpdated: ISODate(),
                lastUpdatedUserId: adminUserId
            }
        }
    );

    if (result.modifiedCount !== 1) {
        print(
            "WARNING: Output was not updated: " +
            output.outputId +
            " oldValue=" +
            oldValue
        );
        return;
    }

    const updatedOutput = db.output.findOne({
        outputId: output.outputId
    });

    audit(
        updatedOutput,
        updatedOutput.outputId,
        "au.org.ala.ecodata.Output",
        adminUserId,
        projectId,
        "Update"
    );

    updated++;
});

print("");
print("Examined outputs: " + examined);
print("Changed outputs: " + changed);
print("Updated outputs: " + updated);
print("Dry run: " + dryRun);