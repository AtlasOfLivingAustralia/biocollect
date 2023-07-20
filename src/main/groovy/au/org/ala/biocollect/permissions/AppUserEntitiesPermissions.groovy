package au.org.ala.biocollect.permissions

import au.org.ala.biocollect.PermissionService
import au.org.ala.biocollect.merit.RoleService
import org.apache.commons.lang.NullArgumentException

/**
 * Provides access to application user permissions for entities.
 *
 * All methods that start with 'getIs(roles)Role(s)(access levels)AccessLevel(s)' are for checking roles /  access levels.
 *
 * Note that the eventual goal is to use the permission checks instead of the role / access level checks,
 * as the role / access level checks are too broad and it is not clear how they map to actions available to users.
 *
 * All methods that start with 'getCan(action)(entity)(part of entity)' are for checking permissions.
 * The permissions checks include checking
 * relevant permissions for other entities (e.g. project permission checks include checking hub permissions), and
 * relevant roles, and
 * relevant entity access levels.
 *
 * The permissions for different Ecodata domain entities are all in this one object because
 * some permission checks require access to other entity types.
 *
 * This class is designed to be immutable.
 * The idea is to create an instance with a set of entity ids, and use the instance to check permissions.
 * If a different set of entity ids need to be checked, create a new instance with the new entity ids.
 *
 * Note that methods of this class must be able to be overridden in a subclass.
 *
 * Instances of this class must be created using an AppUserPermissions instance.
 */
class AppUserEntitiesPermissions {
    protected AppUserPermissions userPermissions
    protected AppEntitiesDetails entitiesDetails

    /**
     * Create a user entities permissions state object.
     * @param userPermissions The user permissions.
     * @param entitiesDetails The entities details to use for this user permissions object.
     */
    AppUserEntitiesPermissions(AppUserPermissions userPermissions, AppEntitiesDetails entitiesDetails) {
        if (!userPermissions) {
            throw new NullArgumentException("userPermissions")
        }
        this.userPermissions = userPermissions
        this.entitiesDetails = entitiesDetails
    }

    /*
     * General checks
     */

    /**
     * Provide access to the user permissions object wrapped by this entities permissions object.
     * @return
     */
    AppUserPermissions getUserPermissions() {
        this.userPermissions
    }

    /**
     * Convenience method to access app user permission entity check.
     * @param accessLevel
     * @param entityType
     * @param entityId
     * @return
     */
    protected boolean hasPermissionForEntity(String accessLevel, String entityType, String entityId) {
        this.userPermissions.hasAccessLevelForEntity(accessLevel, entityType, entityId)
    }

    /**
     * Convenience method to check for admin, app admin, project admin.
     * @return True if user has these roles or access level.
     */
    protected boolean getIsAdminOrAppAdminRolesOrProjectAdminLevel() {
        this.userPermissions.isAdminOrAppAdminRoles || isProjectAdminLevel
    }

    /**
     * Convenience method to check for admin, app admin, read only, project editor, hub admin.
     * @return True if user has these roles or access levels.
     */
    protected boolean getIsAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels() {
        this.userPermissions.isAdminOrAppAdminOrAppReadOnlyRoles || isProjectEditorLevel || isHubAdminLevel
    }

    /**
     * Convenience method to check for admin, app admin, app officer, project editor, hub admin.
     * @return True if user has these roles or access levels.
     */
    protected boolean getIsAdminOrAppAdminOrAppOfficerRolesOrProjectEditorOrHubAdminLevels() {
        this.userPermissions.isAdminOrAppAdminOrAppOfficerRoles || isProjectEditorLevel || isHubAdminLevel
    }

    /**
     * Convenience method to check for admin, app admin, app officer, project admin, hub admin.
     * @return True if user has these roles or access levels.
     */
    protected boolean getIsAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels() {
        this.userPermissions.isAdminOrAppAdminOrAppOfficerRoles || isProjectAdminLevel || isHubAdminLevel
    }

    /*
     * Checks for Hubs
     */

    /**
     * Can the user create a project in the hub?
     * @return True if the user has this permission.
     */
    boolean getCanCreateHubProjects() {
        this.userPermissions.isLoggedInRole && entitiesDetails?.hubId
    }

    /**
     * Can the user download project export from the 'download' button on All Projects page for a hub?
     * @return True if the user has this permission.
     */
    boolean getCanDownloadHubProjects() {
        this.userPermissions.isAdminOrAppAdminRoles || isHubAdminLevel
    }

    /**
     * Can the user user to add, remove, and edit all users' permissions for a hub?
     * @return True if the user has this permission.
     */
    boolean getCanManageHubUsers() {
        this.userPermissions.isAdminOrAppAdminRoles || isHubAdminLevel
    }

