modules = {
    ala2Skin {
        dependsOn 'a-jquery-ui', 'autocomplete', 'bootstrap', 'defaultSkin'
        resource url: 'vendor/bootstrap-combobox/bootstrap-combobox.js'
        resource url: 'css/bootstrap-combobox.css'
        resource url: 'css/common.css'
        resource url: 'css/biocollect-banner.css'
    }

    alaSkin {
        dependsOn 'a-jquery-ui', 'autocomplete', 'bootstrap', 'defaultSkin'
        resource url: 'vendor/bootstrap-combobox/bootstrap-combobox.js'
        resource url: 'css/bootstrap-combobox.css'
        resource url: 'css/common.css'
        resource url: 'css/biocollect-banner.css'
    }

    nrmSkin {
        dependsOn 'application', 'bootstrap_nrm', 'font_awesome_44'
        resource url: 'css/nrm/css/screen.css', attrs: [media: 'screen,print']
        resource url: 'css/capture.css'
        resource url: 'css/nrm/images/AustGovt_inline_white_on_transparent.png'
        resource url: 'css/common.css'
    }

    bootstrap_nrm {
        dependsOn 'bootstrap', 'app_bootstrap', 'a-jquery-ui', 'app_bootstrap_responsive_nrm'
        resource url: [dir: 'css/nrm/less', file: 'bootstrap.less'], attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print'], bundle: 'bundle_app_bootstrap'
        resource url: 'css/empty.css'

    }

    app_bootstrap_responsive_nrm {
        dependsOn 'app_bootstrap'
        resource url: 'css/nrm/less/responsive.less', attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print'], bundle: 'bundle_app_bootstrap_responsive'
        resource url: 'css/empty.css' // needed for less-resources plugin ?
    }

    /** BEGIN - Fildcapture/Marite resources **/
    application {
        dependsOn 'jquery', 'knockout', 'bootbox'
        resource url: 'vendor/html5/html5.js', wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }, disposition: 'head'
        resource url: 'vendor/vkbeautyfy/vkbeautify.0.99.00.beta.js'
        resource url: 'js/fieldcapture-application.js'
        resource url: 'vendor/jquery.shorten/jquery.shorten.js'
        resource url: 'vendor/jquery.columnizer/jquery.columnizer.js'
        resource url: 'vendor/jquery.blockUI/jquery.blockUI.js'
        resource url: 'vendor/polyfill/es6-promise.auto.js'
    }

    bootbox {
        resource url: "vendor/bootbox/bootbox.min.js"
    }

    defaultSkin {
        dependsOn 'application'
        resource url: 'css/default.skin.css'
    }

    wmd {
        resource url: 'vendor/wmd/wmd.css'
        resource url: 'vendor/wmd/showdown.js'
        resource url: 'vendor/wmd/wmd.js'
        resource url: 'vendor/wmd/wmd-buttons.png'
        resource url: 'css/wmd-editor.css'
    }

    nrmPrintSkin {
        dependsOn 'nrmSkin'
        resource url: 'css/print.css', attrs: [media: 'screen,print']
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

    timepicker {
        resource url: "vendor/jquery.timeentry.package-2.0.1/jquery.plugin.min.js"
        resource url: "vendor/jquery.timeentry.package-2.0.1/jquery.timeentry.min.js"
        resource url: "vendor/jquery.timeentry.package-2.0.1/jquery.timeentry.css"
    }

    app_bootstrap {
        dependsOn 'application', 'font_awesome_44'
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
        resource url: 'vendor/bootstrap/less/responsive.less', attrs: [rel: "stylesheet/less", type: 'css', media: 'screen,print']
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
        dependsOn 'knockout, pagination'
        resource url: 'js/activity.js'
        resource url: 'js/facets.js'
        resource url: 'css/facets-filter-view.css'
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
        resource url: 'js/meriPlan.js'
        resource url: 'js/risks.js'
        resource url: 'js/works.js'
        resource url: 'js/issues.js'
        resource url: 'js/output-targets.js'
        resource url: 'vendor/moment/moment.min.js'
        resource url: 'vendor/moment/moment-timezone-with-data.min.js'
        resource url: 'css/surveys.css'
        resource url: 'css/project-tile-view.css'
        resource url: 'css/project-map-view.css'
        resource url: 'css/works-project.css'
        resource url: 'css/blog.css'
        resource url: 'js/permissionTable.js'
        resource url: "https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400italic,600,700", attrs:[type:"css"]
        resource url: "https://fonts.googleapis.com/css?family=Oswald:300", attrs:[type:"css"]
    }

    projectFinder {
        dependsOn('knockout', 'projects','bootstrap', 'responsiveTable', 'zip', 'underscore','amplify', 'jqueryValidationEngine')
        resource url: 'js/button-toggle-events.js'
        resource url: 'js/project-finder.js'
        resource url: 'css/project-finder.css'
        resource url: 'js/facets.js'
        resource url: 'css/facets-filter-view.css'
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
        resource url: 'js/aekosWorkflow.js'
        resource url: 'js/aekosWorkflowUtility.js'
        resource url: 'js/aekosPreQualification.js'
        resource url: 'js/projectActivities.js'
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

    speciesFieldsSettings {
        defaultBundle 'application'
        dependsOn 'knockout', 'species'
        resource url: 'js/speciesFieldsSettings.js'
    }

    projectSpeciesFieldsConfiguration {
        defaultBundle 'application'
        dependsOn 'knockout', 'speciesFieldsSettings'
        resource url: 'js/projectSpeciesFieldsConfiguration.js'
        resource url: 'css/projectSpeciesFieldsConfiguration.css'
    }

    "leaflet_0.7.7" {
        resource url: [dir: "vendor/leaflet-0.7.7", file: "leaflet.js", plugin: "ala-map"]
        resource url: [dir: "vendor/leaflet-0.7.7", file: "leaflet.css", plugin: "ala-map"]
    }

    'leaflet-fullscreen' {
        dependsOn 'leaflet_0.7.7'
        resource url: [plugin: "images-client-plugin", dir: 'js/leaflet', file: 'Control.FullScreen.css']
        resource url: [plugin: "images-client-plugin", dir: 'js/leaflet', file: 'Control.FullScreen.js']
    }

    'leaflet-measure' {
        dependsOn 'leaflet_0.7.7'
        resource url: [plugin: "images-client-plugin", dir: 'js/leaflet', file: 'leaflet.measure.js']
        resource url: [plugin: "images-client-plugin", dir: 'js/leaflet', file: 'leaflet.measure.css']
    }

    overrides {
        'leaflet-draw' {
            dependsOn 'leaflet_0.7.7'
        }

        'leaflet-loading' {
            dependsOn 'leaflet_0.7.7'
        }

        'image-viewer' {
            dependsOn 'jquery', 'bootstrap', 'leaflet_0.7.7', 'leaflet-measure', 'leaflet-draw', 'leaflet-loading', 'font-awesome'
        }
        
        map {
            dependsOn "underscore"
            dependsOn "jquery"
            dependsOn "jqueryScrollView"
            dependsOn 'leaflet_0.7.7'
            dependsOn "leaflet_draw"
            dependsOn "leaflet_coords"
            dependsOn "leaflet_easyButton"
            dependsOn "leaflet_geocoder"
            dependsOn "leaflet_cluster"
            dependsOn "leaflet_loading"
            dependsOn "turf"
            dependsOn "custom_controls"
            dependsOn "font-awesome"
            dependsOn "leaflet_sleep"
        }

        custom_controls {
            dependsOn 'leaflet_0.7.7'
        }
        
        leaflet_draw {
            dependsOn 'leaflet_0.7.7'
        }

        leaflet_coords {
            dependsOn 'leaflet_0.7.7'
        }

        leaflet_easyButton {
            dependsOn 'leaflet_0.7.7'
        }

        leaflet_geocoder {
            dependsOn 'leaflet_0.7.7'
        }

        leaflet_cluster {
            dependsOn 'leaflet_0.7.7'
        }

        leaflet_loading {
            dependsOn 'leaflet_0.7.7'
        }

        leaflet_sleep {
            dependsOn 'leaflet_0.7.7'
        }
    }

    imageViewer {
        dependsOn 'image-viewer', 'jquery'
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
        resource url: 'css/organisation.css'
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

    leaflet_google_base {
        resource url: 'vendor/leaflet-plugins-2.0.0/layer/tile/Google.js'
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

    underscore {
        resource url: "vendor/underscore/underscore-1.8.3.min.js"
    }

    mapUtils {
        dependsOn 'map' // from the ala-map plugin
        defaultBundle 'application'
        resource url: 'js/MapUtilities.js'
    }

    siteSelection {
        resource url: "js/siteSelection.js"
        resource url: "css/siteSelection.css"
    }

    siteDisplaysiteDispl {
        resource url: "js/siteDisplay.js"
    }
    
    activities{
        resource url: 'css/activities.css'
        resource url: 'css/map.css'
    }

    largeCheckbox{
        resource url: 'vendor/large-checkbox/large-checkbox.css'
    }

    audio {
        dependsOn "modernizr"
        resource url: 'js/audio.js'
        resource url: 'css/audio-control.css'
        resource url: 'vendor/recorderjs/recorder.js'
    }

    modernizr {
        resource url: "vendor/modernizr/modernizr-custom.js"
    }

    imageDataType{
        resource url: 'js/images.js'
        resource url: 'css/images.css'
    }

    photoPoint {
        dependsOn ('attachDocuments', 'imageDataType')
        resource url: 'js/photoPoint.js'
    }

    admin {
        resource url: 'js/hubs.js'
        resource url: 'css/admin.css'
    }

    imageGallery{
        dependsOn('imageViewer','knockout')
        resource url: 'css/image-gallery.css'
        resource url: 'js/fieldcapture-application.js'
        resource url: 'js/images.js'
        resource url: 'js/image-gallery.js'
    }

    projectDaysToGo {
        resource url: 'css/project-daystogo.css'
    }
    sites{
        dependsOn('imageViewer', 'font_awesome_44', 'projectActivityInfo', 'myActivity', 'knockout')
        resource url: 'css/sites.css'
        resource url: 'css/horizontal-scroll-list.css'
        resource url: 'vendor/vkbeautyfy/vkbeautify.0.99.00.beta.js'
        resource url: 'js/fieldcapture-application.js'
        resource url: 'js/images.js'
        resource url: 'js/poi-gallery.js'
    }

    siteSearch{
        dependsOn('mapUtils','map')
        resource url: 'css/sites-list.css'
        resource url: 'js/pagination.js'
        resource url: 'js/sites-list.js'
    }

    responsiveTableStacked{
        resource url: 'vendor/responsive-table-stacked/stacked.css'
        resource url: 'vendor/responsive-table-stacked/stacked.js'
    }

    mdba {
        dependsOn 'bootstrap','font_awesome_44', 'a-jquery-ui', 'autocomplete', 'bootstrap', 'defaultSkin'
        resource url: 'vendor/bootstrap-combobox/bootstrap-combobox.js'
        resource url: 'css/bootstrap-combobox.css'
        resource url: 'css/common.css'
        resource url: [dir:'css', file:'Common_fonts.css']
        resource url: [dir:'css', file:'mdba-styles.css']
    }

    viewmodels {
        resource url: 'js/viewModels.js'
        resource url: 'js/modals.js'
    }

    configHubTemplate1 {
        dependsOn 'ala', 'font_awesome_44', 'a-jquery-ui', 'autocomplete', 'bootstrap', 'defaultSkin'
        resource url: 'vendor/bootstrap-combobox/bootstrap-combobox.js'
        resource url: 'css/bootstrap-combobox.css'
        resource url: 'css/common.css'
        resource url: [dir: 'css', file: 'Common_fonts.css']
    }
    mobile{
        resource url: 'css/mobile_activity.css'
    }

    // This module is used by ala-bootstrap2 plugin. Removed application.js file from module.
    core {
        dependsOn 'jquery', 'autocomplete'
        resource url:[plugin: 'ala-bootstrap2', dir: 'js',file:'html5.js'], wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }
    }
}
