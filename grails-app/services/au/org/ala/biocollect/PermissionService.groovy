package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CacheService
import au.org.ala.biocollect.merit.RoleService
import au.org.ala.biocollect.merit.WebService
import au.org.ala.biocollect.permissions.AppUserDetails
import au.org.ala.biocollect.permissions.AppUserPermissions
import grails.core.GrailsApplication

/**
 * Defines the available permissions and entity types.
 * Decides whether a user has permissions based on the roles and access levels.
 */
class PermissionService {
    GrailsApplication grailsApplication
    RoleService roleService
    UtilService utilService
    WebService webService
    CacheService cacheService

    /*
     * Ecodata Entity Types used for permissions checks.
     */

    public static final String ENTITY_DOCUMENT = 'au.org.ala.ecodata.Document'
    public static final String ENTITY_HUB = 'au.org.ala.ecodata.Hub'
    public static final String ENTITY_ORGANISATION = 'au.org.ala.ecodata.Organisation'
    public static final String ENTITY_PROJECT = 'au.org.ala.ecodata.Project'
    public static final String ENTITY_SITE = 'au.org.ala.ecodata.Site'

    public static final List<String> ALL_ENTITIES = [
            ENTITY_DOCUMENT,
            ENTITY_HUB,
            ENTITY_ORGANISATION,
            ENTITY_PROJECT,
            ENTITY_SITE,
    ]

    /**
     * Get all the Ecodata UserPermissions for this given userId.
     *
     *
     * Cached to allow for getting the updated user permissions if they change,
     * but also allow this method to be very fast, even for users with lots of permissions.
     *
     * That seems to be a good middle road between making sure updates are available,
     * and requesting possibly 100's of user permission entries for each user on every call.
     *
     * It also seems better than making lots of separate Ecodata api calls to check each aspect of a user's access.
     *
     * @param userId The user id.
     * @return All the UserPermissions for the user.
     */
    def getUserRolesForUserId(String userId) {
        if (!userId) return null
        def cacheAgeInDays = (1 / (24 * 60)) * 10  // 10 minutes
        return cacheService.get("permissionService-getUserRolesForUserId-${userId}", {

            String url = grailsApplication.config.ecodata.service.url + "/permissions/getUserRolesForUserId/${userId}"
            webService.getJson(url, null, true)
        }, cacheAgeInDays)
    }

    /**
     * Clear the cached Ecodata access levels for the given user.
     * @param userId Clear the cache for this user id.
     */
    void clearCachedUserRolesForUserId(String userId){
        cacheService.clear("permissionService-getUserRolesForUserId-${userId}")
    }

    /**
     * Build the user permissions for the given user id.
     * @param userId Build permissions for this user.
     * @return The application user permissions.
     */
    AppUserPermissions getUserPermissions(String userId) {
        def user = utilService.getUserById(userId)
        return buildUserPermissions(user)
    }

    /**
     * Build the user permissions for the current user.
     * @return The application user permissions.
     */
    AppUserPermissions getCurrentUserPermissions() {
        def user = utilService.currentUser
        return buildUserPermissions(user)
    }

