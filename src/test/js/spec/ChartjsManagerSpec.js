describe('Test chart.js view models', function () {
    beforeAll(function () {
        window.fcConfig = {
            flimit: 15,
            searchProjectActivitiesUrl: 'test-url'
        };
    });

    it('should create an instance of the chart.js manager view model', function () {
        let vm = new ChartjsManagerViewModel();
        let facetConfigs = [{
            name: 'testFacet',
            chartjsType: 'pie',
            chartjsConfig: {},
        }];
        let arVm = new ActivitiesAndRecordsViewModel('test-activities-vm', null, null, true, true, false, null, facetConfigs);
        let filterViewModel = new FilterViewModel({
            parent: arVm,
            flimit: fcConfig.flimit
        });
        let facets = [
            new FacetViewModel({name: 'testFacet', title: 'Test Facet', ref: filterViewModel, type: 'terms',}),
        ];
        vm.setChartsFromFacets(facets, facetConfigs);

        expect(vm.chartjsPerRowOptions()).toEqual(['1', '2', '3', '4']);
        expect(vm.chartjsPerRowSelected()).toEqual('2');
        expect(vm.chartjsPerRowSpan()).toEqual('span6');

        let chartList = vm.chartjsList()
        expect(chartList.length).toEqual(1);

        let chartItem = chartList[0];
        expect(chartItem.transients.facet()).toEqual(facets[0]);
        expect(chartItem.transients.chartConfig()).toEqual({});
        expect(chartItem.chartFacetName()).toEqual(facets[0].name());
        expect(chartItem.chartType()).toEqual(facetConfigs[0].chartjsType);
    });

    it('should correctly parse the custom chart data format', function () {
        let vm = new ChartjsManagerViewModel();
        let facetConfig = {};
        let arVm = new ActivitiesAndRecordsViewModel('test-activities-vm', null, null, true, true, false, null, facetConfig);
        let filterViewModel = new FilterViewModel({
            parent: arVm,
            flimit: fcConfig.flimit
        });
        let terms = [
            {
                facet: 'testAFacet',
                count: 4,
                term: 'CustomChartDataItem|||testTerm|||3',
                title: null,
            },
            {
                facet: 'testAFacet',
                count: 2,
                term: 'CustomChartDataItem|||testTerm|||2',
                title: null,
            }
        ];
        let facets = [
            new FacetViewModel({
                name: 'testAFacet',
                title: 'Test A Facet',
                ref: filterViewModel,
                type: 'terms',
                terms: terms
            }),
        ];
        let facetConfigs = [{
            name: 'testAFacet',
            chartjsType: 'pie',
            chartjsConfig: {},
        }];
        vm.setChartsFromFacets(facets, facetConfigs);

        let chartList = vm.chartjsList()
        expect(chartList.length).toEqual(1);

        let chartItem = chartList[0];
        let facetTerms = facets[0].terms();
        expect(chartItem.getChartDataCustomTerms(facetTerms)).toEqual([
            {value: 'testTerm', rangeFrom: null, rangeTo: null, count: (4 * 3) + (2 * 2), title: 'testTerm'}
        ]);
    });

    it('should produce the correct chart.js data and options', function () {
        let vm = new ChartjsManagerViewModel();
        let facetConfigs = [{
            name: 'test01Facet',
            chartjsType: 'pie',
            chartjsConfig: {},
        }];
        let arVm = new ActivitiesAndRecordsViewModel('test-activities-vm', null, null, true, true, false, null, facetConfigs);
        let filterViewModel = new FilterViewModel({
            parent: arVm,
            flimit: fcConfig.flimit
        });
        let facets = [
            new FacetViewModel({name: 'test01Facet', title: 'Test 01 Facet', ref: filterViewModel, type: 'terms',}),
        ];
        vm.setChartsFromFacets(facets, facetConfigs);

        expect(vm.chartjsPerRowOptions()).toEqual(['1', '2', '3', '4']);
        expect(vm.chartjsPerRowSelected()).toEqual('2');
        expect(vm.chartjsPerRowSpan()).toEqual('span6');

        let chartList = vm.chartjsList()
        expect(chartList.length).toEqual(1);

        let chartItem = chartList[0];

        expect(chartItem.chartData()).toEqual({
            datasets: [
                {label: 'Test 01 Facet', data: []}
            ],
            labels: [],
        });
        expect(chartItem.chartOptions()).toEqual({
            plugins: {
                title: {display: true, text: 'Test 01 Facet'},
            },
        });
    });

    it('should order and update the chart data and labels as expected', function () {
        let vm = new ChartjsManagerViewModel();
        let facetConfigs = [
            {
                // testFacet - tests a term facet using the term counts
                name: 'testFacet',
                chartjsType: 'pie',
                chartjsConfig: {
                    dataUseCount: 'true',
                    mainLabels: [
                        {originalLabel: 'Label2'},
                        {originalLabel: 'Label1', newLabel: 'Label One'},
                    ]
                },
            },
            {
                // test2Facet - tests a range facet
                name: 'test2Facet',
                chartjsType: 'bar',
                chartjsConfig: {
                    mainLabels: [
                        {originalLabel: 'from 3 to < 4'},
                        {originalLabel: 'from 2 to < 3', newLabel: 'Label Three'},
                    ]
                },
            },

            {
                // test3Facet - tests a term facet with dataApplyRanges
                name: 'test3Facet',
                chartjsType: 'line',
                chartjsConfig: {
                    dataUseCount: 'true',
                    dataApplyRanges: [
                        {minVal: 1, maxVal: 10}, {minVal: 10.1, maxVal: 20},
                    ],
                    mainLabels: [
                        {originalLabel: '20', newLabel: 'New Label 20'},
                        {originalLabel: '10', newLabel: 'New Label 10'},
                    ]
                },
            },

        ];
        let arVm = new ActivitiesAndRecordsViewModel('test-activities-vm', null, null, true, true, false, null, facetConfigs);
        let filterViewModel = new FilterViewModel({
            parent: arVm,
            flimit: fcConfig.flimit
        });
        let facets = [
            new FacetViewModel({
                name: 'testFacet',
                title: 'Test Facet',
                ref: filterViewModel,
                total: 3,
                type: 'terms',
                ranges: null,
                entries: null,
                terms: [
                    {
                        "count": 1,
                        "term": "label1",
                        "title": null
                    },
                    {
                        "count": 2,
                        "term": "label2",
                        "title": null
                    },
                ]
            }),
            new FacetViewModel({
                name: "test2Facet",
                title: "Test 2 Facet",
                ref: filterViewModel,
                total: null,
                type: "range",
                ranges: [
                    {
                        "from": 2,
                        "to": 3,
                        "count": 1
                    },
                    {
                        "from": 3,
                        "to": 4,
                        "count": 2
                    }
                ],
                terms: null
            }),

            new FacetViewModel({
                name: 'test3Facet',
                title: 'Test 3 Facet',
                ref: filterViewModel,
                total: 5,
                type: 'terms',
                ranges: null,
                entries: null,
                terms: [
                    {
                        "count": 5,
                        "term": "label10",
                        "title": null
                    },
                    {
                        "count": 15,
                        "term": "label20",
                        "title": null
                    },
                ]
            }),
        ];
        vm.setChartsFromFacets(facets, facetConfigs);

        expect(vm.chartjsPerRowOptions()).toEqual(['1', '2', '3', '4']);
        expect(vm.chartjsPerRowSelected()).toEqual('2');
        expect(vm.chartjsPerRowSpan()).toEqual('span6');

        let chartList = vm.chartjsList();
        expect(chartList.length).toEqual(3);

        let chartItem1 = chartList[0];
        expect(chartItem1.chartData()).toEqual({
            datasets: [
                {label: 'Test Facet', data: [2, 1]}
            ],
            labels: ['Label2', 'Label One'],
        });
        expect(chartItem1.chartOptions()).toEqual({
            plugins: {
                title: {display: true, text: 'Test Facet'},
            },
        });

        let chartItem2 = chartList[1];
        expect(chartItem2.chartData()).toEqual({
            datasets: [
                {label: 'Test 2 Facet', data: [2, 1]}
            ],
            labels: ['from 3 to < 4', 'Label Three'],
        });
        expect(chartItem2.chartOptions().plugins).toEqual({
            title: {display: true, text: 'Test 2 Facet'},
        });


        let chartItem3 = chartList[2];
        expect(chartItem3.chartData()).toEqual({
            datasets: [
                {label: 'Test 3 Facet', data: [1, 1]}
            ],
            labels: ['New Label 20', 'New Label 10'],
        });
        expect(chartItem3.chartOptions().plugins).toEqual({
            title: {display: true, text: 'Test 3 Facet'},
        });
    });
});