var siteBcScore = 0;
var selectedEcosystemBenchmark = {};

// Section 0 - Helper functions.
var bioConditionAssessmentTableReference = {};
initialiseReferenceTable = function (data) {
        bioConditionAssessmentTableReference = data.bioConditionAssessmentTableReference;
};

var consolidatedBenchmarks = [];
initialiseBenchmark = function(data){
    consolidatedBenchmarks = data.consolidatedBenchmarks
};

populateBenchmark = function(data){
    if(selectedEcosystemBenchmark) {
        //Fields not used - notes
        data.benchmarkEucalyptLargeTreeNo=selectedEcosystemBenchmark.tot_num_large_trees_euc_ha; // tot_num_large_trees_euc_ha
        data.benchmarkEucalyptLargeTreeDBH=selectedEcosystemBenchmark.large_tree_threshold_eucalypt; // large_tree_threshold_Eucalypt
        data.benchmarkNonEucalyptLargeTreeNo=selectedEcosystemBenchmark.tot_num_large_trees_non_euc_ha; // tot_num_large_trees_non_euc_ha
        data.benchmarkNonEucalyptLargeTreeDBH=selectedEcosystemBenchmark.large_tree_threshold_non_eucalypt; // large_tree_threshold_Non_eucalypt
        data.benchmarkCWD=selectedEcosystemBenchmark.woody_debris_length_ha; // woody_debris_length_ha

        data.benchmarkTreeEDLHeight=selectedEcosystemBenchmark.emergent_canopy_height; // emergent_canopy_height
        data.benchmarkTreeCanopyHeight=selectedEcosystemBenchmark.tree_canopy_height; // tree_canopy_height
        data.benchmarkSubCanopyHeight=selectedEcosystemBenchmark.tree_subcanopy_height; // tree_subcanopy_height
        data.benchmarkEdlSpeciesRecruitment=selectedEcosystemBenchmark.recruitment; // recruitment

        data.benchmarkNumTreeSpeciesTotal=selectedEcosystemBenchmark.tree_sp_richness; // tree_sp_richness
        data.benchmarkNumShrubSpeciesTotal=selectedEcosystemBenchmark.shrub_sp_richness; // shrub_sp_richness
        data.benchmarkNumGrassSpeciesTotal=selectedEcosystemBenchmark.grass_sp_richness; // grass_sp_richness
        data.benchmarkNumForbSpeciesTotal=selectedEcosystemBenchmark.forb_other_sp_richness; // forb_other_sp_richness
        data.benchmarkSpeciesCoverExotic=selectedEcosystemBenchmark.nn_plant_cover; // nn_plant_cover

        data.benchmarkGroundCoverNativeGrassCover=selectedEcosystemBenchmark.native_per_grass; // native_per_grass
        data.benchmarkGroundCoverOrganicLitterCover=selectedEcosystemBenchmark.litter_grd_cov; // litter_grd_cov

        data.benchmarkMaxScoreExcludeLandscape =selectedEcosystemBenchmark.max_score_exclude_landscape; // max_score_exclude_landscape
        data.benchmarkReliability =selectedEcosystemBenchmark.reliability; // reliability
        data.benchmarkSource =selectedEcosystemBenchmark.source; // source

        data.benchmarkTreeCanopyCover=selectedEcosystemBenchmark.tree_canopy_cover; // tree_canopy_cover
        data.benchmarkTreeSubcanopyCover=selectedEcosystemBenchmark.tree_subcanopy_cover; // tree_subcanopy_cover
        data.benchmarkEmergentCanopyCover=selectedEcosystemBenchmark.emergent_canopy_cover; // emergent_canopy_cover
        data.benchmarkShrubCanopyCover=selectedEcosystemBenchmark.shrub_canopy_cover; //shrub_canopy_cover
    }

    return data
};

getTable = function(tableNumber){
    var table;
    table = findTable();

    function findTable() {
        var table
        bioConditionAssessmentTableReference.value.filter(function (row) {
            if (row.key == tableNumber) {
                table = row
                return table
            }
        })
        return table
    }

    return table;
}

