package au.org.ala.biocollect.merit

class HubConfigurationFilters {

    def settingService

    def filters = {
        all(controller: '*', action: '*') {
            before = {
                settingService.loadHubConfig(params.hub)
            }
            after = { Map model ->

            }
            afterView = { Exception e ->
                // The settings are cleared in a servlet filter so they are available during page rendering.
            }
        }
    }
}
