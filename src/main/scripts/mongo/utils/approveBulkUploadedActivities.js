var bulkImportIds = [
    "5360b881-3499-4f36-a70f-f5a006802459", "56bd50e0-284f-45da-996b-38f5a87ad4ae",
    "3d98073e-473d-4e67-a255-e46e154cc44d", "6ffdfd33-a97d-4ffd-a8dc-22ed72d9b66e", "663f6fc3-d468-44d7-b758-aeb1d5b4679b",
    "e38504fa-b444-4345-bf78-99e2d8f2a561", "c0f597a6-31f5-431e-b84a-f151984f4ac1","3a3d825d-aa26-4a96-bf96-68b1bc38bb9e",
    "92b15850-0440-43b7-8002-e2d5f668df8b", "afaede7d-3e9b-4255-ac12-a5c4f199b0d3", "580b0bbc-b613-4d90-aa63-9491e1beb2cf"
]
var result = db.activity.updateMany({
    bulkImportId: {$in: bulkImportIds},
},{
    $set: {
        "verificationStatus": "approved"
    }
});

print("Updated " + result.modifiedCount + " activities to approved status.");