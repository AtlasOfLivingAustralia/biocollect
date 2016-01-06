package au.org.ala.biocollect

import org.codehaus.groovy.grails.web.json.JSONObject
import org.codehaus.groovy.grails.web.taglib.NamespacedTagDispatcher

public interface ModelWidgetRenderer {

    void renderLiteral(WidgetRenderContext context)
    void renderText(WidgetRenderContext context)
    void renderReadonlyText(WidgetRenderContext context)
    void renderNumber(WidgetRenderContext context)
    void renderBoolean(WidgetRenderContext context)
    void renderTextArea(WidgetRenderContext context)
    void renderSimpleDate(WidgetRenderContext context)
    void renderSelectOne(WidgetRenderContext context)
    void renderSelectMany(WidgetRenderContext context)
    void renderImage(WidgetRenderContext context)
    void renderEmbeddedImage(WidgetRenderContext context)
    void renderEmbeddedImages(WidgetRenderContext context)
    void renderAutocomplete(WidgetRenderContext context)
    void renderFusedAutocomplete(WidgetRenderContext context)
    void renderPhotoPoint(WidgetRenderContext context)
    void renderLink(WidgetRenderContext context)
    void renderDate(WidgetRenderContext context)
    void renderTime(WidgetRenderContext context)
    void renderDocument(WidgetRenderContext context)
    void renderButtonGroup(WidgetRenderContext context)
    void renderGeoMap(WidgetRenderContext context)
}


public class WidgetRenderContext {

    JSONObject model
    String context
    String validationAttr
    Databindings databindAttrs
    AttributeMap attributes
    AttributeMap labelAttributes
    StringWriter writer
    def tagAttrs

    NamespacedTagDispatcher g

    def deferredTemplates = []

    public WidgetRenderContext(JSONObject model, String context, String validationAttr, Databindings databindAttrs, AttributeMap attributes, AttributeMap labelAttributes, NamespacedTagDispatcher g, tagAttrs) {
        this.model = model
        this.context = context
        this.validationAttr = validationAttr
        this.databindAttrs = databindAttrs ?: new Databindings()
        this.attributes = attributes ?: new AttributeMap()
        this.labelAttributes = labelAttributes ?: new AttributeMap()
        this.g = g
        this.tagAttrs = tagAttrs
        writer = new StringWriter()
    }

    public String getSource() {
        return (context ? context + '.' : '') + model.source
    }

    def getInputWidth() {
        return getInputSize(model.width)
    }

    def getInputSize(width) {
        if (!width) { return 'input-small' }
        if (width && width[-1] == '%') {
            width = width - '%'
        }
        switch (width.toInteger()) {
            case 0..10: return 'input-mini'
            case 11..20: return 'input-small'
            case 21..30: return 'input-medium'
            case 31..40: return 'input-large'
            default: return 'input-small'
        }
    }

    public String specialProperties(properties) {
        return properties.collectEntries { entry ->
            switch (entry.getValue()) {
                case "#siteId":
                    entry.setValue(tagAttrs?.site?.siteId)
                    break;
            }
            return entry
        }
    }

    def addDeferredTemplate(name) {
        deferredTemplates.add(name)
    }

}
