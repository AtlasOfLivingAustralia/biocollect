var projectPromise, paPromise;
var surveyName = "Dung Beetle Monitoring",  listId = "dr2683", limit=5, query = "", offset = 0;
var db = getDB();

function fetchProject() {
    if (!projectPromise) {
        projectPromise = $.ajax({
            url: fcConfig.projectURL
        });
    }

    return projectPromise;
}

function saveProject (project) {
    var deferred = $.Deferred();

    db.project.put(project).then(function (projectId) {
        deferred.resolve({message: "Saved project to db", success: true, data: project});
    }).catch(function () {
        deferred.reject({message: "Failed to save project to db", success: false});
    });

    return deferred.promise();
}

function  fetchProjectActivity () {
    if (!paPromise) {
        paPromise = $.ajax({
            url: fcConfig.projectActivityURL
        });
    }

    return paPromise;
}

function saveProjectActivity (pa) {
    var deferred = $.Deferred();

    db.projectActivity.put(pa).then(function () {
        deferred.resolve({message: "Saved project activity to db", success: true, data: pa});
    }).catch(function () {
        deferred.reject({message: "Failed to save project activity to db", success: false});
    });

    return deferred.promise();
}

fetchProject().then(saveProject).then(fetchProjectActivity).then(saveProjectActivity).done(function (result) {
    var pa = result.data;
    var promises = [];
    pa.speciesFields && pa.speciesFields.forEach(function (field) {
        console.log("fetching species");
        promises.push(updateDBForField(field.dataFieldName, field.output));
    });

    $.when.apply($, promises).always(function () {
        console.log("Starting to fetch sites");
        fetchSites(pa.sites, 0).done(function (result) {
            console.log(result.message);
        });
    });
}).fail(function () {
    alert("Failed to fetch species configuration for survey");
});