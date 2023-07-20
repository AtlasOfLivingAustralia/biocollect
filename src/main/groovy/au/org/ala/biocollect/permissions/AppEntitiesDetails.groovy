package au.org.ala.biocollect.permissions

import au.org.ala.biocollect.merit.hub.HubSettings
import groovy.transform.Immutable

/**
 * Captures details of Ecodata entities that are needed to determine permissions.
 */
@Immutable
class AppEntitiesDetails {
    String hubId
    String projectId
    String siteId
    String organisationId

    // TODO: store hub facet details for use in determining permissions
    // Map hubFacets

    boolean projectIsExternal
    String projectType
    String projectAccessRestriction

    /**
     * Create an application entities details instance from hub settings.
     * @param hub The hub settings
     * @return An application entities details instance.
     */
    static AppEntitiesDetails buildHub(HubSettings hub) {
        new AppEntitiesDetails(
                hubId: hub?.hubId?.toString()?.trim() ?: null,
                // hubFacets: hub?.hubFacets
        )
    }

    /**
     * Create an application entities details instance from hub settings and project data.
     * @param hub The hub settings
     * @param project The project data.
     * @return An application entities details instance.
     */
    static AppEntitiesDetails buildHubProject(HubSettings hub, Map project) {
        new AppEntitiesDetails(
                hubId: hub?.hubId?.toString()?.trim() ?: null,
                projectId: project?.projectId?.toString()?.trim() ?: null,
                // hubFacets: hub?.hubFacets,
                projectIsExternal: project?.isExternal?.toString()?.toBoolean() ?: false,
                projectType: project?.projectType?.toString()?.trim() ?: null,
                projectAccessRestriction: project?.userAccessRestriction?.toString()?.trim() ?: null,
        )
    }

    /**
     * Create an application entities details instance from organisation data.
     * @param organisation The organisation data.
     * @return An application entities details instance.
     */
    static AppEntitiesDetails buildOrganisation(Map organisation) {
        new AppEntitiesDetails(
                organisationId: organisation?.organisationId?.toString()?.trim() ?: null,
        )
    }
}
