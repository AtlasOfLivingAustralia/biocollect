package au.org.ala.biocollect

import org.grails.plugin.cache.GrailsCacheManager
import org.springframework.beans.factory.ObjectProvider
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.cache.CacheManager
import org.springframework.cache.annotation.CachingConfigurer
import org.springframework.cache.annotation.EnableCaching
import org.springframework.context.annotation.Configuration

/**
 * Grails {@code @Cacheable} is applied when this application is compiled, so it never
 * reaches plugin classes that were already compiled with Spring's {@code @Cacheable}
 * (images-client {@code SpeciesListWebService}, ala-admin {@code SystemMessageService}).
 * Turn on Spring's cache interceptor and point it at the Ehcache-backed
 * {@code grailsCacheManager} so those plugins share the same store.
 */
@Configuration
@EnableCaching(proxyTargetClass = true)
class SpringCacheConfiguration implements CachingConfigurer {

    @Autowired
    ObjectProvider<GrailsCacheManager> grailsCacheManager

    @Override
    CacheManager cacheManager() {
        grailsCacheManager.getObject()
    }
}
