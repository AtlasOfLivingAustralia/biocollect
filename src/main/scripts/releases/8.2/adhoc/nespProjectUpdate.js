var nesp1OrgNames = [
    "NESP - Threatened Species Recovery Hub",
    "NESP - Marine Biodiversity Hub",
    "NESP - Tropical Water Quality Hub",
    "NESP - Northern Australia Environmental Resources Hub",
    "NESP - Clean Air and Urban Landscapes Hub",
    "NESP - Earth Systems and Climate Change Hub"
];

var nesp1OrgIds = db.runCommand({distinct: "organisation", key: "organisationId", query: {name: {$in: nesp1OrgNames}}}).values;
var projectUpdate = db.project.updateMany({
        organisationId: {$in: nesp1OrgIds}
    },
    {
        "$set": {
            "urlWeb":null,
            "fundings": [
                {
                    "fundingSource": "NESP Phase 1 (2015-2021)",
                    "fundingSourceAmount": 0,
                    "fundingType": "Public - commonwealth"
                }
            ],
        }
    });

print("Updated " + projectUpdate.modifiedCount + " projects");

var nesp2OrgNames = [
    "NESP 2 - Resilient Landscapes Hub",
    "NESP 2 - Sustainable Communities and Waste Hub",
    "NESP 2 - Marine and Coastal Hub",
    "NESP 2 - Climate Systems Hub"
];

var nesp2OrgIds = db.runCommand({distinct: "organisation", key: "organisationId", query: {name: {$in: nesp2OrgNames}}}).values;
var project2Update = db.project.updateMany({
        organisationId: {$in: nesp2OrgIds}
    },
    {
        "$set": {
            "fundings": [
                {
                    "fundingSource": "NESP Phase 2 (2021-2027)",
                    "fundingSourceAmount": 0,
                    "fundingType": "Public - commonwealth"
                }
            ],
        }
    });

print("Updated " + project2Update.modifiedCount + " projects");