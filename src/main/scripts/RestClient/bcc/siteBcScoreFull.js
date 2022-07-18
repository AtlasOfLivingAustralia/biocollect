// ***** Need to finalise

self.data.siteBcScore = ko.observable().extend({numericString: 2});
self.selectedEcosystemBenchmark = {};

// Section 0 - Helper functions.
self.bioConditionAssessmentTableReference = {};
self.initialiseReferenceTable = function () {
    if ($.isEmptyObject(self.bioConditionAssessmentTableReference)) {
        self.bioConditionAssessmentTableReference = self.loadLookups('BioConditionAssessmentTableReference');
    }
};

self.consolidatedBenchmarks = {};
self.initialiseBenchmark = function(){
    if ($.isEmptyObject(self.consolidatedBenchmarks)) {
        self.consolidatedBenchmarks = self.loadLookups('ConsolidatedBenchmarks');
    }
};
self.resetBenchmark = function(){
    self.data.benchmarkEucalyptLargeTreeNo("0");
    self.data.benchmarkEucalyptLargeTreeDBH("0");
    self.data.benchmarkNonEucalyptLargeTreeNo("0");
    self.data.benchmarkNonEucalyptLargeTreeDBH("0");
    self.data.benchmarkCWD("0");

    self.data.benchmarkTreeEDLHeight("0");
    self.data.benchmarkTreeCanopyHeight("0");
    self.data.benchmarkSubCanopyHeight("0");
    self.data.benchmarkEdlSpeciesRecruitment("0");

    self.data.benchmarkNumTreeSpeciesTotal("0");
    self.data.benchmarkNumShrubSpeciesTotal("0");
    self.data.benchmarkNumGrassSpeciesTotal("0");
    self.data.benchmarkNumForbSpeciesTotal("0");
    self.data.benchmarkSpeciesCoverExotic("0");

    self.data.benchmarkGroundCoverNativeGrassCover("0");
    self.data.benchmarkGroundCoverOrganicLitterCover("0");

    self.data.benchmarkMaxScoreExcludeLandscape ("0");
    self.data.benchmarkReliability ("0");
    self.data.benchmarkSource ("0");

    self.data.benchmarkTreeCanopyCover("0");
    self.data.benchmarkTreeSubcanopyCover("0");
    self.data.benchmarkEmergentCanopyCover("0");
    self.data.benchmarkShrubCanopyCover("0");

};
self.populateBenchmark = function(){
    if(self.selectedEcosystemBenchmark) {
        //Fields not used - notes
        self.data.benchmarkEucalyptLargeTreeNo(self.selectedEcosystemBenchmark.tot_num_large_trees_euc_ha); // tot_num_large_trees_euc_ha
        self.data.benchmarkEucalyptLargeTreeDBH(self.selectedEcosystemBenchmark.large_tree_threshold_eucalypt); // large_tree_threshold_Eucalypt
        self.data.benchmarkNonEucalyptLargeTreeNo(self.selectedEcosystemBenchmark.tot_num_large_trees_non_euc_ha); // tot_num_large_trees_non_euc_ha
        self.data.benchmarkNonEucalyptLargeTreeDBH(self.selectedEcosystemBenchmark.large_tree_threshold_non_eucalypt); // large_tree_threshold_Non_eucalypt
        self.data.benchmarkCWD(self.selectedEcosystemBenchmark.woody_debris_length_ha); // woody_debris_length_ha

        self.data.benchmarkTreeEDLHeight(self.selectedEcosystemBenchmark.emergent_canopy_height); // emergent_canopy_height
        self.data.benchmarkTreeCanopyHeight(self.selectedEcosystemBenchmark.tree_canopy_height); // tree_canopy_height
        self.data.benchmarkSubCanopyHeight(self.selectedEcosystemBenchmark.tree_subcanopy_height); // tree_subcanopy_height
        self.data.benchmarkEdlSpeciesRecruitment(self.selectedEcosystemBenchmark.recruitment); // recruitment

        self.data.benchmarkNumTreeSpeciesTotal(self.selectedEcosystemBenchmark.tree_sp_richness); // tree_sp_richness
        self.data.benchmarkNumShrubSpeciesTotal(self.selectedEcosystemBenchmark.shrub_sp_richness); // shrub_sp_richness
        self.data.benchmarkNumGrassSpeciesTotal(self.selectedEcosystemBenchmark.grass_sp_richness); // grass_sp_richness
        self.data.benchmarkNumForbSpeciesTotal(self.selectedEcosystemBenchmark.forb_other_sp_richness); // forb_other_sp_richness
        self.data.benchmarkSpeciesCoverExotic(self.selectedEcosystemBenchmark.nn_plant_cover); // nn_plant_cover

        self.data.benchmarkGroundCoverNativeGrassCover(self.selectedEcosystemBenchmark.native_per_grass); // native_per_grass
        self.data.benchmarkGroundCoverOrganicLitterCover(self.selectedEcosystemBenchmark.litter_grd_cov); // litter_grd_cov

        self.data.benchmarkMaxScoreExcludeLandscape (self.selectedEcosystemBenchmark.max_score_exclude_landscape); // max_score_exclude_landscape
        self.data.benchmarkReliability (self.selectedEcosystemBenchmark.reliability); // reliability
        self.data.benchmarkSource (self.selectedEcosystemBenchmark.source); // source

        self.data.benchmarkTreeCanopyCover(self.selectedEcosystemBenchmark.tree_canopy_cover); // tree_canopy_cover
        self.data.benchmarkTreeSubcanopyCover(self.selectedEcosystemBenchmark.tree_subcanopy_cover); // tree_subcanopy_cover
        self.data.benchmarkEmergentCanopyCover(self.selectedEcosystemBenchmark.emergent_canopy_cover); // emergent_canopy_cover
        self.data.benchmarkShrubCanopyCover(self.selectedEcosystemBenchmark.shrub_canopy_cover); //shrub_canopy_cover
    }
};

self.getTable = function(tableNumber){
    var table;
    $.grep(!$.isEmptyObject(self.bioConditionAssessmentTableReference) ? self.bioConditionAssessmentTableReference.value : [], function (row) {
        if (row.key == tableNumber) {
            table = row;
        }
    });

    return table;
}

