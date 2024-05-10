package au.org.ala.biocollect

import com.github.tomakehurst.wiremock.WireMockServer
import com.github.tomakehurst.wiremock.extension.responsetemplating.ResponseTemplateTransformer

import com.nimbusds.jose.jwk.JWKSet

import com.nimbusds.jose.jwk.RSAKey
import geb.Browser
import grails.converters.JSON
import io.jsonwebtoken.security.Keys
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import org.openqa.selenium.StaleElementReferenceException
import org.openqa.selenium.WebDriverException
import org.pac4j.jwt.config.signature.RSASignatureConfiguration
import org.pac4j.jwt.profile.JwtGenerator
import wiremock.com.github.jknack.handlebars.EscapingStrategy
import wiremock.com.github.jknack.handlebars.Handlebars
import wiremock.com.github.jknack.handlebars.Helper
import wiremock.com.github.jknack.handlebars.Options
import wiremock.com.google.common.collect.ImmutableMap

import java.security.KeyPair
import java.security.interfaces.RSAPublicKey
import static com.github.tomakehurst.wiremock.client.WireMock.*
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.options

//import com.github.tomakehurst.wiremock.WireMockServer

/**
 * Supports stubbing access to CAS via wiremock.
 */
class StubbedCasSpec extends BiocollectFunctionalTest {

    static String READ_ONLY_USER_ID = '1000'
    static String GRANT_MANAGER_USER_ID = '1001'
    static String MERIT_ADMIN_USER_ID = '1002'
    static String ALA_ADMIN_USER_ID = '2000'
    static KeyPair pair
    static RSAKey signingKey
    static {
        //  KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA")
        //  generator.initialize(2048)
        //  pair = generator.generateKeyPair()
        //
        //  signingKey = new RSAKey.Builder(pair.getPublic()).privateKey(pair.getPrivate()).build()
        //  RSAKey publicKey =  new RSAKey.Builder(pair.getPublic()).build()
        //  println signingKey.toJSONObject() - this is hardcoded below and is used to sign tokens
        //  println publicKey.toJSONObject() - this goes into wiremock as the response to the jwks request

        // It would be better to generate this at runtime, but the stub needs to be in wirework during bean initialisation of MERIT
        // So we've generated a random key as above and coded it here and into the wiremock stub
        Map key = ["p":"ybsLU3Xf05Nkmfthec3Gf5SCR1cMG4gHYTJh9dP575RavQO63oxS9G-srVmNTmCYsoi-KJs9RODO8Ive701DrpSBkeM7cYZ5_7J3Zt7kTtIPCavwJsb0yhyJQGcm6v7iuF8GIRukeKLT57LwjhSPPqZgdOu9elsc3T7-D9jPPBE",
        "kty":"RSA",
        "q":"rA9mDEolsAG9br7CJlgPIaNsAdpPmqwGTnaHZgJCeN3XwKLlTkLiBlH66OdvakvoFHuvoiaUXFx2xd0G-WrBdePnqZcAb0SdLMp0RxDCRyC4HwJSE9YwieOpIO8EvgzYZKL7liUKR0fz3HAciV9oW3lA6bnh1doSVadw18LMKZk",
        "d":"GDawqqYZsTqZpR3WRyK1YoSI0qO4RS61jvW-l72SbpILYHl9M0cZewef95OrT9yl4-7SurBV15j7wkqLvLxmQNxpIs-yXRK5hpmvxa07SiXZOtwW7EvG_PMx9tyQ8LiyM8MnTr-qknh_Rtbjr9bH0mrMeUCQfVj5VSSF8SNHEVPGy_QxQoswIhRgzcq9tOaGP1W-FoVCaQjAxJG4boAselX_bvYe3IVuDwE_ZV8KPCQcZISEqrY8B8-b8AdTgecORODQB5lChElqRBeKUeoOtVMvD8rlwUgjV9ir_QK25Vq8rLcEkdPrRhV0EKKnr1eBir1WSpdLjzIUhAsF5HPUAQ",
        "e":"AQAB", "qi":"kuYhMgrJR1fTuX0IJar-SjWhrn3EV96bfaObAkxMZDHes-tthLxcZ58PpKKbsMSK8kncT41JMb0Irb9HC12B6aSDy3Kzsns-gzcD38m9YcdOk80kyjCqLIceU2tmMIeIxSF54wGwVO_p4p94xeANf4si450ssqdPM_q1n1SRu88",
        "dp":"Gx8Nj8P6OqzHSrh0S3bx5_ckaMj4NL9eFqA6cV11bdNpO55DwmXlRT26Xnf6un3cKayevEDaxObgi5CSgWPG5LLMlLuTI1ksD8eDrA3tbfdp1CgMmnoHMSETBtiXb-Kiwpzr6wmXXCywBqeVFdUHySl_MFj9WXTkdY5hg-nnOrE",
        "dq":"DwhxZBV-YXhlcq2cDPmYqNm8cBUA64SoMGbOwazk3eaUGTKiUkopsV-sSnkeFO1444FDASnZwJAbmIINP_GB4aj97qVQ1mfqS6WMr0DZmJlVPPBY9365UvLfLg90HJ7GsVREIwQtd7jjp5jsBVyeo49eio1BHAwnmfA9Pby5VdE",
        "n":"h5XN-_LL1yXb8oPWHOTNMby0Y6olpByVCNJGo1mjhk9PUoX8bfu6wNr4G7oR7O0NfIQVNLykqE7Q04RrP7JfexI97UuH5B0xBjHVo-S5SxeyUrVSQBpRu6EisQzxxF3a038a0GHYJpA5YUAZWD7Pux0yqJ5ly1y2Sn7uGb_JJ_bJ86EVWs3AxE1RZHmeY975A1kk470ylDAyfQuW_GU-gUzG5vdE1wAEIKe6GFtg5ulA_n_XVsrz9qio7ZtEyWZDAOCtk0jfg8iTJf5eLP2Q3D8ePy_6IvYvFDuQLmvKHn1jg5MnnDWZHV3GBRnfU8CtPu2ChFKhXedcrhQhhAWfKQ"
        ]

        signingKey = RSAKey.parse(key)
        pair = signingKey.toKeyPair()

    }

