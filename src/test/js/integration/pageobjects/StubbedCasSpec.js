const jose = require('node-jose');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const axios = require('axios');
const util = require('node:util');
const execFile = util.promisify(require('node:child_process').execFile);
const path = require('node:path');
class StubbedCasSpec {
    loggedInUser = null;
    baseUrl = '';
    serverUrl = '';
    testConfig = {};
    jwk = {
        p: "ybsLU3Xf05Nkmfthec3Gf5SCR1cMG4gHYTJh9dP575RavQO63oxS9G-srVmNTmCYsoi-KJs9RODO8Ive701DrpSBkeM7cYZ5_7J3Zt7kTtIPCavwJsb0yhyJQGcm6v7iuF8GIRukeKLT57LwjhSPPqZgdOu9elsc3T7-D9jPPBE",
        kty: "RSA",
        q: "rA9mDEolsAG9br7CJlgPIaNsAdpPmqwGTnaHZgJCeN3XwKLlTkLiBlH66OdvakvoFHuvoiaUXFx2xd0G-WrBdePnqZcAb0SdLMp0RxDCRyC4HwJSE9YwieOpIO8EvgzYZKL7liUKR0fz3HAciV9oW3lA6bnh1doSVadw18LMKZk",
        d: "GDawqqYZsTqZpR3WRyK1YoSI0qO4RS61jvW-l72SbpILYHl9M0cZewef95OrT9yl4-7SurBV15j7wkqLvLxmQNxpIs-yXRK5hpmvxa07SiXZOtwW7EvG_PMx9tyQ8LiyM8MnTr-qknh_Rtbjr9bH0mrMeUCQfVj5VSSF8SNHEVPGy_QxQoswIhRgzcq9tOaGP1W-FoVCaQjAxJG4boAselX_bvYe3IVuDwE_ZV8KPCQcZISEqrY8B8-b8AdTgecORODQB5lChElqRBeKUeoOtVMvD8rlwUgjV9ir_QK25Vq8rLcEkdPrRhV0EKKnr1eBir1WSpdLjzIUhAsF5HPUAQ",
        e: "AQAB",
        qi: "kuYhMgrJR1fTuX0IJar-SjWhrn3EV96bfaObAkxMZDHes-tthLxcZ58PpKKbsMSK8kncT41JMb0Irb9HC12B6aSDy3Kzsns-gzcD38m9YcdOk80kyjCqLIceU2tmMIeIxSF54wGwVO_p4p94xeANf4si450ssqdPM_q1n1SRu88",
        dp: "Gx8Nj8P6OqzHSrh0S3bx5_ckaMj4NL9eFqA6cV11bdNpO55DwmXlRT26Xnf6un3cKayevEDaxObgi5CSgWPG5LLMlLuTI1ksD8eDrA3tbfdp1CgMmnoHMSETBtiXb-Kiwpzr6wmXXCywBqeVFdUHySl_MFj9WXTkdY5hg-nnOrE",
        dq: "DwhxZBV-YXhlcq2cDPmYqNm8cBUA64SoMGbOwazk3eaUGTKiUkopsV-sSnkeFO1444FDASnZwJAbmIINP_GB4aj97qVQ1mfqS6WMr0DZmJlVPPBY9365UvLfLg90HJ7GsVREIwQtd7jjp5jsBVyeo49eio1BHAwnmfA9Pby5VdE",
        n: "h5XN-_LL1yXb8oPWHOTNMby0Y6olpByVCNJGo1mjhk9PUoX8bfu6wNr4G7oR7O0NfIQVNLykqE7Q04RrP7JfexI97UuH5B0xBjHVo-S5SxeyUrVSQBpRu6EisQzxxF3a038a0GHYJpA5YUAZWD7Pux0yqJ5ly1y2Sn7uGb_JJ_bJ86EVWs3AxE1RZHmeY975A1kk470ylDAyfQuW_GU-gUzG5vdE1wAEIKe6GFtg5ulA_n_XVsrz9qio7ZtEyWZDAOCtk0jfg8iTJf5eLP2Q3D8ePy_6IvYvFDuQLmvKHn1jg5MnnDWZHV3GBRnfU8CtPu2ChFKhXedcrhQhhAWfKQ"
    };
    privateKey = '';
    constructor () {
        this.testConfig = browser.options.testConfig;
        this.baseUrl = this.testConfig.baseUrl;
        this.serverUrl = this.testConfig.serverUrl;
    }

