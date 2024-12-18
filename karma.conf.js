// Karma configuration
// Generated on Thu May 21 2015 09:01:47 GMT+1000 (AEST)

module.exports = function (config) {
    var sourcePreprocessors = ['coverage'];
    var reporters = ['progress', 'coverage', 'verbose'];

    function isDebug(argument) {
        return argument === '--debug';
    }
    if (process.argv.some(isDebug)) {
        sourcePreprocessors = [];
        reporters = ['progress'];
    }

    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',

        plugins: ['@metahub/karma-jasmine-jquery', 'karma-*', 'karma-verbose-reporter'],
        htmlReporter: {
            outputFile: 'tests/units.html'
        },

        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: [
            'jquery-3.3.1', // Because we are using a grails plugin for jquery it is not easily available via a project path.
            'jasmine-jquery',
            'jasmine'],


        // list of files / patterns to load in the browser
        files: [
            'grails-app/assets/vendor/knockout/3.4.0/knockout-3.4.0.js',
            'grails-app/assets/vendor/knockout.js/knockout.mapping-latest.js',
            'grails-app/assets/vendor/underscore/underscore-1.8.3.min.js',
            'grails-app/assets/vendor/bootstrap4/js/bootstrap.bundle.min.js',
            'grails-app/assets/vendor/bootbox/bootbox.min.js',
            'node_modules/jasmine-ajax/lib/mock-ajax.js',
            'grails-app/assets/javascripts/knockout-dates.js',
            'grails-app/assets/vendor/wmd/showdown.js',
            'grails-app/assets/vendor/wmd/wmd.js',
            'grails-app/assets/javascripts/document.js',
            'grails-app/assets/vendor/fuse/fuse.min.js',
            'grails-app/assets/javascripts/fieldcapture-application.js',
            'grails-app/assets/javascripts/EmailViewModel.js',
            'grails-app/assets/javascripts/projects.js',
            'grails-app/assets/vendor/moment/moment.min.js',
            'grails-app/assets/javascripts/organisation.js',
            'grails-app/assets/javascripts/pagination.js',
            'grails-app/assets/javascripts/sites.js',
            'grails-app/assets/javascripts/activity.js',
            'grails-app/assets/javascripts/biocollect-utils.js',
            'grails-app/assets/javascripts/pwa-index.js',
            'node_modules/leaflet/dist/leaflet.js',
            'grails-app/assets/vendor/leaflet-plugins-2.0.0/layer/tile/Google.js',
            'grails-app/assets/javascripts/MapUtilities.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/vendor/expr-eval/2.0.2/bundle.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin@feature/cognito/grails-app/assets/javascripts/images.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/vendor/select2/4.0.3/js/select2.full.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/vendor/typeahead/0.11.1/bloodhound.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/vendor/expr-eval/2.0.2/bundle.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/javascripts/forms.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/javascripts/speciesModel.js',
            'https://cdn.jsdelivr.net/gh/AtlasOfLivingAustralia/ecodata-client-plugin/grails-app/assets/javascripts/forms.js',
            'grails-app/assets/javascripts/projectActivityInfo.js',
            'grails-app/assets/javascripts/projectActivity.js',
            'grails-app/assets/javascripts/projectActivities.js',
            'grails-app/assets/javascripts/aekosWorkflow.js',
            'grails-app/assets/javascripts/aekosWorkflowUtility.js',
            'grails-app/assets/javascripts/speciesFieldsSettings.js',
            'grails-app/assets/vendor/moment/moment-timezone-with-data.min.js',
            'grails-app/assets/vendor/moment/moment.min.js',
            'grails-app/assets/vendor/amplify/amplify.min.js',
            'grails-app/assets/javascripts/facets.js',
            'grails-app/assets/javascripts/chartjsManager.js',
            'grails-app/assets/components/components.js',
            'grails-app/assets/components/compile/*.js',
            'grails-app/assets/components/javascript/*.js',
            'src/test/js/spec/**/*.js'
        ],


        // list of files to exclude
        exclude: [],


        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors: {
            'grails-app/assets/javascripts/*.js':sourcePreprocessors
        },


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: reporters,

        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: ['Chrome'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: true,
        coverageReporter: {
            'dir':'./target',
            'type':"text",
            check: {
                global: {
                    lines: 10
                }
            }
        },
    });
};