self.getAssesmentPercentage = function(param1, param2){
    var assessmentPercentage = 0;
    if(param1 != 'na' && !isNaN(param1) && !isNaN(param2) && param1 > 0) {
        assessmentPercentage = parseInt(param2)/parseInt(param1) * 100;
    }
    return assessmentPercentage;
};

self.getTable6Score = function(assessmentPercentage){
    var score = 0;
    var table = self.getTable('table_6');
    if(table && table.value && table.value.length == 3) {
        if (table.value[0].name == '<25% of benchmark height' && assessmentPercentage <= 0) {
            score = table.value[0].value;
        } else if (table.value[1].name == '≥25% to 70% of benchmark height' && assessmentPercentage >= 25 && assessmentPercentage < 70) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥70% of benchmark height' && assessmentPercentage >= 70) {
            score = table.value[2].value;
        }
    }

    return score;
};

self.getTable7Score = function(assessmentPercentage){
    var score = 0;
    var table = self.getTable('table_7');
    if(table && table.value && table.value.length == 3) {
        if (table.value[0].name == '<20% of dominant canopy* species present as regeneration' && assessmentPercentage < 20) {
            score = table.value[0].value;
        } else if (table.value[1].name == '≥20 – 75% of dominant canopy* species present as regeneration' && assessmentPercentage >= 20 && assessmentPercentage < 75) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥75% of dominant canopy* species present as regeneration' && assessmentPercentage >= 75) {
            score = table.value[2].value;
        }
    }
    return score;
}

self.getTable8Score = function(assessmentPercentage){
    var score = 0;
    var table = self.getTable('table_8');
    if(table.key == 'table_8' && table && table.value && table.value.length == 4) {
        if (table.value[0].name == '<10' && assessmentPercentage < 10) {
            score = table.value[0].value;
        } else if (table.value[1].name == '>=10% and <50%' && assessmentPercentage >= 10 && assessmentPercentage < 50) {
            score = table.value[1].value;
        } else if (table.value[2].name == '>=50% or <=200%' && assessmentPercentage >= 50 && assessmentPercentage <= 200) {
            score = table.value[2].value;
        } else if (table.value[3].name == '>200%' && assessmentPercentage > 200) {
            score = table.value[3].value;
        }
    }
    return score;
};

self.getTable9Score = function(assessmentPercentage){
    var score = 0;
    var table = self.getTable('table_9');
    if(table.key == 'table_9' && table && table.value && table.value.length == 3) {
        if (table.value[0].name == '<10% of benchmark shrub cover' && assessmentPercentage < 10) {
            score = table.value[0].value;
        } else if (table.value[1].name == '>/= 10 to <50% or >200% of benchmark shrub cover' && ((assessmentPercentage >= 10 && assessmentPercentage < 50) || assessmentPercentage >= 200)) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥50% or ≤200% of benchmark shrub cover' && assessmentPercentage >= 50 && assessmentPercentage <= 200) {
            score = table.value[2].value;
        }
    }
    return score;
};

self.getTable10Score = function(totalCwdLength, bmv10, bmv50, bmv200) {
    var score = 0;
    var table = self.getTable('table_10');
    if (table && table.value && table.value.length == 3) {
        if (table.value[0].name == '<10% of benchmark number or total length of CWD' && totalCwdLength  < bmv10 ) {
            score = table.value[0].value;
        } else if (table.value[1].name == '>/= 10 to <50% or >200% of benchmark number or total length of CWD' &&
            (totalCwdLength >= bmv10 && totalCwdLength < bmv50) ||
            (totalCwdLength > bmv200)) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥50% or ≤200% of benchmark number or total length of CWD' &&
            (totalCwdLength >= bmv50 || totalCwdLength <= bmv200)) {
            score = table.value[2].value;
        }
    }
    return score;
};

self.getTable11Score = function(assessmentPercentage){
    var score = 0;
    var table = self.getTable('table_11');
    if(table && table.value && table.value.length == 3) {
        if (table.value[0].name == '<25% of benchmark number of species within each life-form' && assessmentPercentage < 25) {
            score = table.value[0].value;
        } else if (table.value[1].name == '≥25% to 90% of benchmark number of species within each life-form' && assessmentPercentage >= 25 && assessmentPercentage < 90) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥90% of benchmark number of species within each life-form' && assessmentPercentage >= 90) {
            score = table.value[2].value;
        }
    }
    return score;
};

self.getTable12Score = function(assessmentPercentage){
    var score = 0;
    var table = self.getTable('table_12');
    if(table && table.value && table.value.length == 4) {
        if (table.value[0].name == '>50% of vegetation cover are non-native plants' && assessmentPercentage > 50) {
            score = table.value[0].value;
        } else if (table.value[1].name == '≥25 – 50% of vegetation cover are non-native plants' && assessmentPercentage >= 25 && assessmentPercentage < 50) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥5 – 25% of vegetation cover are non-native plants' && assessmentPercentage >= 5 && assessmentPercentage < 25) {
            score = table.value[2].value;
        } else if (table.value[3].name == '<5% of vegetation cover are non-native plants' && assessmentPercentage < 5) {
            score = table.value[3].value;
        }
    }
    return score;
};

// getTable13Score and getTable14Score implemented inside groundCover.js

