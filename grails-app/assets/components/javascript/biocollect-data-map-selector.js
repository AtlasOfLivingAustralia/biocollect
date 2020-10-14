
ko.components.register('biocollect-data-map-selector', {
    viewModel: function (params) {
        var self = this;
        var mapDisplays = self.mapDisplays = params.mapDisplays || ko.observableArray([]),
            allMapDisplays = params.allMapDisplays,
            savedMapDisplays = params.savedMapIdplays,
            showProjectMemberColumn = self.showProjectMemberColumn = ko.observable(params.showProjectMemberColumn != undefined ? params.showProjectMemberColumn : true);

        self.transients = {
            isDefaultMapDisplay: ko.observable()
        };

        self.transients.isDefaultMapDisplay.subscribe(setDefaultMapDisplay, self);

        function MapDisplayViewModel(config) {
            var self = this;
            self.value = ko.observable(config.value || "");
            self.key = ko.observable(config.key || "");
            self.showLoggedOut = ko.observable(!!config.showLoggedOut);
            self.showLoggedIn = ko.observable(!!config.showLoggedIn);
            self.showProjectMembers = ko.observable(!!config.showProjectMembers);
            self.isDefault = ko.observable(config.isDefault || "");
            self.size = config.size;
        }

        function  setDefaultMapDisplay (selectedDisplay) {
            var displays = self.mapDisplays();

            displays.forEach(function (display) {
                display.isDefault(selectedDisplay);
            });
        };

        function loadMapDisplays() {
            // component gets mapDisplay objects via observable.
            // convert those objects to view models.
            var savedMapDisplays = self.mapDisplays();
            self.mapDisplays([]);

            allMapDisplays.forEach(function (item) {
                var foundItem = $.grep(savedMapDisplays || [], function (display) {
                    return item.key == display.key;
                });

                var mapDisplay = null;

                if (foundItem.length == 1) {
                    // to pick new defaults added to allMapDisplays
                    item = $.extend(item, foundItem[0]);
                    mapDisplay = new MapDisplayViewModel(item);
                }
                else if (foundItem.length == 0) {
                    mapDisplay = new MapDisplayViewModel(item);
                }

                if (mapDisplay) {
                    mapDisplays.push(mapDisplay);
                    self.transients.isDefaultMapDisplay(mapDisplay.isDefault());
                }
            });
        }

        loadMapDisplays();
    },
    template:componentService.getTemplate('biocollect-data-map-selector')
});