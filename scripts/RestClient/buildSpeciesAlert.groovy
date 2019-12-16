
// export PATH=$PATH:/Users/sat01a/All/j2ee/groovy-2.4.11/bin
// groovy
@Grapes([
        @Grab('org.apache.poi:poi:3.10.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.9'),
        @Grab('org.apache.poi:poi-ooxml:3.10.1')]
)
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import static org.apache.poi.ss.usermodel.Cell.*
import java.nio.file.Paths
import static java.util.UUID.randomUUID
def SERVER_URL = "https://biocollect.ala.org.au"
def SPECIES_URL = "/search/searchSpecies/cd71f766-8fd4-410a-a362-8185719a07e9?limit=10&hub=acsa&dataFieldName=species1&output=Multiple%20species%20sightings"

def speciesNames = [
    "Australian Humpback Dolphin - Sousa sahulensis",
    "Australian Snubfin Dolphin - Orcaella heinsohni",
    "Blainville's Beaked Whale - Mesoplodon densirostris",
    "Blue Whale - Balaenoptera musculus",
    "Bottlenose Dolphin - Tursiops spp.",
    "Bryde's Whale - Balaenoptera edeni",
    "Common Dolphin - Delphinus delphis",
    "Cuvier's Beaked Whale - Ziphius cavirostris",
    "Dwarf Minke Whale - Balaenoptera acutorostrata",
    "Dwarf Sperm Whale - Kogia simus",
    "Dwarf Spinner Dolphin - Stenella longirostris rosiventris",
    "False Killer Whale - Pseudorca crassidens",
    "Fraser's Dolphin - Lagenodelphis hosei",
    "Humpback Whale - Megaptera novaeangliae",
    "Indo-Pacific Bottlenose Dolphin - Tursiops aduncus",
    "Killer Whale - Orcinus orca",
    "Melon-headed Whale - Peponocephala electra",
    "Offshore Bottlenose Dolphin - Tursiops truncatus",
    "Pantropical Spotted Dolphin - Stenella attenuata",
    "Risso's Dolphin - Grampus griseus",
    "Rough-toothed Dolphin - Steno bredanensis",
    "Sei Whale - Balaenoptera borealis",
    "Short-beaked Common Dolphin - Delphinus delphis",
    "Short-finned Pilot Whale - Globicephala macrorhynchus",
    "Sperm Whale - Physeter macrocephalus",
    "Spinner Dolphin - Stenella longirostris",
    "Striped Dolphin - Stenella coeruleoalba",
    "Unidenified dolphin species - DELPHINIDAE",
    "Unidenified whale species - CETACEA",
    "Dugong - Dugong dugon",
    "Banded Eagle Ray - Aetomylaeus nichofii",
    "Eagle Rays - MYLIOBATIDAE",
    "Giant Manta Ray - Mobula birostris",
    "Manta Ray - Mobula alfredi",
    "Ornate Eagle Ray - Aetomylaeus vespertilio",
    "Smalleye Stingray - Megatrygon microps",
    "Spotted Eagle Ray - Aetobatus ocellatus",
    "Stingrays - DASYATIDAE",
    "Whale Shark - Rhincodon typus",
    "Flatback Turtle - Natator depressus",
    "Green Turtle - Chelonia mydas",
    "Hawksbill Turtle - Eretmochelys imbricata",
    "Leatherback Turtle - Dermochelys coriacea",
    "Loggerhead Turtle - Caretta caretta",
    "Modern Sea Turtles - CHELONIIDAE",
    "Olive Ridley Turtle - Lepidochelys olivacea",
    "Unidentified Turtles - TESTUDINES"
];