// Section 1 - 100 x 50m Area - Ecologically Dominant Layer
// Part 1 = A
self.calculateLargeTreeScore = function(){
    var numLargeEucalypt = parseInt(self.data.numLargeEucalypt());
    var numLargeNonEucalypt = parseInt(self.data.numLargeNonEucalypt());

    self.data.totalLargeTrees(numLargeEucalypt + numLargeNonEucalypt);
    self.data.numLargeEucalyptPerHa(numLargeEucalypt * 2);
    self.data.numLargeNonEucalyptPerHa(numLargeNonEucalypt * 2);
    self.data.totalLargeTreesPerHa(parseInt(self.data.numLargeEucalyptPerHa()) + parseInt(self.data.numLargeNonEucalyptPerHa()));

    var benchmarkNumLargeEucalypt = self.data.benchmarkEucalyptLargeTreeNo();
    var benchmarkNumLargeNonEucalypt = self.data.benchmarkNonEucalyptLargeTreeNo();
    var assessmentPercentage = 0;
    var benchmarkTotalLargeTrees = 0;

    if(!isNaN(benchmarkNumLargeEucalypt)){
        benchmarkTotalLargeTrees = benchmarkTotalLargeTrees + parseInt(benchmarkNumLargeEucalypt);
    }

    if(!isNaN(benchmarkNumLargeNonEucalypt)) {
        benchmarkTotalLargeTrees = benchmarkTotalLargeTrees + parseInt(benchmarkNumLargeNonEucalypt);
    }

    if(benchmarkTotalLargeTrees > 0) {
        assessmentPercentage = (parseInt(self.data.totalLargeTreesPerHa())/parseInt(benchmarkTotalLargeTrees)) * 100;
    }

    // Get the table value
    var table = self.getTable('table_5');

    // Calculate the score.
    assessmentPercentage = parseInt(assessmentPercentage);
    var score = 0;
    if (table && table.value && table.value.length == 4) {
        if (table.value[0].name == 'No large trees present' && assessmentPercentage <= 0) {
            score = table.value[0].value;
        } else if (table.value[1].name == '0 to 50% of benchmark number of large trees' && assessmentPercentage > 0 && assessmentPercentage < 50) {
            score = table.value[1].value;
        } else if (table.value[2].name == '≥50% to 100% of benchmark number of large trees' && assessmentPercentage >= 50 && assessmentPercentage < 100) {
            score = table.value[2].value;
        } else if (table.value[3].name == '≥ benchmark number of large trees' && assessmentPercentage >= 100 ) {
            score = table.value[3].value;
        }
    }
    self.data.largeTreesScore(score);
};

// Part 2 = B
self.calculateAveCanopyHeightScore = function(){
    // Emergent canopy height score
    var emergentHeight = self.data.emergentHeightInMetres();
    var benchmarkEmergentHeight = self.data.benchmarkTreeEDLHeight();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkEmergentHeight, emergentHeight);
    self.data.emergentHeightScore(self.getTable6Score(assessmentPercentage));

    // EDL tree canopy height score
    var treeCanopyHeight = self.data.treeCanopyHeightInMetres();
    var benchmarkTreeCanopyHeight = self.data.benchmarkTreeCanopyHeight();
    assessmentPercentage = self.getAssesmentPercentage(benchmarkTreeCanopyHeight, treeCanopyHeight);;
    self.data.edlCanopyHeightScore(self.getTable6Score(assessmentPercentage));

    // Tree subcanopy height score
    var subcanopyHeight = self.data.subcanopyHeightInMetres();
    var benchmarkSubCanopyHeight = self.data.benchmarkSubCanopyHeight();
    assessmentPercentage = self.getAssesmentPercentage(benchmarkSubCanopyHeight, subcanopyHeight);
    self.data.subcanopyHeightScore(self.getTable6Score(assessmentPercentage));

    // Averaged canopy height score
    var count = 0;
    parseInt(self.data.subcanopyHeightScore()) > 0 ? count++ : 0;
    parseInt(self.data.edlCanopyHeightScore()) > 0 ? count++ : 0;
    parseInt(self.data.emergentHeightScore()) > 0 ? count++ : 0;
    var avg = (parseInt(self.data.subcanopyHeightScore()) + parseInt(self.data.edlCanopyHeightScore()) + parseInt(self.data.emergentHeightScore()))/parseInt(count);
    avg = avg > 0 ? avg : 0;
    self.data.aveCanopyHeightScore(avg);
};

// Part 3 = C
self.calculateEDLSpeciesRecruitment  = function(){
    var proportionDominantCanopySpeciesWithEvidenceOfRecruitment = self.data.proportionDominantCanopySpeciesWithEvidenceOfRecruitment();
    var benchmarkEdlSpeciesRecruitment = self.data.benchmarkEdlSpeciesRecruitment();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkEdlSpeciesRecruitment, proportionDominantCanopySpeciesWithEvidenceOfRecruitment);
    self.data.edlRecruitmentScore(self.getTable7Score(assessmentPercentage));
};

//>> Part 4 template
var Output_BioConditionConsolidated_treeSpeciesRichnessRow = function (data, dataModel, context, config) {
    var self = this;
    ecodata.forms.NestedModel.apply(self, [data, dataModel, context, config]);
    context = _.extend(context, {parent:self});            var speciesNameTreeConfig = _.extend(config, {printable:'', dataFieldName:'speciesNameTree', output: 'BioCondition Site Method', surveyName: '' });
    self.speciesNameTree = new SpeciesViewModel({}, speciesNameTreeConfig);
    self.loadData = function(data) {
        self['speciesNameTree'].loadData(ecodata.forms.orDefault(data['speciesNameTree'], {}));
    };
    self.loadData(data || {});
};
var context = _.extend({}, context, {parent:self, listName:'treeSpeciesRichness'});
self.data.treeSpeciesRichness = ko.observableArray().extend({list:{metadata:self.dataModel, constructorFunction:Output_BioConditionConsolidated_treeSpeciesRichnessRow, context:context, userAddedRows:true, config:config}});
self.data.treeSpeciesRichness.loadDefaults = function() {
};
//<<

// Part 4 = G1
self.calculateTreeSpeciesRichness = function() {
    self.data.numTreeSpecies(self.data.treeSpeciesRichness().length);
    var sumofNumOfSpecies = parseInt(self.data.numTreeSpecies()) + parseInt(self.data.numUnknownTreeSpecies());
    var benchmarkNumTreeSpeciesTotal = self.data.benchmarkNumTreeSpeciesTotal();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkNumTreeSpeciesTotal,sumofNumOfSpecies);
    self.data.numTreeSpeciesTotal(self.getTable11Score(assessmentPercentage));
};