getAssesmentPercentage = function(param1, param2){
    var assessmentPercentage = 0;
    if(param1 != 'na' && !isNaN(param1) && !isNaN(param2) && param1 > 0) {
        assessmentPercentage = parseInt(param2)/parseInt(param1) * 100;
    }
    return assessmentPercentage;
};

getTable6Score = function(assessmentPercentage){
    var score = 0;
    var table = getTable('table_6');
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

getTable7Score = function(assessmentPercentage){
    var score = 0;
    var table = getTable('table_7');
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

getTable8Score = function(assessmentPercentage){
    var score = 0;
    var table = getTable('table_8');
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

getTable9Score = function(assessmentPercentage){
    var score = 0;
    var table = getTable('table_9');
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

getTable10Score = function(totalCwdLength, bmv10, bmv50, bmv200) {
    var score = 0;
    var table = getTable('table_10');
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

getTable11Score = function(assessmentPercentage){
    var score = 0;
    var table = getTable('table_11');
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

getTable12Score = function(assessmentPercentage){
    var score = 0;
    var table = getTable('table_12');
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
calculateLargeTreeScore = function(data){
    var numLargeEucalypt = parseInt(data.numLargeEucalypt);
    var numLargeNonEucalypt = parseInt(data.numLargeNonEucalypt);

    data.totalLargeTrees=numLargeEucalypt + numLargeNonEucalypt;
    data.numLargeEucalyptPerHa=numLargeEucalypt * 2;
    data.numLargeNonEucalyptPerHa=numLargeNonEucalypt * 2;
    data.totalLargeTreesPerHa=parseInt(data.numLargeEucalyptPerHa) + parseInt(data.numLargeNonEucalyptPerHa);

    var benchmarkNumLargeEucalypt = data.benchmarkEucalyptLargeTreeNo;
    var benchmarkNumLargeNonEucalypt = data.benchmarkNonEucalyptLargeTreeNo;
    var assessmentPercentage = 0;
    var benchmarkTotalLargeTrees = 0;

    if(!isNaN(benchmarkNumLargeEucalypt)){
        benchmarkTotalLargeTrees = benchmarkTotalLargeTrees + parseInt(benchmarkNumLargeEucalypt);
    }

    if(!isNaN(benchmarkNumLargeNonEucalypt)) {
        benchmarkTotalLargeTrees = benchmarkTotalLargeTrees + parseInt(benchmarkNumLargeNonEucalypt);
    }

    if(benchmarkTotalLargeTrees > 0) {
        assessmentPercentage = (parseInt(data.totalLargeTreesPerHa)/parseInt(benchmarkTotalLargeTrees)) * 100;
    }

    // Get the table value
    var table = getTable('table_5');

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
    data.largeTreesScore=score;
};

// Part 2 = B
calculateAveCanopyHeightScore = function(data){
    // Emergent canopy height score
    var emergentHeight = data.emergentHeightInMetres;
    var benchmarkEmergentHeight = data.benchmarkTreeEDLHeight;
    var assessmentPercentage = getAssesmentPercentage(benchmarkEmergentHeight, emergentHeight);
    data.emergentHeightScore=getTable6Score(assessmentPercentage);

    // EDL tree canopy height score
    var treeCanopyHeight = data.treeCanopyHeightInMetres;
    var benchmarkTreeCanopyHeight = data.benchmarkTreeCanopyHeight;
    assessmentPercentage = getAssesmentPercentage(benchmarkTreeCanopyHeight, treeCanopyHeight);
    data.edlCanopyHeightScore=getTable6Score(assessmentPercentage);

    // Tree subcanopy height score
    var subcanopyHeight = data.subcanopyHeightInMetres;
    var benchmarkSubCanopyHeight = data.benchmarkSubCanopyHeight;
    assessmentPercentage = getAssesmentPercentage(benchmarkSubCanopyHeight, subcanopyHeight);
    data.subcanopyHeightScore=getTable6Score(assessmentPercentage);

    // Averaged canopy height score
    var count = 0;
    parseInt(data.subcanopyHeightScore) > 0 ? count++ : 0;
    parseInt(data.edlCanopyHeightScore) > 0 ? count++ : 0;
    parseInt(data.emergentHeightScore) > 0 ? count++ : 0;
    var avg = (parseInt(data.subcanopyHeightScore) + parseInt(data.edlCanopyHeightScore) + parseInt(data.emergentHeightScore))/parseInt(count);
    avg = avg > 0 ? avg : 0;
    data.aveCanopyHeightScore=avg;
};

// Part 3 = C
calculateEDLSpeciesRecruitment  = function(data){
    var proportionDominantCanopySpeciesWithEvidenceOfRecruitment = data.proportionDominantCanopySpeciesWithEvidenceOfRecruitment;
    var benchmarkEdlSpeciesRecruitment = data.benchmarkEdlSpeciesRecruitment;
    var assessmentPercentage = getAssesmentPercentage(benchmarkEdlSpeciesRecruitment, proportionDominantCanopySpeciesWithEvidenceOfRecruitment);
    data.edlRecruitmentScore=getTable7Score(assessmentPercentage);
};

// Part 4 = G1
calculateTreeSpeciesRichness = function(data) {
    data.numTreeSpecies=data.treeSpeciesRichness.length;
    var sumofNumOfSpecies = parseInt(data.numTreeSpecies) + parseInt(data.numUnknownTreeSpecies);
    var benchmarkNumTreeSpeciesTotal = data.benchmarkNumTreeSpeciesTotal;
    var assessmentPercentage = getAssesmentPercentage(benchmarkNumTreeSpeciesTotal,sumofNumOfSpecies);
    data.numTreeSpeciesTotal=getTable11Score(assessmentPercentage);
};

// Section 2 - 50 x 10m Area - Understorey & Sub-dominant Layer
// Part 1 - G2
calculateNativeShrubSpeciesRichness = function(data) {
    data.numShrubSpecies=data.shrubSpeciesRichness.length;
    var numShrubSpecies = parseInt(data.numShrubSpecies) + parseInt(data.numUnknownShrubSpecies);
    var benchmarkNumShrubSpeciesTotal = data.benchmarkNumShrubSpeciesTotal;
    var assessmentPercentage = getAssesmentPercentage(benchmarkNumShrubSpeciesTotal, numShrubSpecies);;
    data.numShrubSpeciesTotal=getTable11Score(assessmentPercentage);
}

// Part 2 - G3
calculateNativeGrassSpeciesRichness = function(data) {
    data.numGrassSpecies=data.grassSpeciesRichness.length;
    var numGrassSpecies = parseInt(data.numGrassSpecies) + parseInt(data.numUnknownGrassSpecies);
    var benchmarkNumGrassSpeciesTotal = data.benchmarkNumGrassSpeciesTotal;
    var assessmentPercentage = getAssesmentPercentage(benchmarkNumGrassSpeciesTotal, numGrassSpecies);;
    data.numGrassSpeciesTotal=getTable11Score(assessmentPercentage);
};

// Part 3 - G4
calculateForbsAndOtherNonGrassGroundSpeciesRichness = function(data) {
    data.numForbSpecies=data.forbsAndOtherNonGrassGroundSpeciesRichness.length;
    var numForbSpecies = parseInt(data.numForbSpecies) + parseInt(data.numUnknownForbSpecies);
    var benchmarkNumForbSpeciesTotal = data.benchmarkNumForbSpeciesTotal;
    var assessmentPercentage = getAssesmentPercentage(benchmarkNumForbSpeciesTotal, numForbSpecies);
    data.numForbSpeciesTotal=getTable11Score(assessmentPercentage);
}

// Part 4 - H
calculateNonNativeSpeciesRichness = function(data) {
    data.numNonNativeSpecies=data.nonNativeSpeciesRichness.length;
    var numNonNativeSpecies = parseInt(data.numNonNativeSpecies) + parseInt(data.numUnknownNonNativeSpecies);
    var benchmarkSpeciesCoverExotic = data.benchmarkSpeciesCoverExotic;
    var assessmentPercentage = getAssesmentPercentage(benchmarkSpeciesCoverExotic, numNonNativeSpecies);;
    data.numNonNativeSpeciesTotal=getTable12Score(assessmentPercentage);

    var score = getTable12Score(parseInt(data.nonNativePlantCoverPercent));
    data.nonNativePlantCoverScore=score;
}

// Section 3 - 50 x 20m area - Coarse Woody Debris
// Part 1 - F
calculateCwdScore = function(data) {
    var benchmarkValue = parseInt(data.benchmarkCWD);
    var totalCwdLength = data.totalCwdLength;
    if(isNaN(totalCwdLength) || totalCwdLength == 0){
        return;
    }

    if(benchmarkValue != 'na' && !isNaN(benchmarkValue)) {
        var bmv10 = (benchmarkValue * 10) / 100;
        var bmv50 = (benchmarkValue * 50) / 100;
        var bmv200 = (benchmarkValue * 200) / 100;
        data.cwdScore=getTable10Score(totalCwdLength * 10, bmv10, bmv50, bmv200);
    }

};

// Section 4 - Five 1x1m plots - Ground Cover
// Refer groundCover.js

// Section 5 - 100m Transect
// Part 1 - D
calculateTreeCanopyCoverScoreAve = function(data) {

    var percentCoverC = 0;
    var percentCoverS = 0;
    var percentCoverE = 0;
    var cCount = 0;
    var sCount = 0;
    var eCount = 0;
    data.treeCanopyRecords.forEach(function( value, index ) {
        var cover = calculateTreeCanopyCover(data.treeCanopyRecords, value);
        data.treeCanopyRecords[index].totalTCCover=parseFloat(value.distanceInMetersAlongTransectTreeEnd) - parseFloat(value.distanceInMetersAlongTransectTreeStart);
        if(value.treeOrTreeGroup == 'C') {
            percentCoverC = parseFloat(percentCoverC) + parseFloat(cover);
            cCount++;
        } else if(value.treeOrTreeGroup == 'S') {
            percentCoverS = parseFloat(percentCoverS) + parseFloat(cover);
            sCount++;
        } else if (value.treeOrTreeGroup == 'E') {
            percentCoverE = parseFloat(percentCoverE) + parseFloat(cover);
            eCount++;
        }
    });

    var lengthOfTransectInMeters = data.lengthOfTransectInMeters;

    if(lengthOfTransectInMeters && lengthOfTransectInMeters >=50){

        percentCoverC = percentCoverC*100/lengthOfTransectInMeters;
        percentCoverS = percentCoverS*100/lengthOfTransectInMeters;
        percentCoverE = percentCoverE*100/lengthOfTransectInMeters;

        data.percentCoverC=percentCoverC;
        data.percentCoverS=percentCoverS;
        data.percentCoverE=percentCoverE;

        var benchmarkTreeCanapyCover = data.benchmarkTreeCanopyCover;
        var benchmarkTreeSubCanapyCover = data.benchmarkTreeSubcanopyCover;
        var benchmarkTreeEmergentCover = data.benchmarkEmergentCanopyCover;

        var assessmentPercentage = 0;
        assessmentPercentage = getAssesmentPercentage(benchmarkTreeCanapyCover, percentCoverC);
        var cCoverScore = getTable8Score(assessmentPercentage);
        data.coverScoreC=cCoverScore;

        var assessmentPercentage = 0;
        assessmentPercentage = getAssesmentPercentage(benchmarkTreeSubCanapyCover, percentCoverS);
        var sCoverScore = getTable8Score(assessmentPercentage);
        data.coverScoreS=sCoverScore;

        var assessmentPercentage = 0;
        assessmentPercentage = getAssesmentPercentage(benchmarkTreeEmergentCover, percentCoverE);
        var eCoverScore = getTable8Score(assessmentPercentage);
        data.coverScoreE=eCoverScore;

        var total = 3;
        if(benchmarkTreeCanapyCover == "na") {total = total -1;}
        if(benchmarkTreeSubCanapyCover == "na") {total = total -1;}
        if(benchmarkTreeEmergentCover == "na") {total = total -1;}

        var treeCanopyCoverScoreAve = total == 0 ? 0 : (parseFloat(cCoverScore) + parseFloat(sCoverScore) + parseFloat(eCoverScore))/total;
        data.treeCanopyCoverScoreAve=treeCanopyCoverScoreAve;
    }
};

calculateTreeCanopyCover = function(treeCanopyRecords, record) {

    var sortedList = Object.values(treeCanopyRecords).sort(function(a,b) { return (parseFloat(a.distanceInMetersAlongTransectTreeStart) - parseFloat(b.distanceInMetersAlongTransectTreeStart)) || (parseFloat(a.distanceInMetersAlongTransectTreeEnd) - parseFloat(b.distanceInMetersAlongTransectTreeEnd)); });
    var list = sortedList.filter(y => y.treeOrTreeGroup == record.treeOrTreeGroup)

    var position = Object.values(list).findIndex(z => z == record)

    if(position == 0){
        return parseFloat(record.distanceInMetersAlongTransectTreeEnd) - parseFloat(record.distanceInMetersAlongTransectTreeStart)
    }
    else{
        if(parseFloat(record.distanceInMetersAlongTransectTreeStart) < parseFloat(list[position -1].distanceInMetersAlongTransectTreeEnd)){

            var currentMaxPosition = position -1;
            var overlapTreePosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectTreeEnd) > parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd)) {
                    overlapTreePosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }
            var extra = parseFloat(record.distanceInMetersAlongTransectTreeEnd) - parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd)
            if (extra > 0){return extra}
            else {return 0}

        }
        else{
            var currentMaxPosition = position -1;
            var overlapTreePosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectTreeEnd) > parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd)) {
                    overlapTreePosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }

            if(overlapTreePosition == position -1) {
                return parseFloat(record.distanceInMetersAlongTransectTreeEnd) - parseFloat(record.distanceInMetersAlongTransectTreeStart)
            }
            else {
                if(parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd) < parseFloat(record.distanceInMetersAlongTransectTreeStart)){
                    return parseFloat(record.distanceInMetersAlongTransectTreeEnd) - parseFloat(record.distanceInMetersAlongTransectTreeStart)
                }
                else {
                    var extra = parseFloat(record.distanceInMetersAlongTransectTreeEnd) - parseFloat(list[overlapTreePosition].distanceInMetersAlongTransectTreeEnd)
                    if (extra > 0){return extra}
                    else {return 0}
                }
            }
        }
    }

};

