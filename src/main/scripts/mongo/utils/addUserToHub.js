var hubs = ["a0c69ce5-a2fc-4dfe-a387-468a4c916685"];
var users = ["229308", "46293"];
var role = "admin";

hubs.forEach(function(hubId) {
   users.forEach(function(userId) {
       addUserToHubWithRole(hubId, userId, role);
   });
});

function addUserToHubWithRole(hubId, userId, role) {
    if(db.userPermission.count({entityId: hubId, userId: userId, accessLevel: role})){
        print("User " + userId + " already has role " + role + " in hub " + hubId);
        return;
    }

    db.userPermission.insertOne({
        "entityId": hubId,
        "entityType": "au.org.ala.ecodata.Hub",
        "accessLevel": role,
        "userId": userId
    });
    print("Added user " + userId + " with role " + role + " to hub " + hubId);
}
