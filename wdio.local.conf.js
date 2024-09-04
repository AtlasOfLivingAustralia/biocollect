const path = require('node:path');
const sharedConfig = require('./wdio.shared.conf.js').config;

const config = {
    ...sharedConfig,
    ...{
        capabilities: [{
            browserName: 'chrome',
            'goog:chromeOptions': {
                args: ['headless', 'disable-gpu']
            }
        }],
        testConfig: {
            baseUrl: 'http://localhost:8087',
            serverUrl: 'http://localhost:8087',
            wireMockBaseUrl: 'http://localhost:8018',
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