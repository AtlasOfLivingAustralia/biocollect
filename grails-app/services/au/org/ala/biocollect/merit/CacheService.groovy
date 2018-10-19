package au.org.ala.biocollect.merit
import grails.converters.JSON
/**
 * Handles caching of service responses (after transforming).
 * Uses passed closures to handle service requests - so remains independent
 * of the source of information.
 * Implements the info source for 'static' data read from a config file.
 */
class CacheService {

    def grailsApplication
    static cache = [:]
    private static final Object LOCK_1 = new Object() {};

    /**
     * Returns the cached results for the specified key if available and fresh
     * else calls the passed closure to get the results (and cache them).
     * @param key for cache storage
     * @param source closure to retrieve the results if required
     * @param maxAgeInDays the maximum age of the cached results
     * @return the results
     */
    def get(String key, Closure source, int maxAgeInDays = 1) {
        def cached = cache[key]
        if (cached && cached.resp && !(new Date().after(cached.time + maxAgeInDays))) {
            return cached.resp
        }
        //log.debug "retrieving " + key
        def results
        try {
            results = source.call()
            // only cache if there is no error returned
            if (!isError(results)) {
                synchronized (LOCK_1) {
                    cache.put key, [resp: results, time: new Date()]
                }
            }
        } catch (Exception e) {
            results = [error: e.message]
        }
        return results
    }

    def isError(results) {
        return (results instanceof Map)?results['error']:results.hasProperty('error')
    }

    def clear(key) {
        cache[key]?.resp = null
    }

    def clear() {
        cache = [:]
    }

    def clearCacheMatchingPattern (String pattern) {
        cache.each { String key, value ->
            if ( key.matches(pattern) ) {
                cache[key].resp = null
            }
        }
    }

    /**
     * Info provider based on an external metadata file.
     * Loading any key will load results for all keys in the file.
     * @param key the type of info requested
     * @return
     */
    def loadStaticCacheFromFile(key) {
        println 'loading static data from file'
        def json = new File(grailsApplication.config.fieldcapture.data.file as String).text
        if (json) {
            JSON.parse(json).each { k,v ->
                cache.put k, [resp: v, time: new Date()]
            }
        }
        return cache[key]?.resp
    }
}
