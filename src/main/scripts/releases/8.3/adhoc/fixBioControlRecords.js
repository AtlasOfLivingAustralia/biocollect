load("../../../mongo/utils/audit.js");
var dryRun = false, counterNotFound = 0, counter = 0;
// list of biocontrol project IDs
var projectIds = [
    "ffeb44d7-08d0-4627-a31b-6a6365700a18",
    "c5b3564b-b170-4105-9e37-6c3de8219e7b",
    "ba1af974-d733-4bea-882e-9b93a00892d2",
    "38c288ee-01da-425a-9e54-ddaf94f0e748",
    "cfd68ff5-10d1-4e52-ae39-4161c9b74c8f",
    "ef09ff0d-2af2-4c58-bee7-3198d4f6db4f",
    "45361e8c-91ac-4447-b4da-9cd2a8fa0aae",
    "20ac4516-b38c-4799-97fa-42489dc039ac",
    "36f4b025-73b1-4722-893e-0877e022b0dd",
    "7b1505b4-dbdf-4ad0-a6db-9068585c02a5",
    "15185781-1089-4718-9630-b2828e7b855a",
    "a90d08cf-974d-4441-97e6-af5da34cb118",
    "8b8b7d50-0916-492a-8e4b-37ea3a1eafc7",
    "738326b6-125b-49a7-b0ed-360c4c3d0062",
    "ba76374c-2859-43ac-ae9a-b6812a05b32c",
    "935994ff-957d-423b-9ebb-6eb39930dfae",
    "f298e305-7e48-4fa9-9c73-8e2c759f7d5f",
    "09db7dd7-a5a1-472f-8999-3ed94cd29290",
    "4dd17bc6-6ca8-4551-90d3-362b0210c682",
    "f8b5dfbf-1eca-4091-be68-0a958292ba66",
    "450e6de7-95b2-4d24-b3ce-b4e2d3d7e029",
    "26ae9f28-4916-4579-afc0-7a9af3e19e0a",
    "68e5faca-a8df-4cea-a310-8db65965a3e9",
    "6b786ef0-5503-4784-8d91-b2571b1323ee",
    "6d55e7aa-5992-4105-bf99-842b70e8698e",
    "56491ea9-f10b-45b0-a645-c7674e31be96",
    "1f6c5b93-b994-43ab-a6b0-3ed833971f1e",
    "c3295d22-036c-47fa-acad-bab6171d9c92",
    "02e56350-7bab-4b9a-a631-78f683896184"
];

// Get activity IDs for the biocontrol projects
var activityIds = db.runCommand({
    "distinct": "activity",
    key: "activityId",
    query : {status: "active", projectId: {$in: projectIds}}
}).values;

// Find outputs with Alcyonium etheridgei and update species details
db.output.find({
    activityId: {$in: activityIds},
    "data.agentSpecies.scientificName": "\"Alcyonium\" etheridgei",
    status: "active"
}).forEach(function(output) {
    counter++;
    // get agent species from project activity config
    var species = findAgentSpecies(output.activityId);
    if (species) {
        output.data.agentSpecies.scientificName = species.scientificName || species.name;
        output.data.agentSpecies.commonName = species.commonName;
        output.data.agentSpecies.guid = species.guid;
        output.data.agentSpecies.name = formatTaxonName(output.data.agentSpecies, species.speciesDisplayFormat);
        if (!dryRun) {
            db.output.updateOne({outputId: output.outputId}, {$set: {data: output.data}});
            var projectId = db.activity.findOne({activityId: output.activityId}, {projectId: 1}).projectId;
            audit(output, output.outputId, 'au.org.ala.ecodata.Output', 'system', projectId, 'Update');
        }

        var outputSpeciesId = output.data.agentSpecies.outputSpeciesId;
        if (outputSpeciesId) {
            var record = db.record.findOne({outputSpeciesId: outputSpeciesId, status: "active"});
            if (!record) {
                record = db.record.findOne({occurrenceID: outputSpeciesId, status: "active"});
            }

            if (record) {
                record.scientificName = species.scientificName;
                record.commonName = species.commonName;
                record.guid = species.guid;
                record.name = output.data.agentSpecies.name;
                if (!dryRun) {
                    db.record.updateOne({_id: record._id}, {$set: {
                        scientificName: record.scientificName,
                        commonName: record.commonName,
                        guid: record.guid,
                        name: record.name
                    }});

                    audit(record, record.occurrenceID, 'au.org.ala.ecodata.Record', 'system', record.projectId, 'Update');
                }
            }
            else
                counterNotFound++;
        }
        else
            counterNotFound++;
    }
    else {
        console.error("No species config found for activityId: " + JSON.stringify(species));
        console.error("No species found for activityId: " + output.activityId);
        counterNotFound++;
    }
});

console.log("Total outputs with no species config found: " + counterNotFound);
console.log("Total outputs processed: " + counter);

/**
 * get agent species from project activity config
 * @param activityId
 * @returns {*}
 */
function findAgentSpecies(activityId) {
    var activity = db.activity.findOne({activityId: activityId}, {projectActivityId: 1});
    if (activity && activity.projectActivityId) {
        var projectActivity = db.projectActivity.findOne({projectActivityId: activity.projectActivityId});
        if (projectActivity && projectActivity.speciesFields) {
            var agentSpecies = projectActivity.speciesFields.find(function(field) {
                return field.dataFieldName === "agentSpecies" && field.config.type === "SINGLE_SPECIES";
            });

            if (agentSpecies) {
                agentSpecies.config.singleSpecies.speciesDisplayFormat = agentSpecies.config.speciesDisplayFormat;
                return agentSpecies.config.singleSpecies;
            }
        }
    }
}

/**
 * format taxon name based on display type
 * @param data
 * @param displayType
 * @returns {string}
 */
function formatTaxonName(data, displayType) {
    let name = '';
    switch (displayType) {
        case 'COMMONNAME(SCIENTIFICNAME)':
            if (data.commonName && data.scientificName) {
                name = `${data.commonName} (${data.scientificName})`;
            } else if (data.commonName) {
                name = data.commonName;
            } else if (data.scientificName) {
                name = data.scientificName;
            }
            break;
        case 'SCIENTIFICNAME(COMMONNAME)':
            if (data.scientificName && data.commonName) {
                name = `${data.scientificName} (${data.commonName})`;
            } else if (data.scientificName) {
                name = data.scientificName;
            } else if (data.commonName) {
                name = data.commonName;
            }
            break;
        case 'COMMONNAME':
            name = data.commonName || data.scientificName || '';
            break;
        case 'SCIENTIFICNAME':
            name = data.scientificName || '';
            break;
    }
    return name;
}
