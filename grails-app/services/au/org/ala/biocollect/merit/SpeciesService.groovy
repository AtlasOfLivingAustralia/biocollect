package au.org.ala.biocollect.merit

import au.org.ala.ecodata.forms.SpeciesListService
import au.org.ala.ecodata.forms.SpeciesListService.SpeciesListItem
import com.opencsv.CSVParser
import com.opencsv.CSVParserBuilder
import com.opencsv.CSVReader
import com.opencsv.CSVReaderBuilder
import grails.converters.JSON
import grails.plugin.cache.Cacheable

import java.util.zip.ZipEntry
import java.util.zip.ZipFile

class SpeciesService {
    static final String COMMON_NAME = 'COMMONNAME'
    static final String SCIENTIFIC_NAME = 'SCIENTIFICNAME'
    static final String COMMON_NAME_SCIENTIFIC_NAME = 'COMMONNAME(SCIENTIFICNAME)'
    static final String SCIENTIFIC_NAME_COMMON_NAME = 'SCIENTIFICNAME(COMMONNAME)'

    def webService, grailsApplication
    SpeciesListService speciesListService

    def searchForSpecies(searchTerm, limit = 10, listId = null) {

        // Try the project species list first.
        if (listId) {
            def results = filterSpeciesList(searchTerm, listId)
            if (results.count) {
                return results
            }
        }
        def results = searchBie(searchTerm, null, limit)

        // standardise output
        // Handle some unhelpful results from the BIE.
        results?.autoCompleteList?.removeAll { !it.name }

        results?.autoCompleteList?.each { result ->
            result.scientificName = result.name
            if(result.commonName && result.commonName.contains(',')) { // ?. doesn't use groovy truth so throws exception for JSON.NULL
                result.commonName = result.commonName.split(',')[0]
            }
        }

        return results
    }

    /**
     * Query certain fields on species lists and return results in a format compatible with jQuery's autocomplete.
     * @param searchTerm
     * @param speciesConfig
     * @return
     */
    def searchSpeciesInLists(String searchTerm,  Map speciesConfig = [:], limit = 10, offset = 0){
        List druids = speciesConfig.speciesLists?.collect{it.dataResourceUid}
        Map fields = getSpeciesListAutocompleteLookupFields(speciesConfig)
        List listResults = speciesListService.searchSpeciesListOnFields(searchTerm, druids, fields.fieldList, limit, offset)
        formatSpeciesListResultToAutocompleteFormat(listResults, fields.fieldMap)
    }

    /**
     * From the species configuration, find the fields that holds scientific name and common name.
     * @param speciesConfig
     * @return
     */
    Map getSpeciesListAutocompleteLookupFields(Map speciesConfig = [:]){
        String scientificNameField = speciesConfig.scientificNameField?:'matchedName',
            commonNameField = speciesConfig.commonNameField?:'commonName'

        [fieldList: [scientificNameField, commonNameField], fieldMap: [scientificNameField: scientificNameField, commonNameField: commonNameField]]
    }

    /**
     * Transform species list search result. Extract scientific name and common name from the result set. Then, make it
     * jQuery autocomplete compatible.
     * @param queryResult
     * @param fields
     * @return
     */
    Map formatSpeciesListResultToAutocompleteFormat(List queryResult, Map fields){
        List autoCompleteList = queryResult?.collect { SpeciesListItem result ->
            Map searchResult = [id: result.id, guid: result.lsid, lsid: result.lsid, listId: result.dataResourceUid]
            searchResult.scientificName = result.kvpValues?.find { it.key ==  fields.scientificNameField } ?.value ?: result.scientificName
            searchResult.scientificNameMatches = searchResult.scientificName ? [ searchResult.scientificName ] : []
            searchResult.commonName = result.kvpValues?.find { it.key ==  fields.commonNameField } ?.value ?: result.commonName
            searchResult.commonNameMatches = searchResult.commonName ? [ searchResult.commonName ] : []
            searchResult
        }

        [autoCompleteList: autoCompleteList]
    }

