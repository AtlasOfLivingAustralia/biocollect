package au.org.ala.biocollect.merit

import grails.test.mixin.TestFor
import spock.lang.Specification

@TestFor(FCTagLib)
class FCTagLibSpec extends Specification {

    void "siteFacet should output a label and facet value when the value is a String"() {
        setup:
        Map site = [extent:[geometry:[state:'ACT']]]

        expect:
        applyTemplate('<fc:siteFacet site="${site}" facet="state" />', [site:site]) == "<dt>state</dt>\n<dd>ACT</dd>"
    }

    void "siteFacet should output a label and comma separated facet value when the value is a List"() {
        setup:
        Map site = [extent:[geometry:[state:['ACT', 'NSW']]]]

        expect:
        applyTemplate('<fc:siteFacet site="${site}" facet="state" />', [site:site]) == "<dt>state</dt>\n<dd>ACT, NSW</dd>"
    }

    void "the max attribute of the siteFacet tag should limit the number of values rendered when the value is a List"() {
        setup:
        Map site = [extent:[geometry:[state:['ACT', 'NSW', 'Unused', 'Unused']]]]

        expect:
        applyTemplate('<fc:siteFacet site="${site}" facet="state" max="2" />', [site:site]) == "<dt>state</dt>\n<dd>ACT, NSW</dd>"
    }

    void "specifying a max attribute greater than the size of the siteFacet tag should limit the number of values rendered when the value is a List"() {
        setup:
        Map site = [extent:[geometry:[state:['ACT', 'NSW']]]]

        expect:
        applyTemplate('<fc:siteFacet site="${site}" facet="state" max="10" />', [site:site]) == "<dt>state</dt>\n<dd>ACT, NSW</dd>"
    }

    void "the label attribute of the siteFacet tag should optionally override the facet name"() {
        setup:
        Map site = [extent:[geometry:[state:['ACT', 'NSW', 'Unused', 'Unused']]]]

        expect:
        applyTemplate('<fc:siteFacet site="${site}" facet="state" max="2" label="State"/>', [site:site]) == "<dt>State</dt>\n<dd>ACT, NSW</dd>"
    }

    void "if there is no value for the facet nothing should be rendered"() {
        setup:
        Map site = [extent:[geometry:[state:['ACT', 'NSW', 'Unused', 'Unused']]]]

        expect:
        applyTemplate('<fc:siteFacet site="${site}" facet="nrm" max="2" label="State"/>', [site:site]) == ""
    }

}