def rows = [];
speciesNames?.each { entry ->
    def names = entry.split("-")
    // Get species name
    def encoded = java.net.URLEncoder.encode(names[1].trim(), "UTF-8")
    def species = [name: '', guid: '', scientificName: '', commonName: '']
    def speciesResponse = new URL(SERVER_URL + SPECIES_URL + "&q=${encoded}").text
    def speciesJSON = new groovy.json.JsonSlurper()
    def autoCompleteList = speciesJSON.parseText(speciesResponse)?.autoCompleteList

    if (!autoCompleteList) {
        println("Species not found >> ${entry}")
    }

    autoCompleteList?.eachWithIndex { item, index ->
        if (index == 0) {
            species.name = item.name
            species.guid = item.guid
            species.scientificName = item.scientificName
            species.commonName = item.commonName
            rows << species
        }
    }
}

rows?.each{ row->
    println("{")
    println('\t"listId" : "",')
    println('\t"commonName" : "' + row.commonName +'",')
    println('\t"scientificName" : "' + row.scientificName +'",')
    println('\t"name" : "' + row.name +'",')
    println('\t"guid" : "' + row.guid +'"')
    println("},")

}

// Species not found.
/*
> Species not found >> Bottlenose Dolphin - Tursiops spp.
> Species not found >> Dwarf Sperm Whale - Kogia simus
> Species not found >> Dwarf Spinner Dolphin - Stenella longirostris rosiventris
> Species not found >> Indo-Pacific Bottlenose Dolphin - Tursiops aduncus
> Species not found >> Short-beaked Common Dolphin - Delphinus delphis
> Species not found >> Eagle Rays - MYLIOBATIDAE
> Species not found >> Stingrays - DASYATIDAE
> Species not found >> Modern Sea Turtles - CHELONIIDAE

﻿{
    "listId" : "",
    "commonName" : "Common Dolphin",
    "outputSpeciesId" : "",
    "scientificName" : "Delphinus delphis",
    "name" : "Delphinus delphis (Common Dolphin)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:caf94a82-7ccf-4957-96dc-444ad0acaa27"
},
﻿{
    "listId" : "",
    "commonName" : "Sea Turtles",
    "outputSpeciesId" : "",
    "scientificName" : "CHELONIIDAE",
    "name" : "CHELONIIDAE (Sea Turtles)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:05887ba7-8f98-48f1-bd08-b0cac93352d1"
},
﻿{
    "listId" : "",
    "commonName" : "Stingrays",
    "outputSpeciesId" : "",
    "scientificName" : "DASYATIDAE",
    "name" : "DASYATIDAE (Stingrays)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:6048ef83-d488-4a17-a3b5-272567122b30"
},
﻿{
    "listId" : "",
    "commonName" : "Eagle Rays",
    "outputSpeciesId" : "",
    "scientificName" : "MYLIOBATIDAE",
    "name" : "MYLIOBATIDAE (Eagle Rays)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:e5676e0f-6797-475f-8474-9aa020cca5e1"
},
﻿{
    "listId" : "",
    "commonName" : "Indian Ocean Bottlenose Dolphin",
    "outputSpeciesId" : "",
    "scientificName" : "Tursiops aduncus",
    "name" : "Tursiops aduncus (Indian Ocean Bottlenose Dolphin)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:aab6d06c-0f49-4567-913b-c29ac529bd3f"
},
﻿{
    "listId" : "",
    "commonName" : "Dwarf Spinner Dolphin",
    "outputSpeciesId" : "",
    "scientificName" : "Stenella longirostris roseiventris",
    "name" : "Stenella longirostris roseiventris (Dwarf Spinner Dolphin)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:b575c0e8-4f68-481d-8314-d13de1584dcf"
},
﻿{
    "listId" : "",
    "commonName" : "Dwarf Sperm Whale",
    "outputSpeciesId" : "",
    "scientificName" : "Kogia sima",
    "name" : "Kogia sima (Dwarf Sperm Whale)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:f130735b-8b94-473a-8e84-bb71cd6dcd3f"
},
﻿{
    "listId" : "",
    "commonName" : "Bottlenose Dolphin",
    "outputSpeciesId" : "",
    "scientificName" : "Tursiops truncatus",
    "name" : "Tursiops truncatus (Bottlenose Dolphin)",
    "guid" : "urn:lsid:biodiversity.org.au:afd.taxon:f2c8b22b-f0b1-45ea-8853-891c4a527293"
}














*/