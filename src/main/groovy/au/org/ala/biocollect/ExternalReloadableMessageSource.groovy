package au.org.ala.biocollect

import org.springframework.context.support.ReloadableResourceBundleMessageSource

import java.time.Duration

/**
 * Message source for bundles installed on the server (for example by the ala-i18n package) and the
 * classpath bundles Grails already listed in {@code spring.messages.basename}.
 *
 * <p>External basenames come first. Spring returns the first match and {@code getMergedProperties}
 * applies basenames in reverse, so an external value replaces a bundled one and a key that exists
 * only in the application is still exported.
 *
 * <p>Defining this bean as {@code messageSource} makes Spring Boot's classpath-only message source
 * back off. Encoding, locale fallback and cache duration are read from {@code spring.messages.*},
 * which is where the Grails i18n plugin publishes them.
 */
class ExternalReloadableMessageSource extends ReloadableResourceBundleMessageSource {

    ExternalReloadableMessageSource(String[] basenames, String encoding, Boolean fallbackToSystemLocale, Duration cacheDuration) {
        setBasenames(basenames)
        setDefaultEncoding(encoding ?: 'UTF-8')
        setFallbackToSystemLocale(fallbackToSystemLocale == null ? false : fallbackToSystemLocale.booleanValue())
        if (cacheDuration != null) {
            setCacheMillis(cacheDuration.toMillis())
        }
    }

    /**
     * External locations first, then each classpath basename. A name that already has a protocol
     * (for example {@code file:} or {@code classpath:}) is kept; every other name is loaded from
     * the classpath.
     */
    static String[] basenames(List<String> externalBasenames, String bundledBasenames) {
        List<String> names = []
        externalBasenames?.each { String name ->
            String trimmed = name?.trim()
            if (trimmed) {
                names << trimmed
            }
        }
        (bundledBasenames ?: '').split(',').each { String name ->
            String trimmed = name.trim()
            if (trimmed) {
                names << (trimmed.contains(':') ? trimmed : "classpath:${trimmed}")
            }
        }
        names as String[]
    }

    /**
     * Spring only consults {@code getMergedProperties} while caching forever, and that result is
     * itself cached forever. A finite {@code spring.messages.cache-duration} has to rebuild the
     * export from the same per-file cache used for {@code getMessage}, or {@code /home/i18n}
     * would keep the first snapshot.
     */
    @Override
    protected PropertiesHolder getMergedProperties(Locale locale) {
        if (getCacheMillis() < 0) {
            return super.getMergedProperties(locale)
        }
        mergeProperties(collectPropertiesToMerge(locale))
    }
}
