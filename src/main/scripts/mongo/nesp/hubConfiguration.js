var hubs = db.hub.find({ urlPath: { $regex: /nesp/, $options: 'i' } });
var faviconlogoUrl = "";
if (faviconlogoUrl === "") {
    print("No favicon provided exiting.");
    exit(0);
}

while (hubs.hasNext()) {
    let hub = hubs.next();

    let updateResult1 = db.hub.updateOne(
        { _id: hub._id },
        {
            $set: {
                "content.overriddenLabels.$[label1].defaultText": "Other project information",
                "content.overriddenLabels.$[label2].customText": "Project map",
                "content.hideProjectGettingStartedButton": true,
                "content.nespFavicon": true,
                "content.showCustomMetadata": true,
                "content.disableOrganisationHyperlink": true,
                "templateConfiguration.homePage.projectFinderConfig.showProjectDownloadButton": true,
                "faviconlogoUrl": faviconlogoUrl
            }
        },
        {
            arrayFilters: [
                { "label1.defaultText": "Project information" },
                { "label2.defaultText": "Geographic Extent of Project" }
            ]
        }
    );

    if (updateResult1.modifiedCount > 0) {
        printjson({
            message: "Updated document",
            documentId: hub._id,
            modifiedCount: updateResult1.modifiedCount,
        });
    }
}


