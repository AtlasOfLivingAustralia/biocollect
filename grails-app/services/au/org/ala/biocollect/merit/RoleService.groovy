package au.org.ala.biocollect.merit

import org.grails.web.json.JSONObject

class RoleService {
    def metadataService, cacheService

    public static final String GRANT_MANAGER_ROLE = 'caseManager'
    public static final String PROJECT_ADMIN_ROLE = 'admin'
    public static final String PROJECT_MODERATOR_ROLE = 'moderator'
    public static final String PROJECT_EDITOR_ROLE = 'editor'
    public static final String PROJECT_PARTICIPANT_ROLE = 'projectParticipant'
    public static final String LOGGED_IN_USER_ROLE = 'loggedInUser'
    public static final String READ_ONLY_ROLE = 'siteReadOnly'
    public static final String EDIT_SITE_ROLE = 'editSite'

    private List roles(Boolean clearCache = false) {
        if (clearCache) {
            log.info "Clearing cache for 'accessLevels'"
            cacheService.clear('accessLevels') // clear cache
        }

        def roles = metadataService.getAccessLevels().collect {
            if (it && it instanceof JSONObject && it.has('name')) {
                it.name
            } else {
                log.warn "Error getting accessLevels: ${it}"
            }
        }

        return roles?:[]
    }

    public List getRoles() {
        List<String> allRoles = roles() // cached
        if (allRoles.size() <= 1) {
            // possible empty list or value, due to pr  evious WS call timing out
            allRoles = roles(true) // reload with cleared cache
        }

        allRoles.findAll { it == PROJECT_ADMIN_ROLE || it == PROJECT_EDITOR_ROLE || it == PROJECT_PARTICIPANT_ROLE || it == PROJECT_MODERATOR_ROLE }
    }

    public List getAugmentedRoles() {
        def rolesCopy = getRoles().clone()
        rolesCopy.addAll(["alaAdmin","siteAdmin","officer",READ_ONLY_ROLE, LOGGED_IN_USER_ROLE, EDIT_SITE_ROLE]) // augment roles with these extra ones TODO: refactor this

        return rolesCopy
    }

    /**
     * Returns a List of roles that are relevant to controlling access to the features of a Hub.
     */
    List getHubRoles() {
        [LOGGED_IN_USER_ROLE, PROJECT_ADMIN_ROLE]
    }
}
