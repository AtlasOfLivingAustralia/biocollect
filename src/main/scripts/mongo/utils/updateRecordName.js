var userId = "USERID"; // replace with actual userId
var displayName = "DISPLAYNAME"; // replace with actual displayName
var activities = db.runCommand({distinct: "activity", key: "activityId", query:{userId: userId}});
var activityIds = activities.values;
print("Found " + activityIds.length + ` activities for user ${userId}`);
var modified = db.record.updateMany(
    {activityId: {$in: activityIds}},
    {
        $set: {
            recordedBy: displayName
        }
    }
);

print("Updated " + modified.modifiedCount + " records");

