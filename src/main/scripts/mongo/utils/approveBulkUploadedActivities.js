var bulkImportIds = ["e38504fa-b444-4345-bf78-99e2d8f2a561", "3d98073e-473d-4e67-a255-e46e154cc44d", "6ffdfd33-a97d-4ffd-a8dc-22ed72d9b66e",
    "663f6fc3-d468-44d7-b758-aeb1d5b4679b", "5360b881-3499-4f36-a70f-f5a006802459", "56bd50e0-284f-45da-996b-38f5a87ad4ae"]
var result = db.activity.updateMany({
    bulkImportId: {$in: bulkImportIds},
},{
    $set: {
        "verificationStatus": "approved"
    }
});

print("Updated " + result.modifiedCount + " activities to approved status.");