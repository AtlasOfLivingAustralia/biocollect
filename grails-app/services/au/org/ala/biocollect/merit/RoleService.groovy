package au.org.ala.biocollect.merit

import grails.core.GrailsApplication

/**
 * Provides access to roles from various sources.
 * The sources are:
 * - Ecodata AccessLevels - roles from the AccessLevel enum in Ecodata
 * - CAS/Userdetails Roles - roles granted via CAS and Userdetails
 * - Biocollect Roles - these are 'representative' roles used for biocollect-specific checks
 */
class RoleService {
    GrailsApplication grailsApplication
    CacheService cacheService
    WebService webService

    /**
     * Ecodata administrator role for domain entities.
     */
    public static final String PROJECT_ADMIN_ROLE = 'admin'

    /**
     * Ecodata case / grant manager role for domain entities.
     */
    public static final String GRANT_MANAGER_ROLE = 'caseManager'

    /**
     * Ecodata moderator role for domain entities.
     */
    public static final String PROJECT_MODERATOR_ROLE = 'moderator'

    /**
     * Ecodata editor role for domain entities.
     */
    public static final String PROJECT_EDITOR_ROLE = 'editor'

    /**
     * Ecodata project participant role for domain entities.
     */
    public static final String PROJECT_PARTICIPANT_ROLE = 'projectParticipant'

    /**
     * Ecodata read-only role for domain entities.
     */
    public static final String READ_ONLY_ROLE = 'readOnly'

    /**
     * Ecodata starred role for domain entities.
     * Indicates a user has 'starred' an entity.
     */
    public static final String STARRED_ROLE = 'starred'

    /**
     * CAS / Userdetails administrator role.
     */
    public static final String ADMIN_ROLE = 'alaAdmin'

    /**
     * CAS / Userdetails application read-only role.
     */
    public static final String APP_READ_ONLY_ROLE = 'siteReadOnly'

    /**
     * CAS / Userdetails application officer role.
     */
    public static final String APP_OFFICER_ROLE = 'officer'

    /**
     * CAS / Userdetails application administrator role.
     */
    public static final String APP_ADMIN_ROLE = 'siteAdmin'

    /**
     * CAS / Userdetails user role.
     */
    public static final String USER_ROLE = 'alaUser'

    /**
     * Biocollect edit site role.
     */
    public static final String EDIT_SITE_ROLE = 'editSite'

    /**
     * Biocollect logged-in user role.
     */
    public static final String LOGGED_IN_USER_ROLE = 'loggedInUser'

    /**
     * Get all Ecodata access levels.
     * @return
     */
    public static final List<String> ALL_ACCESS_LEVELS = [
            PROJECT_ADMIN_ROLE,
            GRANT_MANAGER_ROLE,
            PROJECT_MODERATOR_ROLE,
            PROJECT_EDITOR_ROLE,
            PROJECT_PARTICIPANT_ROLE,
            READ_ONLY_ROLE,
            STARRED_ROLE
    ]

    /**
     * Get all CAS / Userdetails roles.
     * @return
     */
    public static final List<String> ALL_ROLES = [
            ADMIN_ROLE,
            APP_READ_ONLY_ROLE,
            APP_OFFICER_ROLE,
            APP_ADMIN_ROLE,
            USER_ROLE,
            LOGGED_IN_USER_ROLE,
    ]

    /**
     * CAS / Userdetails role that allows access to all of Biocollect.
     * Use 'ADMIN_ROLE' static property.
     * @return
     */
    String getRoleUserdetailsAdmin() {
        grailsApplication.config.getProperty('security.cas.alaAdminRole', "ROLE_ADMIN")
    }

    /**
     * CAS / Userdetails role that allows read-only access to selected admin functions.
     * Use 'APP_READ_ONLY_ROLE' static property.
     */
    String getRoleUserdetailsAppReadOnly() {
        grailsApplication.config.getProperty('security.cas.readOnlyOfficerRole', "ROLE_FC_READ_ONLY")
    }

    /**
     * CAS / Userdetails role that allows edit access to all projects (and some other entities?).
     * Use 'APP_OFFICER_ROLE' static property.
     * @return
     */
    String getRoleUserdetailsAppOfficer() {
        grailsApplication.config.getProperty('security.cas.officerRole', "ROLE_FC_OFFICER")
    }

    /**
     * CAS / Userdetails role that allows admin access to all projects (and some other entities?).
     * Use 'APP_ADMIN_ROLE' static property.
     * @return
     */
    String getRoleUserdetailsAppAdmin() {
        grailsApplication.config.getProperty('security.cas.adminRole', "ROLE_FC_ADMIN")
    }

    /**
     * CAS / Userdetails role given to all active users.
     * Use 'USER_ROLE' static property.
     * @return
     */
    String getRoleUserdetailsUser() {
        grailsApplication.config.getProperty('security.cas.alaUserRole', "ROLE_USER")
    }

    /**
     * Get the list of access levels from Ecodata.
     * @return
     */
    List<String> getEcodataRoles() {
        return cacheService.get('accessLevels', {
            webService.getJson(grailsApplication.config.ecodata.service.url + "/permissions/getAllAccessLevels?baseLevel=" + PROJECT_PARTICIPANT_ROLE)
        })
    }

    /**
     * Get all the Ecodata access levels that are relevant to Biocollect.
     */
    List<String> getEcodataRolesForBiocollect() {
        [
                PROJECT_ADMIN_ROLE,
                PROJECT_MODERATOR_ROLE,
                PROJECT_EDITOR_ROLE,
                PROJECT_PARTICIPANT_ROLE
        ]
    }

    /**
     * Get the roles that are relevant to Biocollect.
     */
    List<String> getBiocollectRoles() {
        ecodataRolesForBiocollect + [
                ADMIN_ROLE,
                APP_ADMIN_ROLE,
                APP_OFFICER_ROLE,
                APP_READ_ONLY_ROLE,
                LOGGED_IN_USER_ROLE,
                EDIT_SITE_ROLE
        ]
    }

    /**
     * Get the roles that are relevant to controlling access to the features of a Hub.
     */
    List<String> getHubRoles() {
        [
                LOGGED_IN_USER_ROLE,
                PROJECT_ADMIN_ROLE
        ]
    }
}