    /**
     * Can the user edit the hub details?
     * @return True if the user has this permission.
     */
    boolean getCanEditHubDetails() {
        this.userPermissions.isAdminOrAppAdminRoles || isHubAdminLevel
    }

    /**
     * Does the user have Ecodata hub admin access?
     * @return True if user has this access level.
     */
    boolean getIsHubAdminLevel() {
        hasPermissionForEntity(RoleService.PROJECT_ADMIN_ROLE, PermissionService.ENTITY_HUB, entitiesDetails?.hubId)
    }

    /*
     * Checks for Projects
     */

    /**
     * Can the user view any part of the project about tab?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectAboutAnyPart() {
        canViewProjectAboutTabAboutTheProject || canViewProjectAboutTabProjectInformation ||
                canViewProjectAboutTabAssociatedOrgs || canViewProjectArea
    }

    /**
     * Can the user view the project about tab 'About the Project' section?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectAboutTabAboutTheProject() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user view the project about tab 'Project Information' section?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectAboutTabProjectInformation() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user view the project about tab 'run in association with' section?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectAboutTabAssociatedOrgs() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user view the project news?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectNews() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user edit the project news?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectNews() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project public resources?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectResourcesPublic() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user view the project private resources?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectResourcesPrivate() {
        isAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user view any project resources?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectResourcesAnyPart() {
        canViewProjectResourcesPublic || canViewProjectResourcesPrivate
    }

    /**
     * Can the user edit the project resources?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectResources() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project activities?
     * Includes Surveys and Data tabs for 'survey' projects, and Work Schedule tab for 'works' projects
     * Also for dashboard tab (Milestones are a type of activity).
     * Also for targets and metrics, which are based on activities.
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectActivities() {
        this.userPermissions?.isLoggedInRole && !this.entitiesDetails?.projectIsExternal
    }

    /**
     * Can the user edit the project activities?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectActivities() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user edit the project activities outputs?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectActivitiesOutput() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user view the project geographic area?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectArea() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user view the project sites?
     * project sites - view: can see existing sites but not change
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectSites() {
        !this.entitiesDetails?.projectIsExternal && isAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user edit the project sites?
     * can add new sites if configured for project
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectSites() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user manage the project sites?
     * can change project settings to allow adding / changing sites
     * @return True if the user has this permission.
     */
    boolean getCanManageProjectSites() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project plan?
     * project plan includes priorities, implementation, partnerships, questions.
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectPlan() {
        isAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user edit the project plan?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectPlan() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project risks?
     * project risk includes risks and threats, issues
     * view is also for dashboard tab
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectRisks() {
        isAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user edit the project risks?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectRisks() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project outcomes?
     * project outcomes includes outcomes (objectives), outcomes monitoring
     * view is also for dashboard tab
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectOutcomes() {
        isAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user edit the project outcomes?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectOutcomes() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project outcomes progress?
     * project outcomes progress is separate from project outcomes.
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectOutcomesProgress() {
        isAdminOrAppAdminOrAppReadOnlyRolesOrProjectEditorOrHubAdminLevels
    }

    /**
     * Can the user edit the project outcomes progress?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectOutcomesProgress() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project funding and budget?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectFundingBudget() {
        !this.entitiesDetails?.projectIsExternal && (
                this.userPermissions?.isAdminOrAppAdminOrAppReadOnlyRoles ||
                        isProjectCaseManagerLevel ||
                        isHubAdminLevel)
    }

    /**
     * Can the user edit the project funding and budget?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectFundingBudget() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project audit records?
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectAudit() {
        isAdminOrAppAdminOrAppOfficerRolesOrProjectAdminOrHubAdminLevels
    }

    /**
     * Can the user view the project report?
     * project reports- summary webpage and pdf - use the relevant view permissions to decide what to display
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectReport() {
        isAdminOrAppAdminRolesOrProjectAdminLevel
    }

    /**
     * Can the user edit all users' access to the project?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectAccess() {
        isAdminOrAppAdminRolesOrProjectAdminLevel
    }

    /**
     * Can the user edit project details?
     * @return True if the user has this permission.
     */
    boolean getCanEditProjectDetails() {
        isAdminOrAppAdminRolesOrProjectAdminLevel
    }

    /**
     * Can the user view any part of the project admin?
     * Note that this permission only checks whether the user has at least one of the permissions needed
     * to view a part of the project admin.
     * This permission DOES NOT mean the user can view or edit all parts of the project admin.
     * Use the individual view and edit checks to decide whether to render the parts.
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectAdminAnyPart() {
        // view
        canViewProjectAudit ||
                canViewProjectReport ||
                // edit
                canEditProjectNews ||
                canEditProjectResources ||
                canEditProjectActivities ||
                canEditProjectSites ||
                canEditProjectPlan ||
                canEditProjectRisks ||
                canEditProjectOutcomes ||
                canEditProjectOutcomesProgress ||
                canEditProjectFundingBudget ||
                canEditProjectAccess ||
                canEditProjectDetails ||
                // manage
                canManageProjectSites ||
                // delete
                canDeleteProject

    }

    /**
     * Can the user view any part of the project dashboard?
     * Note that this permission only checks whether the user has at least one of the permissions needed
     * to view a part of the project dashboard.
     * This permission DOES NOT mean the user can view all parts of the project dashboard.
     * Use the individual view and edit checks to decide whether to render the parts.
     * @return True if the user has this permission.
     */
    boolean getCanViewProjectDashboardAnyPart() {
        !this.entitiesDetails?.projectIsExternal &&
                (canViewProjectActivities ||
                        canViewProjectRisks ||
                        canViewProjectOutcomes ||
                        canViewProjectOutcomesProgress)
    }

    /**
     * Can the user access any part of the project?
     * @return True if the user has this permission.
     */
    boolean getCanAccessProjectAnyPart() {
        !this.entitiesDetails?.projectIsExternal &&
                // view
                (canViewProjectAboutAnyPart ||
                        canViewProjectNews ||
                        canViewProjectResourcesAnyPart ||
                        canViewProjectActivities ||
                        canViewProjectSites ||
                        canViewProjectPlan ||
                        canViewProjectRisks ||
                        canViewProjectOutcomes ||
                        canViewProjectOutcomesProgress ||
                        canViewProjectFundingBudget ||
                        canViewProjectAudit ||
                        canViewProjectReport ||
                        canViewProjectAdminAnyPart ||
                        canViewProjectDashboardAnyPart ||
                        // edit
                        canEditProjectNews ||
                        canEditProjectResources ||
                        canEditProjectActivities ||
                        canEditProjectActivitiesOutput ||
                        canEditProjectSites ||
                        canEditProjectPlan ||
                        canEditProjectRisks ||
                        canEditProjectOutcomes ||
                        canEditProjectOutcomesProgress ||
                        canEditProjectFundingBudget ||
                        canEditProjectAccess ||
                        canEditProjectDetails ||
                        // others
                        canManageProjectSites ||
                        canDeleteProject)
    }

    /**
     * Can the user delete the project?
     * @return True if the user has this permission.
     */
    boolean getCanDeleteProject() {
        isAdminOrAppAdminRolesOrProjectAdminLevel
    }

    /**
     * Does the user have Ecodata project admin access?
     * @return True if user has this access level.
     */
    boolean getIsProjectAdminLevel() {
        hasPermissionForEntity(RoleService.PROJECT_ADMIN_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
    }

    /**
     * Does the user have Ecodata project grant manager / case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsProjectCaseManagerLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.GRANT_MANAGER_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
        hasAccess || isProjectAdminLevel
    }

    /**
     * Does the user have Ecodata project moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsProjectModeratorLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_MODERATOR_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
        hasAccess || isProjectCaseManagerLevel
    }

    /**
     * Does the user have Ecodata project editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsProjectEditorLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_EDITOR_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
        hasAccess || isProjectModeratorLevel
    }

    /**
     * Does the user have Ecodata project participant or editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsProjectParticipantLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_PARTICIPANT_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
        hasAccess || isProjectEditorLevel
    }

    /**
     * Does the user have Ecodata project read-only or participant or editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsProjectReadOnlyLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.READ_ONLY_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
        hasAccess || isProjectParticipantLevel
    }

    /**
     * Does the user have Ecodata project starred level?
     * The starred access level does not check the access levels with higher code number.
     * @return True if user has this access level.
     */
    boolean getIsProjectStarredLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.STARRED_ROLE, PermissionService.ENTITY_PROJECT, entitiesDetails?.projectId)
        hasAccess
    }

    /*
     * Checks for Sites
     */

    /**
     * Does the user have Ecodata site admin access?
     * @return True if user has this access level.
     */
    boolean getIsSiteAdminLevel() {
        hasPermissionForEntity(RoleService.PROJECT_ADMIN_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
    }

    /**
     * Does the user have Ecodata site grant manager / case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsSiteCaseManagerLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.GRANT_MANAGER_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
        hasAccess || isSiteAdminLevel
    }

    /**
     * Does the user have Ecodata site moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsSiteModeratorLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_MODERATOR_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
        hasAccess || isSiteCaseManagerLevel
    }

    /**
     * Does the user have Ecodata site editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsSiteEditorLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_EDITOR_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
        hasAccess || isSiteModeratorLevel
    }

    /**
     * Does the user have Ecodata site participant or editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsSiteParticipantLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_PARTICIPANT_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
        hasAccess || isSiteEditorLevel
    }

    /**
     * Does the user have Ecodata site read-only or participant or editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsSiteReadOnlyLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.READ_ONLY_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
        hasAccess || isSiteParticipantLevel
    }

    /**
     * Does the user have Ecodata site starred level?
     * The starred access level does not check the access levels with higher code number.
     * @return True if user has this access level.
     */
    boolean getIsSiteStarredLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.STARRED_ROLE, PermissionService.ENTITY_SITE, entitiesDetails?.siteId)
        hasAccess
    }

    /*
     * Checks for Organisations
     */

    /**
     * Can the user create an organisation?
     * @return True if the user has this permission.
     */
    boolean getCanCreateOrganisation() {
        this.userPermissions.isLoggedInRole
    }

    /**
     * Can the user view the organisation about?
     * @return True if the user has this permission.
     */
    boolean getCanViewOrganisationAbout() {
        // available to anon and logged in users
        true
    }

    /**
     * Can the user view the organisation projects?
     * @return True if the user has this permission.
     */
    boolean getCanViewOrganisationProjects() {
        this.userPermissions.isLoggedInRole
    }

    /**
     * Can the user view the organisation activities?
     * @return True if the user has this permission.
     */
    boolean getCanViewOrganisationActivities() {
        this.userPermissions.isLoggedInRole
    }

    /**
     * Can the user edit the organisation details?
     * @return True if the user has this permission.
     */
    boolean getCanEditOrganisationDetails() {
        this.userPermissions.isAdminOrAppAdminRoles || isOrganisationAdminLevel
    }

    /**
     * Can the user edit the organisation access?
     * @return True if the user has this permission.
     */
    boolean getCanEditOrganisationAccess() {
        this.userPermissions.isAdminOrAppAdminRoles || isOrganisationAdminLevel
    }

    /**
     * Can the user delete the organisation?
     * @return True if the user has this permission.
     */
    boolean getCanDeleteOrganisation() {
        this.userPermissions.isAdminOrAppAdminRoles || isOrganisationAdminLevel
    }

    /**
     * Can the user view the organisation admin?
     * Note that this permission only checks whether the user has at least one of the permissions needed
     * to view or edit a part of the organisation admin.
     * This permission DOES NOT mean the user can view or edit all parts of the organisation admin.
     * Use the individual view and edit checks to decide whether to render the parts.
     * @return True if the user has this permission.
     */
    boolean getCanViewOrganisationAdminAnyPart() {
        canEditOrganisationDetails || canEditOrganisationAccess || canDeleteOrganisation
    }

    /**
     * Does the user have Ecodata organisation admin access?
     * @return True if user has this access level.
     */
    boolean getIsOrganisationAdminLevel() {
        hasPermissionForEntity(RoleService.PROJECT_ADMIN_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
    }

    /**
     * Does the user have Ecodata organisation grant manager / case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsOrganisationCaseManagerLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.GRANT_MANAGER_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
        hasAccess || isOrganisationAdminLevel
    }

    /**
     * Does the user have Ecodata organisation moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsOrganisationModeratorLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_MODERATOR_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
        hasAccess || isOrganisationCaseManagerLevel
    }

    /**
     * Does the user have Ecodata organisation editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsOrganisationEditorLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_EDITOR_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
        hasAccess || isOrganisationModeratorLevel
    }

    /**
     * Does the user have Ecodata organisation participant or editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsOrganisationParticipantLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.PROJECT_PARTICIPANT_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
        hasAccess || isOrganisationEditorLevel
    }

    /**
     * Does the user have Ecodata organisation read-only or participant or editor or moderator or case manager or admin access?
     * @return True if user has this access level.
     */
    boolean getIsOrganisationReadOnlyLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.READ_ONLY_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
        hasAccess || isOrganisationParticipantLevel
    }

    /**
     * Does the user have Ecodata organisation starred level?
     * The starred access level does not check the access levels with higher code number.
     * @return True if user has this access level.
     */
    boolean getIsOrganisationStarredLevel() {
        def hasAccess = hasPermissionForEntity(RoleService.STARRED_ROLE, PermissionService.ENTITY_ORGANISATION, entitiesDetails?.organisationId)
        hasAccess
    }
}
