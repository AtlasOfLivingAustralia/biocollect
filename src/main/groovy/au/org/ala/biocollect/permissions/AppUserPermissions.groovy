package au.org.ala.biocollect.permissions

import au.org.ala.biocollect.PermissionService
import au.org.ala.biocollect.merit.RoleService
import org.apache.commons.lang.NullArgumentException

/**
 * Provides access to application user permissions.
 *
 * All methods in the form 'getIs(one or more roles)Role(s)' are for checking roles.
 *
 * Note that the eventual goal is to use the permission checks in AppUserEntitiesPermissions instead of the role checks,
 * as the role checks are too broad and it is not clear how they map to actions available to users.
 *
 * This class is designed to be immutable.
 * The idea is to create an instance with a user and sets of roles and access levels, and use the instance to check roles and access levels for that user.
 * If a different user or set of roles and access levels need to be checked, create a new instance with the new user, roles, and access levels.
 *
 * Note that methods of this class must be able to be overridden in a subclass.
 *
 * Instances of this class must be created using the PermissionService.
 */
@SuppressWarnings('GrMethodMayBeStatic')
class AppUserPermissions {
    protected AppUserDetails user
    protected Map<String, Boolean> roles
    protected boolean rolesApiSuccess
    protected Map<String, Map<String, List<String>>> accessLevels
    protected boolean accessLevelsApiSuccess

    /**
     * Create a user permissions state object.
     * @param user The user details.
     * @param roles The roles for the user [RoleService.(CAS role name): (is user in role?)].
     * @param rolesApiSuccess True if the api call to get the user CAS / Userdetails roles succeeded.
     * @param accessLevels The access levels for the user [RoleService.(Ecodata access level): [PermissionService.(entity type): [(entity id), ...]]].
     * @param accessLevelsApiSuccess True if the api call to get the user Ecodata access levels succeeded.
     */
    AppUserPermissions(AppUserDetails user,
                       boolean rolesApiSuccess, Map<String, Boolean> roles,
                       boolean accessLevelsApiSuccess, Map<String, Map<String, List<String>>> accessLevels) {
        this.user = user
        this.roles = roles ?: [:]
        this.rolesApiSuccess = rolesApiSuccess
        this.accessLevels = accessLevels ?: [:]
        this.accessLevelsApiSuccess = accessLevelsApiSuccess
    }

    /**
     * Get the user details.
     * @return The user details.
     */
    AppUserDetails getUser() {
        this.user
    }

    /**
     * Did the roles api call succeed?
     * @return True if the api call to get the user CAS / Userdetails roles succeeded.
     */
    boolean getIsRolesApiSuccess() {
        return rolesApiSuccess
    }

    /**
     * Dis the access level api call succeed?
     * @return True if the api call to get the user Ecodata access levels succeeded.
     */
    boolean getIsAccessLevelsApiSuccess() {
        return accessLevelsApiSuccess
    }

    /**
     * Get the number of CAS / Userdetails roles.
     * @return The number of roles.
     */
    int getCountRoles() {
        // count the number of roles that are true
        this.roles?.inject(0, { sum, value -> value?.value ? sum + 1 : sum })
    }

    /**
     * Get the number of Ecodata access levels.
     * @return The number of access levels.
     */
    int getCountAccessLevels() {
        // count the number of distinct AccessLevel, EntityType, EntityId combinations
        this.accessLevels?.inject(0, { sumAccessLevel, accessLevel ->
            sumAccessLevel + accessLevel?.value?.inject(0, { sumEntityType, entityType ->
                sumEntityType + entityType?.value?.size() ?: 0
            })
        })
    }

    /**
     * Get the entities permissions using the given entity ids.
     * @param entitiesDetails The entities details to use for this user permissions object.
     */
    AppUserEntitiesPermissions getEntitiesPermissions(AppEntitiesDetails entitiesDetails) {
        new AppUserEntitiesPermissions(this, entitiesDetails)
    }

