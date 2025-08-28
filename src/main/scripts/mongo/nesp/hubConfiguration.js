var hubs = db.hub.find({urlPath: {$regex: /nesp/, $options: 'i'}});
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
                "content.enableNationalProjectsExclusionFilter": true,
                "templateConfiguration.homePage.projectFinderConfig.showProjectDownloadButton": true,
                "faviconlogoUrl": faviconlogoUrl,
                "pages": {
                    "allRecords": {
                        "facets": []
                    }, "bulkImport": {
                        "facets": []
                    }, "userProjectActivityRecords": {
                        "facets": []
                    }, "myRecords": {
                        "facets": []
                    }, "project": {
                        "facets": []
                    }, "projectFinder": {
                        "facets": [{
                            "adminOnly": false,
                            "isNotHistogram": true,
                            "helpText": "The administrative Program under which a project is being run.",
                            "facetTermType": "Default",
                            "formattedName": "Hub (associatedProgramFacet)",
                            "name": "associatedProgramFacet",
                            "interval": 10,
                            "state": "Expanded",
                            "title": "Hub",
                            "chartjsType": "none"
                        }, {
                            "adminOnly": false,
                            "isNotHistogram": true,
                            "helpText": "Selects projects that start between the specified date range.",
                            "facetTermType": "Date",
                            "formattedName": "Project Start Date (plannedStartDate)",
                            "name": "plannedStartDate",
                            "interval": 10,
                            "state": "Expanded",
                            "chartjsConfig": "",
                            "title": "Project Start Date",
                            "chartjsType": "none"
                        }, {
                            "adminOnly": false,
                            "isNotHistogram": true,
                            "helpText": "",
                            "facetTermType": "Default",
                            "formattedName": "Research program (funding source) (fundingSourceFacet)",
                            "name": "fundingSourceFacet",
                            "interval": 10,
                            "state": "Collapsed",
                            "title": "Research program (funding source)",
                            "chartjsType": "none"
                        }, {
                            "adminOnly": false,
                            "isNotHistogram": true,
                            "helpText": "Organisations either running projects or associated with projects (eg. as partners).",
                            "facetTermType": "Default",
                            "formattedName": "Delivery & partner organisations (organisationFacet)",
                            "name": "organisationFacet",
                            "interval": 10,
                            "state": "Collapsed",
                            "title": "Delivery & partner organisations",
                            "chartjsType": "none"
                        }, {
                            "adminOnly": false,
                            "isNotHistogram": true,
                            "helpText": "Filters projects by project lifecycle status",
                            "facetTermType": "Default",
                            "formattedName": "Project Lifecycle Status (projLifecycleStatus)",
                            "name": "projLifecycleStatus",
                            "interval": 10,
                            "state": "Collapsed",
                            "chartjsConfig": "",
                            "title": "Project Lifecycle Status",
                            "chartjsType": "none"
                        }]
                    }, "projectRecords": {
                        "facets": []
                    }, "myProjectRecords": {
                        "facets": []
                    }
                }
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
            message: "Updated document", documentId: hub._id, modifiedCount: updateResult1.modifiedCount,
        });
    }
}