    /**
     * Searches for an exact match of scientific name in the BIE and optionally a project list.
     * @param scientificName the scientific name of the taxa to search for.
     * @param listId the list to search if desired.
     * @return the matching taxa, or null if not match was found.
     */
    def searchByScientificName(scientificName, listId = null) {
        def results = searchForSpecies(scientificName, 10, listId)
        return results.autoCompleteList?.find {it.name.equalsIgnoreCase(scientificName)}
    }

    /**
     * Searches each result supplied list to find a name that matches (in a case insensitive manner) the supplied name.
     * This method expects the format of each result to be as returned from the BIE species autocomplete function.
     * @param speciesSearchResults the list of results.
     * @param name the name to match.
     * @return the result that matches the supplied name, or null if no match is found.
     */
    Map findMatch(Map speciesSearchResults, String name) {
        speciesSearchResults?.autoCompleteList?.find { result ->
            (result.name == name || result.matchedNames?.find { matchedName -> name.equalsIgnoreCase(matchedName) })
        }
    }

    /**
     * Searches the "name" returned by the Species List service for the supplied search term and reformats the
     * results to match those returned by the bie.
     * @param query the term to search for.
     * @param listId the id of the list to search.
     * @return a JSON formatted String of the form {"autoCompleteList":[{...results...}]}
     */
    private def filterSpeciesList(String query, String listId) {
        def listContents = speciesListService.allSpeciesListItems(listId, query)

        def filtered = listContents.collect({[id: it.id, listId: listId, name: it.name, commonName: it.commonName, scientificName: it.scientificName, scientificNameMatches:[it.name], guid:it.lsid]})

        def results = [:];
        results.autoCompleteList = filtered
        results.count = filtered.size()

        return results
    }

    def searchBie(searchTerm, fq, limit) {
        if (!limit) {
            limit = 10
        }

        def encodedQuery = URLEncoder.encode(searchTerm ?: '', "UTF-8")
        String url = "${grailsApplication.config.bieWs.baseURL}/ws"
         if (fq) {
            String encodedFacetQuery = URLEncoder.encode(fq, 'UTF-8')
            url += "/search.json?q=${encodedQuery}&fq=${encodedFacetQuery}&pageSize=${limit}"
        }
        else {
            def encodedFq = URLEncoder.encode(fq ?: '', "UTF-8")
            url += "/search/auto.jsonp?q=${encodedQuery}&limit=${limit}&idxType=TAXON"

        }
        webService.getJson(url)
    }

    /**
     * formats a name into the specified format
     * if species does not match to a taxon, then mention it in name.
     * @param displayType
     * @param data
     * @return
     */
    String formatSpeciesName(String displayType, Map data){
        String name
        if(data.guid){
            name = formatTaxonName(data, displayType)
        } else {
            // when no guid, append unmatched taxon string
            name = "${data.rawScientificName?:''} (Unmatched taxon)"
        }

        name
    }

    /** format species by specific type **/
    String formatTaxonName (Map data, String displayType) {
        String name = ''
        switch (displayType){
            case COMMON_NAME_SCIENTIFIC_NAME:
                if (data.commonName && data.scientificName) {
                    name = "${data.commonName} (${data.scientificName})"
                } else if (data.commonName) {
                    name = data.commonName
                } else if (data.scientificName) {
                    name = data.scientificName
                }
                break
            case SCIENTIFIC_NAME_COMMON_NAME:
                if (data.scientificName && data.commonName) {
                    name = "${data.scientificName} (${data.commonName})"
                } else if (data.scientificName) {
                    name = data.scientificName
                } else if (data.commonName) {
                    name = data.commonName
                }
                break
            case COMMON_NAME:
                name = data.commonName ?: data.scientificName ?: ""
                break
            case SCIENTIFIC_NAME:
                name = data.scientificName ?: ""
                break
        }

        name
    }