    /**
     * Build the user permissions for the given user.
     * @param user The permissions are for this user.
     * @return The application user permissions.
     */
    protected AppUserPermissions buildUserPermissions(AppUserDetails user) {
        // Note that user can be null, this indicates not logged in.
        def userId = user?.userId

        // roles format: list of strings
        def roles = user?.roles ?: []

        // accessLevels format: [[entityId:it.entityId, entityType:it.entityType, role:it.accessLevel.name()]]
        List<Map> accessLevels = []

        // check if the roles or access levels api calls failed
        // the roles api call failed if there is no valid user or 'roles' is null (an empty list is success)
        def rolesApiSuccess = user != null && user?.roles != null

        // the access levels api call failed if the request does not have a json map with a 'roles' key,
        // or the 'roles' key is null (an empty list is success)
        def accessLevelsApiSuccess = false

        // to be logged in, a user must not be null and must have a valid userId (an integer greater than 0)
        def userIdCheck = user?.userId?.toString()?.trim()
        def isLoggedIn
        try {
            isLoggedIn = user != null && userIdCheck
            if (isLoggedIn) {
                def isGreaterThanZero = userIdCheck?.toBigInteger() > 0
                if (!isGreaterThanZero) {
                    log.error("Invalid user id '${user?.userId}'.")
                    isLoggedIn = false
                }
            }
        } catch (Exception e) {
            log.error("Invalid user id '${user?.userId}'.", e)
            isLoggedIn = false
        }

        // get the user's Ecodata access levels
        if (userId && isLoggedIn) {
            def accessLevelsResponse = getUserRolesForUserId(userId)
            accessLevelsApiSuccess = [
                    accessLevelsResponse,
                    accessLevelsResponse instanceof Map,
                    accessLevelsResponse?.error == null,
                    accessLevelsResponse?.roles != null
            ].every()
            if (accessLevelsApiSuccess && accessLevelsResponse?.roles) {
                accessLevels = accessLevelsResponse?.roles
            }
        }

        // if a user is not logged in, but has roles or access levels, this is a sign the auth system is not working correctly
        if (roles?.size() > 0 && accessLevels?.size() > 0 && !isLoggedIn) {
            log.error("A user that is not logged in must not have any roles or access levels. " +
                    "User '${user}'. Roles '${roles}'. AccessLevels '${accessLevels}'.")
        }

        // evaluate the CAS / Userdetails roles
        // a user must be logged in to have any roles
        Map<String, Boolean> rolesResult = [:]
        rolesResult[RoleService.ADMIN_ROLE] = isLoggedIn && roles.contains(roleService.roleUserdetailsAdmin)
        rolesResult[RoleService.APP_READ_ONLY_ROLE] = isLoggedIn && roles.contains(roleService.roleUserdetailsAppReadOnly)
        rolesResult[RoleService.APP_OFFICER_ROLE] = isLoggedIn && roles.contains(roleService.roleUserdetailsAppOfficer)
        rolesResult[RoleService.APP_ADMIN_ROLE] = isLoggedIn && roles.contains(roleService.roleUserdetailsAppAdmin)
        rolesResult[RoleService.USER_ROLE] = isLoggedIn && roles.contains(roleService.roleUserdetailsUser)
        rolesResult[RoleService.LOGGED_IN_USER_ROLE] = isLoggedIn

        // evaluate the Ecodata access levels
        // a user must be logged in to have any access levels
        Map<String, Map<String, List<String>>> accessLevelsResult = [:]
        if (isLoggedIn) {
            accessLevels.each { accessLevel ->
                def role = accessLevel.role?.toString()
                if (!accessLevelsResult.containsKey(role)) {
                    accessLevelsResult[role] = ([:] as Map<String, List<String>>)
                }

                def entityType = accessLevel.entityType?.toString()
                if (!accessLevelsResult[role].containsKey(entityType)) {
                    accessLevelsResult[role][entityType] = []
                }

                def entityId = accessLevel.entityId?.toString()
                if (!accessLevelsResult[role][entityType].contains(entityId)) {
                    accessLevelsResult[role][entityType].add(entityId)
                }
            }
        }

        // for debugging
        // def logDetails = [
        //         userId                : userId,
        //         accessLevels          : accessLevels,
        //         rolesApiSuccess       : rolesApiSuccess,
        //         accessLevelsApiSuccess: accessLevelsApiSuccess,
        // ]
        // log.warn("Creating app user permissions ${logDetails}.")

        return createUserPermissions(user, rolesApiSuccess, rolesResult, accessLevelsApiSuccess, accessLevelsResult)
    }

    /**
     * Create an application user permissions instance that can calculate the permissions for the given roles and access levels.
     * NOTE: This method may be overridden in a PermissionService subclass to return an AppUserPermissions subclass.
     * This is done to allow changing how roles and access levels map to permissions.
     *
     * @param user The permissions are for this user.
     * @param roles The user's roles.
     * @params rolesApiSuccess Did the role api call succeed?
     * @param accessLevels The user's access levels.
     * @param accessLevelsApiSuccess Did the access levels api call succeed?
     * @return The application user permissions.
     */
    protected AppUserPermissions createUserPermissions(
            AppUserDetails user,
            boolean rolesApiSuccess, Map<String, Boolean> roles,
            boolean accessLevelsApiSuccess, Map<String, Map<String, List<String>>> accessLevels
    ) {
        return new AppUserPermissions(user, rolesApiSuccess, roles, accessLevelsApiSuccess, accessLevels)
    }

}
