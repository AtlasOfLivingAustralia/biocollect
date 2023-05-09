package au.org.ala.biocollect

import com.github.tomakehurst.wiremock.WireMockServer
import com.github.tomakehurst.wiremock.extension.responsetemplating.ResponseTemplateTransformer
import geb.Browser
import grails.converters.JSON
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import org.openqa.selenium.StaleElementReferenceException
import org.pac4j.jwt.profile.JwtGenerator
import spock.lang.Shared
import wiremock.com.github.jknack.handlebars.EscapingStrategy
import wiremock.com.github.jknack.handlebars.Handlebars
import wiremock.com.github.jknack.handlebars.Helper
import wiremock.com.github.jknack.handlebars.Options
import wiremock.com.google.common.collect.ImmutableMap

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

    @Shared WireMockServer wireMockServer
    def setupSpec() {
        if (testConfig.wiremock.embedded){

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

        JSON.registerObjectMarshaller(new MapMarshaller())
        JSON.registerObjectMarshaller(new CollectionMarshaller())
        // Configure the client
        configureFor("localhost", testConfig.wiremock.port)
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
        login([userId:ALA_ADMIN_USER_ID, role:"ROLE_ADMIN", email: 'ala_admin@nowhere.com', firstName:"ALA", lastName:"Administrator"], browser)
    }
    /** Convenience method to stub the login of a user no special roles */
    def loginAsUser(String userId, Browser browser) {
        if (userId in [MERIT_ADMIN_USER_ID, READ_ONLY_USER_ID, GRANT_MANAGER_USER_ID, ALA_ADMIN_USER_ID]) {
            throw new IllegalArgumentException("${userId} is reserved for users with higher level roles")
        }
        login([userId:userId, email: "user${userId}@nowhere.com", firstName:"MERIT", lastName:"User ${userId}"], browser)
    }

    private String loggedInUser = null

    def login(Map userDetails, Browser browser) {
        if (loggedInUser != userDetails.userId) {
            logout(browser)
        }
        oidcLogin(userDetails, browser)
        loggedInUser = userDetails.userId
    }

    def oidcLogin(Map userDetails, Browser browser) {

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
                email:userDetails.email
        ]
        String idToken = new JwtGenerator(null).generate(idTokenClaims)
        Map token = [:]
        token.access_token = idToken
        token.id_token = idToken
        token.refresh_token = null
        token.token_type = "bearer"
        token.expires_in = 86400
        token.scope = "user_defined email openid profile roles"

        stubFor(post(urlPathEqualTo("/cas/oidc/oidcAccessToken"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody((token as JSON).toString())
                        .withTransformers("response-template")
                        ))


        Map profile = [
                sub:userDetails.userId,
                name:userDetails.firstName+" "+userDetails.lastName,
                given_name:userDetails.firstName,
                family_name:userDetails.lastName,
                email:userDetails.email
        ]

        stubFor(get(urlPathEqualTo("/cas/oidc/oidcProfile"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody((profile as JSON).toString())
                ))

        browser.go "${getConfig().baseUrl}login"
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
                .withHeader("Location", "{{{request.requestLine.query.service}}}?ticket=aticket")
                .withHeader("Set-Cookie", "ALA-Auth=\"${email}\"; Domain=ala.org.au; Path=/; HttpOnly")
                .withTransformers("response-template")))

        stubFor(get(urlMatching("/cas/login\\?service=.*\\?.*"))
                .willReturn(aResponse()
                        .withStatus(302)
                        .withHeader("location", "{{{request.requestLine.query.service}}}&ticket=aticket")
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