// Section 2 - 50 x 10m Area - Understorey & Sub-dominant Layer
// Part 1 - G2
self.calculateNativeShrubSpeciesRichness = function() {
    self.data.numShrubSpecies(self.data.shrubSpeciesRichness().length);
    var numShrubSpecies = parseInt(self.data.numShrubSpecies()) + parseInt(self.data.numUnknownShrubSpecies());
    var benchmarkNumShrubSpeciesTotal = self.data.benchmarkNumShrubSpeciesTotal();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkNumShrubSpeciesTotal, numShrubSpecies);;
    self.data.numShrubSpeciesTotal(self.getTable11Score(assessmentPercentage));
}

// Part 2 - G3
self.calculateNativeGrassSpeciesRichness = function() {
    self.data.numGrassSpecies(self.data.grassSpeciesRichness().length);
    var numGrassSpecies = parseInt(self.data.numGrassSpecies()) + parseInt(self.data.numUnknownGrassSpecies());
    var benchmarkNumGrassSpeciesTotal = self.data.benchmarkNumGrassSpeciesTotal();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkNumGrassSpeciesTotal, numGrassSpecies);;
    self.data.numGrassSpeciesTotal(self.getTable11Score(assessmentPercentage));
};

// Part 3 - G4
self.calculateForbsAndOtherNonGrassGroundSpeciesRichness = function() {
    self.data.numForbSpecies(self.data.forbsAndOtherNonGrassGroundSpeciesRichness().length);
    var numForbSpecies = parseInt(self.data.numForbSpecies()) + parseInt(self.data.numUnknownForbSpecies());
    var benchmarkNumForbSpeciesTotal = self.data.benchmarkNumForbSpeciesTotal();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkNumForbSpeciesTotal, numForbSpecies);
    self.data.numForbSpeciesTotal(self.getTable11Score(assessmentPercentage));
}

// Part 4 - H
self.calculateNonNativeSpeciesRichness = function() {
    self.data.numNonNativeSpecies(self.data.nonNativeSpeciesRichness().length);
    var numNonNativeSpecies = parseInt(self.data.numNonNativeSpecies()) + parseInt(self.data.numUnknownNonNativeSpecies());
    var benchmarkSpeciesCoverExotic = self.data.benchmarkSpeciesCoverExotic();
    var assessmentPercentage = self.getAssesmentPercentage(benchmarkSpeciesCoverExotic, numNonNativeSpecies);;
    self.data.numNonNativeSpeciesTotal(self.getTable12Score(assessmentPercentage));

    var score = self.getTable12Score(self.data.nonNativePlantCoverPercent());
    self.data.nonNativePlantCoverScore(score);
}

// Section 3 - 50 x 20m area - Coarse Woody Debris
// Part 1 - F
self.calculateCwdScore = function() {
    var benchmarkValue = parseInt(self.data.benchmarkCWD());
    var totalCwdLength = self.data.totalCwdLength();
    if(isNaN(totalCwdLength) || totalCwdLength == 0){
        return;
    }

    if(benchmarkValue != 'na' && !isNaN(benchmarkValue)) {
        var bmv10 = (benchmarkValue * 10) / 100;
        var bmv50 = (benchmarkValue * 50) / 100;
        var bmv200 = (benchmarkValue * 200) / 100;
        self.data.cwdScore(self.getTable10Score(totalCwdLength * 10, bmv10, bmv50, bmv200));
    }

};

// Section 4 - Five 1x1m plots - Ground Cover
// Refer groundCover.js

// Section 5 - 100m Transect
// Part 1 - D
self.calculateTreeCanopyCoverScoreAve = function() {

    var percentCoverC = 0;
    var percentCoverS = 0;
    var percentCoverE = 0;
    var cCount = 0;
    var sCount = 0;
    var eCount = 0;
    $.each(self.data.treeCanopyRecords(), function( index, value ) {
        var cover = self.calculateTreeCanopyCover(self.data.treeCanopyRecords(), value);
        self.data.treeCanopyRecords()[index].totalTCCover(parseFloat(value.distanceInMetersAlongTransectTreeEnd()) - parseFloat(value.distanceInMetersAlongTransectTreeStart()));
        if(value.treeOrTreeGroup() == 'C') {
            percentCoverC = parseFloat(percentCoverC) + parseFloat(cover);
            cCount++;
        } else if(value.treeOrTreeGroup() == 'S') {
            percentCoverS = parseFloat(percentCoverS) + parseFloat(cover);
            sCount++;
        } else if (value.treeOrTreeGroup() == 'E') {
            percentCoverE = parseFloat(percentCoverE) + parseFloat(cover);
            eCount++;
        }
    });

    var lengthOfTransectInMeters = self.data.lengthOfTransectInMeters();

    if(lengthOfTransectInMeters && lengthOfTransectInMeters >=50){

        percentCoverC = percentCoverC*100/lengthOfTransectInMeters;
        percentCoverS = percentCoverS*100/lengthOfTransectInMeters;
        percentCoverE = percentCoverE*100/lengthOfTransectInMeters;

        self.data.percentCoverC(percentCoverC);
        self.data.percentCoverS(percentCoverS);
        self.data.percentCoverE(percentCoverE);

        var benchmarkTreeCanapyCover = self.data.benchmarkTreeCanopyCover();
        var benchmarkTreeSubCanapyCover = self.data.benchmarkTreeSubcanopyCover();
        var benchmarkTreeEmergentCover = self.data.benchmarkEmergentCanopyCover();

        var assessmentPercentage = 0;
        assessmentPercentage = self.getAssesmentPercentage(benchmarkTreeCanapyCover, percentCoverC);
        var cCoverScore = self.getTable8Score(assessmentPercentage);
        self.data.coverScoreC(cCoverScore);

        var assessmentPercentage = 0;
        assessmentPercentage = self.getAssesmentPercentage(benchmarkTreeSubCanapyCover, percentCoverS);
        var sCoverScore = self.getTable8Score(assessmentPercentage);
        self.data.coverScoreS(sCoverScore);

        var assessmentPercentage = 0;
        assessmentPercentage = self.getAssesmentPercentage(benchmarkTreeEmergentCover, percentCoverE);
        var eCoverScore = self.getTable8Score(assessmentPercentage);
        self.data.coverScoreE(eCoverScore);

        var total = 3;
        if(benchmarkTreeCanapyCover == "na") {total = total -1;}
        if(benchmarkTreeSubCanapyCover == "na") {total = total -1;}
        if(benchmarkTreeEmergentCover == "na") {total = total -1;}

        var treeCanopyCoverScoreAve = total == 0 ? 0 : (parseFloat(cCoverScore) + parseFloat(sCoverScore) + parseFloat(eCoverScore))/total;
        self.data.treeCanopyCoverScoreAve(treeCanopyCoverScoreAve);
    }
};

