var outputDefaults = {
    create: function() {
        return {
            "activityId": "activity_1",
            "data": {},
            "name": "Weed Treatment Details",
            "outputId": "output_1",
            "status": "active"
        }
    }
};

var pestOutDataDefaults = {
    create: function(){
        return {
    "activityId" : "",
    "dateCreated" : ISODate("2016-02-01T00:46:44.105Z"),
    "lastUpdated" : ISODate("2016-02-01T00:49:04.646Z"),
    "outputId" : "output_4",
    "status" : "active",
    "data" : {
    "treatmentObjectiveBenefits" : "",
        "treatmentType" : "Initial treatment",
        "treatmentObjective" : [
        "Co-ordinated control to protect agriculture production",
        "Local / regional eradication",
        "Manage threats to priority environmental assets"
    ],
        "notes" : "",
        "totalAreaTreatedHa" : "1365",
        "pestManagement" : [
        {
            "noUnknown" : true,
            "areaTreatedHa" : "841",
            "pestAnimalsTreatedNo" : 0,
            "targetSpecies" : {
                "listId" : "Atlas of Living Australia",
                "name" : "Oryctolagus cuniculus",
                "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:692effa3-b719-495f-a86f-ce89e2981652",
                "list" : ""
            },
            "pestPriorityStatus" : "Priority local pest",
            "treatmentIncentiveMethod" : "Other (specify in notes)",
            "pestDensityPerHa" : 0,
            "pestManagementMethod" : "Other (specify in notes)"
        },
        {
            "noUnknown" : true,
            "areaTreatedHa" : "524",
            "pestAnimalsTreatedNo" : 0,
            "targetSpecies" : {
                "listId" : "Atlas of Living Australia",
                "name" : "Vulpes vulpes",
                "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:ba8d0c3b-9753-46cf-87b4-a1b9ec290634",
                "list" : ""
            },
            "pestPriorityStatus" : "Priority local pest",
            "treatmentIncentiveMethod" : "No incentive program applicable",
            "pestDensityPerHa" : 0,
            "pestManagementMethod" : "Trap & cull"
        }
    ],
        "treatmentCostPerHa" : 0,
        "partnerType" : [
        "Local Landcare, 'Friends of', community, or farmer group",
        "Regional Primary Industry group or community / Landcare Network"
    ]
},
    "appendTableRows" : true,
    "name" : "Pest Management Details"
}}};