   // @Shared WireMockServer wireMockServer
    def setupSpec() {
        JSON.registerObjectMarshaller(new MapMarshaller())
        JSON.registerObjectMarshaller(new CollectionMarshaller())
        if (testConfig.wiremock.embedded){
            startWireMock()
        }

        // Configure the client
        configureFor("localhost", testConfig.wiremock.port)
    }

    private void startWireMock() {
        Handlebars handlebars = new Handlebars()
        handlebars.escapingStrategy = EscapingStrategy.NOOP

        // This is done so we can use a custom handlebars with a NOOP escaping strategy - the default escapes HTML
        // which breaks the redirect URL returned by the PDF generation stub.
        Helper noop = new Helper() {
            Object apply(Object context, Options options) throws IOException {
                return context[0]
            }
        }
        wireMockServer = new WireMockServer(options()
                .port(testConfig.wiremock.port)
                .usingFilesUnderDirectory(getMappingsPath())
                .extensions(new ResponseTemplateTransformer(false, handlebars, ImmutableMap.of("noop", noop), null, null)))

        wireMockServer.start()
    }

    def cleanupSpec() {
        if (testConfig.wiremock.embedded)
            wireMockServer.stop()
    }

    /**
     * Opens a new window and logs out.  This will cause the next
     * request to be unauthenticated which is a reasonable simulation of
     * a session timeout.
     */
    def simulateTimeout(Browser browser) {
        withNewWindow({
            js.exec("window.open('${getConfig().baseUrl}');")}, {logout(browser); return true})
    }

    /** Presses the OK button on a displayed bootbox modal */
    def okBootbox(buttonSelector = '.btn-primary') {
        Thread.sleep(1000) // wait for the animation to finish
        // The reason we are doing an "each" and catching exception is sometimes previous dialogs remain
        // in scope despite being detached from the DOM and StaleElementException is thrown.
        def backdrop = $('.modal-backdrop')
        $('.bootbox '+buttonSelector).each { ok ->

            try {
                if (ok.displayed) {
                    ok.click()
                }
            }
            catch (Exception e) {
                e.printStackTrace()
            }
        }
        Thread.sleep(1000)
        // Dismissing bootbox modals is intermittently unreliable, so trying a javascript fallback.
        // The other issue here is one of the tests transitions from a page with bootbox up to a page which
        // immediately displays a modal, so the Thread.sleep means we can actually be catching the dialog on the
        // second page.  Hence why we get the element reference at the start.
        try {
            if (backdrop.displayed) {
                js.exec('$(".bootbox ' + buttonSelector + '").click();')
                Thread.sleep(1000)
                waitFor {
                    boolean backdropDisplayed
                    try {
                        backdropDisplayed = backdrop.displayed
                    }
                    catch (StaleElementReferenceException e) {
                        backdropDisplayed = false
                        // The backdrop was already detached from the DOM due to page transition
                    }
                    !backdropDisplayed
                }
            }
        }
        catch (StaleElementReferenceException e) { // Do nothing, backdrop was already detached
        }
        catch (NullPointerException e) {
            // Do nothing, backdrop was already detached and destroyed before we selected it
        }
        catch (WebDriverException e) {
            // We are now seeing WebDriverException instead of StateElementReferenceException in some cases
        }
    }