self.calculateTreeCanopyCover = function(treeCanopyRecords, record) {

    var sortedList = Object.values(treeCanopyRecords).sort(function(a,b) { return (parseFloat(a.distanceInMetersAlongTransectTreeStart()) - parseFloat(b.distanceInMetersAlongTransectTreeStart())) || (parseFloat(a.distanceInMetersAlongTransectTreeEnd()) - parseFloat(b.distanceInMetersAlongTransectTreeEnd())); });
    var list = sortedList.filter(y => y.treeOrTreeGroup() == record.treeOrTreeGroup())

    var position = Object.values(list).findIndex(z => z == record)

    if(position == 0){
        return parseFloat(record.distanceInMetersAlongTransectTreeEnd()) - parseFloat(record.distanceInMetersAlongTransectTreeStart())
    }
    else{
        if(parseFloat(record.distanceInMetersAlongTransectTreeStart()) < parseFloat(list[position -1].distanceInMetersAlongTransectTreeEnd())){

            var currentMaxPosition = position -1;
            var overlapTreePosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectTreeEnd()) > parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd())) {
                    overlapTreePosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }
            var extra = parseFloat(record.distanceInMetersAlongTransectTreeEnd()) - parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd())
            if (extra > 0){return extra}
            else {return 0}

        }
        else{
            var currentMaxPosition = position -1;
            var overlapTreePosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectTreeEnd()) > parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd())) {
                    overlapTreePosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }

            if(overlapTreePosition == position -1) {
                return parseFloat(record.distanceInMetersAlongTransectTreeEnd()) - parseFloat(record.distanceInMetersAlongTransectTreeStart())
            }
            else {
                if(parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd()) < parseFloat(record.distanceInMetersAlongTransectTreeStart())){
                    return parseFloat(record.distanceInMetersAlongTransectTreeEnd()) - parseFloat(record.distanceInMetersAlongTransectTreeStart())
                }
                else {
                    var extra = parseFloat(record.distanceInMetersAlongTransectTreeEnd()) - parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd())
                    if (extra > 0){return extra}
                    else {return 0}
                }
            }
        }
    }

};

// Part 2 - E
self.calculateShrubCanopyCoverScoreN = function() {
    var percentCoverNative = 0;
    var percentCoverExotic = 0;

    $.each(self.data.shrubCanopyRecords(), function( index, value ) {
        var cover = self.calculateShrubCanopyCover(self.data.shrubCanopyRecords(), value);
        self.data.shrubCanopyRecords()[index].totalSCCover(parseFloat(value.distanceInMetersAlongTransectShrubEnd()) - parseFloat(value.distanceInMetersAlongTransectShrubStart()));
        if(value.shrubType() == 'native') {
            percentCoverNative = parseFloat(percentCoverNative) + parseFloat(cover);
        } else if(value.shrubType() == 'exotic') {
            percentCoverExotic = parseFloat(percentCoverExotic) + parseFloat(cover);
        }
    });

    var lengthOfTransectInMeters = self.data.lengthOfTransectInMeters();

    if(lengthOfTransectInMeters && lengthOfTransectInMeters >=50){

        percentCoverNative = percentCoverNative*100/lengthOfTransectInMeters;
        percentCoverExotic = percentCoverExotic*100/lengthOfTransectInMeters;

        self.data.percentCoverNative(percentCoverNative);
        self.data.percentCoverExotic(percentCoverExotic);


        var benchmarkShrubCoverNative = self.data.benchmarkShrubCanopyCover();
        var assessmentPercentage = self.getAssesmentPercentage(benchmarkShrubCoverNative, percentCoverNative);;
        self.data.shrubCanopyCoverScoreN(self.getTable9Score(assessmentPercentage));
    }
};

self.calculateShrubCanopyCover = function(shrubCanopyRecords, record) {

    var sortedList = Object.values(shrubCanopyRecords).sort(function(a,b) { return (parseFloat(a.distanceInMetersAlongTransectShrubStart()) - parseFloat(b.distanceInMetersAlongTransectShrubStart())) || (parseFloat(a.distanceInMetersAlongTransectShrubEnd()) - parseFloat(b.distanceInMetersAlongTransectShrubEnd())); });
    var list = sortedList.filter(y => y.shrubType() == record.shrubType())

    var position = Object.values(list).findIndex(z => z == record)

    if(position == 0){
        return parseFloat(record.distanceInMetersAlongTransectShrubEnd()) - parseFloat(record.distanceInMetersAlongTransectShrubStart())
    }
    else{
        if(parseFloat(record.distanceInMetersAlongTransectShrubStart()) < parseFloat(list[position -1].distanceInMetersAlongTransectShrubEnd())){

            var currentMaxPosition = position -1;
            var overlapShrubPosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectShrubEnd()) > parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd())) {
                    overlapShrubPosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }
            var extra = parseFloat(record.distanceInMetersAlongTransectShrubEnd()) - parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd())
            if (extra > 0){return extra}
            else {return 0}

        }
        else{
            var currentMaxPosition = position -1;
            var overlapShrubPosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectShrubEnd()) > parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd())) {
                    overlapShrubPosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }

            if(overlapShrubPosition == position -1) {
                return parseFloat(record.distanceInMetersAlongTransectShrubEnd()) - parseFloat(record.distanceInMetersAlongTransectShrubStart())
            }
            else {
                if(parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd()) < parseFloat(record.distanceInMetersAlongTransectShrubStart())){
                    return parseFloat(record.distanceInMetersAlongTransectShrubEnd()) - parseFloat(record.distanceInMetersAlongTransectShrubStart())
                }
                else {
                    var extra = parseFloat(record.distanceInMetersAlongTransectShrubEnd()) - parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd())
                    if (extra > 0){return extra}
                    else {return 0}
                }
            }

        }
    }

};

