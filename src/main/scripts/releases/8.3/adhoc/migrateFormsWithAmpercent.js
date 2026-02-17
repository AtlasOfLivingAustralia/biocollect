load("../../../mongo/utils/audit.js");
// todo: after running the script update program model with new names;
// todo: publish 'Nest Box Maintenance and Monitoring Form - Victoria'
var userId = "system";
var activityFormNames = [
    {oldName:'Nest Box Monitoring and Maintenance Form - Victoria', newName: 'Nest Box Monitoring and Maintenance Form - Mullinmur'},
    {oldName:'Nest Box Monitoring & Maintenance Form - Victoria', newName: 'Nest Box Maintenance and Monitoring Form - Victoria'},
    {oldName: 'Nest Box Monitoring & Maintenance Form - Knox City Council', newName: 'Nest Box Maintenance and Monitoring Form - Knox City Council'}
];
var sectionNames = [
    {oldName: 'Nest Box Monitoring & Maintenance Form - Victoria', newName: 'Nest Box Maintenance and Monitoring Form - Victoria'},
    {oldName: 'Nest Box Monitoring & Maintenance Form - Knox City Council', newName: 'Nest Box Maintenance and Monitoring Form - Knox City Council'},
    {oldName: 'RARC - Site & Event Details', newName: 'RARC - Site and Event Details'}
];

activityFormNames.forEach(function (toChange){
    replaceActivityForm(toChange);
    replaceProjectActivity(toChange);
    replaceActivity(toChange);
});

sectionNames.forEach(function (toChange){
    replaceOutput(toChange);
});

function replaceActivityForm(toChange){
    var newName = toChange.newName;
    // need not track changes to activityForm. Hence, no audit entry.
    var result = db.activityForm.updateOne({name: toChange.oldName}, {$set: {name: newName}});
    console.log("Number of forms updated for " + toChange.oldName + " " + result.modifiedCount);
}

function replaceActivity(toChange) {
    var counter = 0;
    var newName = toChange.newName;
    var oldName = toChange.oldName;
    var cursor = db.activity.find({type: oldName});
    cursor.forEach(function (activity) {
        activity.type = newName;
        var result = db.activity.updateOne({activityId: activity.activityId}, {$set: {type: newName}});
        audit(activity, activity.activityId, 'au.org.ala.ecodata.Activity', userId, activity.projectId)
        counter += result.modifiedCount;
    });

    console.log("Number of activities updated with new name " + newName + " - " + counter);
}

function replaceOutput(toChange) {
    var newName = toChange.newName,
        oldName = toChange.oldName,
        result,
        outputCounter = 0,
        activityIds = [];

    // update section name
    db.activityForm.find({"sections.name": oldName}).forEach(function (activityForm) {
        var modified = false;
        activityForm.sections.forEach(function (section) {
            if (section.name === oldName) {
                section.name = newName;
                modified = true
            }
        });

        if (modified) {
            db.activityForm.updateOne({_id: activityForm._id}, {$set: activityForm});
            activityIds.push.apply(activityIds, db.runCommand({distinct: "activity", query: {type: activityForm.name}, key: "activityId"}).values);
            console.log("Section in Activity form " + activityForm.name + " updated." );
        }
    });

    console.log(JSON.stringify(activityIds.slice(0,5)));

    db.output.find({name: oldName, activityId: {$in: activityIds}}).forEach(function (output) {
        output.name = newName;
        result = db.output.updateOne({outputId: output.outputId}, {$set: {name: newName}});
        if(result.modifiedCount) {
            outputCounter ++;
            audit(output, output.outputId, 'au.org.ala.ecodata.Output', userId);
        }
    });

    console.log("Number of outputs updated " + outputCounter);
}

function replaceProjectActivity(toChange) {
    var newName = toChange.newName,
        oldName = toChange.oldName;
    db.projectActivity.find({pActivityFormName: oldName}).forEach(function (pa){
        var result = db.projectActivity.updateOne({projectActivityId: pa.projectActivityId}, {$set: {pActivityFormName: newName}});
        audit(pa, pa.projectActivityId, 'au.org.ala.ecodata.ProjectActivity', userId);
        console.log("Number of project activity modified " + result.modifiedCount + " for " + pa.name);
    });

}