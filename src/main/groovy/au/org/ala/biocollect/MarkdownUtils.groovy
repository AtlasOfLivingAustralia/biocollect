package au.org.ala.biocollect

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import org.commonmark.parser.Parser
import org.commonmark.renderer.html.HtmlRenderer
import org.owasp.html.HtmlChangeListener
import org.owasp.html.HtmlPolicyBuilder
import org.owasp.html.PolicyFactory
import org.owasp.html.Sanitizers

@CompileStatic
@Slf4j
class MarkdownUtils {

    /** Allow simple formatting, links and text within p and divs by default */
    static PolicyFactory policy = (Sanitizers.FORMATTING & Sanitizers.LINKS & Sanitizers.BLOCKS & Sanitizers.IMAGES
            & Sanitizers.TABLES & Sanitizers.STYLES) & new HtmlPolicyBuilder().allowTextIn("p", "div").toFactory()

    static String markdownToHtml(String text) {
        Parser parser = Parser.builder().build()
        org.commonmark.node.Node document = parser.parse(text)
        HtmlRenderer renderer = HtmlRenderer.builder().build()
        String html = renderer.render(document)

        html
    }

    static String markdownToHtmlAndSanitise(String text) {
        Parser parser = Parser.builder().build()
        org.commonmark.node.Node document = parser.parse(text)
        HtmlRenderer renderer = HtmlRenderer.builder().build()
        String html = renderer.render(document)

        internalSanitise(policy, html)
    }

    private static String internalSanitise(PolicyFactory policyFactory, String input, String imageId = '', String metadataName = '') {
        policyFactory.sanitize(input, new HtmlChangeListener<Object>() {
            void discardedTag(Object context, String elementName) {
                log.warn("Dropping element $elementName in $imageId.$metadataName")
            }
            void discardedAttributes(Object context, String tagName, String... attributeNames) {
                log.warn("Dropping attributes $attributeNames from $tagName in $imageId.$metadataName")
            }
        }, null)
    }

}