// Section 6 - Update full form calculation
self.calculate = function() {
    //Section 1
    self.calculateLargeTreeScore();
    self.calculateAveCanopyHeightScore();
    self.calculateEDLSpeciesRecruitment();
    self.calculateTreeSpeciesRichness();

    //Section 2
    self.calculateNativeShrubSpeciesRichness();
    self.calculateNativeGrassSpeciesRichness();
    self.calculateForbsAndOtherNonGrassGroundSpeciesRichness();
    self.calculateNonNativeSpeciesRichness();

    self.data.nativePlantSpeciesRichnessScore(parseFloat(self.data.numTreeSpeciesTotal()) + parseFloat(self.data.numShrubSpeciesTotal()) + parseFloat(self.data.numGrassSpeciesTotal()) + parseFloat(self.data.numForbSpeciesTotal()));

    //Section 3
    self.calculateCwdScore();

    // Section 4 - Five 1x1m plots - Ground Cover
    // Refer groundCover.js

    // Section 5 - 100m Transect
    self.calculateTreeCanopyCoverScoreAve()
    self.calculateShrubCanopyCoverScoreN()

    // Calculate Site Based Final Score
    // a+b+c+d+e+f+g+h+i+j/Y
    // Y = Maximum Benchmark Value.
    var a = parseFloat(self.data.largeTreesScore());
    var b = parseFloat(self.data.aveCanopyHeightScore());
    var c = parseFloat(self.data.edlRecruitmentScore());
    var d = parseFloat(self.data.treeCanopyCoverScoreAve());
    var e = parseFloat(self.data.shrubCanopyCoverScoreN());
    var f = parseFloat(self.data.cwdScore());
    var g = parseFloat(self.data.nativePlantSpeciesRichnessScore());
    var h = parseFloat(self.data.nonNativePlantCoverScore());
    var k = parseFloat(self.data.patchSizeScore());
    var l = parseFloat(self.data.connectivityScore());
    var m = parseFloat(self.data.landscapeContextScore());
    var n = parseFloat(self.data.distanceFromWaterScore());
    var z = 20; // is the maximum site score that can be obtained for landscape attributes (k–m in fragmented landscapes or n in intact landscapes) (Z = 20)

    // % Native Perennial ('decreaser') grass cover*
    var groundCoverNativeGrassCover;
    $.each(self.data.groundCover(), function (i, obj) {
        if (obj.groundCoverType() == "% Native Perennial ('decreaser') grass cover*") {
            groundCoverNativeGrassCover = obj;
        }
    });
    if(groundCoverNativeGrassCover) {
        self.data.nativePerennialGrassCoverScore(groundCoverNativeGrassCover.groundCoverScore());
    }


    // % Litter*
    var groundCoverOrganicLitterCover;
    $.each(self.data.groundCover(), function (i, obj) {
        if (obj.groundCoverType() == "% Litter*") {
            groundCoverOrganicLitterCover = obj;
        }
    });

    if(groundCoverOrganicLitterCover) {
        self.data.litterCoverScore(groundCoverOrganicLitterCover.groundCoverScore());
    }

    var i = parseFloat(self.data.nativePerennialGrassCoverScore());
    var j = parseFloat(self.data.litterCoverScore());
    var y = parseFloat(self.data.benchmarkMaxScoreExcludeLandscape());
    var isFragmentedLandscape = self.data. isFragmentedLandscape();
    var landscapeAttScore = isFragmentedLandscape == "Yes" ? parseFloat(k+l+m) : parseFloat(n)
    var sum = parseFloat(a+b+c+d+e+f+g+h+i+j+landscapeAttScore);
    if(y > 0 && sum > 0) {
        var siteScore = sum/(y+z);
        self.data.siteBcScore(siteScore);
    }
};

// Section 7 - Setup and Initialisation
self.benchmarkSetup = function(benchmarkCode) {
    $.grep(!$.isEmptyObject(self.consolidatedBenchmarks) ? self.consolidatedBenchmarks : [], function (row) {
        if (row.re_with_dec == benchmarkCode) {
            self.selectedEcosystemBenchmark = row;
            self.populateBenchmark();
            self.calculate();
        }
    });
};

