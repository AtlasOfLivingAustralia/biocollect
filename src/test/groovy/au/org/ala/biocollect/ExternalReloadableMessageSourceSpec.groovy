package au.org.ala.biocollect

import spock.lang.Specification

import java.time.Duration

class ExternalReloadableMessageSourceSpec extends Specification {

    File externalDir

    void setup() {
        externalDir = File.createTempDir('i18n', '')
        new File(externalDir, 'messages.properties').text = 'overridden=External value\n'
        new File(externalDir, 'messages_es.properties').setText('overridden=Valor externo\n', 'UTF-8')
    }

    void cleanup() {
        externalDir.deleteDir()
    }

    def "external basenames precede classpath bundles"() {
        expect:
        ExternalReloadableMessageSource.basenames(
                ['file:/var/messages', '  file:/opt/messages  '],
                ' messages , classpath:already-qualified, plugin.messages ') ==
                ['file:/var/messages', 'file:/opt/messages', 'classpath:messages',
                 'classpath:already-qualified', 'classpath:plugin.messages'] as String[]
    }

    def "a cache duration is applied and a missing duration caches forever"() {
        when:
        ExternalReloadableMessageSource timed = source(['file:/does-not-exist/messages'], Duration.ofSeconds(5))
        ExternalReloadableMessageSource forever = source(['file:/does-not-exist/messages'], null)

        then:
        timed.cacheMillis == 5000L
        forever.cacheMillis == -1L
    }

    def "external bundles take precedence and other messages fall back to the classpath bundle"() {
        given:
        ExternalReloadableMessageSource messageSource = source(
                ["file://${new File(externalDir, 'missing').absolutePath}/messages".toString(),
                 "file://${externalDir.absolutePath}/messages".toString()])

        expect:
        messageSource.getMessage('overridden', null, Locale.ENGLISH) == 'External value'
        messageSource.getMessage('overridden', null, new Locale('es')) == 'Valor externo'
        messageSource.getMessage('bundledOnly', null, Locale.ENGLISH) == 'Only in the bundle'
        messageSource.getMessage('notDefined', null, 'default', Locale.ENGLISH) == 'default'
    }

    def "bulk export includes a bundled-only key when external bundles are absent"() {
        given:
        ExternalReloadableMessageSource messageSource = source(
                ["file://${externalDir.absolutePath}/missing/messages".toString()])

        when:
        Properties exported = messageSource.getMergedProperties(Locale.ENGLISH).properties

        then:
        exported.getProperty('bundledOnly') == 'Only in the bundle'
        exported.getProperty('overridden') == 'Bundled value'
    }

    def "bulk export keeps a bundled-only key when external files override another key"() {
        given:
        ExternalReloadableMessageSource messageSource = source(
                ["file://${externalDir.absolutePath}/messages".toString()])

        when:
        Properties exported = messageSource.getMergedProperties(Locale.ENGLISH).properties

        then:
        exported.getProperty('bundledOnly') == 'Only in the bundle'
        exported.getProperty('overridden') == 'External value'
    }

    def "bulk export includes a bundled-only key when the cache duration is finite"() {
        given:
        ExternalReloadableMessageSource messageSource = source(
                ["file://${externalDir.absolutePath}/missing/messages".toString()], Duration.ofSeconds(5))

        expect:
        messageSource.getMergedProperties(Locale.ENGLISH).properties.getProperty('bundledOnly') == 'Only in the bundle'
    }

    private ExternalReloadableMessageSource source(List<String> externalBasenames, Duration cacheDuration = null) {
        new ExternalReloadableMessageSource(
                ExternalReloadableMessageSource.basenames(externalBasenames, 'au/org/ala/biocollect/externalmessages'),
                'UTF-8',
                false,
                cacheDuration)
    }
}