    Object searchSpeciesForConfig(Map speciesConfig, String q, Integer limit, Integer offset = 0) {
        def result
        switch (speciesConfig?.type) {
            case 'SINGLE_SPECIES':
                result = searchForSpecies(speciesConfig?.singleSpecies?.name, 1)
                break

            case 'ALL_SPECIES':
                result = searchForSpecies(q, limit)
                break

            case 'GROUP_OF_SPECIES':
                result = searchSpeciesInLists(q, speciesConfig, limit, offset)
                break
            default:
                result = [autoCompleteList: []]
                break
        }
        return result
    }

    Map formatSpeciesNameInAutocompleteList(String speciesDisplayFormat, Map data){
        data?.autoCompleteList?.each{
            it.name = formatSpeciesName(speciesDisplayFormat?:'SCIENTIFICNAME(COMMONNAME)', it)
        }

        data
    }

    Map<String,String> addSpeciesList (Map<String,String> postBody) {
        if (speciesListService.checkListAPIVersion(SpeciesListService.LIST_VERSION_V1)) {
            String druid = postBody.druid ?: ""
            return speciesListService.uploadSpeciesListUsingV1(postBody, druid)
        } else {
            List<List> rows = getSpeciesListAsCSV(postBody.listItems as String)
            return speciesListService.uploadSpeciesListUsingV2(rows, postBody.listName, postBody.description, postBody.licence, postBody.listType)
        }
    }

    /**
     * Convert comma seperated species list to a format resembling CSV.
     * @return
     */
    List<List> getSpeciesListAsCSV(String listItems){
        List<List> csv = []
        if (listItems) {
            csv.add(["scientificName"])
            List speciesList = listItems.split(',')?.toList()
            speciesList.each {
                csv.add([it])
            }
        }

        csv
    }

    /**
     * Get species details from BIE for a taxon id
     */
    Map getSpeciesDetailsForTaxonId(String id, Boolean encode = true){
        if(encode){
            id = id.encodeAsURL();
        }

        // While the BIE is in the process of being cut over to the new version we have to handle both APIs.
        def url = "${grailsApplication.config.bieWs.baseURL}/ws/species/${id}.json"
        Map result = webService.getJson(url)

        if (!result || result.error || result.statusCode != 200) {
            url = "${grailsApplication.config.bieWs.baseURL}/ws/species/shortProfile/${id}.json"
            result = webService.getJson(url)
        }

        result
    }

    /**
     * Returns a thumbnail image for the supplied GUID.
     * @param id the species GUID.
     * @return
     */
    String speciesImageThumbnailUrl(String id) {
        Map profile = speciesProfile(id)
        return profile.thumbnail
    }

    Map speciesProfile(String id) {

        // While the BIE is in the process of being cut over to the new version we have to handle both APIs.
        def url = "${grailsApplication.config.bieWs.baseURL}/ws/species/shortProfile/${id}"
        webService.getJson(url)
    }

