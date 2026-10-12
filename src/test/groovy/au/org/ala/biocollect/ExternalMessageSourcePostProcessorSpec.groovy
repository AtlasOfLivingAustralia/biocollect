package au.org.ala.biocollect

import org.springframework.context.MessageSource
import org.springframework.context.support.StaticMessageSource
import spock.lang.Specification

class ExternalMessageSourcePostProcessorSpec extends Specification {

    File externalDir
    StaticMessageSource bundledMessages

    void setup() {
        externalDir = File.createTempDir("i18n", "")
        new File(externalDir, 'messages.properties').text = 'overridden=External value\n'
        new File(externalDir, 'messages_es.properties').setText('overridden=Valor externo\n', 'UTF-8')

        bundledMessages = new StaticMessageSource()
        bundledMessages.addMessage('overridden', Locale.ENGLISH, 'Bundled value')
        bundledMessages.addMessage('bundledOnly', Locale.ENGLISH, 'Only in the bundle')
    }

    void cleanup() {
        externalDir.deleteDir()
    }

    def "external bundles take precedence and other messages fall back to the original message source"() {
        given:
        ExternalMessageSourcePostProcessor postProcessor = new ExternalMessageSourcePostProcessor(
                basenames: ["file://${new File(externalDir, 'missing').absolutePath}/messages".toString(),
                            "file://${externalDir.absolutePath}/messages".toString()])

        when:
        MessageSource messageSource = (MessageSource) postProcessor.postProcessAfterInitialization(bundledMessages, 'messageSource')

        then:
        messageSource.getMessage('overridden', null, Locale.ENGLISH) == 'External value'
        messageSource.getMessage('overridden', null, new Locale('es')) == 'Valor externo'
        messageSource.getMessage('bundledOnly', null, Locale.ENGLISH) == 'Only in the bundle'
        messageSource.getMessage('notDefined', null, 'default', Locale.ENGLISH) == 'default'
    }

    def "beans other than the message source are left unchanged"() {
        given:
        ExternalMessageSourcePostProcessor postProcessor = new ExternalMessageSourcePostProcessor(
                basenames: ["file://${externalDir.absolutePath}/messages".toString()])

        expect:
        postProcessor.postProcessAfterInitialization(bundledMessages, 'otherMessageSource').is(bundledMessages)
    }
}
