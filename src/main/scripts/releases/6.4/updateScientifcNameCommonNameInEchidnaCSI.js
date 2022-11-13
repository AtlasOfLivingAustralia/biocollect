// modify echidna csi survey records so that when ecodata regenerates records, scientific and common names will be
// populated correctly.
var modified = db.output.updateMany({
    "data.species.name": {
        "$in": [
            "Short-beaked Echidna (Tachyglossus aculeatus)", "Tachyglossus aculeatus (Short-Beaked Echidna)",
            "Short-Beaked Echidna (Tachyglossus aculeatus)", "Short-beaked Echidna", "Tachyglossus aculeatus"
        ]
    },
    "data.species.scientificName": null,
    name: "Echidna CSI"
}, {
    $set: {
        "data.species.scientificName": "Tachyglossus aculeatus",
        "data.species.commonName": "Short-beaked Echidna",
        "data.species.guid": "urn:lsid:biodiversity.org.au:afd.taxon:0d4c9c0c-51d3-44e0-a365-fe0f8b791c66",
    }
});

print("Total outputs selected by query - " + modified.matchedCount);
print("Total outputs updated - " + modified.modifiedCount);