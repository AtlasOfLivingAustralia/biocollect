package au.org.ala.biocollect.permissions

import au.org.ala.biocollect.TestingHelpers
import au.org.ala.biocollect.merit.RoleService
import org.apache.commons.lang.NullArgumentException
import spock.lang.Specification
import spock.lang.Unroll

class AppUserEntitiesPermissionsSpec extends Specification {

    def "can create app user entities permissions with no extra permissions"() {
        given:
        def appUserPermissions = TestingHelpers.createUserPermissions(null, [], [], true, true)
        def boolProps = TestingHelpers.getAllMethodsBooleanNoArgs(AppUserEntitiesPermissions).collectEntries { [it, false] }
        def expected = TestingHelpers.mergeWith({ a, b -> a || b }, boolProps, [
                getCanViewProjectAboutAnyPart              : true,
                getCanViewProjectAboutTabAboutTheProject   : true,
                getCanViewProjectAboutTabProjectInformation: true,
                getCanViewProjectAboutTabAssociatedOrgs    : true,
                getCanViewProjectNews                      : true,
                getCanViewProjectResourcesPublic           : true,
                getCanViewOrganisationAbout                : true,
                getCanViewProjectResourcesAnyPart          : true,
                getCanViewProjectArea                      : true,
                getCanAccessProjectAnyPart                 : true,
        ])

        when:
        def permissions = new AppUserEntitiesPermissions(appUserPermissions, null)
        def actual = boolProps.collectEntries { [it.key, permissions."${it.key}"()] }

        then:
        0 * _
        noExceptionThrown()
        permissions.userPermissions == appUserPermissions
        boolProps.size() == 69
        actual.size() == expected.size()
        actual.collect { it }.sort() == expected.collect { it }.sort()
    }

    @Unroll
    def "calling permission for entity checks parameters '#accessLevel' '#entityType'"(
            String accessLevel, String entityType, String entityId, Class expectedErrorType, String expectedError) {
        given:
        def user = null
        def appUserPermissions = TestingHelpers.createUserPermissions(user?.userId)

        when:
        def result = appUserPermissions.hasAccessLevelForEntity(accessLevel, entityType, entityId)

        then:
        0 * _
        appUserPermissions.user == user
        def ex = thrown(expectedErrorType)
        ex.message == expectedError
        !result

        where:
        accessLevel                    | entityType | entityId | expectedErrorType        | expectedError
        null                           | null       | null     | NullArgumentException    | "accessLevel must not be null."
        "  "                           | null       | null     | NullArgumentException    | "accessLevel must not be null."
        "blah"                         | null       | null     | IllegalArgumentException | "Unknown accessLevel 'blah'."
        RoleService.PROJECT_ADMIN_ROLE | null       | null     | NullArgumentException    | "entityType must not be null."
        RoleService.PROJECT_ADMIN_ROLE | "  "       | null     | NullArgumentException    | "entityType must not be null."
        RoleService.PROJECT_ADMIN_ROLE | "blah"     | null     | IllegalArgumentException | "Unknown entityType 'blah'."
    }
}
