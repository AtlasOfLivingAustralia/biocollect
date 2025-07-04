package au.org.ala.biocollect.merit

import au.org.ala.ecodata.forms.EcpWebService
import grails.converters.JSON
import grails.web.mapping.LinkGenerator
import grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.context.MessageSource

/**
 * Proxies to the ecodata DocumentController/DocumentService.
 */
class DocumentService {
    private static final String DOCUMENT_FILTER = "className:au.org.ala.ecodata.Document"
    public String ROLE_LOGO = "logo"

    def webService, grailsApplication
    MessageSource messageSource
    UserService userService
    ActivityService activityService
    SearchService searchService
    ProjectService projectService
    SettingService settingService
    LinkGenerator grailsLinkGenerator
    CommonService commonService
    EcpWebService ecpWebService

    def get(String id) {
        def url = "${grailsApplication.config.getProperty('ecodata.service.url')}/document/${id}"
        return webService.getJson(url)
    }

    def delete(String id) {
        def url = "${grailsApplication.config.getProperty('ecodata.service.url')}document/${id}"
        return webService.doDelete(url)
    }

    def createTextDocument(doc, content) {
        doc.content = content
        updateDocument(doc)
    }

    def updateDocument(doc) {
        def url = "${grailsApplication.config.getProperty('ecodata.service.url')}/document/${doc.documentId?:''}"

        return webService.doPost(url, doc)
    }

    def createDocument(doc, contentType, inputStream) {

        def url = grailsApplication.config.getProperty('ecodata.service.url') + "/document"

        def params = [document:doc as JSON]
        return webService.postMultipart(url, params, inputStream, contentType, doc.filename)
    }

    def getDocumentsForSite(id) {
        def url = "${grailsApplication.config.getProperty('ecodata.service.url')}/site/${id}/documents"
        return webService.doPost(url, [:])
    }

    /**
     * This method saves a document that has been staged (the image uploaded, but the document object not
     * created).  The purpose of this is to support atomic create / edits of objects that include document
     * references, e.g. activities containing photo point photos and organisations.
     * @param document the document to save.
     */
    def saveStagedImageDocument(document) {
        def result
        if (!document.documentId) {
            document.remove('url')
            def file = new File(grailsApplication.config.upload.images.path, document.filename)
            // Create a new document, supplying the file that was uploaded to the ImageController.
            result = createDocument(document, document.contentType, new FileInputStream(file))
            if (org.springframework.http.HttpStatus.resolve(result.statusCode as int).is2xxSuccessful()) {
                file.delete()
            }
        }
        else {
            // Just update the document.
            result = updateDocument(document)
        }
        result
    }

    def saveLink(link) {
        link.public = true
        link.type = "link"
        link.externalUrl = link.remove('url')
        updateDocument(link)
    }

    Map search(Map params) {
        def url = "${grailsApplication.config.ecodata.baseURL}/ws/document/search"
        def resp = webService.doPost(url, params)
        if (resp && !resp.error) {
            return resp.resp
        }
        return resp
    }

    /**
     * Download documents with search criteria.
     * @param requestParams
     * @return
     */
    Map documentsDownload(GrailsParameterMap requestParams) {
        Map params = populateDocumentSearchParameters(requestParams)
        params.email = userService.getUser().email
        params.downloadUrl = grailsLinkGenerator.link(controller: 'download', action: 'downloadProjectDataFile', absolute: true) + '/'
        ecpWebService.getJson2("${grailsApplication.config.getProperty('ecodata.service.url')}/search/downloadAllDocuments" + commonService.buildUrlParamsFromMap(params))
    }

    Map allDocumentsSearch(GrailsParameterMap requestParams) {
        Map params = populateDocumentSearchParameters(requestParams)
        Map results = searchService.fulltextSearch(
                params, true
        )

        //add the associated projectId when viewing hub documents
        if (!projectId) {
            Map project

            if (results) {
                for (int i = 0; i < results.hits.hits.size(); i++) {
                    project = projectService.get(results.hits.hits[i]._source.projectId)

                    if (project)
                        results.hits.hits[i]._source.put("projectName", project.name)
                }
            }
        }

        results
    }

