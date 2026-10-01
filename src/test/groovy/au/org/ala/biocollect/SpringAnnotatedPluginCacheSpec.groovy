package au.org.ala.biocollect

import au.org.ala.admin.SystemMessageService
import au.org.ala.biocollect.cache.GrailsAnnotatedCacheProbe
import au.org.ala.biocollect.cache.SpringAnnotatedCacheProbe
import grails.plugin.cache.ehcache.GrailsEhcacheCacheManager
import images.client.plugin.SpeciesListWebService
import org.grails.plugin.cache.GrailsCacheManager
import org.springframework.aop.Advisor
import org.springframework.aop.framework.Advised
import org.springframework.aop.support.AopUtils
import org.springframework.cache.annotation.AnnotationCacheOperationSource
import org.springframework.cache.interceptor.CacheInterceptor
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Import
import spock.lang.Specification

class SpringAnnotatedPluginCacheSpec extends Specification {

    AnnotationConfigApplicationContext context

    void setup() {
        context = new AnnotationConfigApplicationContext(PluginCacheTestConfiguration)
    }

    void cleanup() {
        context?.close()
    }

    void "application enables spring caching against the grails cache manager"() {
        expect:
        Application.getAnnotation(Import).value() as List == [SpringCacheConfiguration]
    }

    void "ehcache config gives spring-annotated plugin caches a bounded region"() {
        when:
        String xml = getClass().classLoader.getResource('biocollect-ehcache.xml').text

        then:
        xml.contains('alias="speciesListKvp"')
        xml.contains('alias="systemMessageCache"')
    }

    void "spring and grails annotations share grailsCacheManager"() {
        given:
        GrailsCacheManager cacheManager = context.getBean(GrailsCacheManager)
        SpringAnnotatedCacheProbe springProbe = context.getBean(SpringAnnotatedCacheProbe)
        GrailsAnnotatedCacheProbe grailsProbe = context.getBean(GrailsAnnotatedCacheProbe)

        expect:
        context.getBean(SpringCacheConfiguration).cacheManager().is(cacheManager)

        when:
        String springFirst = springProbe.load('k')
        String springSecond = springProbe.load('k')

        then:
        springFirst == 'spring-k'
        springSecond == 'spring-k'
        springProbe.calls == 1
        cacheManager.getCache('springProbeCache').get('k')?.get() == 'spring-k'

        when:
        springProbe.clear()
        springProbe.load('k')

        then:
        springProbe.calls == 2

        when:
        String grailsFirst = grailsProbe.load('k')
        String grailsSecond = grailsProbe.load('k')

        then:
        grailsFirst == 'grails-k'
        grailsSecond == 'grails-k'
        grailsProbe.calls == 1
        cacheHasEntries(cacheManager, 'grailsProbeCache')

        when:
        grailsProbe.clear()
        grailsProbe.load('k')

        then:
        grailsProbe.calls == 2
    }

    void "plugin services that use spring cache annotations are advised and name their regions"() {
        when:
        SpeciesListWebService speciesList = context.getBean(SpeciesListWebService)
        SystemMessageService systemMessages = context.getBean(SystemMessageService)

        then:
        cacheAdvisorPresent(speciesList)
        cacheAdvisorPresent(systemMessages)
        cacheNames(SpeciesListWebService, 'getPreferredImageSpeciesList') == ['speciesListKvp'] as Set
        cacheNames(SpeciesListWebService, 'saveImageToSpeciesList') == ['speciesListKvp'] as Set
        cacheNames(SystemMessageService, 'getSystemMessage') == ['systemMessageCache'] as Set
        cacheNames(SystemMessageService, 'setSystemMessage') == ['systemMessageCache'] as Set
    }

    private static boolean cacheAdvisorPresent(Object bean) {
        if (!AopUtils.isAopProxy(bean)) {
            return false
        }
        // GroovyObject.getProperty swallows the Advised interface, so call it directly.
        Advisor[] advisors = Advised.getMethod('getAdvisors').invoke(bean) as Advisor[]
        advisors.any { Advisor advisor -> advisor.advice instanceof CacheInterceptor }
    }

    private static Set<String> cacheNames(Class<?> type, String methodName) {
        def source = new AnnotationCacheOperationSource(false)
        def method = type.declaredMethods.find { it.name == methodName }
        assert method != null
        source.getCacheOperations(method, type)*.cacheNames.flatten() as Set
    }

    private static boolean cacheHasEntries(GrailsCacheManager cacheManager, String name) {
        def cache = cacheManager.getCache(name)
        cache != null && cache.nativeCache.iterator().hasNext()
    }

    @Configuration
    @Import(SpringCacheConfiguration)
    static class PluginCacheTestConfiguration {

        @Bean(name = 'grailsCacheManager')
        GrailsEhcacheCacheManager grailsCacheManager() {
            new GrailsEhcacheCacheManager()
        }

        @Bean
        SpringAnnotatedCacheProbe springAnnotatedCacheProbe() {
            new SpringAnnotatedCacheProbe()
        }

        @Bean
        GrailsAnnotatedCacheProbe grailsAnnotatedCacheProbe() {
            new GrailsAnnotatedCacheProbe()
        }

        @Bean
        SpeciesListWebService speciesListWebService() {
            new SpeciesListWebService()
        }

        @Bean
        SystemMessageService systemMessageService() {
            new SystemMessageService()
        }
    }
}
