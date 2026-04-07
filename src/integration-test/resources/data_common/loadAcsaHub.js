load('../data/acsaHub.js');
var hubId = 'acsaId'
if (!db.hub.find({urlPath:acsaHub.urlPath}).hasNext()) {
    db.hub.insert(acsaHub);
}

// setup some users with higher level MERIT roles to assist with functional tests for these roles
// the hubId of the merit hub inserted earlier is "merit"
// Create read only user with id "1000"
db.userPermission.insert({userId:'1000', entityType:'au.org.ala.ecodata.Hub', entityId:hubId, accessLevel:'readOnly'});
// Create MERIT admin user with id "1002"
db.userPermission.insert({userId:'1002', entityType:'au.org.ala.ecodata.Hub', entityId:hubId, accessLevel:'admin'});


