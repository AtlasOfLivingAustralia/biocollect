package au.org.ala.biocollect.cache

import grails.plugin.cache.CacheEvict
import grails.plugin.cache.Cacheable

/**
 * Compiled with the Grails cache transform so tests can show application
 * {@code @Cacheable} methods store entries in {@code grailsCacheManager}.
 */
class GrailsAnnotatedCacheProbe {

    int calls

    @Cacheable('grailsProbeCache')
    String load(String key) {
        calls++
        "grails-$key"
    }

    @CacheEvict(value = 'grailsProbeCache', allEntries = true)
    void clear() {
    }
}