// Part 2 - E
calculateShrubCanopyCoverScoreN = function(data) {
    var percentCoverNative = 0;
    var percentCoverExotic = 0;

    data.shrubCanopyRecords.forEach(function( value,index ) {
        var cover = calculateShrubCanopyCover(data.shrubCanopyRecords, value);
        data.shrubCanopyRecords[index].totalSCCover(parseFloat(value.distanceInMetersAlongTransectShrubEnd) - parseFloat(value.distanceInMetersAlongTransectShrubStart));
        if(value.shrubType == 'native') {
            percentCoverNative = parseFloat(percentCoverNative) + parseFloat(cover);
        } else if(value.shrubType == 'exotic') {
            percentCoverExotic = parseFloat(percentCoverExotic) + parseFloat(cover);
        }
    });

    var lengthOfTransectInMeters = data.lengthOfTransectInMeters;

    if(lengthOfTransectInMeters && lengthOfTransectInMeters >=50){

        percentCoverNative = percentCoverNative*100/lengthOfTransectInMeters;
        percentCoverExotic = percentCoverExotic*100/lengthOfTransectInMeters;

        data.percentCoverNative= percentCoverNative;
        data.percentCoverExotic =percentCoverExotic;


        var benchmarkShrubCoverNative = data.benchmarkShrubCanopyCover;
        var assessmentPercentage = getAssesmentPercentage(benchmarkShrubCoverNative, percentCoverNative);;
        data.shrubCanopyCoverScoreN=getTable9Score(assessmentPercentage);
    }
};

