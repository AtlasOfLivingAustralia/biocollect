package au.org.ala.biocollect.permissions

import au.org.ala.biocollect.TestingHelpers
import au.org.ala.biocollect.merit.RoleService
import org.apache.commons.lang.NullArgumentException
import spock.lang.Specification
import spock.lang.Unroll

class AppUserPermissionsSpec extends Specification {

    def "can create app user permissions with no permissions"() {
        given:
        def user = null
        def rolesApiSuccess = true
        def accessLevelsApiSuccess = true
        def boolProps = TestingHelpers.getAllMethodsBooleanNoArgs(AppUserPermissions).collectEntries { [it, false] }
        def expected = TestingHelpers.mergeWith({ a, b -> a || b }, boolProps, [
                getIsRolesApiSuccess       : rolesApiSuccess,
                getIsAccessLevelsApiSuccess: accessLevelsApiSuccess
        ])

        when:
        def permissions = TestingHelpers.createUserPermissions(user?.userId, rolesApiSuccess ? []: null, accessLevelsApiSuccess ? [] : null, rolesApiSuccess, accessLevelsApiSuccess)
        def actual = boolProps.collectEntries { [it.key, permissions."${it.key}"()] }

        then:
        0 * _
        noExceptionThrown()
        permissions.user == user
        boolProps.size() == 11
        actual.size() == expected.size()
        actual.collect { it }.sort() == expected.collect { it }.sort()
    }

    @Unroll
    def "asking for invalid permission for entity throws error for accessLevel '#accessLevel' entityType '#entityType'"(
            String accessLevel, String entityType, Class expectedErrorType, String expectedError) {
        given:
        def user = null
        def permissions = TestingHelpers.createUserPermissions(user?.userId)

        when:
        def result = permissions.hasAccessLevelForEntity(accessLevel, entityType, null)

        then:
        0 * _
        permissions.user == user
        def ex = thrown(expectedErrorType)
        ex.message == expectedError
        !result

        where:
        accessLevel                    | entityType | expectedErrorType        | expectedError
        null                           | null       | NullArgumentException    | "accessLevel must not be null."
        "  "                           | null       | NullArgumentException    | "accessLevel must not be null."
        "blah"                         | null       | IllegalArgumentException | "Unknown accessLevel 'blah'."
        RoleService.PROJECT_ADMIN_ROLE | null       | NullArgumentException    | "entityType must not be null."
        RoleService.PROJECT_ADMIN_ROLE | "  "       | NullArgumentException    | "entityType must not be null."
        RoleService.PROJECT_ADMIN_ROLE | "blah"     | IllegalArgumentException | "Unknown entityType 'blah'."
    }
}