    async at(regexTitle) {
        return await browser.waitUntil( async () => {
            const title = await browser.getTitle();
            const regex = new RegExp(regexTitle);
            return regex.test(title);
        }, {
            timeout: 5000,
        });
    }

    async loginAsUser(userId) {
        const reservedUserIds = [
            'MERIT_ADMIN_USER_ID',
            'READ_ONLY_USER_ID',
            'GRANT_MANAGER_USER_ID',
            'ALA_ADMIN_USER_ID'
        ];

        // Check if userId is one of the reserved IDs
        if (reservedUserIds.includes(userId)) {
            throw new Error(`${userId} is reserved for users with higher level roles`);
        }

        // User login data
        const userDetails = {
            userId: userId,
            email: `user${userId}@nowhere.com`,
            firstName: "MERIT",
            lastName: `User ${userId}`
        };

        // Call the login function, assuming it exists
        await this.login(userDetails);
    }

    async login(userDetails) {
      if (this.loggedInUser != userDetails.userId) {
          await this.logout()
      }
      await this.oidcLogin(userDetails)
      this.loggedInUser = userDetails.userId;
    }

    async logout(returnPage = 'EntryPage') {
        const logoutButtonSelector = '.custom-header-login-logout';
        const logoutButton = await browser.$(logoutButtonSelector);

        if (await logoutButton.isDisplayed()) {
            const buttonText = await logoutButton.getText();
            if (buttonText.trim() === "Logout") {
                try {
                    await logoutButton.click();
                    await browser.waitUntil(async () => {
                        const currentUrl = await browser.getUrl();
                        // Adjust this condition to check if you are on the expected return page
                        return currentUrl.includes(returnPage);
                    }, {
                        timeout: 25000, // Wait for up to 25 seconds
                        timeoutMsg: 'Timed out after 25 seconds waiting for return page'
                    });
                } catch (error) {
                    console.warn("Test ended during page reload or with a modal backdrop resulting in failure to click logout button - directly navigating browser");
                    await this.logoutViaUrl();
                }
            } else {
                await this.logoutViaUrl();
            }
        } else {
            await this.logoutViaUrl();
        }
    }

    async logoutViaUrl() {
        await browser.url(`${this.baseUrl}/logout?appUrl=${this.baseUrl}`);
    }

    async oidcLogin(userDetails) {
        await this.setupOidcAuthForUser(userDetails)
        await browser.url(`${this.baseUrl}/login`)
    }

    async setupOidcAuthForUser(userDetails) {
        // Get the test configuration (assuming getTestConfig is defined elsewhere)
        const clientId = this.testConfig.oidc.clientId;
        const clientSecret = this.testConfig.oidc.secret;

        // Base64 encode clientId:clientSecret
        const base64EncodedAuth = 'Basic ' + Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

        // Set default roles and append additional role if provided
        let roles = ['ROLE_USER'];
        if (userDetails.role) {
            roles.push(userDetails.role);
        }

        // Define ID Token Claims
        const idTokenClaims = {
            at_hash: 'KX-L2Fj6Z9ow-gOpYfehRA',
            sub: userDetails.userId,
            email_verified: true,
            role: roles,
            amr: 'DelegatedClientAuthenticationHandler',
            iss: `${this.testConfig.wireMockBaseUrl}/cas/oidc`,
            preferred_username: userDetails.email,
            given_name: userDetails.firstName,
            family_name: userDetails.lastName,
            client_id: clientId,
            sid: 'test_sid',
            aud: clientId,
            audience: clientId,
            name: `${userDetails.firstName} ${userDetails.lastName}`,
            state: 'maybe_this_matters',
            auth_time: -1,
            nbf: Math.floor(Date.now() / 1000) - 365 * 24 * 60 * 60,  // Not before (one year ago)
            exp: Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60,  // Expires in one year
            iat: Math.floor(Date.now() / 1000),  // Issued at
            jti: 'id',
            email: userDetails.email,
            scope: this.testConfig.oidc.scope
        };

        const idToken = await this.signPayload(idTokenClaims);

        // Stub the POST request for token exchange (using nock)
        await this.setupAccessToken('/cas/oidc/oidcAccessToken', {
            access_token: idToken,
            id_token: idToken,
            refresh_token: null,
            token_type: 'bearer',
            expires_in: 86400,
            scope: 'openid profile ala roles email'
        }, base64EncodedAuth);
        await this.setupProfileEndpoint(userDetails, base64EncodedAuth);

        // Return the ID token
        return idToken;
    }

