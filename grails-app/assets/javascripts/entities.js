var entities = (function () {
    var GROUP = "GROUP_OF_SPECIES", SINGLE = "SINGLE_SPECIES", ALL = 'ALL_SPECIES', SPECIES_MAX_FETCH = 20;

    var projectPromise, paPromise;
    var limit = 5, query = "", offset = 0;
    var db = getDB(), dbOpen = convertToJqueryPromise(db.open(), true), forceOffline = false,
    downloadingAllSpecies = false;

    function getProject() {
        if (isOffline()) {
            return offlineFetchProject();
        } else {
            return onlineFetchProject();
        }
    }

    function onlineFetchProject(isSave) {
        isSave = isSave || false;
        if (!projectPromise) {
            projectPromise = $.ajax({
                url: fcConfig.projectURL
            });

            projectPromise.then(saveProject);
        }

        return projectPromise.then(function (result) {
            return {data: result}
        });
    }

    function offlineFetchProject(projectId) {
        projectId = projectId || fcConfig.projectId;
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('project').where('projectId').equals(projectId).first());
        });
    }

    function saveProject(project) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('project').put(project));
        });
    }

    function getProjectActivity(pActivityId) {
        if (isOffline()) {
            return offlineFetchProjectActivity(pActivityId);
        } else {
            return onlineFetchProjectActivity(pActivityId);
        }
    }

    function onlineFetchProjectActivity(pActivityId) {
        if (!paPromise) {
            paPromise = $.ajax({
                url: fcConfig.projectActivityURL + "/" + pActivityId
            });

            paPromise.then(saveProjectActivity);
        }

        return paPromise.then(function (result) {
            return {data: result}
        });
    }

    function offlineFetchProjectActivity(pActivityId) {
        pActivityId = pActivityId || fcConfig.projectActivityId;
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('projectActivity').where('projectActivityId').equals(pActivityId).first());
        });
    }

    function saveProjectActivity(pa) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('projectActivity').put(pa));
        });
    }

    function getActivitiesForProjectActivity(projectActivityId, max, offset, sort, order) {
        // if(isOffline()) {
        return offlineGetActivitiesForProjectActivity(projectActivityId, max, offset, sort, order);
        // }
        // else {
        //     return onlineGetActivitiesForProjectActivity(projectActivityId, max, offset, sort, order);
        // }
    }

    function onlineGetActivitiesForProjectActivity(max, offset, sort, order) {
        return dbOpen.then(function () {
            sort = sort || 'lastUpdated';
            order = order || 'DESC';
            max = max || 30;
            offset = offset || 0;

            return $.ajax({
                url: fcConfig.activitiesFromProjectActivityURL, data: {
                    sort: sort, order: order, max: max, offset: offset
                }
            }).then(function (result) {
                // save the activities into db so that we can query db to get the unpublished activities.
                return saveActivitiesForProjectActivity({data: result}).then(function () {
                    return offlineGetActivitiesForProjectActivity(max, offset, sort, order).then(function (offlineResults) {
                        return {data: {activities: offlineResults.data, total: result.total}};
                    });
                });
            });
        });
    }

    function saveActivitiesForProjectActivity(result) {
        var activities = result.data.activities;
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('activity').bulkPut(activities));
        })
    }

    function offlineGetActivitiesForProjectActivity(projectActivityId, max, offset, sort, order) {
        sort = sort || 'lastUpdated';
        order = order || 'DESC';
        max = max || 30;
        offset = offset || 0;

        return dbOpen.then(function () {
            var promise,
                countPromise = convertToJqueryPromise(db.table('activity').where('projectActivityId').equals(projectActivityId).count());
            switch (order) {
                default:
                case 'DESC':
                    promise = convertToJqueryPromise(db.table('activity').where('projectActivityId').equals(projectActivityId).reverse().offset(offset).limit(max).sortBy(sort));
                    break;
                case 'ASC':
                    promise = convertToJqueryPromise(db.table('activity').where('projectActivityId').equals(projectActivityId).offset(offset).limit(max).sortBy(sort));
                    break;
            }

            return $.when(promise, countPromise).then(function (activitiesResult, totalResult) {
                return {data: {activities: activitiesResult.data, total: totalResult.data}};
            });
        });
    }

    function getActivity(activityId) {
        if (isOffline()) {
            return offlineGetActivity(activityId);
        } else {
            return onlineGetActivity(activityId).then(null, function () {
                // dexie will return not get activity if it is of the wrong type.
                try {
                    activityId = parseInt(activityId);
                } catch (e) {
                    console.debug("activityId is not a number - " + activityId);
                }
                return offlineGetActivity(activityId);
            });
        }
    }

    function onlineGetActivity(activityId) {
        var promise = $.ajax({
            url: fcConfig.activityURL + '/' + activityId
        });

        promise.then(function (result) {
            var result = {data: result}
            saveActivity(result);
        }, function (error) {
            console.log("failed to get activity from server");
        });
        return promise;
    }

    // function saveActivity(result) {
    //     var activity = result.data;
    //     return dbOpen.then(function() {
    //         return convertToJqueryPromise(db.table('activity').put(activity));
    //     });
    // }

    function offlineGetActivity(activityId) {
        var isDexie = false;
        if (isUuid(activityId) || (isDexie = isDexieEntityId(activityId))) {
            if (isDexie) {
                activityId = convertIdToInteger(activityId);
            }

            return dbOpen.then(function () {
                return convertToJqueryPromise(db.table('activity').where('activityId').equals(activityId).first());
            });
        } else return $.Deferred().resolve({
            data: {
                activityId: '', siteId: '', projectId: fcConfig.projectId, type: fcConfig.type
            }
        }).promise();
    }

    function offlineGetAllActivities(max, offset, sort, order) {
        sort = sort || 'lastUpdated';
        order = order || 'DESC';
        max = max || 30;
        offset = offset || 0;

        return dbOpen.then(function () {
            var promise, countPromise = convertToJqueryPromise(db.table('activity').count());
            switch (order) {
                default:
                case 'DESC':
                    promise = convertToJqueryPromise(db.table('activity').reverse().offset(offset).limit(max).sortBy(sort));
                    break;
                case 'ASC':
                    promise = convertToJqueryPromise(db.table('activity').offset(offset).limit(max).sortBy(sort));
                    break;
            }

            return $.when(promise, countPromise).then(function (activitiesResult, totalResult) {
                return {data: {activities: activitiesResult.data, total: totalResult.data}};
            });
        });
    }

    function offlineGetActivitiesForProject(projectId, max, offset, sort, order) {
        sort = sort || 'lastUpdated';
        order = order || 'DESC';
        max = max || 30;
        offset = offset || 0;

        return dbOpen.then(function () {
            var promise,
                countPromise = convertToJqueryPromise(db.table('activity').where('projectId').equals(projectId).count());
            switch (order) {
                default:
                case 'DESC':
                    promise = convertToJqueryPromise(db.table('activity').where('projectId').equals(projectId).reverse().offset(offset).limit(max).sortBy(sort));
                    break;
                case 'ASC':
                    promise = convertToJqueryPromise(db.table('activity').where('projectId').equals(projectId).offset(offset).limit(max).sortBy(sort));
                    break;
            }

            return $.when(promise, countPromise).then(function (activitiesResult, totalResult) {
                return {data: {activities: activitiesResult.data, total: totalResult.data}};
            });
        });
    }

    function getSite(siteId) {
        if (isOffline()) {
            return offlineGetSite(siteId);
        } else {
            return onlineGetSite(siteId);
        }
    }

    function onlineGetSite(siteId) {
        var deferred = $.Deferred();
        $.ajax({
            url: fcConfig.siteUrl + "/" + siteId
        }).then(function (result) {
            saveSite(result.site);
            deferred.resolve(standardiseResult(result.site));
        }, function (){
            offlineGetSite(siteId).then(function (result) {
                deferred.resolve(result);
            }, function () {
                deferred.reject();
            });
        });

        return deferred;
    }

    function saveSite(site) {
        return dbOpen.then(function () {
            return db.table('site').put(site);
        });
    }

    function saveSites(sites) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('site').bulkPut(sites));
        });
    }

    function offlineGetSite(siteId) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('site').where('siteId').equals(siteId).first());
        });
    }

    function saveSpeciesPaged(species) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('taxon').bulkPut(species));
        })
    }

    function deleteAllSpecies() {
        return dbOpen.then(function () {
            return db.taxon.where({
                listId: "all"
            }).delete();
        });
    }

    function countAllSpecies() {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.taxon.where({
                listId: "all"
            }).count());
        });
    }

    /**
     * Sequentially download sites. This is done sequentially to avoid overloading the server.
     * @param sites
     * @param index
     * @param deferred
     * @returns {*}
     */
    function getSites(sites, index, deferred) {
        index = index || 0;
        deferred = deferred || $.Deferred();

        if (index < sites.length) {
            onlineGetSite(sites[index]).always(function () {
                getSites(sites, index + 1, deferred);
            });
        } else {
            deferred.resolve({message: "Finished fetching sites", success: true});
        }

        return deferred.promise();
    }

    /**
     * Save an array of species to the database.
     * @param data
     * @returns {*}
     */
    function saveSpecies(data, dataFieldName, outputName, projectActivityId) {
        console.log("in addSpecies");
        if (data.length === 0) {
            return;
        }

        data.forEach(function (item) {
            delete item.commonNameMatches;
            delete item.scientificNameMatches;
            delete item.id;
            item.projectActivityId = projectActivityId;
            item.dataFieldName = dataFieldName;
            item.outputName = outputName;
        });

        return dbOpen.then(function () {
            return convertToJqueryPromise(db.taxon.bulkPut(data));
        });
    };

    /**
     *
     * @param projectActivityId
     * @param dataFieldName
     * @param outputName
     * @returns {*}
     */
    function deleteSpeciesEntries(projectActivityId, dataFieldName, outputName) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.taxon.where({
                projectActivityId: projectActivityId, dataFieldName: dataFieldName, outputName: outputName
            }).delete());
        });
    }

    function getSpeciesForProjectActivity(pa, callback) {
        var promises = [];
        pa.speciesFields && pa.speciesFields.forEach(function (field) {
            var config = field.config, type = config.type;
            console.log("fetching species");
            switch (type) {
                case GROUP:
                case SINGLE:
                    promises.push(deleteFetchedSpeciesEntriesAndGetSpeciesForProjectActivityAndFieldInOutput(pa.projectActivityId, field.dataFieldName, field.output, callback));
                    break;
                case ALL:
                    promises.push(downloadAllSpecies(callback));
                    break;
            }
        });

        return $.when.apply($, promises);
    }

    function onlineGetSpeciesForProjectActivityAndFieldInOutput(offset, projectActivityId, dataFieldName, outputName, limit) {
        return $.ajax({
            url: fcConfig.fetchSpeciesUrl, data: {
                projectActivityId: projectActivityId,
                dataFieldName: dataFieldName,
                output: outputName,
                limit: limit,
                q: "",
                offset: offset
            }
        }).then(function (result) {
            return result.autoCompleteList;
        });
    };

    function downloadAllSpecies (callback) {
        var page = 0,
        total = 1,
        deferred = $.Deferred();
        if (downloadingAllSpecies)
            return

        downloadingAllSpecies = true;
        function fetchNext () {
            page ++;
            if (page <= total) {
                return $.ajax({
                    url: fcConfig.downloadSpeciesUrl + "?page=" + page
                }).then(function (species) {
                    updateProgress();
                    saveSpeciesPaged(species).then(fetchNext, deferred.reject);
                }, function () {
                    updateProgress();
                    deferred.reject();
                });
            }
            else {
                deferred.resolve();
            }

            updateProgress();
        }

        function startFetchingSpecies () {
            return $.ajax({
                url: fcConfig.totalUrl,
                success: function (resp) {
                    total = resp.total;
                    updateProgress();
                }
            }).then(fetchNext);
        }

        function updateProgress () {
            callback && callback(total, page);
        }

        countAllSpecies().then(function (result) {
            if(result.data === 0) {
                startFetchingSpecies();
            }
            else {
                deferred.resolve();
            }
        });

        return deferred.promise();
    }


    function deleteFetchedSpeciesEntriesAndGetSpeciesForProjectActivityAndFieldInOutput(projectActivityId, dataFieldName, outputName) {
        var offset = 0, deferred = $.Deferred();

        function fetchNext(data) {
            data = data || [];
            if (data.length != 0 || offset === 0) {
                onlineGetSpeciesForProjectActivityAndFieldInOutput(offset, projectActivityId, dataFieldName, outputName, SPECIES_MAX_FETCH).then(function (result) {
                    return saveSpecies(result, dataFieldName, outputName, projectActivityId);
                }).then(fetchNext).fail(function () {
                    deferred.reject({
                        offset: offset,
                        projectActivityId: projectActivityId,
                        dataFieldName: dataFieldName,
                        outputName: outputName,
                        completed: false,
                        message: "Failed to fetch species for " + dataFieldName + " " + outputName
                    });
                })
                offset += SPECIES_MAX_FETCH;
            } else {
                deferred.resolve({
                    offset: offset,
                    projectActivityId: projectActivityId,
                    dataFieldName: dataFieldName,
                    outputName: outputName,
                    completed: true,
                    message: "Fetched all spcies for " + dataFieldName + " " + outputName
                });
            }
        }

        function deleteSuccessHandler(count) {
            console.log("Deleted " + count + " items");
            return;
        }

        function deleteFailHandler() {
            console.log("Deletion failed");
            console.log(arguments);
            return;
        }

        deleteSpeciesEntries(projectActivityId, dataFieldName, outputName).then(deleteSuccessHandler, deleteFailHandler).then(fetchNext);
        return deferred.promise();
    }

    // function getActivitiesForProjectActivity(projectActivityId) {
    //     return dbOpen.then(function () {
    //         return convertToJqueryPromise(db.table('activity').where('projectActivityId').equals(projectActivityId).toArray());
    //     });
    // }

    function saveActivity(activity) {
        activity.activityId = activity.activityId || undefined;
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('activity').put(activity));
        });
    }

    function getDocument(documentId) {
        if (isOffline()) {
            return offlineGetDocument(documentId);
        } else {
            return onlineGetDocument(documentId);
        }
    }

    function offlineGetDocument(documentId) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.document.where("documentId").equals(documentId).first());
        });
    }

    function onlineGetDocument(documentId) {
        return $.ajax({
            url: fcConfig.documentUrl + "/" + documentId
        });
    }

    function getProjectActivityMetadata(projectActivityId, activityId) {
        // if(isOffline()) {
        //     return offlineGetProjectActivityMetadata(projectActivityId);
        // }
        // else {
        return onlineGetProjectActivityMetadata(projectActivityId, activityId);
        // }
    }

    function onlineGetProjectActivityMetadata(projectActivityId, activityId) {
        return $.ajax({
            url: fcConfig.metadataURL + "?projectActivityId=" + projectActivityId + (isUuid(activityId) ? "&activityId=" + activityId : "")
        })
            .done(saveProjectActivityMetadata)
            .then(function (result) {
                if (isDexieEntityId(activityId)) {
                    return offlineGetActivity(activityId).then(function (activityResult) {
                        result.activity = activityResult.data;
                        return standardiseResult(result);
                    });
                }

                return standardiseResult(result);
            }, function () {
                return offlineGetProjectActivityMetadata(projectActivityId, activityId)
            });
    }

    function saveProjectActivityMetadata(metadata) {
        if (metadata.projectSite) {
            saveSite(metadata.projectSite);
        }

        if (metadata.project) {
            saveProject(metadata.project);
        }

        if (metadata.pActivity) {
            saveProjectActivity(metadata.pActivity);
        }

        if (metadata.metaModel) {
            var metaModel = mergeMetaModelAndOutputs(metadata);
            saveMetaModel(metaModel);
        }
    }

    function mergeMetaModelAndOutputs(metadata) {
        var outputs = metadata.outputModels;
        metadata.metaModel.outputModels = outputs;
        return metadata.metaModel;
    }

    function saveMetaModel(metaModel) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('metaModel').put(metaModel));
        });
    }

    function offlineGetMetaModel(modelName) {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('metaModel').where('name').equals(modelName).first());
        });
    }

    function offlineGetProjectActivityMetadata(projectActivityId, activityId) {
        var paPromise = offlineFetchProjectActivity(projectActivityId),
            activityPromise = offlineGetActivity(activityId), result = $.Deferred();

        $.when(paPromise, activityPromise)
            .then(function (paResult, activityResult) {
                var pa = paResult.data, activity = activityResult.data, projectId = pa.projectId,
                    projectPromise = offlineFetchProject(projectId),
                    metaModelPromise = offlineGetMetaModel(pa.pActivityFormName),
                    sitePromise = offlineGetSite(activity.siteId)

                $.when(metaModelPromise, projectPromise, sitePromise)
                    .then(function (metaModelResult, projectResult, siteResult) {
                        var metaModel = metaModelResult.data, project = projectResult.data, site = siteResult.data,
                            projectSitePromise = offlineGetSite(project.projectSiteId);

                        projectSitePromise.then(function (projectSiteResult) {
                            var projectSite = projectSiteResult.data;
                            result.resolve(standardiseResult({
                                "activity": activity,
                                "mode": "",
                                "site": site,
                                "project": project,
                                "projectSite": projectSite,
                                "speciesLists": [],
                                "metaModel": metaModel,
                                "outputModels": metaModel.outputModels,
                                "themes": [],
                                "user": null,
                                "mapFeatures": [],
                                "pActivity": pa,
                                "speciesConfig": {"surveyConfig": {"speciesFields": pa.speciesFields}},
                                "projectName": project.name,
                                "isUserAdminModeratorOrEditor": false
                            }));
                        });
                    });
            }).catch(function () {
            result.reject({message: "Failed to get project activity metadata"});
        });

        return result.promise();
    }

    function bulkDeleteDocuments(documentIds) {
        return bulkDelete(documentIds, 'document');
    }

    function deleteSites(siteIds) {
        return bulkDelete(siteIds, 'site');
    }

    function deleteActivities(activityIds) {
        return bulkDelete(activityIds, 'activity');
    }

    function bulkDelete(ids, tableName) {
        if (!Array.isArray(ids)) {
            ids = [ids];
        }

        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table(tableName).bulkDelete(ids));
        });
    }

    function saveMap(map){
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('offlineMap').put(map));
        });
    }

    function getMaps () {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('offlineMap').toArray());
        })
    }

    function deleteMap(mapId) {
        return bulkDelete([mapId], 'offlineMap');
    }

    function standardiseResult(result) {
        return {data: result}
    }

    function convertIdToInteger(id) {
        if (!isNaN(id)) {
            id = parseInt(id)
        }

        return id;
    }

    function getCredentials() {
        return dbOpen.then(function () {
            var promise = db.table('credential').toArray().then(function (credentials) {
                if (credentials.length > 0) {
                    setupAjax(credentials[0]);
                }

                return credentials;
            });

            return convertToJqueryPromise(promise);
        });
    }

    function saveCredentials(credentials) {
        return removeCredentials().then(function () {
            return db.table('credential').put(credentials);
        });
    }

    function setupAjax(credentials) {
        var authorization = "Bearer " + credentials.token;
        $.ajaxSetup({
            cache: false,
            beforeSend: function (xhr) {
                xhr.setRequestHeader('Authorization', authorization);
            }
        });
    }

    function removeCredentials() {
        return dbOpen.then(function () {
            return convertToJqueryPromise(db.table('credential').clear());
        });
    }

    /**
     * Dexie entity ids are integers.
     * @param id
     * @returns {boolean}
     */
    function isDexieEntityId(id) {
        return Number.isInteger(Number.parseInt(id))
    }

    return {
        getProject: getProject,
        getProjectActivity: getProjectActivity,
        saveProjectActivity: saveProjectActivity,
        getActivitiesForProjectActivity: getActivitiesForProjectActivity,
        getActivity: getActivity,
        getSite: getSite,
        getSites: getSites,
        saveSite: saveSite,
        saveSites: saveSites,
        deleteMap: deleteMap,
        saveMap: saveMap,
        getMaps: getMaps,
        offlineGetMetaModel: offlineGetMetaModel,
        offlineGetActivitiesForProject: offlineGetActivitiesForProject,
        offlineGetAllActivities: offlineGetAllActivities,
        saveActivity: saveActivity,
        getDocument: getDocument,
        saveSpecies: saveSpeciesPaged,
        deleteAllSpecies: deleteAllSpecies,
        countAllSpecies: countAllSpecies,
        offlineGetDocument: offlineGetDocument,
        getProjectActivityMetadata: getProjectActivityMetadata,
        getSpeciesForProjectActivity: getSpeciesForProjectActivity,
        bulkDeleteDocuments: bulkDeleteDocuments,
        deleteSites: deleteSites,
        deleteActivities: deleteActivities,
        getCredentials: getCredentials,
        removeCredentials: removeCredentials,
        saveCredentials: saveCredentials,
        utils: {
            isDexieEntityId: isDexieEntityId
        }
    }
})();

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