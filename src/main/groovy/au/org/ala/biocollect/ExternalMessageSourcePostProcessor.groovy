package au.org.ala.biocollect

import org.springframework.beans.factory.config.BeanPostProcessor
import org.springframework.context.MessageSource
import org.springframework.context.support.AbstractApplicationContext
import org.springframework.context.support.ReloadableResourceBundleMessageSource

/**
 * Lets message bundles installed on the server (for example by the ala-i18n package) override the
 * messages bundled with the application and its plugins.
 *
 * Spring Boot's message source only reads classpath bundles, so it is wrapped by a source that reads the
 * external files first and delegates every message they do not define to Boot's source.
 */
class ExternalMessageSourcePostProcessor implements BeanPostProcessor {

    List<String> basenames = []

    @Override
    Object postProcessAfterInitialization(Object bean, String beanName) {
        if (beanName != AbstractApplicationContext.MESSAGE_SOURCE_BEAN_NAME || !(bean instanceof MessageSource)) {
            return bean
        }
        ReloadableResourceBundleMessageSource externalMessageSource = new ReloadableResourceBundleMessageSource()
        externalMessageSource.setBasenames(basenames as String[])
        externalMessageSource.setDefaultEncoding('UTF-8')
        externalMessageSource.setFallbackToSystemLocale(false)
        externalMessageSource.setParentMessageSource((MessageSource) bean)
        externalMessageSource
    }
}
