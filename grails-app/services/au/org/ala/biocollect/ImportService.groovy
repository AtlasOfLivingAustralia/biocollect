package au.org.ala.biocollect

import grails.converters.JSON
import org.apache.commons.io.IOUtils
import org.grails.web.json.JSONObject
import org.grails.web.json.parser.JSONParser

import java.text.SimpleDateFormat

class ImportService {

    def documentService
    def outputService
    def projectActivityService
    def projectService
    def userService
    def activityService

    def importSightingsData(InputStream json, inputProjectId, inputType, inputName, inputActivityId) {
        BufferedReader br = new BufferedReader(new InputStreamReader(json, 'UTF-8'))
        String line

        int count = 0

        while ((line = br.readLine())) {
            count++
            line = line.replaceAll("ObjectId\\( \"[0-9a-z]*\" \\)", "\"\"").replaceAll(" Date\\( ", "\"").replaceAll(" \\), \"", "\", \"")

            JSONParser jp = new JSONParser(IOUtils.toInputStream(line))
            JSONObject record = (JSONObject) jp.parseJSON()

            def userId = record.userId

            Map newRecord = createRecordFromSighting(record, inputProjectId.toString(), inputType.toString(), inputName.toString())

            saveRecord(newRecord, inputActivityId, userId)
        }

        def results = [
                Imported: count
        ]
        return results
    }

