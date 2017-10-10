package au.org.ala.biocollect.merit.metadata


import org.apache.commons.logging.Log
import org.apache.commons.logging.LogFactory

/**
 * Define the set of valid data types for an output & provides a data type based switch to method to help
 * me make sure all valid types are handled when processing output metadata.
 *
 * Copied from ecodata
 */
class OutputModelProcessor {

    static Log log = LogFactory.getLog(OutputModelProcessor.class)

    interface ProcessingContext {}

    interface Processor<T extends ProcessingContext> {
        def number(node, T context)

        def integer(node, T context)

        def text(node, T context)

        def time(node, T context)

        def date(node, T context)

        def image(node, T context)

        def embeddedImages(node, T context)

        def species(node, T context)

        def stringList(node, T context)

        def booleanType(node, T context)

        def document(node, T context)
    }

    def processNode(processor, node, context) {

        def type = node.dataType
        if (type == null) {
            log.warn("Found node with null dataType: "+node)
            return
        }

        switch(type) {
            case 'number':
                processor.number(node, context);
                break;
            case 'integer':
                processor.integer(node, context);
                break;
            case 'time':
                processor.time(node, context);
                break;
            case 'text':
                processor.text(node, context);
                break;
            case 'date':
            case 'simpleDate':
                processor.date(node, context);
                break;
            case 'image':
                processor.image(node, context);
                break;
            case 'embeddedImages':
                processor.embeddedImages(node, context);
                break;
            case 'species':
                processor.species(node, context);
                break;
            case 'stringList':
                processor.stringList(node, context)
                break;
            case 'boolean':
                processor.booleanType(node, context)
                break;
            case 'lookupRange':
            case 'lookupByDiscreteValues': // These types exist in data but are not supported.
                break; // do nothing
            case 'document':
                processor.document(node, context)
                break
            case 'masterDetail':
                break // do nothing, not supported yet
            case 'geoMap':
                break
            case 'set':
                break
            default:
                throw new RuntimeException("Unexpected data type: ${node.dataType}")
        }
    }

    /**
     * Takes an output containing potentially nested values and produces a flat List of stuff.
     * If the output contains more than one set of nested properties, the number of items returned will
     * be the sum of the nested properties - any particular row will only contain values from one of the
     * nested rows.
     * @param output the data to flatten
     * @param outputMetadata description of the output to flatten
     * @param duplicationNonNestedValues true if each item in the returned list contains all of the non-nested data in the output
     */
    List flatten(Map output, OutputMetadata outputMetadata, boolean duplicateNonNestedValues = true) {

        List rows = []

        def flat = output.data?:[:]
        if (duplicateNonNestedValues) {
            flat += output
        }
        def nested = outputMetadata.getNestedPropertyNames()
        if (!nested || !duplicateNonNestedValues) {
            rows << flat
        }
        if (nested) {
            Map toRepeat = duplicateNonNestedValues?flat:getRepeatingData(flat, outputMetadata)
            nested.each { property ->
                Collection nestedData = flat.remove(property)
                nestedData.each { row ->
                    rows << (row + toRepeat)
                }
            }
        }
        rows
    }

    def hideMemberOnlyAttributes(Map output, OutputMetadata outputMetadata, boolean userIsProjectMember = false) {

        if (userIsProjectMember) {
            return
        }

        Map result = output.data?:[:]
        def memberOnly = outputMetadata.getMemberOnlyPropertyNames()
        if (memberOnly && !userIsProjectMember) {
            memberOnly.each { property ->
                result[property] = ''
            }
        }
    }

    Map getRepeatingData(Map data, OutputMetadata outputMetadata) {

        Map result = [:]
        ['text', 'stringList'].each {
            outputMetadata.getNamesForDataType(it, null).each {name, val ->
                if (val == true) {
                    result[name] = data[name]
                }
            }
        }
        result
    }
}
