load('../data/projectDefaults.js');
load('../data/siteDefaults.js');
load('../data/activityForms/SingleSighting.js');
load('../data/activityDefaults.js');
load('../data/outputDefaults.js');


function createProject(projectProperties) {
    // var project = Object.assign({}, projectDefaults);
    // Object.assign(project, projectProperties || {});
    var project = projectDefaults.create()
    assign(projectProperties,project)

    db.project.insert(project);
    return project;
}

function createProgram(programProperties) {
    //Avoid possibile compatibility of js
    //var program = Object.assign({}, programDefaults);
    //Object.assign(program, programProperties || {});

    var program = programDefaults.create()
    assign(programProperties,program)
    db.program.insert(program);
}

function createOrganisation(organisationProperties){
    if (!organisationProperties.hubId) {
        organisationProperties.hubId = "merit";
    }
    db.organisation.insert(organisationProperties)
}

function createMu(muProperties) {
    // var mu = Object.assign({}, muDefaults);
    // Object.assign(mu, muProperties || {});

    var mu = muDefaults.create()
    assign(muProperties,mu)
    db.managementUnit.insert(mu);
}

function createScoreWeedHaDefaults(weedsProperties) {
    var weedHa = scoreWeedHaDefaults.create();
    assign(weedsProperties, weedHa);
    db.score.insert(weedHa);

}

function createActivities(activities){
    var activity = activityDefaults.create();
    assign(activities, activity);
    db.activity.insert(activity);
}

function createOutput(outputs) {
    var out = outputDefaults.create();
    assign(outputs, out);
    db.output.insert(out);
}

function createPestOutDataDefaults(pestData){
    var pestOutput =pestOutDataDefaults.create();
    assign(pestData, pestOutput);
    db.output.insert(pestOutput);
}
function createScoreInvasiveSpecies(invasiveSpecies){
    var species = scoreInvasiveSpeciesDefaults.create();
    assign(invasiveSpecies, species);
    db.score.insert(species);
}

function createProjectNumberBaselineDataSets(data){
    var scoreDefault = projectNumberBaselineDataSets.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);

}
function createProjectNumberOfCommunicationMaterialsPublished(data){
    var scoreDefault = projectNumberOfCommunicationMaterialsPublished.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);

}
function createProjectWeedAreaSurveyedHaDefault(data){
    var scoreDefault = projectWeedAreaSurveyedHaDefault.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectWeedNumberOfSurveysConductedDefault(data){
    var scoreDefault = projectWeedNumberOfSurveysConductedDefault.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectPestAreaFollowup(data){
    var scoreDefault = projectPestAreaFollowup.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectPestAreaInitial(data){
    var scoreDefault = projectPestAreaInitial.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectAccessHasBeenControlled(data){
    var scoreDefault = projectAccessHasBeenControlled.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectRLPLengthInstalled(data){
    var scoreDefault = projectRLPLengthInstalled.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectCommunityAdviceInteractions(data){
    var scoreDefault = projectCommunityAdviceInteractions.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectCommunitySeminars(data){
    var scoreDefault = projectCommunitySeminars.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectCommunityWorkshopEvent(data){
    var scoreDefault = projectCommunityWorkshopEvent.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectCommunityFiledDays(data){
    var scoreDefault = projectCommunityFiledDays.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectRLPNumberOfStructuresInstalled(data){
    var scoreDefault = projectRLPNumberOfStructuresInstalled.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectCommunityOnGroundWorks(data){
    var scoreDefault = projectCommunityOnGroundWorks.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}
function createProjectCommunityDemostrations(data){
    var scoreDefault = projectCommunityDemostrations.create();
    assign(data, scoreDefault)
    db.score.insert(scoreDefault);
}

function createSite(siteProperties) {
    // var mu = Object.assign({}, muDefaults);
    // Object.assign(mu, muProperties || {});

    var site = siteDefaults.create()
    assign(siteProperties,site)
    db.site.insert(site);
}

function loadActivityForms() {
    db.activityForm.insert(singleSighting);

    var forms = db.activityForm.find({});
    print("Total Forms in DB: " + forms.count());
    forms.forEach( function (form){
        if (form) {
            print("Updating Form Version From Double to Int: " + form.name)
            db.activityForm.update({_id: form._id},{$set: {formVersion:NumberInt(form.formVersion), minOptionalSectionsCompleted: NumberInt(form.minOptionalSectionsCompleted)}})
        }
    });

    var forms2 = db.activity.find({});
    print("Total Forms in DB: " + forms2.count());
    forms2.forEach( function (form){
        if (form){
            print("Updating Form Version From Double to Int: " + form.type)
            db.activity.update({activityId: form.activityId},{$set: {formVersion:NumberInt(form.formVersion)}})
        }
    });
}


/**
 * Be aware of copying Date may lose turn it to String
 * @param src
 * @param des
 */
function assign(src, des){
    for(var prop in src){
        if(src.hasOwnProperty(prop)){
            if(src[prop] && isObject(src[prop]) && !(src[prop] instanceof Date)) {
                if ( Array.isArray(src[prop]))
                    des[prop] = []
                else
                    des[prop] ={}
                assign(src[prop],des[prop])
            }else{
                des[prop] = src[prop]
            }
        }
    }

}