const path = require('node:path');
const { config: sharedConfig, isFunctionalTestCaptureDisabled } = require('./wdio.shared.conf.js');

const config = {
    ...sharedConfig,
    ...{
         // specs: [
         //     './src/test/js/integration/specs/pwa/InstallationSpec.js'
         // ],
        maxInstances: 1,
        maxInstancesPerCapability: 1,
        // services: ['devtools'],
        capabilities: [{
            maxInstances: 1,
            browserName: 'chrome',
            'goog:chromeOptions': {
                // args: ['--auto-open-devtools-for-tabs','disable-gpu']
                args: ['headless', 'disable-gpu', 'window-size=3000,1400', 'disable-dev-shm-usage', 'no-sandbox', '--headless', '--disable-gpu', '--window-size=3000,3000', '--disable-dev-shm-usage', '--no-sandbox']
                // args: ['--auto-open-devtools-for-tabs', 'disable-gpu', '--window-size=3000,1400']
            }
            // No 'wdio:chromedriverOptions.binary' override: WebdriverIO v9 automatically
            // downloads a chromedriver that matches the installed Chrome version. Hardcoding a
            // binary path tied to the `chromedriver` npm package broke CI whenever the runner's
            // Chrome version drifted from the pinned package (spawn ... chromedriver ENOENT).
        }],
        testConfig: {
            disableCapture: isFunctionalTestCaptureDisabled(),
            baseUrl: 'http://localhost:8087',
            serverUrl: 'http://localhost:8087',
            wireMockBaseUrl: 'http://localhost:8018',
            pwaUrl: 'http://localhost:5173/mobile-app',
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
