// Karma configuration
// Generated on Thu May 21 2015 09:01:47 GMT+1000 (AEST)

module.exports = function (config) {
    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',

        plugins: [
            'karma-jquery',
            'karma-chrome-launcher',
            'karma-jasmine',
            'karma-jasmine-jquery',
            'karma-coverage',
            'karma-firefox-launcher',
            'karma-phantomjs-launcher'
        ],


        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: [
            'jquery-1.11.0', // Because we are using a grails plugin for jquery it is not easily available via a project path.
            'jasmine-jquery',
            'jasmine'],


        // list of files / patterns to load in the browser
        files: [
            'grails-app/assets/vendor/knockout.js/knockout-3.3.0.min.js',
            'grails-app/assets/vendor/knockout.js/knockout.mapping-latest.js',
            'grails-app/assets/vendor/underscore/underscore-1.8.3.min.js',
            'grails-app/assets/javascripts/knockout-dates.js',
            'grails-app/assets/vendor/wmd/showdown.js',
            'grails-app/assets/vendor/wmd/wmd.js',
            'grails-app/assets/javascripts/document.js',
            'grails-app/assets/vendor/fuse/fuse.min.js',
            'grails-app/assets/javascripts/fieldcapture-application.js',
            'grails-app/assets/javascripts/projects.js',
            'grails-app/assets/vendor/moment/moment.min.js',
            'grails-app/assets/javascripts/organisation.js',
            'grails-app/assets/javascripts/pagination.js',
            'grails-app/assets/javascripts/sites.js',
            '../ecodata-client-plugin/grails-app/assets/vendor/select2/4.0.3/js/select2.full.js',
            '../ecodata-client-plugin/grails-app/assets/vendor/typeahead/0.11.1/bloodhound.js',
            '../ecodata-client-plugin/grails-app/assets/javascripts/speciesModel.js',
            'grails-app/assets/javascripts/projectActivityInfo.js',
            'grails-app/assets/javascripts/projectActivity.js',
            'grails-app/assets/javascripts/projectActivities.js',
            'grails-app/assets/javascripts/aekosWorkflow.js',
            'grails-app/assets/javascripts/aekosWorkflowUtility.js',
            'grails-app/assets/javascripts/speciesFieldsSettings.js',
            'test/js/spec/**/*.js'
        ],


        // list of files to exclude
        exclude: [],


        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors: {},


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['progress', 'coverage'],

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
        browsers: ['Chrome','Firefox','PhantomJS'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: true
    });
};
