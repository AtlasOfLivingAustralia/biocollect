describe("ProjectViewModel Spec", function () {
    const koToJSON = function koToJSON(obj) {
        return ko.mapping.toJS(obj, {'ignore': ['transients']});
    };

    beforeAll(function() {
        window.fcConfig = {
            imageLocation: '/',
            financeDataDisplay: {
                funding: {options: {fundingType: [], fundClass: []}},
                budget:{
                    options:{budgetCategory:[],budgetClass:[],budgetPaymentStatus:[], budgetRiskStatus:[] },
                    optionsByName:{budgetCategory:{'Others': 'Others'},budgetClass:{},budgetPaymentStatus:{}, budgetRiskStatus:{}}
                }
            }
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {

        var projectData = {
            name:'Name',
            description:'Description'
        };

        var isEditor = true;
        var project = new ProjectViewModel(projectData, isEditor);

        expect(project.name()).toEqual(projectData.name);
        expect(project.description()).toEqual(projectData.description);
    });

    it("should compute the project type and whether the project is a citizen science project from a single selection", function() {
        var projectData = {
            isCitizenScience:true,
            projectType:'survey'
        };
        var project = new ProjectViewModel(projectData);
        expect(project.transients.kindOfProject()).toBe('citizenScience');

        projectData.projectType = 'works';
        expect(new ProjectViewModel(projectData).transients.kindOfProject()).toBe('citizenScience');


        projectData.isCitizenScience = false;
        expect(new ProjectViewModel(projectData).transients.kindOfProject()).toBe('works');

        projectData.projectType = 'survey';
        expect(new ProjectViewModel(projectData).transients.kindOfProject()).toBe('survey');


        project = new ProjectViewModel({});
        project.transients.kindOfProject('citizenScience');
        expect(project.isCitizenScience()).toBe(true);
        expect(project.isWorks()).toBe(false);
        expect(project.isEcoScience()).toBe(false);
        expect(project.projectType()).toBe('survey');


        project.transients.kindOfProject('survey');
        expect(project.isCitizenScience()).toBe(true);
        expect(project.isWorks()).toBe(false);
        expect(project.isEcoScience()).toBe(false);
        expect(project.projectType()).toBe('survey');

        project.transients.kindOfProject('works');
        expect(project.isCitizenScience()).toBe(false);
        expect(project.isWorks()).toBe(true);
        expect(project.isEcoScience()).toBe(false);
        expect(project.projectType()).toBe('works');

        project.transients.kindOfProject('ecoScience');
        expect(project.isCitizenScience()).toBe(false);
        expect(project.isWorks()).toBe(false);
        expect(project.isEcoScience()).toBe(true);
        expect(project.projectType()).toBe('ecoScience');

    });

    it("should identify mobile app and social media links", function() {
        var urlAndroid = 'http://play.google.com/store/apps/myApp'
        var urlFacebook = 'http://www.facebook.com/myFace'
        var projectData = {
            links: [
                {
                    role:'android',
                    url:urlAndroid
                },
                {
                    role:'facebook',
                    url:urlFacebook
                }
            ]
        };

        var project = new ProjectViewModel(projectData);
        expect(project.transients.mobileApps()).toEqual({
            asymmetricMatch: function(actual) {
                expect(actual.length).toBe(1);
                expect(actual[0].name).toBe('Android');
                expect(actual[0].link.url).toBe(urlAndroid);
                return true;
            }
        });
        expect(project.transients.socialMedia()).toEqual({
            asymmetricMatch: function(actual) {
                expect(actual.length).toBe(1);
                expect(actual[0].name).toBe('Facebook');
                expect(actual[0].link.url).toBe(urlFacebook);
                return true;
            }
        });

    });

    it("should create an empty work project", function () {
        // arrange
        const projectData = {
            projectId: 'works-project-id',
            projectType: 'works',
            plannedStartDate: '2020-07-05',
            plannedEndDate: '2022-05-10',
            custom: {
                details: {
                    budget: {
                        headers: [{data: '2020/2021'}, {data: '2021/2022'}],
                        rows: [{
                            shortLabel: 'Others',
                            description: 'description 1',
                            fundingSource: 'funding source 1',
                            dueDate: '',
                            paymentStatus: undefined,
                            paymentNumber: undefined,
                            fundClass: undefined,
                            riskStatus: undefined,
                            rowTotal: 3,
                            costs: [{dollar: 1}, {dollar: 2}]
                        }, {
                            shortLabel: 'Others',
                            description: 'description 2',
                            fundingSource: 'funding source 2',
                            dueDate: '',
                            paymentStatus: undefined,
                            paymentNumber: undefined,
                            fundClass: undefined,
                            riskStatus: undefined,
                            rowTotal: 7,
                            costs: [{dollar: 3}, {dollar: 4}]
                        }]
                    }
                }
            }
        };

        // act
        const project = new WorksProjectViewModel(projectData, false, [], {});

        // assert
        expect(koToJSON(project.details.budget.headers)).toEqual(projectData.custom.details.budget.headers);
        expect(koToJSON(project.details.budget.rows)).toEqual(projectData.custom.details.budget.rows);
        expect(koToJSON(project.details.budget.columnTotal())).toEqual([{data: 4}, {data: 6}]);
        expect(project.details.budget.overallTotal()).toEqual(10);
    });

});