    private String getMappingsPath() {
        new File(getClass().getResource("/wiremock").toURI())
    }

    /** Convenience method to stub the login of a user with the MERIT siteReadOnly role */
    def loginAsReadOnlyUser(Browser browser) {
        login([userId:READ_ONLY_USER_ID, email: 'read_only@nowhere.com', firstName:"Read", lastName:"Only"], browser)
    }
    /** Convenience method to stub the login of a user with the MERIT siteAdmin role */
    def loginAsMeritAdmin(Browser browser) {
        login([userId:MERIT_ADMIN_USER_ID, email: 'merit_admin@nowhere.com', firstName:"MERIT", lastName:"Administrator"], browser)
    }
    /** Convenience method to stub the login of a user with the MERIT siteOfficer role */
    def loginAsGrantManager(Browser browser) {
        login([userId:GRANT_MANAGER_USER_ID, email: 'grant_manager@nowhere.com', firstName:"Grant", lastName:"Manager"], browser)
    }
    /** Convenience method to stub the login of a user with the CAS ROLE_ALA_ADMIN role */
    def loginAsAlaAdmin(Browser browser) {
        login([userId:ALA_ADMIN_USER_ID, role:"ROLE_ADMIN", userName: 'ala_admin@nowhere.com', email: 'ala_admin@nowhere.com', firstName:"ALA", lastName:"Administrator"], browser)
    }
    /** Convenience method to stub the login of a user no special roles */
    def loginAsUser(String userId, Browser browser) {
        if (userId in [MERIT_ADMIN_USER_ID, READ_ONLY_USER_ID, GRANT_MANAGER_USER_ID, ALA_ADMIN_USER_ID]) {
            throw new IllegalArgumentException("${userId} is reserved for users with higher level roles")
        }
        login([userId:userId, email: "user${userId}@nowhere.com", firstName:"MERIT", lastName:"User ${userId}"], browser)
    }

    String tokenForUser(String userId) {
        Map userDetails = [userId:userId, email: "user${userId}@nowhere.com", firstName:"MERIT", lastName:"User ${userId}"]
        setupOidcAuthForUser(userDetails)
    }

    private String loggedInUser = null

    def login(Map userDetails, Browser browser) {
        if (loggedInUser != userDetails.userId) {
            logout(browser)
        }
        oidcLogin(userDetails, browser)
        loggedInUser = userDetails.userId
    }

    def jks() {
        KeyPair keyPair = Keys.keyPairFor(SignatureAlgorithm.RS256);

        // Convert the public key to JWKS format
        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();
        RSAKey rsaKey = new RSAKey.Builder(publicKey)
                .keyID("1")
                .build();
        JWKSet jwkSet = new JWKSet(rsaKey);

        // Print the JWKS
        System.out.println(jwkSet.toPublicJWKSet().toString());

    }

    def oidcLogin(Map userDetails, Browser browser) {
        setupOidcAuthForUser(userDetails)
        browser.go "${browser.getConfig().baseUrl}login"
    }