    def createRecordFromSighting(JSONObject record, String inputProjectId, String inputType, String inputName) {
        Map newRecord = [:]

        //remap
        newRecord.mainTheme = ""
        newRecord.activityId = ""
        newRecord.siteId = ""
        newRecord.projectId = inputProjectId
        newRecord.type = inputType
        newRecord.projectStage = ""
        newRecord.outputs = []

        Map data = record

        def dateCreated = data.remove("dateCreated")
        def coordinateUncertaintyInMeters = data.remove("coordinateUncertaintyInMeters")
        def decimalLatitude = data.remove("decimalLatitude")
        def decimalLongitude = data.remove("decimalLongitude")
        def eventDate = data.remove("eventDate")
        def geodeticDatum = data.remove("geodeticDatum")
        def georeferenceProtocol = data.remove("georeferenceProtocol")
        def identificationVerificationStatus = data.remove("identificationVerificationStatus")
        def imageLicence = data.remove("imageLicence")
        def individualCount = data.remove("individualCount")
        def lastUpdated = data.remove("lastUpdated")
        def locality = data.remove("locality")
        def occurrenceID = data.remove("occurrenceID")
        def projectId = data.remove("projectId")
        def recordedBy = data.remove("recordedBy")
        def scientificName = data.remove("scientificName")
        def userDisplayName = data.remove("userDisplayName")
        def _id = data.remove("_id")
        def userId = data.remove("userId")
        def occurrenceRemarks = data.remove("occurrenceRemarks")
        def kingdom = data.remove("kingdom")
        def family = data.remove("family")
        def commonName = data.remove("commonName")
        def usingReverseGeocodedLocality = data.remove("usingReverseGeocodedLocality")
        def verbatimLatitude = data.remove("verbatimLatitude")
        def verbatimLongitude = data.remove("verbatimLongitude")
        def locationRemark = data.remove("locationRemark")
        def taxonConceptID = data.remove("taxonConceptID")
        def device = data.remove("device") //image device
        def tags = data.remove("tags")
        def coordinatePrecision = data.remove("coordinatePrecision")
        def devicePlatform = data.remove("devicePlatform")
        def dataResourceUid = data.remove("dataResourceUid")
        def submissionMethod = data.remove("submissionMethod")

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"))
        if (eventDate) {
            eventDate = eventDate.replaceAll("\\+0000", "Z")
        } else {
            eventDate = sdf.format(new Date(dateCreated.toLong()))
        }

        def multimedia = data.multimedia; data.remove("multimedia")

        def tagsFormatted = null
        if (tags) {
            tagsFormatted = []
            def tagMap = ["Australian Ground Frogs": "Amphibians", "Narrow-Mouthed Frogs": "Amphibians", "Tree Frogs": "Amphibians", "True Frogs": "Amphibians", "True Toads": "Amphibians", "Bitterns, Ibises": "Birds", "Buttonquails": "Birds", "Cranes": "Birds", "Cuckoos": "Birds", "Doves": "Birds", "Ducks, Geese, Swans": "Birds", "Falcons": "Birds", "Flamingos": "Birds", "Fowls": "Birds", "Grebes": "Birds", "Hummingbirds, Swifts": "Birds", "Kingfishers": "Birds", "Large waterbirds": "Birds", "Nightjars, Frogmouths, Potoos": "Birds", "Ostriches": "Birds", "Owls": "Birds", "Parrots": "Birds", "Penguins": "Birds", "Perching Birds": "Birds", "Petrels, Fulmars": "Birds", "Waders, Gulls, Auks": "Birds", "Barnacles, Copepods": "Crustaceans", "Crabs, Lobsters": "Crustaceans", "Fairy shrimp, Clam shrimp": "Crustaceans", "Seed shrimp": "Crustaceans", "Anchovies ": "Fish", "Angel Sharks": "Fish", "Anglerfishes": "Fish", "Baldfishes,Tubeshoulders": "Fish", "Batoids": "Fish", "Batrachoidiforms": "Fish", "Beardfishes": "Fish", "Boarfishes": "Fish", "Bonefishes": "Fish", "Bonytongues": "Fish", "Bullhead Sharks": "Fish", "Carpet Sharks": "Fish", "Catfishes": "Fish", "Chimaeras": "Fish", "Cods": "Fish", "Cow Sharks": "Fish", "Cowfishes": "Fish", "Deep-sea ray-finned fishes": "Fish", "Deep-sea ray-finned fishes": "Fish", "Dogfish Sharks": "Fish", "Dragonfishes": "Fish", "Eels": "Fish", "Electric Rays": "Fish", "Flatfishes": "Fish", "Ground Sharks": "Fish", "Guitarfish": "Fish", "Hagfishes": "Fish", "Halfbeeks": "Fish", "Jellynose Fishes": "Fish", "Killifishes": "Fish", "Latern Fishes, Neoscopelids": "Fish", "Lungfish": "Fish", "Mackerel Sharks": "Fish", "Marine ray-finned fish": "Fish", "Milkfishes": "Fish", "Minnows": "Fish", "Mullet fish": "Fish", "Opahs": "Fish", "Ophidiiforms": "Fish", "Perch-like Fishes": "Fish", "Rainbow Fishes": "Fish", "Ray-finned fishes": "Fish", "Sackpharynx Fishes": "Fish", "Salmons": "Fish", "Saw Sharks": "Fish", "Sawfish": "Fish", "Scorpion Fishes, Sculpins": "Fish", "Softnose Skates": "Fish", "Spiny Eels": "Fish", "Swamp Eels": "Fish", "Tarpons": "Fish", "Asco's": "Fungi", "Basidio's": "Fungi", "Chytrids": "Fungi", "Glomeromycota": "Fungi", "Zygomycetes": "Fungi", "Alderflies, Dobsonflies, Fishflies": "Insects and Spiders", "Beetles": "Insects and Spiders", "Booklice, Barklice, Barkflies": "Insects and Spiders", "Bristletails": "Insects and Spiders", "Butterflies, Moths": "Insects and Spiders", "Caddisflies, Sedge-flies or Rail-flies": "Insects and Spiders", "Cicadas, Aphids, Planthoppers, Leafhoppers, Shield Bugs": "Insects and Spiders", "Cockroaches, Termites": "Insects and Spiders", "Dragonflies, Damselflies": "Insects and Spiders", "Earwigs": "Insects and Spiders", "Fleas": "Insects and Spiders", "Flies, Mosquitoes": "Insects and Spiders", "Grasshoppers, Crickets, Locusts, Katydids, Weta, Lubber": "Insects and Spiders", "Lacewings, Mantidflies, Antlions": "Insects and Spiders", "Lice": "Insects and Spiders", "Mantises": "Insects and Spiders", "Mayflies, Shadlfies": "Insects and Spiders", "Scorpionflies, Hangingflies": "Insects and Spiders", "Silverfish": "Insects and Spiders", "Spiders": "Insects and Spiders", "Stick Insects, Phasmids": "Insects and Spiders", "Stoneflies": "Insects and Spiders", "Thrips": "Insects and Spiders", "Twisted-Wing Parasites": "Insects and Spiders", "Wasps, Ants, Bees, Sawflies": "Insects and Spiders", "Webspinners": "Insects and Spiders", "Zorapterans": "Insects and Spiders", "Bandicoots, Bilbies": "Mammals", "Bats": "Mammals", "Carnivores": "Mammals", "Carnivorous Marsupials": "Mammals", "Dolphins, Porpoises, Whales": "Mammals", "Dugongs, Manatees, Sea Cows": "Mammals", "Even-toed hoofed": "Mammals", "Hares, Pikas, Rabbits": "Mammals", "Herbivorous Marsupials": "Mammals", "Marsupial Moles": "Mammals", "Monotremes": "Mammals", "Odd-toed hoofed": "Mammals", "Rodents": "Mammals", "Shrews, Hedgehogs": "Mammals", "Chitons": "Molluscs", "Cuttlefish": "Molluscs", "Gastropods, Slugs, Snails": "Molluscs", "Mussels, Clams": "Molluscs", "Solenogasters": "Molluscs", "Tooth Shells": "Molluscs", "Conifers, Cycads": "Plants", "Dicots": "Plants", "Ferns and Allies": "Plants", "Flowering plants": "Plants", "Monocots": "Plants", "Crocodiles": "Reptiles", "Lizards, Snakes": "Reptiles", "Tortoises, Turtles, Terrapins": "Reptiles"]
            tags.each {
                def group = tagMap[it]
                if (group) tagsFormatted.add(group + ", " + it)
                else tagsFormatted.add(it)
            }
        }

        def identificationVerificationStatusFormatted = null
        if (identificationVerificationStatus) {
            if (identificationVerificationStatus.toString().toLowerCase() == 'confident') {
                identificationVerificationStatusFormatted = "Certain"
            } else {
                identificationVerificationStatusFormatted = "Uncertain"
            }
        }

        def surveyDate = eventDate

        def newData = [
                name              : inputName,
                outputId          : "",
                outputNotCompleted: false,
                data              : [
                        tags                     : tagsFormatted,
                        identificationConfidence1: identificationVerificationStatusFormatted,
                        locationLatitude         : decimalLatitude,
                        locationLongitude        : decimalLongitude,
                        locationLocality         : locality,
                        locationNotes            : locationRemark,
                        locationAccuracy         : coordinateUncertaintyInMeters,
                        locationSource           : georeferenceProtocol,
                        comments1                : occurrenceRemarks,
                        recordedBy               : recordedBy,
                        species1                 : [
                                lsid           : taxonConceptID,
                                outputSpeciesId: outputService.getOutputSpeciesId(),
                                name           : scientificName
                        ],
                        sightingPhoto1           : [],
                        surveyDate               : surveyDate,
                        individualCount1         : individualCount
                ]
        ]

        newData.data = newData.data.findAll {
            it.value != null
        }
        newData.data.species1 = newData.data.species1.findAll { it.value != null }

        multimedia.each {
            def img = createImageFromSightingMultimedia(it)
            newData.data.sightingPhoto1.add(img)
        }

        newRecord.outputs.add(newData)

        newRecord
    }

