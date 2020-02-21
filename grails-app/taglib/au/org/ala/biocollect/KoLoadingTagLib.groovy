package au.org.ala.biocollect

/**
 * Tag to wrap a block of KnockoutJS powered code in a div that will display a 'loading' indicator until KnockoutJS has finished processing all its bindings.
 *
 * This prevents unpopulated view components from being displayed before the bindings have been processed.
 *
 * NOTE: This approach is similar to the 'ng-cloak' directive in AngularJS.
 */
class KoLoadingTagLib {
    static namespace = "bc"

    static final String WAIT_INDICATOR = """<div data-bind="visible: false">
    <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
    </div>"""

    // we need to use inline style instead of CSS because Knockout's visible binding uses inline styles, and so will overwrite any css rules.
    // It also triggers 'knockout-visible' event on all children elements of the wrapper 'div'.
    static final String WRAPPER_OPEN = """<div style="display: none" data-bind="visible: function(element){setTimeout(function(){\$(element).children().trigger('knockout-visible')},0); return true}(\$element)">"""
    static final String WRAPPER_CLOSE = "</div>"

    def koLoading = { attrs, body ->
        out << WAIT_INDICATOR
        out << WRAPPER_OPEN
        out << body()
        out << WRAPPER_CLOSE
    }
}
