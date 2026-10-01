package au.org.ala.biocollect.cache

import org.springframework.cache.annotation.CacheEvict
import org.springframework.cache.annotation.Cacheable

/**
 * Stand-in for plugin services that ship Spring cache annotations.
 */
class SpringAnnotatedCacheProbe {

    int calls

    @Cacheable('springProbeCache')
    String load(String key) {
        calls++
        "spring-$key"
    }

    @CacheEvict(cacheNames = 'springProbeCache', allEntries = true)
    void clear() {
    }
}
