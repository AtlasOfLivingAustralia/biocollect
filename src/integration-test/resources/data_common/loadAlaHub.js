load('../data/alaHub.js');
var hubId = 'alaId'
if (!db.hub.find({urlPath:alaHub.urlPath}).hasNext()) {
    db.hub.insert(alaHub);
}

// setup some users with higher level MERIT roles to assist with functional tests for these roles
// the hubId of the merit hub inserted earlier is "merit"
// Create read only user with id "1000"
db.userPermission.insert({userId:'1000', entityType:'au.org.ala.ecodata.Hub', entityId:hubId, accessLevel:'readOnly'});
// Create MERIT admin user with id "1002"
db.userPermission.insert({userId:'1002', entityType:'au.org.ala.ecodata.Hub', entityId:hubId, accessLevel:'admin'});