    Map populateDocumentSearchParameters(GrailsParameterMap requestParams) {
        String searchType = requestParams.searchType
        String searchTerm = requestParams.searchTerm
        String searchInRole = requestParams.searchInRole
        String projectId = requestParams.projectId
        int offset = requestParams.getInt('offset', 0)
        int max = requestParams.getInt('max', 100)
        String hub = settingService.getHubConfig().urlPath
        String order = requestParams.order
        String sort = requestParams.sort
        String searchTextBy = ""
        Map params

        if (searchType == 'none' && searchTerm)
            searchTextBy += "(name:" + searchTerm + " OR labels:" + searchTerm + " OR attribution:" + searchTerm + " OR citation:" + searchTerm + " OR description:" + searchTerm + ")";

        if (searchType && searchTerm) {
            if (searchType != 'none')
                searchTextBy += searchType + ":" + searchTerm;
        }

        if (searchInRole) {
            if (searchInRole != 'none') {
                if (!searchTextBy.isEmpty())
                    searchTextBy += " AND role:" + searchInRole;
                else
                    searchTextBy += "role:" + searchInRole;
            }
        }

        //projectId is passed in the case of viewing project documents
        if (projectId) {
            if (!searchTextBy.isEmpty())
                searchTextBy += " AND projectId:" + projectId;
            else
                searchTextBy += "projectId:" + projectId;

            params = [
                    offset: offset,
                    max   : max,
                    query : searchTextBy,
                    fq    : DOCUMENT_FILTER
            ]

            Boolean isALAAdmin = userService.userIsAlaAdmin()

            String userId = userService.getCurrentUserId()

            boolean isViewable = isALAAdmin

            if (userId && !isALAAdmin) {
                def members = projectService.getMembersForProjectId(projectId)
                isViewable = members.find { it.userId == userId }
            }

            if (params.fq)
                params.fq = [params.fq]
            else
                params.fq = []

            // at project level admins and project members can view both public and private documents
            if (!isViewable)
                params.fq.push("publiclyViewable:true")

        } else { //when viewing hub documents
            params = [
                    offset: offset,
                    max   : max,
                    query : searchTextBy,
                    fq    : DOCUMENT_FILTER,
                    hub   : hub
            ]

            if (params.fq)
                params.fq = [params.fq]
            else
                params.fq = []

            // at hub level all users can view public documents only
            params.fq.push("publiclyViewable:true")
        }

        //exclude logo and mainImage roles
        params.fq.push("-role:logo")
        params.fq.push("-role:mainImage")

        if (order) {
            params.order = order
        }

        if (sort) {
            params.sort = sort
        }

        if (searchType) {
            params.type = searchType
        }

        if (searchInRole) {
            params.searchInRole = searchInRole
        }

        return params
    }

    /**
     * de reference licence code and adds the value to licenceDescription property
     * @param documents
     * @return
     */
    public List addLicenceDescription (List documents){
        documents?.each{ document ->
            if(document.licence){
                document.licenceDescription = messageSource.getMessage('licence.' + document.licence.replace(' ', '_'), [].toArray(), '', Locale.default);
            }
        }

        documents;
    }

    /**
     * Returns true if the current user has permission to edit/update the
     * supplied document.
     * @param document the document to be edited/updated
     */
    boolean canEdit(Map document) {
        if (document.documentId) {
            document = get(document.documentId)
        }
        boolean canEdit = false

        if (document) {
            // Only FC_ADMINS can edit an existing read only document, but
            // other roles can create them.
            if (document.readOnly && document.documentId) {
                canEdit = userService.userIsAlaOrFcAdmin()
            }
            else {
                canEdit = hasEditorPermission(document)
            }

        }

        canEdit
    }

    /** Returns true if the currently logged in user has permission to edit the supplied Document */
    private boolean hasEditorPermission(Map document) {
        boolean canEdit = userService.userIsAlaOrFcAdmin()
        if (!canEdit) {
            // Check the permissions that apply to the entity the document is
            // associated with.
            String userId = userService.getCurrentUserId()
            if (document.projectId) {
                canEdit = userService.canUserEditProject(userId, document.projectId)
            } else if (document.organisationId) {
                canEdit = userService.isUserAdminForOrganisation(userId, document.organisationId)
            }
            else if (document.activityId) {
                Map activity = activityService.get(document.activityId)
                if (activity?.projectId) {
                    canEdit = userService.canUserEditProject(userId, activity.projectId)
                }
            }
        }
        canEdit
    }
    /** Returns true if the currently logged in user has permission to view the supplied Document */
    boolean canView(Map document) {
        document.publiclyViewable || document.activityId || userService.userHasReadOnlyAccess() || hasEditorPermission(document)
    }

    /**
     * Returns true if the current user has permission to delete the
     * supplied document.
     * @param documentId the id of the document to be deleted
     */
    boolean canDelete(String documentId) {
        canEdit([documentId:documentId])
    }
}
