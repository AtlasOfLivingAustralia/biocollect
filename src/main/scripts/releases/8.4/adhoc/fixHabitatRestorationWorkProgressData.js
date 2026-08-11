load("../../../mongo/utils/audit.js");

let dryRun = false;

const adminUserId = "system";
const outputName = "Habitat Restoration - Work Progress and follow-up";

const weedTreatmentMethodsAllowed = [
    "Manual weeding",
    "Spray circles (herbicide)",
    "Broad-scale spray (herbicide)",
    "Selective spot spraying (herbicide)",
    "Injection (herbicide)",
    "Slashing",
    "Scraping",
    "Cut and paint",
    "Biological control agents",
    "Traditional burning",
    "Other",
    "None"
];

const herbicideUsedAllowed = [
    "Glyphosate",
    "Metsulfuron methyl",
    "Other",
    "None"
];

const vertebratePestsTargetedAllowed = [
    "Rabbits",
    "Hares",
    "Pigs",
    "Wallabies",
    "Kangaroos",
    "Other"
];

const vertebratePestControlMethodsAllowed = [
    "Bait",
    "Trap",
    "Shoot",
    "Biocontrol",
    "Exclusion fence",
    "Plant guards"
];

const weedControlFields = {
    weedTreatmentMethods: weedTreatmentMethodsAllowed,
    herbicideUsed: herbicideUsedAllowed
};

const vertebratePestFields = {
    vertebratePestsTargeted: vertebratePestsTargetedAllowed,
    vertebratePestControlMethods: vertebratePestControlMethodsAllowed
};

function asArray(value) {
    return Array.isArray(value) ? value : [];
}

function unique(values) {
    return [
        ...new Set(
            values.filter(value =>
                value !== null &&
                value !== undefined &&
                value !== ""
            )
        )
    ];
}

function sameArray(first, second) {
    return JSON.stringify(asArray(first)) ===
        JSON.stringify(asArray(second));
}

function sameUniqueValues(first, second) {
    const firstValues = unique(asArray(first)).sort();
    const secondValues = unique(asArray(second)).sort();

    return JSON.stringify(firstValues) ===
        JSON.stringify(secondValues);
}

function redistribute(fields, source) {
    const allValues = unique(
        Object.keys(fields).flatMap(fieldName => asArray(source[fieldName]))
    );

    const result = {};

    Object.keys(fields).forEach(fieldName => {
        result[fieldName] = allValues.filter(value => fields[fieldName].includes(value));
    });

    return result;
}

function redistributePreservingAmbiguousValues(fields, source, ambiguousValues) {
    const fieldNames = Object.keys(fields);

    const allValues = unique(
        fieldNames.flatMap(fieldName => asArray(source[fieldName]))
    );

    const result = {};

    fieldNames.forEach(fieldName => {
        const originalValues = unique(asArray(source[fieldName]));

        const unambiguousValues = allValues.filter(value =>
            !ambiguousValues.includes(value) &&
            fields[fieldName].includes(value)
        );

        const preservedAmbiguousValues = originalValues.filter(value =>
            ambiguousValues.includes(value) &&
            fields[fieldName].includes(value)
        );

        result[fieldName] = unique([
            ...unambiguousValues,
            ...preservedAmbiguousValues
        ]);
    });

    return result;
}

/**
 * "Other" and "None" are valid values for both weedTreatmentMethods and
 * herbicideUsed, so their original field cannot always be determined from
 * historical conflated data.
 */
function containsAmbiguousWeedValue(values) {
    return asArray(values).some(value =>
        value === "Other" || value === "None"
    );
}

const query = {
    name: outputName,
    $or: [
        {"data.weedTreatmentMethods": {$exists: true}},
        {"data.herbicideUsed": {$exists: true}},
        {"data.vertebratePestsTargeted": {$exists: true}},
        {"data.vertebratePestControlMethods": {$exists: true}}
    ]
};

let examined = 0;
let changed = 0;
let updated = 0;

let duplicateCleanupOnly = 0;
let actualRedistribution = 0;
let ambiguousWeedRecords = 0;