    async setupAccessToken(url, body, base64EncodedAuth){
        try {
            // Set up POST request to "/cas/oidc/oidcAccessToken"
            await axios.post(`${this.testConfig.wireMockBaseUrl}/__admin/mappings`, {
                request: {
                    method: 'POST',
                    url: url,
                    headers: {
                        'Authorization': {
                            "equalTo": base64EncodedAuth
                        }
                    }
                },
                response: {
                    status: 200,
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(body),
                    transformers: ['response-template']
                }
            });
            console.log('Stub configured successfully.');
        } catch (error) {
            console.error('Error configuring stub:', error);
        }
    }

    async setupProfileEndpoint(userDetails, base64EncodedAuth) {
        // Create user profile
        const profile = {
            userid: userDetails.userId,
            sub: userDetails.userId,
            name: `${userDetails.firstName} ${userDetails.lastName}`,
            given_name: userDetails.firstName,
            family_name: userDetails.lastName,
            email: userDetails.email
        };

        await axios.post(`${this.testConfig.wireMockBaseUrl}/__admin/mappings`, {
            request: {
                method: 'GET',
                url: '/cas/oidc/oidcProfile',
                headers: {
                    'Authorization':  {
                        "equalTo": base64EncodedAuth
                    }
                }
            },
            response: {
                status: 200,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(profile)
            }
        });

    }

    async setupTokenForSystem() {
        // The test config isn't a normal grails config object (probably need to to into why) so getProperty doesn't work.
        let clientId = this.testConfig.webservice["client-id"]
        let clientSecret = this.testConfig.webservice["client-secret"]
        let base64EncodedAuth = "Basic " + Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

        let idTokenClaims = {
            at_hash: "KX-L2Fj6Z9ow-gOpYfehRA",
            sub: clientId,
            amr: "DelegatedClientAuthenticationHandler",
            iss: "http://localhost:8018/cas/oidc",
            client_id: clientId,
            aud: clientId,
            audience: clientId,
            state: "maybe_this_matters",
            auth_time: -1,
            nbf: Math.floor(Date.now() / 1000) - 365 * 24 * 60 * 60,  // Not before (one year ago)
            exp: Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60,  // Expires in one year
            iat: Math.floor(Date.now() / 1000),  // Issued at
            jti: "id-system",
            scope: this.testConfig.webservice["jwt-scopes"]
        }
        // Simulate generating JWT (signing token) - Assuming you have RSA private key in 'privateKey'
        let idToken = await this.signPayload(idTokenClaims);
        let token = {}
        token.access_token = idToken
        token.id_token = idToken
        token.refresh_token = null
        token.token_type = "bearer"
        token.expires_in = 86400
        token.scope = this.testConfig.webservice["jwt-scopes"]

        await this.setupAccessToken("/cas/oidc/oidcAccessToken", token, base64EncodedAuth);

        return idToken
    }

    async createPrivateKey() {
        if (!this.privateKey) {
            const keyStore = jose.JWK.createKeyStore();
            this.privateKey = await keyStore.add(this.jwk, 'private', {kid: "localhost:8018"});
            console.log("Private Key Created: ", this.privateKey);
        }

        return this.privateKey;
    }

    async signPayload(payload){
        await this.createPrivateKey();
        let accessToken = await jose.JWS.createSign({format:"compact", fields: {
                alg: 'RS256',
                kid: "localhost:8018",
            }}, this.privateKey)
            .update(JSON.stringify(payload))
            .final();
        console.log("Access Token Created: ", accessToken);
        return accessToken;
    }


    async loadDataSet(dataSet) {
        const targetDir = path.resolve(this.testConfig.resourceDir, dataSet);
        let args = [targetDir];
        if (this.testConfig.databaseUserName) {
            args.push(this.testConfig.databaseUserName);
        }
        if (this.testConfig.databasePassword) {
            args.push(this.testConfig.databasePassword);
        }
        const {error, stdout, stderr} = await execFile(this.testConfig.datasetLoadScript, args)
        //     , (error, stdout, stderr) => {
        //     if (error) {
        //         console.error(`Error loading dataset ${dataSet}: ${error.message}`);
        //         return;
        //     }
        //     if (stderr) {
        //         console.error(`Error loading dataset ${dataSet}: ${stderr}`);
        //         return;
        //     }
        //     console.log(`Dataset ${dataSet} loaded successfully: ${stdout}`);
        // });
        console.log(`result of command ${JSON.stringify(error)} \n\n ${JSON.stringify(stderr)} \n\n ${JSON.stringify(stdout)}`);
    }
}

module.exports = StubbedCasSpec;