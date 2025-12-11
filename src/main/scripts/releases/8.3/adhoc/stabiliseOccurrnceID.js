// create an eventID index on record collection for faster lookup
// db.record.createIndex({eventID: 1});
// db.auditMessage.createIndex({entityType: 1, entityId: 1});
// usage mongosh ecodata stabiliseOccurrnceID.js

load("../../../../mongo/utils/audit.js");
var files = [
    "allresources_1.js" ,
    "allresources_2.js" ,
    "allresources_3.js" ,
    "allresources_4.js" ,
    "allresources_5.js" ,
    "allresources_6.js" ,
    "allresources_7.js" ,
    "allresources_8.js" ,
    "allresources_9.js" ,
    "allresources_10.js" ,
    "allresources_11.js" ,
    "allresources_12.js" ,
    "allresources_13.js",
    "allresources_14.js",
    "allresources_15.js",
    "allresources_16.js" ,
    "allresources_17.js" ,
    "allresources_18.js" ,
    "allresources_19.js" ,
    "allresources_20.js" ,
    "allresources_21.js" ,
    "allresources_22.js" ,
    "allresources_23.js",
    "allresources_24.js",
    "allresources_25.js",
    "allresources_26.js" ,
    "allresources_27.js" ,
    "allresources_28.js" ,
    "allresources_29.js" ,
    "allresources_30.js" ,
    "allresources_31.js" ,
    "allresources_32.js",
    "allresources_33.js",
    "allresources_34.js",
    "allresources_35.js",
    "allresources_36.js" ,
    "allresources_37.js" ,
    "allresources_38.js" ,
    "allresources_39.js" ,
    "allresources_40.js" ,
    "allresources_41.js",
    "allresources_42.js",
    "allresources_43.js",
    "allresources_44.js",
    "allresources_45.js",
    "allresources_46.js" ,
    "allresources_47.js" ,
    "allresources_48.js" ,
    "allresources_49.js" ,
    "allresources_50.js",
    "allresources_51.js",
    "allresources_52.js",
    "allresources_53.js",
    "allresources_54.js",
    "allresources_55.js",
    "allresources_56.js",
    "allresources_57.js",
    "allresources_58.js"
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
                let newOccurrenceID = record.outputSpeciesId || record.occurrenceID;
                if (oldOccurrenceID !== newOccurrenceID) {
                    // also update output data so that next regeneration creates records with old occurrence ID.
                    let outputs = db.output.find({activityId: eventID, status: 'active'}).toArray();
                    outputs.forEach(output => {
                        var isUpdated = recurseDataAndUpdateOutputSpeciesID(output.data, oldOccurrenceID, newOccurrenceID);
                        if (isUpdated) {
                            db.output.updateOne({outputId: output.outputId}, {$set: {data: output.data}});
                            audit(output, output.outputId, 'au.org.ala.ecodata.Output', 'system');
                            print("Updated outputId: " + output.outputId + ", and occurrenceID from " + newOccurrenceID + " to " + oldOccurrenceID);
                        }
                    });

                    db.record.updateOne({_id: record._id}, {$set: {occurrenceID: oldOccurrenceID}});
                    audit(record, record.occurrenceID, 'au.org.ala.ecodata.Record', 'system');
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
print("Total missing occurrences found: " + missingOccurrences.length);
printjson(missingOccurrences);
print("Total missing records found: " + missingRecords.length);
printjson(missingRecords);

function recurseDataAndUpdateOutputSpeciesID(data, oldOccurrenceID, newOccurrenceID, isUpdated) {
    isUpdated = isUpdated || false;
    for (let key in data) {
        if (data.hasOwnProperty(key)) {
            let value = data[key];
            if (typeof value === 'object' && value !== null) {
                var tempIsUpdated = recurseDataAndUpdateOutputSpeciesID(value, oldOccurrenceID, newOccurrenceID, isUpdated);
                isUpdated = isUpdated || tempIsUpdated;
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