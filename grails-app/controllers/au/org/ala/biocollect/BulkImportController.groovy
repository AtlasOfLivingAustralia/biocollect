package au.org.ala.biocollect

import au.org.ala.biocollect.merit.PreAuthorise
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService
import au.org.ala.web.SSO
import grails.converters.JSON
import org.apache.http.HttpStatus
import org.grails.web.converters.exceptions.ConverterException

import static org.apache.http.HttpStatus.*

@PreAuthorise(accessLevel = 'alaAdmin')
class BulkImportController {
    static allowedMethods = ['create'                   : 'POST', 'get': 'GET', 'list': 'GET', 'update': ['PUT', 'POST'],
                             'publishActivitiesImported': ['PUT', 'POST'], "deleteActivitiesImported": "DELETE",
                             "index"                    : "GET", "embargoActivitiesImported": ['PUT', 'POST']
    ]
    WebService webService
    UserService userService
    BulkImportService bulkImportService
    ProjectActivityService projectActivityService

    @PreAuthorise(accessLevel = 'alaAdmin')
    def list() {
        String sort = params.sort ?: "lastUpdated"
        String order = params.order ?: "desc"
        int offset = params.getInt('offset', 0)
        int max = params.getInt('max',10)
        String search = params.query ?: ""
        Map query = [sort: sort, order: order, max: max, offset: offset, query: search]
        if (params.hasProperty('userId')) {
            query.userId = params.userId
        }

        String url = grailsApplication.config.getProperty('ecodata.service.url') + "/bulkImport"
        Map result = webService.doGet(url, query)

        if (!result.error) {
            render text: result?.resp as JSON, contentType: 'application/json'
        } else {
            render text: getMessage(result), status: SC_INTERNAL_SERVER_ERROR, contentType: 'application/json'
        }
    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def create() {
        def json = request.JSON
        if (!json) {
            render text: [status: "error", error: "Request missing JSON content"] as JSON, status: SC_BAD_REQUEST, contentType: 'application/json'
        } else {
            Map result = bulkImportService.create(json)
            if (!result.error) {
                render text: result.resp as JSON, contentType: "application/json", status: result.statusCode
            } else {
                render text: getMessage(result), status: result.statusCode, contentType: 'application/json'
            }
        }

    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def update(String id) {
        def json = request.JSON
        if (!id) {
            render text: [status: "error", error: "Missing id"] as JSON, status: SC_BAD_REQUEST, contentType: "application/json"
        } else if (!json) {
            render text: [status: "error", error: "Request missing JSON content"] as JSON, status: SC_BAD_REQUEST, contentType: "application/json"
        } else {
            checkArguments(null, id)
            Map result = bulkImportService.update(json, id)
            if (result.error) {
                render(text: getMessage(result), status: result.statusCode, contentType: 'application/json')
            } else {
                render(text: result?.resp as JSON, status: result.statusCode, contentType: 'application/json')
            }
        }
    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def get(String id) {
        if (!id) {
            render text: [status: "error", error: "Missing id"], status: SC_BAD_REQUEST, contentType: "application/json"
        } else {
            checkArguments(null, id)
            Map result = bulkImportService.get(id)
            if (!result.error) {
                render text: result as JSON, contentType: 'application/json'
            } else {
                render text: getMessage(result), status: result.statusCode, contentType: "application/json"
            }
        }
    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def deleteActivitiesImported(String id) {
        if (!id) {
            render text: [status: "error", error: "Missing bulk import id"], status: SC_BAD_REQUEST, contentType: "application/json"
        } else {
            checkArguments(null, id)
            Map result = bulkImportService.deleteActivitiesImported(id)
            if (!result.error) {
                render text: result as JSON, contentType: 'application/json'
            } else {
                render text: getMessage(result), status: result.statusCode, contentType: "application/json"
            }
        }
    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def publishActivitiesImported(String id) {
        if (!id) {
            render text: [status: "error", error: "Missing bulk import id"], status: SC_BAD_REQUEST, contentType: "application/json"
        } else {
            checkArguments(null, id)
            Map result = bulkImportService.publishActivitiesImported(id)
            if (!result.error) {
                render text: result as JSON, contentType: 'application/json'
            } else {
                render text: getMessage(result), status: result.statusCode, contentType: "application/json"
            }
        }
    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def embargoActivitiesImported(String id) {
        if (!id) {
            render text: [status: "error", error: "Missing bulk import id"], status: SC_BAD_REQUEST, contentType: "application/json"
        } else {
            checkArguments(null, id)
            Map result = bulkImportService.embargoActivitiesImported(id)
            if (!result.error) {
                render text: result as JSON, contentType: 'application/json'
            } else {
                render text: getMessage(result), status: result.statusCode, contentType: "application/json"
            }
        }
    }

    @SSO
    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def index() {
        Map bulkImport
        String projectActivityId = params.projectActivityId
        String bulkImportId = params.id

        if (bulkImportId) {
            bulkImport = bulkImportService.get(bulkImportId)
            if (!bulkImport.error) {
                projectActivityId = bulkImport.projectActivityId
            }
        }
        checkArguments(bulkImport)

        if (projectActivityId) {
            Map projectActivity = projectActivityService.get(projectActivityId)
            if (projectActivity && bulkImport) {
                Map model = projectActivity
                model.bulkImportId = bulkImport.bulkImportId
                render view: 'index', model: model
            } else {
                response.setStatus(SC_NOT_FOUND)
            }
        } else {
            render text: [message: "Missing required parameters - projectActivityId"] as JSON, status: HttpStatus.SC_BAD_REQUEST
        }
    }

    @SSO
    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId", redirectController = "", redirectAction = "")
    def createPage() {
        String projectActivityId = params.projectActivityId
        checkArguments()

        if (projectActivityId) {
            Map projectActivity = projectActivityService.get(projectActivityId)
            if (projectActivity) {
                Map model = projectActivity

                render view: 'index', model: model
            } else {
                response.setStatus(SC_NOT_FOUND)
            }
        } else {
            render text: [message: "Missing required parameters - projectActivityId"] as JSON, status: HttpStatus.SC_BAD_REQUEST
        }
    }

    def listings () {
        render view: 'listings'
    }

    private String getMessage(Map resp) {
        def errorMessage
        if (resp.detail) {
            try {
                errorMessage = JSON.parse(resp?.detail)
            } catch (ConverterException ce) {
                errorMessage = resp.error
            }
        }

        errorMessage ?: resp.error
    }

    private boolean checkArguments(Map bulkImport = null, String bulkImportId = null) {
        if (bulkImport) {
            if(!bulkImport && bulkImportId) {
                bulkImport = bulkImportService.get(bulkImportId)
            }

            if (bulkImport.projectId != params.projectId) {
                throw new IllegalArgumentException("Provided projectId is invalid")
            }
        }

        if (params.projectActivityId  && params.projectId) {
            Map pa = projectActivityService.get(params.projectActivityId)
            if (pa.projectId != params.projectId) {
                throw new IllegalArgumentException("Provided projectId and projectActivityId do not match")
            }
        }

        return true
    }
}
