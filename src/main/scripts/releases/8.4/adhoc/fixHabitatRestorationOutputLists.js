let dryRun = true; // set to false to perform actual updates

const adminUserId = "system";
const outputName = "Habitat Restoration - Combined Site and Work Details";

const aimsAllowed = [
    "Not defined",
    "Habitat restoration",
    "Biodiversity conservation",
    "Carbon sequestration",
    "Amenity revegetation",
    "Timber production",
    "Education",
    "Research",
    "Riparian repair/erosion control",
    "Agricultural resilience",
    "Agricultural productivity"
];

const collaboratorsAllowed = [
    "Research institution",
    "Non-government organisation (NGO)",
    "World Wildlife Fund (WWF)",
    "Government agencies",
    "Communities",
    "Landcare",
    "Traditional owners / communities",
    "Landholders",
    "Training institution",
    "Commercial / developer",
    "Other 'Care' groups (eg. Bushcare, Coastcare, Rivercare, etc.)"
];

const fundingAllowed = [
    "Public - commonwealth",
    "Public - state",
    "Public - local",
    "Public - in-kind",
    "Private - in-kind",
    "Private - industry",
    "Private - philanthropic",
    "Private - bequeath/other",
    "Private - NGO",
    "Private - volunteer"
];

function cleanList(value, allowed) {
    if (!Array.isArray(value)) {
        return value;
    }

    return value.filter(v => allowed.includes(v));
}

function sameArray(a, b) {
    return JSON.stringify(a || []) === JSON.stringify(b || []);
}

const query = {
    name: outputName,
    $or: [
        { "data.interventionProjectAims": { $in: collaboratorsAllowed.concat(fundingAllowed) } },
        { "data.projectCollaborators": { $in: aimsAllowed.concat(fundingAllowed) } },
        { "data.fundingType": { $in: aimsAllowed.concat(collaboratorsAllowed) } }
    ]
};

let examined = 0;
let changed = 0;
let updated = 0;

db.output.find(query).forEach(output => {
    examined++;

    const original = {
        interventionProjectAims: output.data?.interventionProjectAims,
        projectCollaborators: output.data?.projectCollaborators,
        fundingType: output.data?.fundingType
    };

    const cleaned = {
        interventionProjectAims: cleanList(original.interventionProjectAims, aimsAllowed),
        projectCollaborators: cleanList(original.projectCollaborators, collaboratorsAllowed),
        fundingType: cleanList(original.fundingType, fundingAllowed)
    };

    const hasChanged =
        !sameArray(original.interventionProjectAims, cleaned.interventionProjectAims) ||
        !sameArray(original.projectCollaborators, cleaned.projectCollaborators) ||
        !sameArray(original.fundingType, cleaned.fundingType);

    if (!hasChanged) {
        return;
    }

    changed++;

    printjson({
        outputId: output.outputId,
        activityId: output.activityId,
        before: original,
        after: cleaned
    });

    if (!dryRun) {
        db.output.updateOne(
            { outputId: output.outputId },
            {
                $set: {
                    "data.interventionProjectAims": cleaned.interventionProjectAims,
                    "data.projectCollaborators": cleaned.projectCollaborators,
                    "data.fundingType": cleaned.fundingType,
                    lastUpdated: new Date(),
                    lastUpdatedUserId: adminUserId
                }
            }
        );

        updated++;
    }
});

print("Examined outputs: " + examined);
print("Changed outputs: " + changed);
print("Updated outputs: " + updated);
print("Dry run: " + dryRun);