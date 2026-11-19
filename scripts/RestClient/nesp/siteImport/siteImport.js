print("Import started");

var projectName = 0;
var projectId = projectName + 1;
var siteId = projectId + 1;
var name = siteId + 1;

var csvData = cat('TSR_sites.csv');
print("Loaded csv file");
var csvRows = csvData.split('\r');
print("Total rows "+ csvRows.length);

for(var i = 1; i < csvRows.length; i++) {
    print("--------START record---------")

    var row = csvRows[i];
    var fields = row.split(',');

    var project_id = fields[projectId];
    var site_id = fields[siteId];
    var site_name = fields[name];

    print("Updating projectSiteId " + site_id + " of projectId - " + project_id)

    var projectResult = db.project.update(
        { projectId: project_id },
        { $set: { projectSiteId: site_id } }
    );

    var projects = [project_id];

    print("Updating projects " + projects + " of site id - " + site_id)

    var today = new ISODate();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!
    var yyyy = today.getFullYear();
    var dateUTC = yyyy+"-"+("0" + mm).slice(-2)+"-"+("0" + dd).slice(-2)+"T00:00:00Z";

    var siteResult = db.site.update(
        { siteId: site_id },
        { $set: { projects: projects, lastUpdated: ISODate(dateUTC) } }
    );

    print("projectResult: "+projectResult)
    print("siteResult: "+siteResult)

    print("--------END record---------")
}

print(">>>>>>>>>>>>>>>>>>>>")
print("Updated " + (i-1) + " records");
print("<<<<<<<<<<<<<<<<<<<")
