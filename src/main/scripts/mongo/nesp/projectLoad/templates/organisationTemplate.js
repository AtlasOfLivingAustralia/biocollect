var organisationMap = {
    "name": "",
    "organisationId": "",
    "status": "active",
    "url": "",
    "description": ""
}

var hubToOrgMap = {
    "RL": "NESP 2 - Resilient Landscapes Hub",
    "SCaW": "NESP 2 - Sustainable Communities and Waste Hub",
    "MaC": "NESP 2 - Marine and Coastal Hub",
    "CS": "NESP 2 - Climate Systems Hub",
    "UTAS": "University of Tasmania",
    "UTas": "University of Tasmania",
    "University of Tasmania":"University of Tasmania",
    "BoM": "Bureau of Meteorology",
    "ANU": "Australian National University",
    "AIMS": "The Australian Institute of Marine Science",
    "Monash": "Monash University",
    "CSIRO": "Commonwealth Scientific and Industrial Research Organisation",
    "UNSW": "University of New South Wales",
    "CDU": "Charles Darwin University",
    "Bush Heritage Australia": "Bush Heritage Australia",
    "UWA": "University of Western Australia",
    "CQU": "Central Queensland University",
    "Curtin": "Curtin University",
    "Deakin": "Deakin University",
    "ECU": "Edith Cowan University",
    "Firesticks": "Firesticks Alliance Indigenous Corporation",
    "Flinders": "Flinders University",
    "GA": "Geoscience Australia",
    "GU":"Griffith University",
    "Griffith":"Griffith University",
    "Griffith University": "Griffith University",
    "JCU": "James Cook University",
    "IDA": "Indigenous Desert Alliance Limited",
    "Latrobe":"La Trobe University",
    "Macquarie": "Macquarie University",
    "MTWAC": "Melaythenner Teeackana Warrana Aboriginal Corporation",
    "Murdoch": "Murdoch University",
    "NAILSMA":"NAILSMA",
    "Newcastle Uni": "The University of Newcastle",
    "NSW DPI": "NSW Department of Primary Industries",
    "Fisheries Research": "NSW Department of Primary Industries",
    "QUT":"Queensland University of Technology",
    "RRRC": "Reef and Rainforest Research Centre Ltd",
    "SIMS": "Sydney Institute of Marine Science",
    "UNE": "University of New England",
    "Uni of Wollongong": "University of Wollongong",
    "University of Adelaide": "University of Adelaide",
    "SARDI": "South Australian Research and Development Institute",
    "University of Queensland": "University of Queensland",
    "Swinburne University": "Swinburne University Of Technology",
    "UoM": "University of Melbourne",
    "UQ": "University of Queensland",
    "USQ": "University of Southern Queensland",
    "DBCA": "Department of Biodiversity, Conservation and Attractions",
    "UTS":"University of Technology Sydney",
    "WSU": "University of Western Sydney",
    "Zoos Victoria": "Zoos Victoria"
}

var nameToOrgMap = {
    "NESP 2 - Resilient Landscapes Hub": undefined,
    "NESP 2 - Sustainable Communities and Waste Hub": undefined,
    "NESP 2 - Marine and Coastal Hub": undefined,
    "NESP 2 - Climate Systems Hub": undefined
}

function createOrFindOrganisation(hub, url, description) {
    var name = hubToOrgMap[hub];
    if (!name) {
        throw new Error("Unknown hub: " + hub);
    }

    var organisation = db.organisation.findOne({name:name, status: "active"});
    if (!organisation) {
        organisation = createOrganisation(name, url, description);
    }

    return organisation;
}

function createOrganisation(name, url, description) {
    print("create a new organisation" + name);
    var org = Object.assign({}, organisationMap);
    org.name = name;
    org.organisationId = UUID.generate();
    org.url = url || "";
    org.description = description || "";
    org.dateCreated = ISODate();
    org.lastUpdated = ISODate();
    db.organisation.insert(org);
    return db.organisation.findOne({organisationId: org.organisationId});
}