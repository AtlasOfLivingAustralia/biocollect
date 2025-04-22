package au.org.ala.biocollect

import spock.lang.Specification

class MarkdownUtilsSpec extends Specification {

    def "markdownToHtmlAndSanitise should convert markdown to HTML and sanitize it"() {
        given:
        String markdown = "# Heading\n\nThis is a [link](http://example.com)."

        when:
        String result = MarkdownUtils.markdownToHtmlAndSanitise(markdown)

        then:
        result == "<h1>Heading</h1>\n<p>This is a <a href=\"http://example.com\" rel=\"nofollow\">link</a>.</p>\n"
    }

    def "markdownToHtmlAndSanitise should remove disallowed tags"() {
        given:
        String markdown = "<script>alert('XSS');</script>"

        when:
        String result = MarkdownUtils.markdownToHtmlAndSanitise(markdown)

        then:
        result == "\n"
    }

    def "markdownToHtmlAndSanitise should allow simple formatting"() {
        given:
        String markdown = "**bold** *italic*"

        when:
        String result = MarkdownUtils.markdownToHtmlAndSanitise(markdown)

        then:
        result == "<p><strong>bold</strong> <em>italic</em></p>\n"
    }

    def "markdownToHtmlAndSanitise should allow text within p and div tags"() {
        given:
        String markdown = "<p>Paragraph</p><div>Division</div>"

        when:
        String result = MarkdownUtils.markdownToHtmlAndSanitise(markdown)

        then:
        result == "<p>Paragraph</p><div>Division</div>\n"
    }
}