calculateShrubCanopyCover = function(shrubCanopyRecords, record) {

    var sortedList = Object.values(shrubCanopyRecords).sort(function(a,b) { return (parseFloat(a.distanceInMetersAlongTransectShrubStart) - parseFloat(b.distanceInMetersAlongTransectShrubStart)) || (parseFloat(a.distanceInMetersAlongTransectShrubEnd) - parseFloat(b.distanceInMetersAlongTransectShrubEnd)); });
    var list = sortedList.filter(y => y.shrubType == record.shrubType)

    var position = Object.values(list).findIndex(z => z == record)

    if(position == 0){
        return parseFloat(record.distanceInMetersAlongTransectShrubEnd) - parseFloat(record.distanceInMetersAlongTransectShrubStart)
    }
    else{
        if(parseFloat(record.distanceInMetersAlongTransectShrubStart) < parseFloat(list[position -1].distanceInMetersAlongTransectShrubEnd)){

            var currentMaxPosition = position -1;
            var overlapShrubPosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectShrubEnd) > parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd)) {
                    overlapShrubPosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }
            var extra = parseFloat(record.distanceInMetersAlongTransectShrubEnd) - parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd)
            if (extra > 0){return extra}
            else {return 0}

        }
        else{
            var currentMaxPosition = position -1;
            var overlapShrubPosition = currentMaxPosition;
            while(currentMaxPosition >= 1) {
                if(parseFloat(list[currentMaxPosition -1].distanceInMetersAlongTransectShrubEnd) > parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd)) {
                    overlapShrubPosition = currentMaxPosition -1;
                }
                currentMaxPosition = currentMaxPosition -1;
            }

            if(overlapShrubPosition == position -1) {
                return parseFloat(record.distanceInMetersAlongTransectShrubEnd) - parseFloat(record.distanceInMetersAlongTransectShrubStart)
            }
            else {
                if(parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd) < parseFloat(record.distanceInMetersAlongTransectShrubStart)){
                    return parseFloat(record.distanceInMetersAlongTransectShrubEnd) - parseFloat(record.distanceInMetersAlongTransectShrubStart)
                }
                else {
                    var extra = parseFloat(record.distanceInMetersAlongTransectShrubEnd) - parseFloat(list[overlapShrubPosition].distanceInMetersAlongTransectShrubEnd)
                    if (extra > 0){return extra}
                    else {return 0}
                }
            }

        }
    }

};

