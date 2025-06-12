var hubs = db.hub.find({ urlPath: { $regex: /nesp/, $options: 'i' } });

while (hubs.hasNext()) {
    let hub = hubs.next();

    let updateResult1 = db.hub.updateOne(
        { _id: hub._id },
        {
            $set: {
                "data.content.overriddenLabels.$[label].defaultText": "Other project information"
            }
        },
        {
            arrayFilters: [
                { "label.defaultText": "Project information" }
            ]
        }
    );

    let updateResult2 = db.hub.updateOne(
        { _id: hub._id },
        {
            $set: {
                "data.content.overriddenLabels.$[label].customText": "Project map"
            }
        },
        {
            arrayFilters: [
                { "label.customText": "Geographic Extent of Project" }
            ]
        }
    );

    if (updateResult1.modifiedCount > 0 || updateResult2.modifiedCount > 0) {
        printjson({
            message: "Updated document",
            documentId: hub._id,
            modifiedCount: updateResult1.modifiedCount + updateResult2.modifiedCount
        });
    }
}


