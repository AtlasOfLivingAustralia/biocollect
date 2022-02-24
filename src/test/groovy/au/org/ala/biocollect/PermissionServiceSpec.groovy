package au.org.ala.biocollect

import au.org.ala.biocollect.merit.RoleService
import au.org.ala.biocollect.merit.WebService
import au.org.ala.biocollect.permissions.AppUserDetails
import au.org.ala.biocollect.permissions.AppUserEntitiesPermissions
import grails.testing.services.ServiceUnitTest
import spock.lang.Specification
import spock.lang.Unroll

class PermissionServiceSpec extends Specification implements ServiceUnitTest<PermissionService> {

    def realRoleService = new RoleService()

    def roleService = Mock(RoleService)
    def utilService = Mock(UtilService)
    def webService = Mock(WebService)

    def setup() {
        service.roleService = roleService
        service.utilService = utilService
        service.webService = webService
        realRoleService.grailsApplication = grailsApplication
    }

    def cleanup() {
    }

    void "get current user permissions"() {
        given:
        def userRoleName = realRoleService.getRoleUserdetailsUser()
        def adminRoleName = realRoleService.getRoleUserdetailsAdmin()
        def appReadOnlyRoleName = realRoleService.getRoleUserdetailsAppReadOnly()
        def appOfficerRoleName = realRoleService.getRoleUserdetailsAppOfficer()
        def appAdminRoleName = realRoleService.getRoleUserdetailsAppAdmin()

        def userId = TestingHelpers.randomId
        def user = new AppUserDetails(userId: userId, roles: [userRoleName, appReadOnlyRoleName])

        when:
        def result = service.getCurrentUserPermissions()

        then:
        1 * utilService.getCurrentUser() >> user
        1 * webService.getJson("null/permissions/getUserRolesForUserId/${userId}", null, true) >> [roles: []]
        1 * roleService.getRoleUserdetailsUser() >> userRoleName
        1 * roleService.getRoleUserdetailsAdmin() >> adminRoleName
        1 * roleService.getRoleUserdetailsAppReadOnly() >> appReadOnlyRoleName
        1 * roleService.getRoleUserdetailsAppOfficer() >> appOfficerRoleName
        1 * roleService.getRoleUserdetailsAppAdmin() >> appAdminRoleName
        0 * _
        noExceptionThrown()
        result != null
        result.getUser() == user
        result.countAccessLevels == 0
        result.countRoles == 3
        !result.getIsAdminOrAppAdminOrAppOfficerRoles()
        result.getIsAdminOrAppAdminOrAppReadOnlyRoles()
        !result.getIsAdminOrAppAdminRoles()
        !result.getIsAdminRole()
        !result.getIsAppAdminRole()
        !result.getIsAppOfficerRole()
        result.getIsAppReadOnlyRole()
        result.getIsLoggedInRole()
        result.getIsUserRole()
    }

    void "get user permissions by id"() {
        given:
        def userRoleName = realRoleService.getRoleUserdetailsUser()
        def adminRoleName = realRoleService.getRoleUserdetailsAdmin()
        def appReadOnlyRoleName = realRoleService.getRoleUserdetailsAppReadOnly()
        def appOfficerRoleName = realRoleService.getRoleUserdetailsAppOfficer()
        def appAdminRoleName = realRoleService.getRoleUserdetailsAppAdmin()

        def userId = TestingHelpers.randomId
        def user = new AppUserDetails(userId: userId, roles: [appAdminRoleName])

        when:
        def result = service.getUserPermissions(userId)

        then:
        1 * utilService.getUserById(userId) >> user
        1 * webService.getJson("null/permissions/getUserRolesForUserId/${userId}", null, true) >> [roles: []]
        1 * roleService.getRoleUserdetailsUser() >> userRoleName
        1 * roleService.getRoleUserdetailsAdmin() >> adminRoleName
        1 * roleService.getRoleUserdetailsAppReadOnly() >> appReadOnlyRoleName
        1 * roleService.getRoleUserdetailsAppOfficer() >> appOfficerRoleName
        1 * roleService.getRoleUserdetailsAppAdmin() >> appAdminRoleName
        0 * _
        noExceptionThrown()
        result != null
        result.getUser() == user
        result.countAccessLevels == 0
        result.countRoles == 2
        result.getIsAdminOrAppAdminOrAppOfficerRoles()
        result.getIsAdminOrAppAdminOrAppReadOnlyRoles()
        result.getIsAdminOrAppAdminRoles()
        !result.getIsAdminRole()
        result.getIsAppAdminRole()
        !result.getIsAppOfficerRole()
        !result.getIsAppReadOnlyRole()
        result.getIsLoggedInRole()
        !result.getIsUserRole()
    }

