function getDB() {
    var DB_NAME = "biocollect";
    var db = new Dexie(DB_NAME);
    db.version(2).stores({
        taxon: `
           ++id,
           projectActivityId,
           dataFieldName,
           outputName,
           name,
           scientificName,
           commonName,
           listId,
           [projectActivityId+dataFieldName+outputName]`,
        site: `++siteId,
           *projects`,
        projectActivity: `++projectActivityId,*sites`,
        project: `++projectId`,
        document: `++documentId`,
        activity: `++activityId,
                    projectActivityId,
                    projectId`,
        metaModel: `name`,
        offlineMap: `++id,name`,
        credential: `++userId`,
    });

    return db;
}

function convertToJqueryPromise(dexiePromise, doNotTransformData) {
    doNotTransformData = !!doNotTransformData && true;
    var deferred = $.Deferred();
    dexiePromise.then(function (result) {
        if (doNotTransformData) {
            deferred.resolve.apply(deferred, arguments);
        }
        else {
            deferred.resolve({data: result});
        }
    }).catch(function (error) {
        if(doNotTransformData) {
            deferred.reject.apply(deferred, arguments);
        }
        else {
            deferred.reject({error: error});
        }
    });

    return deferred.promise();
}