package au.org.ala.biocollect.merit

/**
 * Canonical Creative Commons licences used in BioCollect.
 * Entries are ordered from most to least permissive, matching
 * https://creativecommons.org/cc-licenses/ (CC0 is more open than the six
 * CC licences, so it is first among current entries). Older URLs are retained
 * so existing surveys continue to display; they are not offered for new surveys.
 * {@code icons} are the official CC icon SVG filenames (without extension)
 * from https://creativecommons.org/mission/downloads/
 */
class LicenceService {

    private static final List LICENCES = [
            licence(
                    code: 'CC0',
                    speciesListValue: 'CC0',
                    url: 'https://creativecommons.org/publicdomain/zero/1.0/',
                    icons: ['cc', 'zero'],
                    description: 'CC0 1.0',
                    name: 'Creative Commons Zero 1.0',
                    aliases: ['Creative Commons Zero', 'Creative Commons Attribution 0'],
                    survey: true, photoPoint: true, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY',
                    speciesListValue: 'CC-BY',
                    url: 'https://creativecommons.org/licenses/by/4.0/',
                    icons: ['cc', 'by'],
                    description: 'CC BY 4.0',
                    name: 'Creative Commons Attribution 4.0 International',
                    aliases: ['Creative Commons Attribution'],
                    survey: true, photoPoint: true, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY-SA',
                    speciesListValue: 'CC-BY-SA',
                    url: 'https://creativecommons.org/licenses/by-sa/4.0/',
                    icons: ['cc', 'by', 'sa'],
                    description: 'CC BY-SA 4.0',
                    name: 'Creative Commons Attribution-Share Alike 4.0 International',
                    aliases: ['Creative Commons Attribution-Share Alike'],
                    survey: true, photoPoint: true, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY-ND',
                    speciesListValue: 'CC-BY-ND',
                    url: 'https://creativecommons.org/licenses/by-nd/4.0/',
                    icons: ['cc', 'by', 'nd'],
                    description: 'CC BY-ND 4.0',
                    name: 'Creative Commons Attribution-NoDerivatives 4.0 International',
                    aliases: ['Creative Commons Attribution-Noderivatives'],
                    survey: false, photoPoint: false, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY-NC',
                    speciesListValue: 'CC-BY-NC',
                    url: 'https://creativecommons.org/licenses/by-nc/4.0/',
                    icons: ['cc', 'by', 'cc-nc'],
                    description: 'CC BY-NC 4.0',
                    name: 'Creative Commons Attribution-Noncommercial 4.0 International',
                    aliases: ['Creative Commons Attribution-Noncommercial'],
                    survey: true, photoPoint: true, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY-NC-SA',
                    speciesListValue: 'CC-BY-NC-SA',
                    url: 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
                    icons: ['cc', 'by', 'cc-nc', 'sa'],
                    description: 'CC BY-NC-SA 4.0',
                    name: 'Creative Commons Attribution-Noncommercial-Share Alike 4.0 International',
                    aliases: ['Creative Commons Attribution-Noncommercial-Share Alike'],
                    survey: true, photoPoint: true, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY-NC-ND',
                    speciesListValue: 'CC-BY-NC-ND',
                    url: 'https://creativecommons.org/licenses/by-nc-nd/4.0/',
                    icons: ['cc', 'by', 'cc-nc', 'nd'],
                    description: 'CC BY-NC-ND 4.0',
                    name: 'Creative Commons Attribution-Noncommercial-NoDerivatives 4.0 International',
                    aliases: ['Creative Commons Attribution-Noncommercial-Noderivatives'],
                    survey: false, photoPoint: false, speciesList: true, current: true
            ),
            licence(
                    code: 'CC BY-NC',
                    speciesListValue: 'CC-BY-NC',
                    url: 'https://creativecommons.org/licenses/by-nc/3.0/au/',
                    icons: ['cc', 'by', 'cc-nc'],
                    description: 'CC BY-NC 3.0 AU',
                    name: 'Creative Commons Attribution-Noncommercial 3.0 Australia',
                    aliases: [],
                    survey: false, photoPoint: false, speciesList: false, current: false
            ),
            licence(
                    code: 'CC BY-NC',
                    speciesListValue: 'CC-BY-NC',
                    url: 'https://creativecommons.org/licenses/by-nc/2.5/',
                    icons: ['cc', 'by', 'cc-nc'],
                    description: 'CC BY-NC 2.5',
                    name: 'Creative Commons Attribution-Noncommercial 2.5',
                    aliases: [],
                    survey: false, photoPoint: false, speciesList: false, current: false
            ),
    ].asImmutable()

    List licences() {
        LICENCES.collect { new LinkedHashMap(it) }
    }

    List surveyLicences() {
        licences().findAll { it.survey }
    }

    List photoPointLicences() {
        licences().findAll { it.photoPoint }
    }

    List speciesListLicences() {
        licences().findAll { it.speciesList }
    }

    String photoPointHelpText() {
        photoPointLicences().collect { "${it.name} (${it.description})" }.join(', ')
    }

    String codeForName(String license) {
        if (!license) {
            return null
        }
        def all = licences()
        def exact = all.find { it.code == license || it.speciesListValue == license || it.name.equalsIgnoreCase(license) }
        if (exact) {
            return exact.code
        }
        all.find { licence ->
            licence.aliases.any { license.equalsIgnoreCase(it) }
        }?.code
    }

    private static Map licence(Map attrs) {
        attrs.asImmutable()
    }
}