// Section 6 - Update full form calculation
calculate = function(data) {
    data = JSON.parse(data);
    initialiseReferenceTable(data);
    initialiseBenchmark(data);

    benchmarkSetup(data.bioregion, data);

    //Section 1
    calculateLargeTreeScore(data);
    calculateAveCanopyHeightScore(data);
    calculateEDLSpeciesRecruitment(data);
    calculateTreeSpeciesRichness(data);

    //Section 2
    calculateNativeShrubSpeciesRichness(data);
    calculateNativeGrassSpeciesRichness(data);
    calculateForbsAndOtherNonGrassGroundSpeciesRichness(data);
    calculateNonNativeSpeciesRichness(data);

    data.nativePlantSpeciesRichnessScore= parseFloat(data.numTreeSpeciesTotal) + parseFloat(data.numShrubSpeciesTotal) + parseFloat(data.numGrassSpeciesTotal) + parseFloat(data.numForbSpeciesTotal);

    //Section 3
    calculateCwdScore(data);

    // Section 4 - Five 1x1m plots - Ground Cover
    // Refer groundCover.js

    // Section 5 - 100m Transect
    calculateTreeCanopyCoverScoreAve(data)
    calculateShrubCanopyCoverScoreN(data)
    data.groundCover[0] = calculateGroundCoverRow(data, data.groundCover[0])
    data.groundCover[6] = calculateGroundCoverRow(data, data.groundCover[6])

    // Calculate Site Based Final Score
    // a+b+c+d+e+f+g+h+i+j/Y
    // Y = Maximum Benchmark Value.
    var a = parseFloat(data.largeTreesScore);
    var b = parseFloat(data.aveCanopyHeightScore);
    var c = parseFloat(data.edlRecruitmentScore);
    var d = parseFloat(data.treeCanopyCoverScoreAve);
    var e = parseFloat(data.shrubCanopyCoverScoreN);
    var f = parseFloat(data.cwdScore);
    var g = parseFloat(data.nativePlantSpeciesRichnessScore);
    var h = parseFloat(data.nonNativePlantCoverScore);

    // % Native Perennial ('decreaser') grass cover*
    var groundCoverNativeGrassCover = data.groundCover[0];
    if(groundCoverNativeGrassCover) {
        data.nativePerennialGrassCoverScore=groundCoverNativeGrassCover.groundCoverScore;
    }


    // % Litter*
    var groundCoverOrganicLitterCover = data.groundCover[6];
    if(groundCoverOrganicLitterCover) {
        data.litterCoverScore=groundCoverOrganicLitterCover.groundCoverScore;
    }

    var i = parseFloat(data.nativePerennialGrassCoverScore);
    var j = parseFloat(data.litterCoverScore);
    var y = parseFloat(data.benchmarkMaxScoreExcludeLandscape);
    var sum = parseFloat(a+b+c+d+e+f+g+h+i+j);

    print("largeTreesScore " + a)
    print("aveCanopyHeightScore " + b)
    print("edlRecruitmentScore "+ c)
    print("treeCanopyCoverScoreAve "+ d)
    print("shrubCanopyCoverScoreN "+ e)
    print("cwdScore "+ f)
    print("nativePlantSpeciesRichnessScore "+ g)
    print("nonNativePlantCoverScore "+ h)
    print("nativePerennialGrassCoverScore "+ i)
    print("litterCoverScore "+ j)
    print("y "+ y)

    if(y > 0 && sum > 0) {
        var siteScore = sum/y;
        data.siteBcScore=siteScore;
    }

    print("siteScore " + siteScore)

    var site = utmToLatLng(56, 474382, 6959395, false);
    data.site = site
    return data;
};