db.output.find(query).forEach(output => {
    examined++;

    const originalWeedControl = {
        weedTreatmentMethods:
        output.data?.weedTreatmentMethods,
        herbicideUsed:
        output.data?.herbicideUsed
    };

    const originalVertebratePestControl = {
        vertebratePestsTargeted:
        output.data?.vertebratePestsTargeted,
        vertebratePestControlMethods:
        output.data?.vertebratePestControlMethods
    };

    const cleanedWeedControl = redistributePreservingAmbiguousValues(
        weedControlFields,
        originalWeedControl,
        ["Other", "None"]
    );

    const cleanedVertebratePestControl = redistribute(
        vertebratePestFields,
        originalVertebratePestControl
    );

    const weedTreatmentMethodsChanged = !sameArray(
        originalWeedControl.weedTreatmentMethods,
        cleanedWeedControl.weedTreatmentMethods
    );

    const herbicideUsedChanged = !sameArray(
        originalWeedControl.herbicideUsed,
        cleanedWeedControl.herbicideUsed
    );

    const vertebratePestsTargetedChanged = !sameArray(
        originalVertebratePestControl.vertebratePestsTargeted,
        cleanedVertebratePestControl.vertebratePestsTargeted
    );

    const vertebratePestControlMethodsChanged = !sameArray(
        originalVertebratePestControl.vertebratePestControlMethods,
        cleanedVertebratePestControl.vertebratePestControlMethods
    );

    const hasChanged =
        weedTreatmentMethodsChanged ||
        herbicideUsedChanged ||
        vertebratePestsTargetedChanged ||
        vertebratePestControlMethodsChanged;

    if (!hasChanged) {
        return;
    }

    changed++;

    const isDuplicateCleanupOnly =
        sameUniqueValues(
            originalWeedControl.weedTreatmentMethods,
            cleanedWeedControl.weedTreatmentMethods
        ) &&
        sameUniqueValues(
            originalWeedControl.herbicideUsed,
            cleanedWeedControl.herbicideUsed
        ) &&
        sameUniqueValues(
            originalVertebratePestControl.vertebratePestsTargeted,
            cleanedVertebratePestControl.vertebratePestsTargeted
        ) &&
        sameUniqueValues(
            originalVertebratePestControl.vertebratePestControlMethods,
            cleanedVertebratePestControl.vertebratePestControlMethods
        );

    if (isDuplicateCleanupOnly) {
        duplicateCleanupOnly++;
    } else {
        actualRedistribution++;
    }

    const hasAmbiguousWeedValue =
        containsAmbiguousWeedValue(
            originalWeedControl.weedTreatmentMethods
        ) ||
        containsAmbiguousWeedValue(
            originalWeedControl.herbicideUsed
        );

    if (hasAmbiguousWeedValue) {
        ambiguousWeedRecords++;
    }

    printjson({
        outputId: output.outputId,
        activityId: output.activityId,
        changeType: isDuplicateCleanupOnly
            ? "duplicate cleanup only"
            : "value redistribution",
        original: {
            weedTreatmentMethods:
            originalWeedControl.weedTreatmentMethods,
            herbicideUsed:
            originalWeedControl.herbicideUsed,
            vertebratePestsTargeted:
            originalVertebratePestControl.vertebratePestsTargeted,
            vertebratePestControlMethods:
            originalVertebratePestControl.vertebratePestControlMethods
        },
        corrected: {
            weedTreatmentMethods:
            cleanedWeedControl.weedTreatmentMethods,
            herbicideUsed:
            cleanedWeedControl.herbicideUsed,
            vertebratePestsTargeted:
            cleanedVertebratePestControl.vertebratePestsTargeted,
            vertebratePestControlMethods:
            cleanedVertebratePestControl.vertebratePestControlMethods
        }
    });

    if (dryRun) {
        return;
    }

    const result = db.output.updateOne(
        {
            _id: output._id,
            outputId: output.outputId
        },
        {
            $set: {
                "data.weedTreatmentMethods":
                cleanedWeedControl.weedTreatmentMethods,

                "data.herbicideUsed":
                cleanedWeedControl.herbicideUsed,

                "data.vertebratePestsTargeted":
                cleanedVertebratePestControl
                    .vertebratePestsTargeted,

                "data.vertebratePestControlMethods":
                cleanedVertebratePestControl
                    .vertebratePestControlMethods,

                lastUpdated: ISODate(),
                lastUpdatedUserId: adminUserId
            }
        }
    );

    if (result.modifiedCount !== 1) {
        print("WARNING: Expected to update one output but modified " + result.modifiedCount + ": " + output.outputId);
        return;
    }

    const updatedOutput = db.output.findOne({outputId: output.outputId});
    const activity = db.activity.findOne({activityId: updatedOutput.activityId}, {projectId: 1});
    audit(updatedOutput, updatedOutput.outputId, "au.org.ala.ecodata.Output", adminUserId, activity?.projectId, "Update");
    updated++;
});

print("");
print("Examined outputs: " + examined);
print("Changed outputs: " + changed);
print("Duplicate cleanup only: " + duplicateCleanupOnly);
print("Actual redistribution: " + actualRedistribution);
print("Changed records containing Other/None: " + ambiguousWeedRecords);
print("Updated outputs: " + updated);
print("Dry run: " + dryRun);