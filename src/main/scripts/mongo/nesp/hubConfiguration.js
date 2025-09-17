var hubs = db.hub.find({urlPath: {$regex: /nesp/, $options: 'i'}});
var faviconlogoUrl = "https://biocollect.ala.org.au/document/download/2025-07/NESP_favicon.png";
if (faviconlogoUrl === "") {
    print("No favicon provided exiting.");
    exit(0);
}

while (hubs.hasNext()) {
    let hub = hubs.next();

    if (hub.content.overriddenLabels) {
     // find id 11
        let labelExists = false, id12Exists = false;
        for (let i = 0; i < hub.content.overriddenLabels.length; i++) {
            if (hub.content.overriddenLabels[i].id === 11) {
                labelExists = true;
            }

            if (hub.content.overriddenLabels[i].id === 12) {
                id12Exists = true;
            }
        }

        if (!labelExists) {
            hub.content.overriddenLabels.push(
                {
                    id: 11,
                    showCustomText: false,
                    page: 'Project > "About" tab',
                    defaultText: 'External Id',
                    customText: '',
                    notes: 'Label for external id field.'
                }
            );
        }

        if (!id12Exists) {
            hub.content.overriddenLabels.push(
                {
                    id: 12,
                    showCustomText: false,
                    page: 'Project > "Admin" tab > "Resources" tab > "Attach document" modal',
                    defaultText: 'make this document public on the project "Resources" tab',
                    customText:'',
                    notes: 'Label for external id field.'
                }
            );
        }
        if (!labelExists || !id12Exists) {
            db.hub.replaceOne({_id: hub._id}, hub);
            printjson({message: "Added overridden labels to document", documentId: hub._id, urlPath: hub.urlPath});
        }
    }

    let updateResult1 = db.hub.updateOne(
        { _id: hub._id },
        {
            $set: {
                "content.overriddenLabels.$[label1].defaultText": 'Project information',
                "content.overriddenLabels.$[label1].customText": "Other project information",
                "content.overriddenLabels.$[label1].showCustomText": true,
                "content.overriddenLabels.$[label2].defaultText": 'Project Area',
                "content.overriddenLabels.$[label2].customText": "Project map",
                "content.overriddenLabels.$[label2].showCustomText": true,
                "content.overriddenLabels.$[label4].customText": "Project number",
                "content.overriddenLabels.$[label4].showCustomText": true,
                "content.overriddenLabels.$[label5].customText": "make this document public on the project \"Products\" tab",
                "content.overriddenLabels.$[label5].showCustomText": true,
                "content.hideProjectGettingStartedButton": true,
                "content.nespFavicon": true,
                "content.showCustomMetadata": true,
                "content.disableOrganisationHyperlink": true,
                "content.enableNationalProjectsExclusionFilter": true,
                "content.hideProjectAboutGeographicInfo": true,
                "templateConfiguration.homePage.homePageConfig": "projectfinder",
                "templateConfiguration.homePage.projectFinderConfig.showProjectDownloadButton": true,
                "templateConfiguration.homePage.projectFinderConfig.defaultSort": "nameSort",
                "templateConfiguration.footer.links.$[label3].displayName": "<p>The National Environmental Science Program (NESP) values its partnerships with Aboriginal and Torres Strait Islander communities. We acknowledge Traditional Owners across Australia and their enduring connection to Country, and pay respect to Elders past and present.</p>" +
                    "<p>This website may include images, voices, names, and dialogue of deceased persons. It also contains links to external sites. NESP and the Australian Government are not responsible for the content or accuracy of these external sources, nor do they endorse any products or services they may offer.</p>",
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
                        }]
                    }, "projectRecords": {
                        "facets": []
                    }, "myProjectRecords": {
                        "facets": []
                    }
                },
                lastUpdated: new ISODate()
            }
        },
        {
            arrayFilters: [
                { "label1.id": 5 },
                { "label2.id": 8 },
                { "label4.id": 11 },
                { "label5.id": 12 },
                { "label3.contentType": "nolink" }
            ]
        }
    );

    if (updateResult1.modifiedCount > 0) {
        printjson({
            message: "Updated document", documentId: hub._id, modifiedCount: updateResult1.modifiedCount, urlPath: hub.urlPath
        });
    }
}