    def createImageFromSightingMultimedia(multimedia) {
        def created = multimedia.created;
        def title = multimedia.title;
        def format = multimedia.format;
        def creator = multimedia.creator;
        def rightsHolder = multimedia.rightsHolder;
        def license = multimedia.license;
        def type = multimedia.type;
        def imageId = multimedia.imageId;
        def identifier = multimedia.identifier;

        def infoUrl = identifier.replaceAll("image/proxyImageThumbnailLarge\\?imageId=", "ws/image/")
        def imageInfo = JSON.parse(new URL(infoUrl).openConnection().inputStream.text)

        def sizeInBytes = String.format("%.2f KB", imageInfo.sizeInBytes / 1024.0)
        def dateTaken = imageInfo.dateTaken.replace(' ', 'T') + 'Z'

        def formattedLicense
        if (license == "Creative Commons Attribution") formattedLicense = "CC BY"
        if (license == "Creative Commons Attribution-Noncommercial-Share Alike") formattedLicense = "CC BY-NC-SA"
        if (license == "Creative Commons Attribution-Noncommercial") formattedLicense = "CC BY-NC"
        if (license == "Creative Commons Attribution-Share Alike") formattedLicense = "CC BY-SA"

        def img = [
                licence      : formattedLicense,
                status       : "active",
                contentType  : format,
                url          : identifier,
                formattedSize: sizeInBytes,
                dateTaken    : dateTaken,
                filesize     : sizeInBytes,
                thumbnailUrl : identifier.replaceAll("ThumbnailLarge", "Thumbnail"),
                name         : title,
                filename     : title,
                notes        : "",
                staged       : true,
                documentId   : "",
                attribution  : rightsHolder
        ]

        img.findAll { it.value != null }
    }

    def saveRecord(newRecord, inputActivityId, userId) {
        // create bioactivity
        def pActivityId = inputActivityId
        def postBody = newRecord
        def activity = null
        def pActivity = null

        pActivity = projectActivityService.get(pActivityId)
        def projectId = pActivity?.projectId

        Map result

        // Check user has admin/editor permission.
        boolean projectEditor = projectService.canUserEditProject(userId, projectId, false)
        Map userAlreadyInRole = userService.isUserInRoleForProject(userId, projectId, "projectParticipant")

        if (!projectEditor && pActivity.publicAccess && !userAlreadyInRole.inRole.toBoolean()) {
            userService.addUserAsRoleToProject(userId, projectId, "projectParticipant")
        }

        postBody.putAt("projectActivityId", pActivity.projectActivityId)
        postBody.putAt("userId", userId)

        result = activityService.update('', postBody)

        String activityId = result?.resp?.activityId

        if (activityId) {
            postBody.outputs?.each {
                it.data?.multimedia?.each {
                    String filename
                    if (it.filename) {
                        filename = it.filename
                    } else if (it.identifier) {
                        filename = it.identifier.substring(it.identifier.lastIndexOf("/") + 1)
                    }

                    if (filename) {
                        Map document = [
                                activityId       : activityId,
                                projectId        : projectId,
                                projectActivityId: pActivityId,
                                contentType      : it.format,
                                filename         : filename,
                                name             : it.title,
                                type             : "image",
                                role             : "image",
                                license          : it.license
                        ]
                        documentService.saveStagedImageDocument(document)
                    }
                }
            }
        }
    }
}
