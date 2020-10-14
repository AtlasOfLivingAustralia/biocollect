/*
 * Copyright (C) 2020 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 14/10/20.
 */
describe("biocollect-data-map-selector component unit tests", function () {

    var vm = null;
    var mockElement = null;
    var facetFilterVM = null;
    beforeAll(function () {
        window.fcConfig = {
            allMapDisplays: [{
                value: "Polygon",
                key: "polygon_sites_project",
                showLoggedOut: true,
                showLoggedIn: true,
                showProjectMembers: true,
                isDefault: "point_circle_project",
                size: 1
            },
                {
                    value: "Heatmap",
                    key: "heatmap",
                    showLoggedOut: true,
                    showLoggedIn: true,
                    showProjectMembers: true,
                    isDefault: "point_circle_project"
                }]

        };

        var mapDisplays =  [{
            value: "Polygon",
            key: "polygon_sites_project",
            showLoggedOut: true,
            showLoggedIn: true,
            showProjectMembers: true,
            isDefault: "point_circle_project",
            size: 1
        },
            {
                value: "Heatmap",
                key: "heatmap",
                showLoggedOut: true,
                showLoggedIn: true,
                showProjectMembers: true,
                isDefault: "point_circle_project"
            }];

        var showProjectMemberColumn = false;
        vm = {
            mapDisplays: ko.observableArray(mapDisplays),
            showProjectMemberColumn: showProjectMemberColumn
        };

        mockElement = document.createElement('div');
        mockElement.id = 'biocollectDataMapSelectorId';
        var selectorComponent = document.createElement('biocollect-data-map-selector');
        selectorComponent.setAttribute('params', "mapDisplays: mapDisplays, allMapDisplays: fcConfig.allMapDisplays, showProjectMemberColumn: showProjectMemberColumn");
        mockElement.appendChild(selectorComponent);
        document.body.appendChild(mockElement);
        ko.applyBindings(vm, mockElement);
    });

    beforeEach(function () {
    });

    it("showProjectMemberColumn should be hidden project member column", function () {
        expect($(mockElement).find('.bdms-project-member-header').text()).toBe("");
    });

    function addLayer(className) {
        $(mockElement).find(className).click();
    }

    function clearComponent() {
        $('#biocollectDataMapSelectorId').remove();
    }
});