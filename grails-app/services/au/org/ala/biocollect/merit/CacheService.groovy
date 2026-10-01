package au.org.ala.biocollect.merit

import grails.converters.JSON
import grails.plugin.cache.GrailsCache
import org.grails.plugin.cache.GrailsCacheManager

/**
 * Caches service responses in the Ehcache region {@code serviceResponseCache}.
 * Callers pass a closure that loads the value on a miss.
 */
class CacheService {

    static final String REGION = 'serviceResponseCache'

    def grailsApplication
    GrailsCacheManager grailsCacheManager

    /**
     * Returns the cached result for {@code key} when it is still within {@code maxAgeInDays}.
     * Otherwise calls {@code source} and caches a successful result.
     */
    def get(String key, Closure source, int maxAgeInDays = 1) {
        def cache = region()
        def hit = cache.get(key)
        if (hit != null) {
            CachedValue cached = hit.get() as CachedValue
            if (cached?.value && !new Date().after(cached.storedAt + maxAgeInDays)) {
                return cached.value
            }
        }

        def results
        try {
            results = source.call()
            if (cacheable(results)) {
                cache.put(key, new CachedValue(value: results, storedAt: new Date()))
            }
        } catch (Exception e) {
            results = [error: e.message]
        }
        return results
    }

    def isError(results) {
        return (results instanceof Map) ? results['error'] : results.hasProperty('error')
    }

    def clear(key) {
        region().evict(key)
    }

    def clear() {
        region().clear()
    }

    def clearCacheMatchingPattern(String pattern) {
        def cache = region()
        if (cache instanceof GrailsCache) {
            ((GrailsCache) cache).getAllKeys().each { key ->
                if (key instanceof String && key.matches(pattern)) {
                    cache.evict(key)
                }
            }
        }
    }

    /**
     * Loads every entry from the configured metadata file into the cache.
     * @param key the entry to return
     */
    def loadStaticCacheFromFile(key) {
        println 'loading static data from file'
        def cache = region()
        def json = new File(grailsApplication.config.getProperty('fieldcapture.data.file') as String).text
        def stored = null
        if (json) {
            JSON.parse(json).each { k, v ->
                def entry = new CachedValue(value: v, storedAt: new Date())
                cache.put(k, entry)
                if (k == key) {
                    stored = v
                }
            }
        }
        return stored
    }

    private org.springframework.cache.Cache region() {
        grailsCacheManager.getCache(REGION)
    }

    private boolean cacheable(results) {
        results && !isError(results)
    }

    static class CachedValue {
        def value
        Date storedAt
    }
}