    void "transforms roles and access levels into correct structure for AppUserPermissions"() {
        given:
        def userRoleName = realRoleService.getRoleUserdetailsUser()
        def adminRoleName = realRoleService.getRoleUserdetailsAdmin()
        def appReadOnlyRoleName = realRoleService.getRoleUserdetailsAppReadOnly()
        def appOfficerRoleName = realRoleService.getRoleUserdetailsAppOfficer()
        def appAdminRoleName = realRoleService.getRoleUserdetailsAppAdmin()

        def roles = [userRoleName, adminRoleName]

        def userId = TestingHelpers.randomId
        def user = new AppUserDetails(userId: userId, roles: roles)

        def hubId = TestingHelpers.randomId
        def projectId = TestingHelpers.randomId
        def siteId = TestingHelpers.randomId
        def organisationId = TestingHelpers.randomId

        // one medium complexity example to test permission service transforms the data structure correctly
        def accessLevels = [
                [entityId: projectId, entityType: PermissionService.ENTITY_PROJECT, role: RoleService.PROJECT_EDITOR_ROLE],
                [entityId: hubId, entityType: PermissionService.ENTITY_HUB, role: RoleService.PROJECT_ADMIN_ROLE],
                [entityId: organisationId, entityType: PermissionService.ENTITY_ORGANISATION, role: RoleService.PROJECT_MODERATOR_ROLE],
                [entityId: projectId, entityType: PermissionService.ENTITY_PROJECT, role: RoleService.STARRED_ROLE],

                // some other permissions that aren't relevant to the checks being made
                [entityId: TestingHelpers.randomId + "-other-hub", entityType: PermissionService.ENTITY_HUB, role: RoleService.PROJECT_ADMIN_ROLE],
                [entityId: TestingHelpers.randomId + "-other-org", entityType: PermissionService.ENTITY_ORGANISATION, role: RoleService.PROJECT_ADMIN_ROLE],
        ]

        def boolProps = TestingHelpers.getAllMethodsBooleanNoArgs(AppUserEntitiesPermissions).collectEntries { [it, true] }
        def expected = TestingHelpers.mergeWith({ a, b -> b }, boolProps, [
                // org - from org moderator access level
                getIsOrganisationAdminLevel      : false,
                getIsOrganisationCaseManagerLevel: false,
                getIsOrganisationStarredLevel    : false,

                // site - none
                getIsSiteStarredLevel            : false,

                // hub - from hub admin access level

                // project - from project editor, project starred, hub admin access levels
                getIsProjectAdminLevel           : false,
                getIsProjectCaseManagerLevel     : false,
                getIsProjectModeratorLevel       : false,
        ])


        when:
        def aup = service.getUserPermissions(userId)
        def result = aup.getEntitiesPermissions(hubId, projectId, siteId, organisationId)
        def actual = boolProps.collectEntries { [it.key, result."${it.key}"()] }

        then:
        1 * utilService.getUserById(userId) >> user
        1 * webService.getJson("null/permissions/getUserRolesForUserId/${userId}", null, true) >> [roles: accessLevels]
        1 * roleService.getRoleUserdetailsUser() >> userRoleName
        1 * roleService.getRoleUserdetailsAdmin() >> adminRoleName
        1 * roleService.getRoleUserdetailsAppReadOnly() >> appReadOnlyRoleName
        1 * roleService.getRoleUserdetailsAppOfficer() >> appOfficerRoleName
        1 * roleService.getRoleUserdetailsAppAdmin() >> appAdminRoleName
        0 * _
        noExceptionThrown()

        aup.getUser() == user
        aup.countAccessLevels == 6
        aup.countRoles == 3

        result != null
        actual.size() == expected.size()
        actual.collect { it }.sort() == expected.collect { it }.sort()
    }

    @Unroll
    void "invalid user ids are caught with userId '#userId' loggedIn '#loggedIn'"(String userId, Boolean loggedIn) {
        given:
        def userRoleName = realRoleService.getRoleUserdetailsUser()
        def adminRoleName = realRoleService.getRoleUserdetailsAdmin()
        def appReadOnlyRoleName = realRoleService.getRoleUserdetailsAppReadOnly()
        def appOfficerRoleName = realRoleService.getRoleUserdetailsAppOfficer()
        def appAdminRoleName = realRoleService.getRoleUserdetailsAppAdmin()

        def user = new AppUserDetails(userId: userId, roles: [userRoleName, appAdminRoleName])

        when:
        def result = service.getUserPermissions(userId)

        then:
        1 * utilService.getUserById(userId) >> user
        if (userId) {
            1 * webService.getJson("null/permissions/getUserRolesForUserId/${userId}", null, true) >> [roles: []]
        }
        if (loggedIn) {
            1 * roleService.getRoleUserdetailsUser() >> userRoleName
            1 * roleService.getRoleUserdetailsAdmin() >> adminRoleName
            1 * roleService.getRoleUserdetailsAppReadOnly() >> appReadOnlyRoleName
            1 * roleService.getRoleUserdetailsAppOfficer() >> appOfficerRoleName
            1 * roleService.getRoleUserdetailsAppAdmin() >> appAdminRoleName
        }
        0 * _
        noExceptionThrown()
        result != null
        result.getUser() == user
        result.countAccessLevels == 0
        result.countRoles == (loggedIn ? 3 : 0)
        result.getIsAdminOrAppAdminOrAppOfficerRoles() == loggedIn
        result.getIsAdminOrAppAdminOrAppReadOnlyRoles() == loggedIn
        result.getIsAdminOrAppAdminRoles() == loggedIn
        !result.getIsAdminRole()
        result.getIsAppAdminRole() == loggedIn
        !result.getIsAppOfficerRole()
        !result.getIsAppReadOnlyRole()
        result.getIsLoggedInRole() == loggedIn
        result.getIsUserRole() == loggedIn

        where:
        userId | loggedIn
        "1234" | true
        ""     | false
        null   | false
        "abc"  | false
        "-123" | false
    }
}