    Map constructSpeciesFiles (Boolean force = false) {
        def config = grailsApplication.config,
            result
        String taxonFileName = config.getProperty('speciesCatalog.taxonFileName'),
               guidHeaderName = config.getProperty('speciesCatalog.taxon.headerNames.guid'),
               scientificNameHeaderName = config.getProperty('speciesCatalog.taxon.headerNames.scientificName'),
               rankStringHeaderName = config.getProperty('speciesCatalog.taxon.headerNames.rankString'),
               directory = config.getProperty('speciesCatalog.dir'),
               taxonID, commonName
        List<Map<String, String>> scientificNames = []
        File speciesDir = new File(directory)
        // setting force to true will delete all files in the species directory
        // and recreate them from the species catalog zip file
        // otherwise, it will only create the species files if they don't already exist
        if (force) {
            speciesDir.listFiles().each { file ->
                file.delete()
            }
        }
        else {
            if (totalFileExists()) {
                return [success: "Species files already exist"]
            }
        }

        File file = getSpeciesCatalogFile()
        ZipFile zipFile = new ZipFile(file)
        try {
            Map speciesAddedToList = [:]
            def isPreferred
            ZipEntry entry = zipFile.getEntry(taxonFileName)
            List header
            String[] line, previous
            int count = 1, BATCH_SIZE = grailsApplication.config.getProperty('speciesCatalog.batchSize', Integer), page = 1
            int guidIndex, scientificNameIndex, rankStringIndex
            if (entry) {
                InputStream is = zipFile.getInputStream(entry)
                InputStreamReader inputStreamReader = new InputStreamReader(is, "UTF-8")
                CSVParser parser =
                        new CSVParserBuilder()
                                .withSeparator('\t'.toCharacter())
                                .withIgnoreQuotations(true)
                                .build()

                CSVReader csvReader =
                        new CSVReaderBuilder(inputStreamReader)
                                .withCSVParser(parser)
                                .build();
                header = csvReader.readNext()
                guidIndex = header.findIndexOf { it == guidHeaderName }
                rankStringIndex = header.findIndexOf { it == rankStringHeaderName }
                scientificNameIndex = header.findIndexOf { it == scientificNameHeaderName }

                while (line = csvReader.readNext()) {
                    (count, scientificNames, page, speciesAddedToList) = addScientificNameToFile(header, line, count, guidIndex, scientificNames, rankStringIndex, scientificNameIndex, BATCH_SIZE, config, page, commonName, speciesAddedToList)
                }

                if (scientificNames) {
                    saveSpeciesBatchToDisk(config, page, scientificNames)
                }

                csvReader.close()
            }

            String fileName = "${config.getProperty('speciesCatalog.dir')}/total.json"
            new File(fileName).write(([total: page] as JSON).toString())
            result = [success: "constructed species files"]
        }
        catch (Exception ex) {
            result = [error: "Error constructing species files"]
        }
        finally {
            zipFile.close()
        }

        result
    }

    boolean totalFileExists() {
        String fileName = "${grailsApplication.config.getProperty('speciesCatalog.dir')}/total.json"
        new File(fileName).exists()
    }

    List addScientificNameToFile(List header, String[] line, int count, int guidIndex, ArrayList<Map<String, String>> scientificNames, int rankStringIndex, int scientificNameIndex, int BATCH_SIZE, config, int page, String commonName, Map speciesAddedToList = [:]) {
        String taxonID
        String unranked = config.getProperty('speciesCatalog.filters.exclude.unrankedValue')
        try {
            if (header.size() != line.size()) {
                log.error("Error parsing line: ${line} ${count}")
                return [count, scientificNames, page, speciesAddedToList]
            }

            // skip unranked taxa
            if (line[rankStringIndex] == unranked) {
                return [count, scientificNames, page, speciesAddedToList]
            }

            taxonID = line[guidIndex]
            commonName = getCommonName(taxonID)
            String scientificName = line[scientificNameIndex],
                   scientificNameLower = scientificName?.toLowerCase()?.trim()

            if (!speciesAddedToList[scientificNameLower]) {
                scientificNames.add([
                        guid          : taxonID,
                        commonName    : commonName,
                        listId        : "all",
                        rankString    : line[rankStringIndex],
                        scientificName: scientificName,
                        name          : commonName ? "${scientificName} (${commonName})" : scientificName
                ])

                speciesAddedToList[scientificNameLower] = true
                count++

                if (count % BATCH_SIZE == 0) {
                    saveSpeciesBatchToDisk(config, page, scientificNames)
                    scientificNames = []
                    page++
                }
            }
            else {
                log.debug("duplicate found - ${scientificName}")
            }
        } catch (Exception ex) {
            log.error("Error parsing line: ${line} ${count}")
        }

        [count, scientificNames, page, speciesAddedToList]
    }

    public void saveSpeciesBatchToDisk(config, int page, ArrayList<Map<String, String>> scientificNames) {
        String fileName = "${config.getProperty('speciesCatalog.dir')}/${page}.json"
        new File(fileName).write((scientificNames as JSON).toString())
    }

    String getCommonName(String guid) {
        Map commonNames = getVernacularNamesGroupedByTaxonId()
        commonNames[guid]?.size() > 0 ? commonNames[guid][0]?.vernacularName : ""
    }

