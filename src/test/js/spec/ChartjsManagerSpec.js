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
                facet: 'testFacet',
                count: 4,
                term: 'CustomChartDataItem|||testTerm|||3',
                title: null,
            },
            {
                facet: 'testFacet',
                count: 2,
                term: 'CustomChartDataItem|||testTerm|||2',
                title: null,
            }
        ];
        let facets = [
            new FacetViewModel({
                name: 'testFacet',
                title: 'Test Facet',
                ref: filterViewModel,
                type: 'terms',
                terms: terms
            }),
        ];
        let facetConfigs = [{
            name: 'testFacet',
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

        expect(chartItem.chartData()).toEqual({
            datasets: [{
                label: '0 items for Test Facet',
                data: [],
                backgroundColor: []
            }], labels: [],
        });
        expect(chartItem.chartOptions()).toEqual({
            plugins: {
                legend: {position: 'top'},
                title: {display: true, text: '0 items for Test Facet'},
            },
        });
    });
});