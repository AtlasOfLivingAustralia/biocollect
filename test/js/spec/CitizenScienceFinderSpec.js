describe("Citizen Science Project Finder Spec", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to be initialised from an object literal", function () {
        var threeDaysAgo = new Date();
        threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
        threeDaysAgo.setMilliseconds(0);
        var fourDaysHence = new Date();
        fourDaysHence.setDate(fourDaysHence.getDate() + 4);
        fourDaysHence.setMilliseconds(0);
        var projectData = [
          'pid',
          'aim',
          {
            locality: "locality",
            state: "state"
          },
          'description',
          'Easy', // difficulty
          fourDaysHence.toISOString(), // plannedEndDate
          false, // hasParticipantCost
          false, // hasTeachingMaterials
          true, // isDIY
          false, // isExternal
          true, // isSuitableForChildren
          'keywords',
          [], // links
          'name',
          'orgid',
          'orgname',
          'scienceType',
          threeDaysAgo.toISOString(), // plannedStartDate
          null, // urlImage
          null // urlWeb
        ];
        var project = new CitizenScienceFinderProjectViewModel(projectData);

        expect(project.aim()).toEqual(projectData[1]);
        expect(project.description()).toEqual(projectData[3]);
        expect(project.difficulty()).toEqual(projectData[4]);
        expect(new Date(project.plannedEndDate())).toEqual(fourDaysHence);
        expect(project.hasParticipantCost()).toEqual(projectData[6]);
        expect(project.hasTeachingMaterials()).toEqual(projectData[7]);
        expect(project.isDIY()).toEqual(projectData[8]);
        expect(project.isExternal()).toEqual(projectData[9]);
        expect(project.isSuitableForChildren()).toEqual(projectData[10]);
        expect(project.keywords()).toEqual(projectData[11]);
        expect(project.name()).toEqual(projectData[13]);
        expect(project.organisationId()).toEqual(projectData[14]);
        expect(project.organisationName()).toEqual(projectData[15]);
        expect(project.scienceType()).toEqual(projectData[16]);
        expect(new Date(project.plannedStartDate())).toEqual(threeDaysAgo);
        expect(project.transients.daysRemaining()).toEqual(4);
        expect(project.transients.daysSince()).toEqual(3);
        expect(project.transients.daysTotal()).toEqual(7);
        expect(project.transients.locality).toEqual(projectData[2].locality);
        expect(project.transients.state).toEqual(projectData[2].state);
        expect(project.daysStatus()).toEqual("active");
    });
});
