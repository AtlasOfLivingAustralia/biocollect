/**
 * Identify duplicate in outputSpeciesId and assign a new one.
 * Usage mongosh -u abc -p xyz ecodata findDuplicateOutputSpeciesIds.js
 */
load("./../../utils/uuid.js");
load("../../../mongo/utils/audit.js");
var biocollectProjects = db.project.find({isMERIT: false, status: 'active'}, {projectId: 1}).toArray();
var biocollectProjectIds = [];
var outputSpeciesIdMap = {};
const OUTPUT_SPECIES_ID = 'outputSpeciesId';
var counter = 0;
biocollectProjects.forEach(proj => {
    biocollectProjectIds.push(proj.projectId);
});
console.time("Processing time");
print("Total projects to process: " + biocollectProjectIds.length);
db.activity.find({projectId: {$in: biocollectProjectIds}, status: 'active'}, {activityId: 1})
    .forEach(function (activity) {
        var outputs = db.output.find({activityId: activity.activityId, status: 'active'}).toArray();
        outputs.forEach(output => {
            var isModified = recurseDataAndFindDuplicateOutputSpeciesId(output.data);
            if (isModified) {
                db.output.updateOne({outputId: output.outputId}, {$set: {data: output.data}});
                audit(output, output.outputId, 'au.org.ala.ecodata.Output', 'system');
                print("Updated outputId: " + output.outputId + " for activityId: " + activity.activityId);
            }
        })
    });

print("Total duplicates found: " + counter);
print("Duplicate outputSpeciesIds:");
printjson(JSON.stringify(outputSpeciesIdMap));
console.timeEnd("Processing time");
function recurseDataAndFindDuplicateOutputSpeciesId(data, isModified) {
    isModified = isModified || false;
    for (let key in data) {
        if (data.hasOwnProperty(key)) {
            let value = data[key];
            if (typeof value === 'object' && value !== null) {
                var tempIsModified = recurseDataAndFindDuplicateOutputSpeciesId(value, isModified);
                isModified = isModified || tempIsModified;
            } else if (key === OUTPUT_SPECIES_ID && UUID.parse(value)) {
                if (outputSpeciesIdMap[value]) {
                    data[key] = UUID.generate();
                    outputSpeciesIdMap[value] += 1;
                    isModified = true;
                    counter++;
                }
                else
                    outputSpeciesIdMap[value] = 1;
            }
        }
    }

    return isModified;
}