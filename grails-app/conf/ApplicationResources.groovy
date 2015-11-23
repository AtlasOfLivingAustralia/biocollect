modules = {

    ala2Skin {
        dependsOn 'a-jquery-ui', 'autocomplete', 'bootstrap', 'defaultSkin'
        resource url: 'vendor/bootstrap-combobox/bootstrap-combobox.js'
        resource url: 'css/bootstrap-combobox.css'
        resource url: 'css/common.css'
        resource url: 'css/biocollect-banner.css'
    }

    nrmSkin {
        dependsOn 'application', 'bootstrap_nrm', 'font_awesome_44'
        resource url: [dir: 'css/nrm/css', file: 'screen.css'], attrs: [media: 'screen,print']
        resource url: [dir: 'css/', file: 'capture.css'], plugin: 'fieldcapture-plugin'
        resource url: [dir: 'css/nrm/images/', file: 'AustGovt_inline_white_on_transparent.png'], plugin: 'fieldcapture-plugin'
        resource url: 'css/common.css'
    }

    bootstrap_nrm {
        dependsOn 'app_bootstrap', 'a-jquery-ui'
        resource url: [dir: 'css/nrm/less', file: 'bootstrap.less'], attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print'], bundle: 'bundle_app_bootstrap'
        resource url: 'css/empty.css'

    }

    app_bootstrap_responsive {
        dependsOn 'app_bootstrap'
        resource url: 'css/nrm/less/responsive.less', attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print'], bundle: 'bundle_app_bootstrap_responsive'
        resource url: 'css/empty.css' // needed for less-resources plugin ?
    }

    /** BEGIN - Fildcapture/Marite resources **/
    application {
        dependsOn 'jquery', 'knockout', 'bootbox'
        resource url: "${grailsApplication.config.ala.baseURL ?: 'http://www.ala.org.au'}/wp-content/themes/ala2011/images/favicon.ico", attrs: [type: 'ico'], disposition: 'head'
        resource url: 'vendor/html5/html5.js', wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }, disposition: 'head'
        resource url: 'vendor/vkbeautyfy/vkbeautify.0.99.00.beta.js'
        resource url: 'js/fieldcapture-application.js'
        resource url: 'vendor/jquery.shorten/jquery.shorten.js'
        resource url: 'vendor/jquery.columnizer/jquery.columnizer.js'
        resource url: 'vendor/jquery.blockUI/jquery.blockUI.js'
        resource url: 'vendor/underscore/underscore-1.8.3.min.js'
    }

    defaultSkin {
        dependsOn 'application'
        resource url: 'css/default.skin.css'
    }

    nrmSkin {
        dependsOn 'application', 'app_bootstrap_responsive'
        resource url: 'css/nrm/css/screen.css', attrs: [media: 'screen,print']
        resource url: 'css/capture.css'
        resource url: 'css/nrm/images/AustGovt_inline_white_on_transparent.png'
    }

    wmd {
        resource url: 'vendor/wmd/wmd.css'
        resource url: 'vendor/wmd/showdown.js'
        resource url: 'vendor/wmd/wmd.js'
        resource url: 'vendor/wmd/wmd-buttons.png'

    }

    nrmPrintSkin {
        dependsOn 'nrmSkin'
        resource url: 'css/print.css', attrs: [media: 'screen,print']
    }

    gmap3 {
        resource url: 'vendor/gmap3/gmap3.min.js'
    }

    projectsMap {
        resource url: 'js/projects-map.js'
        resource url: 'js/wms.js'
        resource url: 'vendor/keydragzoom/keydragzoom.js'
    }

    mapWithFeatures {
        resource url: 'js/wms.js'
        resource url: 'js/mapWithFeatures.js'
    }

    knockout {
        resource url: 'vendor/knockout.js/knockout-3.3.0.debug.js'
        resource url: 'vendor/knockout.js/knockout.mapping-latest.js'
        resource url: 'js/knockout-custom-bindings.js'
        resource url: 'js/knockout-custom-extenders.js'
        resource url: 'js/knockout-dates.js'
        resource url: 'js/outputs.js'
    }

    knockout_sortable {
        dependsOn 'knockout'
        resource url: 'vendor/knockout.js/knockout-sortable.min.js'
    }

    jqueryValidationEngine {
        resource url: 'vendor/jquery.validationEngine/jquery.validationEngine.js'
        resource url: 'vendor/jquery.validationEngine/jquery.validationEngine-en.js'
        resource url: 'css/validationEngine.jquery.css'
    }

    datepicker {
        resource url: 'vendor/bootstrap-datepicker/js/bootstrap-datepicker.js'
        resource url: 'vendor/bootstrap-datepicker/css/datepicker.css'
    }

    app_bootstrap {
        dependsOn 'application', 'font_awesome_44'
        resource url: 'vendor/bootstrap/js/bootstrap.min.js'
        // The less css resources plugin (1.3.3, resources plugin 1.2.14) is unable to resolve less files in a plugin so apps that use this plugin must supply their own bootstrap styles.
        // However, commenting this section
        resource url: 'vendor/bootstrap/less/bootstrap.less', attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print'], bundle: 'bundle_app_bootstrap'
        resource url: 'vendor/bootstrap/img/glyphicons-halflings-white.png'
        resource url: 'vendor/bootstrap/img/glyphicons-halflings.png'
        resource url: 'css/empty.css'// needed for less-resources plugin ?
        resource url: 'vendor/bootstrap-combobox/bootstrap-combobox.js'
        resource url: 'css/bootstrap-combobox.css'
    }

    app_bootstrap_responsive {
        dependsOn 'app_bootstrap'
        resource url: 'vendor/bootstrap/less/responsive.less', attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print'], bundle: 'bundle_app_bootstrap_responsive'
        resource url: 'css/empty.css' // needed for less-resources plugin ?
    }

    restoreTab {
        defaultBundle true
        dependsOn 'amplify'
        resource url: 'js/restoreTab.js'
    }

    amplify {
        defaultBundle true
        resource url: 'vendor/amplify/amplify.min.js'
    }

    myActivity {
        defaultBundle 'application'
        dependsOn 'knockout, pagination'
        resource url: 'js/activity.js'
    }

    jstimezonedetect {
        resource url: 'vendor/jstz/jstz.min.js'
    }

    js_iso8601 {
        resource url: 'vendor/js-iso8601/js-iso8601.min.js'
    }

    // name changed since jquery-ui js file should load before bootstrap js file. Otherwise, bootstrap functionality
    // like button toggle does not work. It seems resource plugin is loading resources in alphabetic order.
    'a-jquery-ui' {
        dependsOn 'jquery'

        resource url: '/vendor/jquery-ui/jquery-ui-1.11.2-no-autocomplete.js', disposition: 'head'
        resource url: '/vendor/jquery-ui/themes/smoothness/jquery-ui.css', attrs: [media: 'all'], disposition: 'head'
        resource url: 'vendor/jquery.appear/jquery.appear.js', disposition: 'head'
    }

    jquery_bootstrap_datatable {
        resource url: 'vendor/jquery.dataTables/jquery.dataTables.js'
        resource url: 'vendor/jquery.dataTables/jquery.dataTables.bootstrap.js'
        resource url: 'vendor/dataTables/dataTables.tableTools.min.js'
        resource url: 'css/dataTables.bootstrap.css'
        resource url: 'css/dataTables.tableTools.min.css'
        resource url: 'images/sort_asc.png'
        resource url: 'images/sort_asc_disabled.png'
        resource url: 'images/sort_both.png'
        resource url: 'images/sort_desc.png'
        resource url: 'images/sort_desc_disabled.png'

    }

    drawmap {
        defaultBundle true
        resource url: 'vendor/keydragzoom/keydragzoom.js'
        resource url: 'js/wms.js'
        resource url: 'js/selection-map.js'
    }

    jQueryFileUpload {
        dependsOn 'a-jquery-ui'
        resource url: 'css/jquery.fileupload-ui.css', disposition: 'head'

        resource url: 'vendor/fileupload-9.0.0/load-image.min.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload-process.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload-image.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload-video.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload-validate.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload-audio.js'
        resource url: 'vendor/fileupload-9.0.0/jquery.iframe-transport.js'

        resource url: 'vendor/fileupload-9.0.0/locale.js'
        resource url: 'vendor/cors/jquery.xdr-transport.js',
                wrapper: { s -> "<!--[if gte IE 8]>$s<![endif]-->" }
    }

    jQueryFileUploadUI {
        dependsOn 'jQueryFileUpload'

        resource url: 'vendor/fileupload-9.0.0/jquery.fileupload-ui.js'
        resource url: 'vendor/fileupload-9.0.0/tmpl.js'

    }
    jQueryFileDownload {
        resource url: 'vendor/jquery.filedownload/jQuery.fileDownload.js'
    }

    attachDocuments {
        defaultBundle 'application'
        dependsOn 'jQueryFileUpload'
        resource url: 'js/document.js'
    }

    activity {
        defaultBundle 'application'
        dependsOn 'knockout'
        resource url: 'js/outputs.js'
        resource url: 'js/parser.js'
    }

    pagination {
        defaultBundle 'application'
        resource url: 'js/pagination.js'
    }

    jqueryGantt {
        resource url: 'vendor/jquery-gantt/css/style.css'
        resource url: 'css/gantt.css'
        resource url: 'vendor/jquery-gantt/js/jquery.fn.gantt.js'
        resource url: 'vendor/jquery-gantt/img/grid.png'
        resource url: 'vendor/jquery-gantt/img/icon_sprite.png'
        resource url: 'vendor/jquery-gantt/img/slider_handle.png'

    }

    projects {
        defaultBundle 'application'
        dependsOn 'knockout', 'attachDocuments', 'wmd', 'responsiveTable'
        resource url: 'js/projects.js'
        resource url: 'js/sites.js'
        resource url: 'vendor/moment/moment.min.js'
        resource url: 'css/surveys.css'
    }

    projectFinder {
        dependsOn('knockout', 'projects','bootstrap', 'responsiveTable')
        resource url: 'js/button-toggle-events.js'
        resource url: 'js/project-finder.js'
        resource url: 'css/project-finder.css'
    }

    responsiveTable{
        resource url: 'vendor/responsive/js/responsive.core.js'
        resource url: 'vendor/responsive/js/responsive.tablelist.js'
        resource url: 'vendor/responsive/css/responsive.tablelist.css'
    }

    jquery_cookie {
        defaultBundle 'application'
        dependsOn 'jquery'
        resource url: 'vendor/jquery.cookie/jquery.cookie.js'
    }

    projectActivity {
        defaultBundle 'application'
        dependsOn 'knockout', 'projectActivityInfo', 'species'
        resource url: 'js/projectActivity.js'
    }

    projectActivityInfo {
        defaultBundle 'application'
        dependsOn 'knockout'
        resource url: 'js/projectActivityInfo.js'
    }

    species {
        defaultBundle 'application'
        dependsOn 'knockout'
        resource url: 'js/speciesModel.js'
    }

    imageViewer {
        dependsOn 'viewer', 'jquery'
        resource url: 'vendor/fancybox/jquery.fancybox.js'
        resource url: 'vendor/fancybox/jquery.fancybox.css?v=2.1.5'
        resource url: 'vendor/fancybox/fancybox_overlay.png'
        resource url: 'vendor/fancybox/fancybox_sprite.png'
        resource url: 'vendor/fancybox/fancybox_sprite@2x.png'
        resource url: 'vendor/fancybox/blank.gif'
        resource url: 'vendor/fancybox/fancybox_loading@2x.gif'
    }

    fuelux {
        dependsOn 'app_bootstrap_responsive'
        resource url: 'vendor/fuelux/js/fuelux.min.js'
        resource url: 'vendor/fuelux/css/fuelux.min.css'

    }

    fuseSearch {
        dependsOn 'jquery'
        resource url: 'vendor/fuse/fuse.min.js'
    }

    wizard {
        dependsOn 'app_bootstrap_responsive'
        resource url: 'vendor/fuelux/js/wizard.js'
        resource url: 'vendor/fuelux/css/fuelux.min.css'
    }

    organisation {
        defaultBundle 'application'
        dependsOn 'jquery', 'knockout', 'wmd'
        resource url: 'js/organisation.js'
    }

    slickgrid {
        dependsOn 'jquery', 'a-jquery-ui'
        resource url: 'vendor/slickgrid/slick.grid.css'
        //resource 'slickgrid/slick-default-theme.css'
        //resource 'slickgrid/css/smoothness/jquery-ui-1.8.16.custom.css'
        //resource 'slickgrid/examples.css'

        resource url: 'vendor/slickgrid/lib/jquery.event.drag-2.2.js'
        resource url: 'vendor/slickgrid/lib/jquery.event.drop-2.2.js'

        resource url: 'vendor/slickgrid/slick.core.js'
        resource url: 'vendor/slickgrid/slick.dataview.js'
        //resource 'slickgrid/plugins/slick.cellcopymanager.js'
        //resource 'slickgrid/plugins/slick.cellrangedecorator.js'
        //resource 'slickgrid/plugins/slick.cellrangeselector.js'
        //resource 'slickgrid/plugins/slick.cellselectionmodel.js'


        resource url: 'vendor/slickgrid/slick.formatters.js'
        resource url: 'vendor/slickgrid/slick.editors.js'

        resource url: 'vendor/slickgrid/slick.grid.js'

        resource url: 'vendor/slickgrid.support/slickgrid.support.js'

        resource url: 'vendor/slickgrid/images/header-columns-bg.gif'
        resource url: 'vendor/slickgrid/images/header-columns-over-bg.gif'


    }

    pretty_text_diff {
        resource url: 'vendor/prettytextdiff/jquery.pretty-text-diff.min.js'
        resource url: 'vendor/prettytextdiff/diff_match_patch.js'
        resource url: 'vendor/prettytextdiff/pretty_text_diff_basic.css'
    }

    leaflet {
        resource url: 'vendor/leaflet/0.7.3/leaflet.js'
        resource url: 'vendor/leaflet/0.7.3/leaflet.css'
    }

    font_awesome_44 {
        resource url: 'vendor/font-awesome/4.4.0/css/font-awesome.min.css', attrs: [media: 'all']
    }
    /** END - Fildcapture/Marite resources **/

    comments {
        dependsOn 'knockout'
        resource url: 'css/comment.css'
        resource url: 'js/comment.js'
    }

    zip {
        resource url: "vendor/lz-string-1.4.4/lz-string.min.js"
    }
}