var benchmarkChangeCount = 0;
self.data.bioregion.subscribe(function (obj) {

    if(benchmarkChangeCount > 0 || window.location.href.search("bioActivity/create") > -1)  {
        if(self.data.bioregion() != undefined) {
            self.benchmarkSetup(self.data.bioregion());
            var displayText =
                "<h2><b>Benchmark values for RE code: "+self.data.bioregion()+"</b></h2><table border='0'>"+
                "<tr><td><b>Benchmark name</b></td><td><b>Benchmark value</b></td></tr>"+

                "<tr><td>EucalyptLargeTreeNo</td><td>"+self.data.benchmarkEucalyptLargeTreeNo()+"</td></tr>"+
                "<tr><td>EucalyptLargeTreeDBH</td><td>"+self.data.benchmarkEucalyptLargeTreeDBH()+"</td></tr>"+
                "<tr><td>NonEucalyptLargeTreeNo</td><td>"+self.data.benchmarkNonEucalyptLargeTreeNo()+"</td></tr>"+
                "<tr><td>NonEucalyptLargeTreeDBH</td><td>"+self.data.benchmarkNonEucalyptLargeTreeDBH()+"</td></tr>"+
                "<tr><td>CWD</td><td>"+self.data.benchmarkCWD()+"</td></tr>"+

                "<tr><td>TreeEDLHeight</td><td>"+self.data.benchmarkTreeEDLHeight()+"</td></tr>"+
                "<tr><td>TreeCanopyHeight</td><td>"+self.data.benchmarkTreeCanopyHeight()+"</td></tr>"+
                "<tr><td>SubCanopyHeight</td><td>"+self.data.benchmarkSubCanopyHeight()+"</td></tr>"+
                "<tr><td>EdlSpeciesRecruitment</td><td>"+self.data.benchmarkEdlSpeciesRecruitment()+"</td></tr>"+

                "<tr><td>NumTreeSpeciesTotal</td><td>"+self.data.benchmarkNumTreeSpeciesTotal()+"</td></tr>"+
                "<tr><td>NumShrubSpeciesTotal</td><td>"+self.data.benchmarkNumShrubSpeciesTotal()+"</td></tr>"+
                "<tr><td>NumGrassSpeciesTotal</td><td>"+self.data.benchmarkNumGrassSpeciesTotal()+"</td></tr>"+
                "<tr><td>NumForbSpeciesTotal</td><td>"+self.data.benchmarkNumForbSpeciesTotal()+"</td></tr>"+
                "<tr><td>SpeciesCoverExotic</td><td>"+self.data.benchmarkSpeciesCoverExotic()+"</td></tr>"+

                "<tr><td>GroundCoverNativeGrassCover</td><td>"+self.data.benchmarkGroundCoverNativeGrassCover()+"</td></tr>"+
                "<tr><td>GroundCoverOrganicLitterCover</td><td>"+self.data.benchmarkGroundCoverOrganicLitterCover()+"</td></tr>"+

                "<tr><td>TreeCanopyCover</td><td>"+self.data.benchmarkTreeCanopyCover()+"</td></tr>"+
                "<tr><td>TreeSubcanopyCover</td><td>"+self.data.benchmarkTreeSubcanopyCover()+"</td></tr>"+
                "<tr><td>EmergentCanopyCover</td><td>"+self.data.benchmarkEmergentCanopyCover()+"</td></tr>"+
                "<tr><td>ShrubCanopyCover</td><td>"+self.data.benchmarkShrubCanopyCover()+"</td></tr>"+
                "<tr><td>MaxScoreExcludeLandscape</td><td>"+self.data.benchmarkMaxScoreExcludeLandscape()+"</td></tr>"+
                "<tr><td>Reliability</td><td>"+self.data.benchmarkReliability()+"</td></tr>"+
                "<tr><td>Source</td><td>"+self.data.benchmarkSource()+"</td></tr>"+

                "</table>";
            bootbox.alert(displayText);
        } else {
            bootbox.alert("<h2><b>Invalid Bioregion RE code</b></h2>");
            self.resetBenchmark();
        }
    } else {
        benchmarkChangeCount++;
    }
});

self.transients.siteBcScore =  ko.computed(function () {
    console.log("[Main Thread] benchmarkSetup");
    self.benchmarkSetup(self.data.bioregion());
});

// Retreive BioCondition reference table and benchmark values
self.loadLookups = function (key) {
    var result = {};
    var bioConditionAssessmentTableReferenceUrl = 'https://biocollect.ala.org.au/download/getScriptFile?hub=bcc&filename=mini_vegetationTable.json.js&model=bioConditionSiteAssessment';
    var consolidatedBenchmarksURL = "https://biocollect.ala.org.au/download/getScriptFile?hub=bcc&filename=benchmark_data_for_release_v3.1.json&model=bioConditionSiteAssessment"
    var url = '';
    switch (key) {
        case 'BioConditionAssessmentTableReference':
            url = bioConditionAssessmentTableReferenceUrl;
            break;
        case 'ConsolidatedBenchmarks'   :
            url = consolidatedBenchmarksURL
            break;
        default:
            break;
    }
    $.ajax({
        url: url,
        dataType: 'json',
        async: false,
        success: function (data) {
            result = data
        }
    });
    return result;
};


// Calculate - Assessment - Landscape Attributes
// Start of 6.1 Landscaping
self.data.patchSize.subscribe(function (obj) {
    var table;
    $.grep(!$.isEmptyObject(self.bioConditionAssessmentTableReference) ? self.bioConditionAssessmentTableReference.value : [], function (row) {
        if (row.key == 'table_15') {
            table = row;
        }
    });

    $.grep(table ? table.value : [], function (row) {
        if (row.name == self.data.patchSize()) {
            self.data.patchSizeScore(row.value);
        }
    });
    self.calculate();
});

self.data.connectivity.subscribe(function (obj) {
    var table;
    $.grep(!$.isEmptyObject(self.bioConditionAssessmentTableReference) ? self.bioConditionAssessmentTableReference.value : [], function (row) {
        if (row.key == 'table_16') {
            table = row;
        }
    });

    $.grep(table ? table.value : [], function (row) {
        if (row.name == self.data.connectivity()) {
            self.data.connectivityScore(row.value);
        }
    });

    self.calculate();
});

self.data.landscapeContext.subscribe(function (obj) {
    var table;

    $.grep(!$.isEmptyObject(self.bioConditionAssessmentTableReference) ? self.bioConditionAssessmentTableReference.value : [], function (row) {
        if (row.key == 'table_17') {
            table = row;
        }
    });

    $.grep(table ? table.value : [], function (row) {
        if (row.name == self.data.landscapeContext()) {
            self.data.landscapeContextScore(row.value);
        }
    });

    self.calculate();
});

self.data.distanceFromWater.subscribe(function (obj) {
    var table;
    $.grep(!$.isEmptyObject(self.bioConditionAssessmentTableReference) ? self.bioConditionAssessmentTableReference.value : [], function (row) {
        if (row.key == 'table_18') {
            table = row;
        }
    });

    $.grep(table ? table.value : [], function (row) {
        if (row.name == self.data.distanceFromWater()) {
            self.data.distanceFromWaterScore(row.value);
        }
    });
    self.calculate();
});
// End of 6.1 Landscaping

self.initialiseReferenceTable();
self.initialiseBenchmark();