// Section 7 - Setup and Initialisation
benchmarkSetup = function(benchmarkCode, data) {

    var benchmark = findBenchmark();

    function findBenchmark() {
        var benchmark
        consolidatedBenchmarks.filter(function (row) {
            if (row.re_with_dec == benchmarkCode) {
                benchmark = row
                return benchmark
            }
        })
        return benchmark
    }

    selectedEcosystemBenchmark = benchmark;
    populateBenchmark(data);
};

var calculateGroundCoverRow = function (data, section) {

    groundCoverType = section.groundCoverType;
    plot1 = section.plot1;
    plot2 = section.plot2;
    plot3 = section.plot3;
    plot4 = section.plot4;
    plot5 = section.plot5;

    plotsMean = function () {
        if (isNaN(Number(plot1)) || isNaN(Number(plot2)) ||
            isNaN(Number(plot3)) || isNaN(Number(plot4)) ||
            isNaN(Number(plot5))) {
            return 0;
        }
        var plotMean = (Number(plot1) + Number(plot2) + Number(plot3) + Number(plot4) + Number(plot5))/5
        var score = calculateGroundCoverScore(plotMean)
        section.groundCoverScore=score;
        section.plotsMean = plotMean;
        return section;
    };

    calculateGroundCoverScore = function (plotMean) {
        if(groundCoverType != "% Native Perennial ('decreaser') grass cover*" &&
            groundCoverType != "% Litter*") {
            return ""; // N/A
        }

        var assessmentPercentage = 0;
        var table;
        var score = 0;
        if(groundCoverType == "% Native Perennial ('decreaser') grass cover*") {
            var benchmarkMarkGroundCoverNativeGrassCover = data.benchmarkGroundCoverNativeGrassCover;
            if(benchmarkMarkGroundCoverNativeGrassCover != 'na' && !isNaN(plotMean) && !isNaN(benchmarkMarkGroundCoverNativeGrassCover) && benchmarkMarkGroundCoverNativeGrassCover > 0) {
                assessmentPercentage = parseInt(plotMean)/parseInt(benchmarkMarkGroundCoverNativeGrassCover) * 100;
            }
            table = getTable('table_13')
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
        } else if(groundCoverType == "% Litter*") {
            var benchmarkGroundCoverOrganicLitterCover = data.benchmarkGroundCoverOrganicLitterCover;
            if(benchmarkGroundCoverOrganicLitterCover != 'na' && !isNaN(plotMean) && !isNaN(benchmarkGroundCoverOrganicLitterCover) && benchmarkGroundCoverOrganicLitterCover > 0) {
                assessmentPercentage = parseInt(plotMean)/parseInt(benchmarkGroundCoverOrganicLitterCover) * 100;
            }
            table = getTable('table_14')
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

    return plotsMean();
};

function utmToLatLng(zone, easting, northing, northernHemisphere){
    if (!northernHemisphere){
        northing = 10000000 - northing;
    }

    var a = 6378137;
    var e = 0.081819191;
    var e1sq = 0.006739497;
    var k0 = 0.9996;

    var arc = northing / k0;
    var mu = arc / (a * (1 - Math.pow(e, 2) / 4.0 - 3 * Math.pow(e, 4) / 64.0 - 5 * Math.pow(e, 6) / 256.0));

    var ei = (1 - Math.pow((1 - e * e), (1 / 2.0))) / (1 + Math.pow((1 - e * e), (1 / 2.0)));

    var ca = 3 * ei / 2 - 27 * Math.pow(ei, 3) / 32.0;

    var cb = 21 * Math.pow(ei, 2) / 16 - 55 * Math.pow(ei, 4) / 32;
    var cc = 151 * Math.pow(ei, 3) / 96;
    var cd = 1097 * Math.pow(ei, 4) / 512;
    var phi1 = mu + ca * Math.sin(2 * mu) + cb * Math.sin(4 * mu) + cc * Math.sin(6 * mu) + cd * Math.sin(8 * mu);

    var n0 = a / Math.pow((1 - Math.pow((e * Math.sin(phi1)), 2)), (1 / 2.0));

    var r0 = a * (1 - e * e) / Math.pow((1 - Math.pow((e * Math.sin(phi1)), 2)), (3 / 2.0));
    var fact1 = n0 * Math.tan(phi1) / r0;

    var _a1 = 500000 - easting;
    var dd0 = _a1 / (n0 * k0);
    var fact2 = dd0 * dd0 / 2;

    var t0 = Math.pow(Math.tan(phi1), 2);
    var Q0 = e1sq * Math.pow(Math.cos(phi1), 2);
    var fact3 = (5 + 3 * t0 + 10 * Q0 - 4 * Q0 * Q0 - 9 * e1sq) * Math.pow(dd0, 4) / 24;

    var fact4 = (61 + 90 * t0 + 298 * Q0 + 45 * t0 * t0 - 252 * e1sq - 3 * Q0 * Q0) * Math.pow(dd0, 6) / 720;

    var lof1 = _a1 / (n0 * k0);
    var lof2 = (1 + 2 * t0 + Q0) * Math.pow(dd0, 3) / 6.0;
    var lof3 = (5 - 2 * Q0 + 28 * t0 - 3 * Math.pow(Q0, 2) + 8 * e1sq + 24 * Math.pow(t0, 2)) * Math.pow(dd0, 5) / 120;
    var _a2 = (lof1 - lof2 + lof3) / Math.cos(phi1);
    var _a3 = _a2 * 180 / Math.PI;

    var latitude = 180 * (phi1 - fact1 * (fact2 + fact3 + fact4)) / Math.PI;

    if (!northernHemisphere){
        latitude = -latitude;
    }

    var longitude = ((zone > 0) && (6 * zone - 183.0) || 3.0) - _a3;

    var obj = {
        latitude : latitude,
        longitude: longitude
    };


    return obj;
}