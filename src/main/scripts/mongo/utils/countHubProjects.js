let hub;
let query;
let count;

hub = db.hub.findOne({urlPath: 'nesp-marineandcoastal'});
query = {associatedProgram: hub.defaultProgram, status: 'active'};
count = db.project.countDocuments(query);
print("Hub: " + hub.urlPath + " | Program: " + hub.defaultProgram + " | Active projects: " + count);

hub = db.hub.findOne({urlPath: 'nesp-resilientlandscapes'});
query = {associatedProgram: hub.defaultProgram, status: 'active'};
count = db.project.countDocuments(query);
print("Hub: " + hub.urlPath + " | Program: " + hub.defaultProgram + " | Active projects: " + count);

hub = db.hub.findOne({urlPath: 'nesp-sustainablecommunities'});
query = {associatedProgram: hub.defaultProgram, status: 'active'};
count = db.project.countDocuments(query);
print("Hub: " + hub.urlPath + " | Program: " + hub.defaultProgram + " | Active projects: " + count);

hub = db.hub.findOne({urlPath: 'nesp-climatesystems'});
query = {associatedProgram: hub.defaultProgram, status: 'active'};
count = db.project.countDocuments(query);
print("Hub: " + hub.urlPath + " | Program: " + hub.defaultProgram + " | Active projects: " + count);