var Output_BioConditionConsolidated_groundCoverRow = function (data, dataModel, context, config) {
    var self = this;
    ecodata.forms.NestedModel.apply(self, [data, dataModel, context, config]);
    context = _.extend(context, {parent:self});
    self.groundCoverType = ko.observable();
    self.groundCoverScore = ko.observable();
    self.plot1 = ko.observable().extend({numericString:2});
    self.plot2 = ko.observable().extend({numericString:2});
    self.plot3 = ko.observable().extend({numericString:2});
    self.plot4 = ko.observable().extend({numericString:2});
    self.plot5 = ko.observable().extend({numericString:2});

    self.plotsMean = ko.computed(function () {
        if (isNaN(Number(self.plot1())) || isNaN(Number(self.plot2())) ||
            isNaN(Number(self.plot3())) || isNaN(Number(self.plot4())) ||
            isNaN(Number(self.plot5()))) {
            return 0;
        }
        var plotMean = (Number(self.plot1()) + Number(self.plot2()) + Number(self.plot3()) + Number(self.plot4()) + Number(self.plot5()))/5
        var score = self.calculateGroundCoverScore(plotMean)
        self.groundCoverScore(score);

        return plotMean;
    });

    self.calculateGroundCoverScore = function (plotMean) {
        if(self.groundCoverType() != "% Native Perennial ('decreaser') grass cover*" &&
            self.groundCoverType() != "% Litter*") {
            return ""; // N/A
        }

        var assessmentPercentage = 0;
        var table;
        var score = 0;
        if(self.groundCoverType() == "% Native Perennial ('decreaser') grass cover*") {
            var benchmarkMarkGroundCoverNativeGrassCover = self.$parent.data.benchmarkGroundCoverNativeGrassCover;
            if(benchmarkMarkGroundCoverNativeGrassCover() != 'na' && !isNaN(plotMean) && !isNaN(benchmarkMarkGroundCoverNativeGrassCover()) && benchmarkMarkGroundCoverNativeGrassCover() > 0) {
                assessmentPercentage = parseInt(plotMean)/parseInt(benchmarkMarkGroundCoverNativeGrassCover()) * 100;
            }
            $.grep(!$.isEmptyObject(self.$parent.bioConditionAssessmentTableReference) ? self.$parent.bioConditionAssessmentTableReference.value : [], function (row) {
                if (row.key == 'table_13') {
                    table = row;
                }
            });
            if(table && table.value && table.value.length == 4) {
                if (table.value[0].name == '<10% of benchmark native perennial (or preferred and intermediate) grass cover' && assessmentPercentage < 10) {
                    score = table.value[0].value;
                } else if (table.value[1].name == '≥10 to 50% of benchmark native perennial (or preferred and intermediate) grass cover' && assessmentPercentage >= 10 && assessmentPercentage < 50) {
                    score = table.value[1].value;
                } else if (table.value[2].name == '≥50 – 90% of benchmark native perennial (or preferred and intermediate) grass cover' && assessmentPercentage >= 50 && assessmentPercentage < 90) {
                    score = table.value[2].value;
                } else if (table.value[3].name == '≥90% of benchmark native perennial (or preferred and intermediate) grass cover' && assessmentPercentage >= 90) {
                    score = table.value[3].value;
                }
            }
        } else if(self.groundCoverType() == "% Litter*") {
            var benchmarkGroundCoverOrganicLitterCover = self.$parent.data.benchmarkGroundCoverOrganicLitterCover;
            if(benchmarkGroundCoverOrganicLitterCover() != 'na' && !isNaN(plotMean) && !isNaN(benchmarkGroundCoverOrganicLitterCover()) && benchmarkGroundCoverOrganicLitterCover() > 0) {
                assessmentPercentage = parseInt(plotMean)/parseInt(benchmarkGroundCoverOrganicLitterCover()) * 100;
            }
            $.grep(!$.isEmptyObject(self.$parent.bioConditionAssessmentTableReference) ? self.$parent.bioConditionAssessmentTableReference.value : [], function (row) {
                if (row.key == 'table_14') {
                    table = row;
                }
            });
            if(table && table.value && table.value.length == 3) {
                if (table.value[0].name == '<10% of benchmark organic litter' && assessmentPercentage < 10) {
                    score = table.value[0].value;
                } else if (table.value[1].name == '≥ 10 to <50% or >200% of benchmark organic 3 litter' && ((assessmentPercentage >= 10 && assessmentPercentage < 50) || (assessmentPercentage > 200))){
                    score = table.value[1].value;
                } else if (table.value[2].name == '≥50% or ≤200% of benchmark organic litter' && (assessmentPercentage >= 50 && assessmentPercentage <= 200)) {
                    score = table.value[2].value;
                }
            }
        }

        return score;
    };

    self.loadData = function(data) {
        self['groundCoverType'](ecodata.forms.orDefault(data['groundCoverType'], undefined));
        self['plot1'](ecodata.forms.orDefault(data['plot1'], 0));
        self['plot2'](ecodata.forms.orDefault(data['plot2'], 0));
        self['plot3'](ecodata.forms.orDefault(data['plot3'], 0));
        self['plot4'](ecodata.forms.orDefault(data['plot4'], 0));
        self['plot5'](ecodata.forms.orDefault(data['plot5'], 0));
    };
    self.loadData(data || {});
};
var context = _.extend({}, context, {parent:self, listName:'groundCover'});
self.data.groundCover = ko.observableArray().extend({list:{metadata:self.dataModel,
        constructorFunction:Output_BioConditionConsolidated_groundCoverRow,
        context:context,
        userAddedRows:false,
        config:config
    }});
self.data.groundCover.loadDefaults = function() {
    self.data.groundCover.addRow({"groundCoverType":"% Native Perennial ('decreaser') grass cover*"});
    self.data.groundCover.addRow({"groundCoverType":"% Native other grass cover (if relevant)"});
    self.data.groundCover.addRow({"groundCoverType":"% Native forbs and other species (non-grass)"});
    self.data.groundCover.addRow({"groundCoverType":"% Native shrubs (< 1m height)"});
    self.data.groundCover.addRow({"groundCoverType":"% Non-native grass"});
    self.data.groundCover.addRow({"groundCoverType":"% Non-native forbs and shrubs"});
    self.data.groundCover.addRow({"groundCoverType":"% Non-native aquatic plant cover"});
    self.data.groundCover.addRow({"groundCoverType":"% Litter*"});
    self.data.groundCover.addRow({"groundCoverType":"% Aquatic/estuarine cover"});
    self.data.groundCover.addRow({"groundCoverType":"% Aquatic/estuarine habitat"});
    self.data.groundCover.addRow({"groundCoverType":"% Rock"});
    self.data.groundCover.addRow({"groundCoverType":"% Bare ground"});
    self.data.groundCover.addRow({"groundCoverType":"% Cryptograms"});
};