package au.org.ala.biocollect.merit

import grails.plugin.cache.GrailsConcurrentMapCacheManager
import org.grails.plugin.cache.GrailsCacheManager
import spock.lang.Specification

class CacheServiceSpec extends Specification {

    GrailsCacheManager cacheManager
    CacheService service

    void setup() {
        cacheManager = new GrailsConcurrentMapCacheManager()
        service = new CacheService(grailsCacheManager: cacheManager)
    }

    void "second read is served from the cache"() {
        given:
        int loads = 0

        when:
        def first = service.get('activity-model') {
            loads++
            [name: 'model']
        }
        def second = service.get('activity-model') {
            loads++
            [name: 'other']
        }

        then:
        first == [name: 'model']
        second == [name: 'model']
        loads == 1
        cached(CacheService.REGION, 'activity-model') != null
    }

    void "errors and empty results are not cached"() {
        given:
        int failures = 0
        int empties = 0

        when:
        def failed = service.get('broken') {
            failures++
            throw new IllegalStateException('down')
        }
        service.get('broken') {
            failures++
            throw new IllegalStateException('down')
        }
        def empty = service.get('missing') {
            empties++
            null
        }
        service.get('missing') {
            empties++
            null
        }

        then:
        failed == [error: 'down']
        failures == 2
        empty == null
        empties == 2
        cached(CacheService.REGION, 'broken') == null
        cached(CacheService.REGION, 'missing') == null
    }

    void "an error map is not cached"() {
        given:
        int loads = 0

        when:
        2.times {
            service.get('programs-model') {
                loads++
                [error: 'unavailable']
            }
        }

        then:
        loads == 2
    }

    void "clear forgets one key and clear removes only this region"() {
        given:
        cacheManager.getCache('userDetailsCache').put('user', 'kept')
        service.get('activity-model') { 'model' }
        service.get('programs-model') { 'programs' }

        when:
        service.clear('activity-model')

        then:
        service.get('activity-model') { 'reloaded' } == 'reloaded'
        service.get('programs-model') { 'ignored' } == 'programs'

        when:
        service.clear()

        then:
        service.get('programs-model') { 'reloaded-programs' } == 'reloaded-programs'
        cached('userDetailsCache', 'user') == 'kept'
    }

    void "clearCacheMatchingPattern evicts only matching keys"() {
        given:
        service.get('projects-in-hub-1') { ['a'] }
        service.get('projects-in-hub-2') { ['b'] }
        service.get('activity-model') { 'model' }

        when:
        service.clearCacheMatchingPattern('^projects-in-hub-.+')

        then:
        service.get('projects-in-hub-1') { ['reloaded'] } == ['reloaded']
        service.get('activity-model') { 'ignored' } == 'model'
    }

    private Object cached(String region, String key) {
        cacheManager.getCache(region).get(key)?.get()
    }
}
