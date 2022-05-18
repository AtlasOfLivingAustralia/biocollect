package au.org.ala.biocollect

import com.github.tomakehurst.wiremock.WireMockServer
import com.github.tomakehurst.wiremock.extension.responsetemplating.ResponseTemplateTransformer
import geb.Browser
import spock.lang.Shared
import wiremock.com.github.jknack.handlebars.EscapingStrategy
import wiremock.com.github.jknack.handlebars.Handlebars
import wiremock.com.github.jknack.handlebars.Helper
import wiremock.com.github.jknack.handlebars.Options
import wiremock.com.google.common.collect.ImmutableMap

import static com.github.tomakehurst.wiremock.client.WireMock.*
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.options


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

        // Configure the client
        configureFor("localhost", testConfig.wiremock.port)
    }

    def cleanupSpec() {
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
    def okBootbox() {
        Thread.sleep(1000) // wait for the animation to finish
        $('.bootbox .btn-primary').each { ok ->


            waitFor 20, {
                try {
                    if (ok.displayed) {
                        ok.click()
                    }

                }
                catch (Exception e) {
                    e.printStackTrace()
                }
                waitFor {
                    $('.modal-backdrop').size() == 0
                }
            }

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

    /** Creates a wiremock configuration to stub a user login request and return the supplied user and role information */
    def login(Map userDetails, Browser browser) {

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