    /**
     * Sets up stubs with wiremock to authenticate a user via OIDC.  Also returns an idToken which can be used
     * if an interactive login is not required.
     * @param userDetails the details of the user to setup
     * @return an idToken for the user.
     */
    String setupOidcAuthForUser(Map userDetails) {
        // The test config isn't a normal grails config object (probably need to to into why) so getProperty doesn't work.
        String clientId = getTestConfig().security.oidc.clientId
        List roles = ["ROLE_USER"]
        if (userDetails.role) {
            roles << userDetails.role
        }

        Map idTokenClaims = [
                at_hash:"KX-L2Fj6Z9ow-gOpYfehRA",
                sub:userDetails.userId,
                email_verified:true,
                role:roles,
                amr:"DelegatedClientAuthenticationHandler",
                iss:"http://localhost:8018/cas/oidc",
                preferred_username:userDetails.email,
                given_name:userDetails.firstName,
                family_name:userDetails.lastName,
                client_id:clientId,
                sid:"test_sid",
                aud:clientId,
                name:userDetails.firstName+" "+userDetails.lastName,
                state:"maybe_this_matters",
                auth_time:-1,
                nbf:com.nimbusds.jwt.util.DateUtils.toSecondsSinceEpoch(new Date().minus(365)),
                exp:com.nimbusds.jwt.util.DateUtils.toSecondsSinceEpoch(new Date().plus(365)),
                iat:com.nimbusds.jwt.util.DateUtils.toSecondsSinceEpoch(new Date()),
                jti:"id",
                email:userDetails.email,
                scope             : "openid profile ala roles email"
        ]
        String idToken = new JwtGenerator(new RSASignatureConfiguration(pair)).generate(idTokenClaims)
        Map token = [:]
        token.access_token = idToken
        token.id_token = idToken
        token.refresh_token = null
        token.token_type = "bearer"
        token.expires_in = 86400
        token.scope = "openid profile ala roles email"

        stubFor(post(urlPathEqualTo("/cas/oidc/oidcAccessToken"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody((token as JSON).toString())
                        .withTransformers("response-template")
                        ))


        Map profile = [
                userid     : userDetails.userId,
                sub        : userDetails.userId,
                name       : userDetails.firstName + " " + userDetails.lastName,
                given_name : userDetails.firstName,
                family_name: userDetails.lastName,
                email      : userDetails.email
        ]

        stubFor(get(urlPathEqualTo("/cas/oidc/oidcProfile"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody((profile as JSON).toString())
                ))
        idToken
    }

    /** Creates a wiremock configuration to stub a user login request and return the supplied user and role information */
    def casLogin(Map userDetails, Browser browser) {

        String email = "fc-te@outlook.com"

        List roles = ["ROLE_USER"]
        if (userDetails.role) {
            roles << userDetails.role
        }
        String casRoles = ""
        roles.each { role ->
            casRoles += "<cas:role>${role}</cas:role>"
        }

        String casXml = """
<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
    <cas:authenticationSuccess>
        <cas:user>${userDetails.email}</cas:user>
        <cas:attributes>
            <cas:lastLogin>2019-08-19 06:25:31</cas:lastLogin>
            <cas:country>AU</cas:country>
            <cas:firstname>${userDetails.firstName}</cas:firstname>
            ${casRoles}
            <cas:role>ROLE_USER</cas:role>
            <cas:isFromNewLogin>false</cas:isFromNewLogin>
            <cas:authenticationDate>2019-08-19T06:34:15.495Z[UTC]</cas:authenticationDate>
            <cas:city></cas:city>
            <cas:clientName>Google</cas:clientName>
            <cas:created>2012-01-05 01:11:19</cas:created>
            <cas:givenName>${userDetails.firstName}</cas:givenName>
            <cas:successfulAuthenticationHandlers>ClientAuthenticationHandler</cas:successfulAuthenticationHandlers>
            <cas:organisation>${userDetails.organisation ?: ''}</cas:organisation>
            <cas:userid>${userDetails.userId}</cas:userid>
            <cas:lastname>${userDetails.lastName}</cas:lastname>
            <cas:samlAuthenticationStatementAuthMethod>urn:oasis:names:tc:SAML:1.0:am:unspecified</cas:samlAuthenticationStatementAuthMethod>
            <cas:credentialType>ClientCredential</cas:credentialType>
            <cas:authenticationMethod>ClientAuthenticationHandler</cas:authenticationMethod>
            <cas:authority>${roles.join(',')}</cas:authority>
            <cas:longTermAuthenticationRequestTokenUsed>false</cas:longTermAuthenticationRequestTokenUsed>
            <cas:state></cas:state>
            <cas:sn>${userDetails.lastName}</cas:sn>
            <cas:id>${userDetails.userId}</cas:id>
            <cas:email>${userDetails.email}</cas:email>
        </cas:attributes>
    </cas:authenticationSuccess>
</cas:serviceResponse>
        """

        stubFor(get(urlPathEqualTo("/cas/login"))

                .willReturn(aResponse()
                .withStatus(302)
                .withHeader("Location", "{{request.requestLine.query.service}}?ticket=aticket")
                .withHeader("Set-Cookie", "ALA-Auth=\"${email}\"; Domain=ala.org.au; Path=/; HttpOnly")
                .withTransformers("response-template")))

        stubFor(get(urlMatching("/cas/login\\?service=.*\\?.*"))
                .willReturn(aResponse()
                        .withStatus(302)
                        .withHeader("location", "{{request.requestLine.query.service}}&ticket=aticket")
                        .withHeader("Set-Cookie", "ALA-Auth=\"${email}\"; Domain=ala.org.au; Path=/; HttpOnly")
                        .withTransformers("response-template")))

        stubFor(get(urlPathEqualTo("/cas/p3/serviceValidate"))
            .willReturn(aResponse()
            .withStatus(200)
            .withBody(casXml)
            .withTransformers("response-template")))

        browser.go "${testConfig.security.cas.loginUrl}?service=${getConfig().baseUrl}"
    }

}