    @Cacheable("vernacularNamesGroupedByTaxonId")
    Map getVernacularNamesGroupedByTaxonId () {
        def config = grailsApplication.config
        Map<String, List<Map<String, String>>> vernacularNames = [:].withDefault {[]}
        File file = getSpeciesCatalogFile()
        ZipFile zipFile = new ZipFile(file)
        String vernacularFileName = grailsApplication.config.getProperty('speciesCatalog.vernacularFileName'),
            taxonIDHeaderName = config.getProperty('speciesCatalog.vernacular.headerNames.taxonID'),
            vernacularHeaderName = config.getProperty('speciesCatalog.vernacular.headerNames.vernacularName'),
            languageHeaderName = config.getProperty('speciesCatalog.vernacular.headerNames.language'),
            preferredHeaderName = config.getProperty('speciesCatalog.vernacular.headerNames.preferred'),
            languageFilter = config.getProperty("speciesCatalog.filters.language"),
            taxonID
        def isPreferred
        ZipEntry entry = zipFile.getEntry(vernacularFileName)
        List header
        String[] line, previous
        int count = 1
        int taxonIDIndex, vernacularNameIndex, languageIndex, preferredIndex
        if (entry) {
            InputStream is = zipFile.getInputStream(entry)
            InputStreamReader inputStreamReader = new InputStreamReader(is, "UTF-8")
            CSVParser parser =
                    new CSVParserBuilder()
                            .withSeparator('\t'.toCharacter())
                            .withIgnoreQuotations(true)
                            .build()
            CSVReader csvReader =
                    new CSVReaderBuilder(inputStreamReader)
                            .withCSVParser(parser)
                            .build();
            header = csvReader.readNext()
            taxonIDIndex = header.findIndexOf { it == taxonIDHeaderName }
            vernacularNameIndex = header.findIndexOf { it == vernacularHeaderName }
            languageIndex = header.findIndexOf { it == languageHeaderName }
            preferredIndex = header.findIndexOf { it == preferredHeaderName }

            while (line = csvReader.readNext()) {
                count ++
                try {
                    if (header.size() != line.size()) {
                        log.error ("Error parsing line: ${line} ${count}")
                        continue
                    }

                    taxonID = line[taxonIDIndex]
                    isPreferred = line[preferredIndex] ?: "true"
                    isPreferred = Boolean.parseBoolean(isPreferred)
                    if (languageFilter.equals(line[languageIndex])  && isPreferred) {
                        vernacularNames[taxonID].add([
                                taxonID       : taxonID,
                                vernacularName: line[vernacularNameIndex],
                                language      : line[languageIndex],
                                preferred     : line[preferredIndex]
                        ])
                    }
                } catch (Exception ex) {
                    log.error("Error parsing line: ${line} ${count}")
                }

                previous = line
            }

            csvReader.close()
        }

        zipFile.close()
        vernacularNames
    }

    File getSpeciesCatalogFile() {
        String url = grailsApplication.config.getProperty('speciesCatalog.url')
        String directory = grailsApplication.config.getProperty('speciesCatalog.dir')
        String fileName = grailsApplication.config.getProperty('speciesCatalog.fileName')
        String saveFileName = directory + File.separator + fileName
        File dir = new File(directory)
        if (!dir.exists()) {
            dir.mkdirs()
        }

        File file = new File(saveFileName)
        if (!file.exists()) {
            downloadFile(url, saveFileName)
        }

        file
    }

    static void downloadFile(String fileURL, String saveFilePath) throws IOException {
        URL url = new URL(fileURL);
        try (InputStream inputStream = url.openStream();
             BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream);
             FileOutputStream fileOutputStream = new FileOutputStream(saveFilePath)) {

            byte[] dataBuffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = bufferedInputStream.read(dataBuffer, 0, 1024)) != -1) {
                fileOutputStream.write(dataBuffer, 0, bytesRead);
            }
        }
    }
}