    /**
     * Does the user have the access level for the entity with the id?
     * @param accessLevel The access level from the RoleService.
     * @param entityType The entity type from the PermissionService.
     * @param entityId The entity id.
     * @return True if the user has the access level for the entity.
     */
    boolean hasAccessLevelForEntity(String accessLevel, String entityType, String entityId) {
        // guard against String != GString
        accessLevel = accessLevel?.toString()
        entityType = entityType?.toString()
        entityId = entityId?.toString()

        if (!accessLevel?.trim()) {
            throw new NullArgumentException("accessLevel")
        }
        if (!RoleService.ALL_ACCESS_LEVELS.contains(accessLevel)) {
            throw new IllegalArgumentException("Unknown accessLevel '${accessLevel}'.")
        }

        if (!entityType?.trim()) {
            throw new NullArgumentException("entityType")
        }
        if (!PermissionService.ALL_ENTITIES.contains(entityType)) {
            throw new IllegalArgumentException("Unknown entityType '${entityType}'.")
        }

        if (!entityId?.trim()) {
            // entity id is allowed to be null, but no entity id is always false for permission check
            return false
        }

        return accessLevels.get(accessLevel)?.get(entityType)?.contains(entityId)
    }

    /**
     * Does the user have the given CAS / Userdetails role?
     * @param role The role to check.
     * @return True if the user has the role.
     */
    boolean hasRole(String role) {
        if (!role?.trim()) {
            throw new NullArgumentException("role")
        }
        if (!RoleService.ALL_ROLES.contains(role)) {
            throw new IllegalArgumentException("Unknown role '${role}'.")
        }

        roles.get(role)
    }

    /**
     * Does the user have the CAS / Userdetails admin role?
     * @return True if the user has the role.
     */
    boolean getIsAdminRole() {
        hasRole(RoleService.ADMIN_ROLE)
    }

    /**
     * Does the user have the CAS / Userdetails application read-only role?
     * @return True if the user has the role.
     */
    boolean getIsAppReadOnlyRole() {
        hasRole(RoleService.APP_READ_ONLY_ROLE)
    }

    /**
     * Does the user have the CAS / Userdetails application officer role?
     * @return True if the user has the role.
     */
    boolean getIsAppOfficerRole() {
        hasRole(RoleService.APP_OFFICER_ROLE)
    }

    /**
     * Does the user have the CAS / Userdetails application admin role?
     * @return True if the user has the role.
     */
    boolean getIsAppAdminRole() {
        hasRole(RoleService.APP_ADMIN_ROLE)
    }

    /**
     * Does the user have the CAS / Userdetails user role?
     * @return True if the user has the role.
     */
    boolean getIsUserRole() {
        hasRole(RoleService.USER_ROLE)
    }

    /**
     * Does the user have the CAS / Userdetails is logged in role?
     * @return True if the user has the role.
     */
    boolean getIsLoggedInRole() {
        hasRole(RoleService.LOGGED_IN_USER_ROLE)
    }

    /**
     * Does the user have any of the CAS / Userdetails roles admin, application admin, or application officer?
     * @return True if the user has any of the roles.
     */
    boolean getIsAdminOrAppAdminOrAppOfficerRoles() {
        isAdminRole || isAppAdminRole || isAppOfficerRole
    }

    /**
     * Does the user have any of the CAS / Userdetails roles admin or application admin?
     * @return True if the user has any of the roles.
     */
    boolean getIsAdminOrAppAdminRoles() {
        isAdminRole || isAppAdminRole
    }

    /**
     * Does the user have any of the CAS / Userdetails roles admin or application admin or application read-only?
     * @return True if the user has any of the roles.
     */
    boolean getIsAdminOrAppAdminOrAppReadOnlyRoles() {
        isAdminRole || isAppAdminRole || isAppReadOnlyRole
    }
}
