const path = require('node:path');
const sharedConfig = require('./wdio.shared.conf.js').config;

const config = {
    ...sharedConfig,
    ...{
        // specs: [
        //     './src/test/js/integration/specs/pwa/InstallationSpec.js'
        // ],
        maxInstances: 1,
        // services: ['devtools'],
        capabilities: [{
            browserName: 'chrome',
            'goog:chromeOptions': {
                // args: ['--auto-open-devtools-for-tabs','disable-gpu']
                args: ['headless', 'disable-gpu', '--window-size=1280,1024']
                // args: ['disable-gpu', '--window-size=1280,1024']
            },
            'wdio:chromedriverOptions': {
                binary: "./node_modules/chromedriver/lib/chromedriver/chromedriver"
            }
        }],
        testConfig: {
            baseUrl: 'http://localhost:8087',
            serverUrl: 'http://localhost:8087',
            wireMockBaseUrl: 'http://localhost:8018',
            pwaUrl: 'http://localhost:5173/pwa-mobile',
            proxyUrl: 'http://localhost:8081',
            proxyPort: 8081,
            dirName: __dirname,
            resourceDir: path.resolve(__dirname, 'src', 'integration-test', 'resources'),
            datasetLoadScript: path.resolve(__dirname, 'src', 'main', 'scripts', 'loadFunctionalTestData.sh'),
            databaseName: "ecodata-functional-test",
            databaseUserName: undefined,
            databasePassword: undefined,
            oidc: {
                clientId: 'oidcId',
                secret: 'oidcSecret',
                scope: "openid profile email roles user_defined ala"
            },
            webservice: {
                "client-id": "jwtId",
                "client-secret": "jwtSecret",
                "jwt-scopes": "ala/internal users/read ala/attrs ecodata/read_test ecodata/write_test"
            }
        }
    }
}

module.exports = { config };