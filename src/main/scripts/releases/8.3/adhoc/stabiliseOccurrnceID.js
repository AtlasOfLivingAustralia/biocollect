// create an eventID index on record collection for faster lookup
// db.record.createIndex({eventID: 1});
// usage mongosh ecodata stabiliseOccurrnceID.js

var files = [
    "dr364_1.js" ,
    "dr364_2.js" ,
    "dr364_3.js" ,
    "dr364_4.js" ,
    "dr364_5.js" ,
    "dr364_6.js" ,
    "dr364_7.js" ,
    "dr364_8.js" ,
    "dr364_9.js" ,
    "dr364_10.js" ,
    "dr364_11.js" ,
    "dr3147.js" ,
    "dr5018_1.js" ,
    "dr5018_2.js" ,
    "dr5018_3.js" ,
    "dr5018_4.js" ,
    "dr15301.js" ,
    "dr16853_1.js" ,
    "dr16853_2.js" ,
    "dr17465.js" ,
    "dr17493.js" ,
    "dr17831.js" ,
    "dr22119.js" ,
    "dr25010_1.js" ,
    "dr25010_2.js"
]

// group by eventId
var index,
    OUTPUT_SPECIES_ID = 'outputSpeciesId',
    counter = 0,
    missingOccurrences = [], missingRecords = [];

for (var fileIndex = 0; fileIndex < files.length; fileIndex++) {
    let file = files[fileIndex];
    print("Processing file: " + file);
    load("./data/" + file);

    for (index in occurrences) {
        var occurrence = occurrences[index],
            eventID = occurrence.eventID,
            oldOccurrenceID = occurrence.occurrenceID;

        if (counter != 0 && counter % 100 == 0) {
            print("Occurrences processed: " + counter);
        }

        // find the record in auditMessage collection
        let oldRecord = db.auditMessage.findOne({entityType: "au.org.ala.ecodata.Record", entityId: oldOccurrenceID});
        if (oldRecord) {
            // use record's _id field find the record that needs updating.
            let oldRecordObjectId = oldRecord.entity._id;
            let record = db.record.findOne({_id: oldRecordObjectId});
            if (record) {
                let newOccurrenceID = record.occurrenceID;
                if (oldOccurrenceID !== newOccurrenceID) {
                    // also update output data so that next regeneration creates records with old occurrence ID.
                    let outputs = db.output.find({activityId: eventID, status: 'active'}).toArray();
                    outputs.forEach(output => {
                        var isUpdated = recurseDataAndUpdateOutputSpeciesID(output.data, oldOccurrenceID, newOccurrenceID);
                        if (isUpdated) {
                            db.output.updateOne({outputId: output.outputId}, {$set: {data: output.data}});
                            print("Updated outputId: " + output.outputId + ", and occurrenceID from " + newOccurrenceID + " to " + oldOccurrenceID);
                        }
                    });

                    db.record.updateOne({_id: record._id}, {$set: {occurrenceID: oldOccurrenceID}});
                }
                else {
                    print("OccurrenceID matches for occurrenceID: " + occurrence.occurrenceID);
                }
            }
            else {
                missingRecords.push({_id: oldRecordObjectId, occurrenceID: oldOccurrenceID});
            }
        } else {
            // if record missing in auditMessage collection, check in record collection. If no active record found, log it.
            if (db.record.countDocuments({occurrenceID: oldOccurrenceID, status: 'active'}) === 0)
                missingOccurrences.push(oldOccurrenceID);
        }
    }
}

print("Total occurrences updated: " + counter);
print("Total multiple records found: " + missingOccurrences.length);
printjson(missingOccurrences);
print("Total missing records found: " + missingRecords.length);
printjson(missingRecords);

function recurseDataAndUpdateOutputSpeciesID(data, oldOccurrenceID, newOccurrenceID, isUpdated) {
    isUpdated = isUpdated || false;
    for (let key in data) {
        if (data.hasOwnProperty(key)) {
            let value = data[key];
            if (typeof value === 'object' && value !== null) {
                isUpdated = isUpdated || recurseDataAndUpdateOutputSpeciesID(value, oldOccurrenceID, newOccurrenceID, isUpdated);
            } else if (key === OUTPUT_SPECIES_ID && value === newOccurrenceID) {
                data[key] = oldOccurrenceID;
                // print("Updated outputSpeciesId from " + newOccurrenceID + " to " + oldOccurrenceID);
                counter++;
                isUpdated = true;
            }
        }
    }

    return isUpdated;
}