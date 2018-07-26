// Reassign activity id.
var ecodataDb = sightingsConn.getDB("ecodata");
var rows = [
];
var count = 0;
println("Updating activities...");

for(var i = 0; i < rows.length; i++) {
    var row = rows[i];
    ecodataDb.activity.update({activityId: row.activityId},{$set:{userId:row.userId}});
    count++;
    if (count % 10 == 0) {
        print("Updated " + count + " activities...");
    }
}

print("Updated " + count + " activities...");
print('Completed...');