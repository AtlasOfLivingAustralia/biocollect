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

const sitePreparationMethodsAllowed = [
    "Ripping",
    "Raking",
    "Scalping"
];

const fireAssistedRegenerationMethodsAllowed = [
    "Cool burn",
    "Pile burn",
    "Gas burner",
    "Smoke water",
    "Cultural burning"
];

const plantProtectionMethodAllowed = [
    "No protection used",
    "Stock fencing",
    "Predator fencing",
    "Combined stock-predator fencing",
    "Wildlife friendly fencing",
    "Plant guards",
    "Other"
];

const weedTreatmentMethodsAllowed = [
    "Manual weeding",
    "Spray circles (herbicide)",
    "Broard-scale spray (herbicide)",
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

const habitatFeaturesAllowed = [
    "Bird perches",
    "Hollow logs",
    "Hollow creation",
    "Nest boxes",
    "Coarse woody debris",
    "Other"
];

function asArray(value) {
    return Array.isArray(value) ? value : [];
}

function unique(values) {
    return [...new Set(values.filter(v => v !== null && v !== undefined && v !== ""))];
}

function sameArray(a, b) {
    return JSON.stringify(asArray(a)) === JSON.stringify(asArray(b));
}

function redistribute(fields, source) {
    const allValues = unique(
        Object.keys(fields).flatMap(fieldName => asArray(source[fieldName]))
    );

    const result = {};

    Object.keys(fields).forEach(fieldName => {
        result[fieldName] = allValues.filter(v => fields[fieldName].includes(v));
    });

    return result;
}

const topLevelFields = {
    interventionProjectAims: aimsAllowed,
    projectCollaborators: collaboratorsAllowed,
    fundingType: fundingAllowed
};

const sitePreparationFields = {
    sitePreparationMethods: sitePreparationMethodsAllowed,
    fireAssistedRegenerationMethods: fireAssistedRegenerationMethodsAllowed,
    plantProtectionMethod: plantProtectionMethodAllowed,
    weedTreatmentMethods: weedTreatmentMethodsAllowed,
    habitatFeatures: habitatFeaturesAllowed
};

const query = {
    name: outputName,
    $or: [
        { "data.interventionProjectAims": { $exists: true } },
        { "data.projectCollaborators": { $exists: true } },
        { "data.fundingType": { $exists: true } },
        { "data.sitePreparationTable": { $exists: true } }
    ]
};

let examined = 0;
let changed = 0;
let updated = 0;

db.output.find(query).forEach(output => {
    examined++;

    const originalTopLevel = {
        interventionProjectAims: output.data?.interventionProjectAims,
        projectCollaborators: output.data?.projectCollaborators,
        fundingType: output.data?.fundingType
    };

    const cleanedTopLevel = redistribute(topLevelFields, originalTopLevel);

    const originalSitePreparationTable = output.data?.sitePreparationTable || [];
    const cleanedSitePreparationTable = originalSitePreparationTable.map(row => {
        const cleanedRowValues = redistribute(sitePreparationFields, row);

        return {
            ...row,
            ...cleanedRowValues
        };
    });

    const topLevelChanged =
        !sameArray(originalTopLevel.interventionProjectAims, cleanedTopLevel.interventionProjectAims) ||
        !sameArray(originalTopLevel.projectCollaborators, cleanedTopLevel.projectCollaborators) ||
        !sameArray(originalTopLevel.fundingType, cleanedTopLevel.fundingType);

    const sitePreparationChanged =
        JSON.stringify(originalSitePreparationTable) !== JSON.stringify(cleanedSitePreparationTable);

    const hasChanged = topLevelChanged || sitePreparationChanged;

    if (!hasChanged) {
        return;
    }

    changed++;

    printjson({
        outputId: output.outputId,
        activityId: output.activityId
    });

    if (!dryRun) {
        db.output.updateOne(
            { outputId: output.outputId },
            {
                $set: {
                    "data.interventionProjectAims": cleanedTopLevel.interventionProjectAims,
                    "data.projectCollaborators": cleanedTopLevel.projectCollaborators,
                    "data.fundingType": cleanedTopLevel.fundingType,
                    "data.sitePreparationTable": cleanedSitePreparationTable,
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