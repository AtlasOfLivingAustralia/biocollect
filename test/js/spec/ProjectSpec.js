describe("ProjectViewModel Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
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
        var organisations = [];
        var isEditor = true;
        var project = new ProjectViewModel(projectData, isEditor, organisations);

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
        expect(project.projectType()).toBe('survey');


        project.transients.kindOfProject('survey');
        expect(project.isCitizenScience()).toBe(false);
        expect(project.projectType()).toBe('survey');

        project.transients.kindOfProject('works');
        expect(project.isCitizenScience()).toBe(false);
        expect(project.projectType()).toBe('works');

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

});
