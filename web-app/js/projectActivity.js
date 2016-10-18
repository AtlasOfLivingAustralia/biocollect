var ProjectActivitiesViewModel = function (params) {
    var self = this;
    var pActivities = params.pActivities;
    var user = params.user;

    self.organisationName = params.organisationName;
    self.pActivityForms = params.pActivityForms;
    self.sites = params.sites;
    self.projectStartDate = params.projectStartDate;
    self.project = params.project;

    self.projectId = ko.observable(params.projectId);
    self.projectActivities = ko.observableArray();

    self.user = user ? user : {isEditor: false, isAdmin: false};

    self.sortBy = ko.observable();
    self.sortOrder = ko.observable();
    self.sortOptions = [{id: 'name', name: 'Name'}, {id: 'description', name: 'Description'}, {
        id: 'transients.status',
        name: 'Status'
    }];
    self.sortOrderOptions = [{id: 'asc', name: 'Ascending'}, {id: 'desc', name: 'Descending'}];

    self.sortBy.subscribe(function (by) {
        self.sort();
    });

    self.sortOrder.subscribe(function (order) {
        self.sort();
    });

    // flag to check if survey was changed by dropdown menu. it is used to decide on saving survey.
    self.isSurveySelected = ko.observable(false);

    self.sort = function () {
        var by = self.sortBy();
        var order = self.sortOrder() == 'asc' ? '<' : '>';
        if (by && order) {
            eval('self.projectActivities.sort(function(left, right) { return left.' + by + '() == right.' + by + '() ? 0 : (left.' + by + '() ' + order + ' right.' + by + '() ? -1 : 1) });');
        }
    };

    self.reset = function () {
        $.each(self.projectActivities(), function (i, obj) {
            obj.current(false);
        });
    };

    self.current = function () {
        var pActivity = null;
        $.each(self.projectActivities(), function (i, obj) {
            if (obj.current()) {
                pActivity = obj;
            }
        });
        return pActivity;
    };

    self.setCurrent = function (pActivity) {
        self.isSurveySelected(true);
        self.reset();
        pActivity.current(true);
        self.isSurveySelected(false);
    };

    self.loadProjectActivities = function (pActivities) {
        self.sortBy("name");
        self.sortOrder("asc");
        $.map(pActivities, function (pActivity, i) {
            var args = {
                pActivity: pActivity,
                pActivityForms: self.pActivityForms,
                projectId: self.projectId(),
                selected: (i == 0),
                sites: self.sites,
                organisationName: self.organisationName,
                startDate: self.projectStartDate,
                project: self.project,
                user: self.user
            };
            return self.projectActivities.push(new ProjectActivity(args));
        });

        self.sort();
    };

    self.userCanEdit = function (pActivity) {
        var projectActive = !pActivity.endDate() || moment(pActivity.endDate()).isAfter(moment());
        var userIsEditorOrAdmin = user && Object.keys(user).length > 0 && (user.isEditor || user.isAdmin);
        return projectActive && (pActivity.publicAccess() || userIsEditorOrAdmin) && fcConfig.version.length == 0;
    };

    self.userIsAdmin = function (pActivity) {
        if (user && Object.keys(user).length > 0 && user.isAdmin) {
            return true;
        } else {
            return false;
        }
    };

    self.loadProjectActivities(pActivities);

   /* self.aekosTestModalView = ko.observable(new AekosViewModel (pActivity, project.name, project.description, project.status));

    //self.aekosModal = ko.observable(false);

    self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosTestModalView().show(true);
    };
*/
};

var ProjectActivitiesListViewModel = function (pActivitiesVM) {
    var self = $.extend(this, pActivitiesVM);
    self.filter = ko.observable(false);

    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.setCurrent = function (pActivity) {
        self.reset();
        pActivity.current(true);
    };
};

var ProjectActivitiesDataViewModel = function (pActivitiesVM) {
    var self = $.extend(this, pActivitiesVM);
};

var AekosViewModel = function (pActivityVM, projectViewModel, user) {

    var self = $.extend(this, pActivityVM);

    self.projectViewModel = projectViewModel;

    if (!self.projectViewModel.name) return;

    self.user = user;

    self.submissionName = self.projectViewModel.name() + ' - ' + self.name();

    self.datasetTitle = ko.computed(function() {
        return self.projectViewModel.organisationName() + ' - ' + self.name();
    });

    self.currentDatasetVersion = ko.computed(function() {
        var res = self.projectViewModel.name().substr(0, 3) + self.name().substr(0, 3);
        //var res = self.name.substr(1, 3);

        if (self.submissionRecords && self.submissionRecords().length > 0) {
            var datasetArray = $.map(self.submissionRecords(), function (o) {
                if (o.datasetVersion().length > 0) {
                    return o.datasetVersion().substr(8, o.datasetVersion().length)
                } else {
                    return 0;
                }
            });
            //var latestDataset = self.submissionRecords()[0].datasetVersion;
            var highest = Math.max.apply(Math, datasetArray);
            highest = highest + 1;
            var i = (highest > 9) ? "" + highest: "0" + highest;

            return res + "_" + i;
        } else {
            return res + "_01";
        }
    });

    self.environmentFeaturesList = (['Climate', 'Disturbance', 'Geology/Lithology', 'Human Population Demographics', 'Landscape Type', 'Land Use', 'Native Vegetation', 'None', 'Other',
                                    'Soil', 'Topography', 'Vegetation Structure'])

    self.environmentFeatures = ko.observableArray();

    self.otherEnvironmentFeatures = ko.observable('');

    self.associatedMaterialTypes = ko.observableArray(['Algorithms', 'Database Manual', 'Database Schema',
                                    'Derived Spatial Layers', 'Field Manual', 'Mathematical Equations',
                                    'None', 'Other', 'Patent', 'Published Paper', 'Published Report']);
    self.selectedMaterialType = '';

    self.otherMaterials = ko.observable('');
    self.associatedMaterialNane = ko.observable('');

    self.materialIdentifierTypes = ko.observableArray(['Ark Persistent Identifier Scheme', 'Australian Research Council Identifier',
                                        'DOI', 'National Library Of Australia Identifier', 'None']);
    self.selectedMaterialIdentifier = ko.observable('');

    self.samplingDesign = ko.observableArray();
    self.samplingDesignSuggest = ko.observable('');

    self.measurementThemeList = (['Derived', 'Human Census', 'None', 'Other', 'Raw Observations']);

    self.measurementTheme = ko.observableArray();

    self.measurementThemeSuggest = ko.observable('');

    self.measurementList = (['Abundance', 'Age', 'Biomass', 'Density', 'Dispersal', '(Dis)Similarity', 'Diversity', 'Dominance', 'Ecophysiology', 'Functional Connectivity',
                            'Geographical Distribution', 'Growth Form', 'Incidence', 'Landscape Elements', 'Light incidence', 'Location', 'Mating System', 'Microsatellite locus allele',
                            'Morphology', 'None', 'Nutrient-acquisition strategy', 'Other', 'Population Structure', 'Presence', 'Population Structure/Absence', 'Richnes', 'Soil Properties',
                            'Stream Elements', 'Stream Processes', 'Stream Structure', 'Structural Connectivity', 'Taxoomic Name']);

    self.measurement = ko.observableArray();

    self.measurementSuggest = ko.observable('');

    self.methodDriftDescription = ko.observable('');

    self.artefactsList = (['Genetic Material', 'Image', 'None', 'Other', 'Recording', 'Specimen']);

    self.artefacts = ko.observableArray();
    self.artefactsSuggest = ko.observable('');

    self.legalCustodianOrganisationTypeList = (['Community-based Organisation', 'Federal Agency', 'Foreign Government Agency', 'Herbarium', 'Individual Researcher', 'International Organisation', 'Museum',
                             'Non-government Organisation', 'Private Enterprise', 'Research Institution', 'State Agency', 'University']);

    self.samplingDesignList = (['AEKOS Data Extraction', 'Before-After, Control Impact (BACI)', 'Census and Population Extrapolation', 'Common garden experiment',
                                 'Completely Randomised', 'Factorial Designs', 'Gradient Designs', 'Mark-Recapture', 'Meta-analysis', 'None', 'Opportunistic Sampling', 'Other',
                                 'Photo Data Capture', 'Power Analyses', 'Randomised Complete Block', 'Randomised Line Transect', 'Reciprocal transplant', 'Repeated Measures',
                                 'Self-selected (Landscape Scale) Sampling', 'Survival Analysis', 'Systematic Sampling']);

    self.samplingDesign = ko.observableArray();

    self.curationStatusList = (['Active', 'Completed', 'Stalled']);
    self.curationStatus = ko.observable('');

    self.curationActivitiesOtherList = (['Data Validation', 'Not curated', 'Plausibility Review', 'Taxonomic Opinion', 'Taxonomic Determination']);
    self.curationActivitiesOther = ko.observable('');

   // self.pageModel = new PageModel();
   // self.pageModel.loadData(_sampleVocabData);

    self.selectedTab = ko.observable('tab-1');

    self.selectTab = function(data, event) {
        if (self.isValidationValid()) {
            var tabId = event.currentTarget.id;
            $("#" + tabId).tab('show');
            var tabNumber = tabId.substr(0, 5);
            self.selectedTab(tabNumber);
        }
    };

    self.selectNextTab = function(nextTab) {
        if (self.isValidationValid()) {
            $(nextTab).tab('show');
            var nextTab = nextTab.substr(1, 5);
            self.selectedTab(nextTab);
        }
    };

    self.nextTab = ko.computed(function(){
        var currentTab = ko.utils.unwrapObservable(self.selectedTab);
        var currentTabNumber = parseInt(currentTab.charAt(4));
        var nextTabNumber = currentTabNumber + 1;
        var nextTab = currentTab.substr(0, 4) + nextTabNumber;
        return nextTab;
    });

    self.dataToggleVal = function(){
        if(self.isValidationValid()){
            return 'tab'
        } else {
            return ''
        }
    }

    self.listFos = ko.observableArray([{ value:"401", name:"Atmospheric Sciences (0401)", description: "Group: Atmospheric Sciences (0401),,"},
        { value:"601", name:"Biochemistry And Cell Biology (0601)", description: "Group: Biochemistry And Cell Biology (0601),,"},
        { value:"501", name:"Ecological Applications (0501)", description: "Group: Ecological Applications (0501),,"},
        { value:"602", name:"Ecology (0602)", description: "Group: Ecology (0602),,"},
        { value:"60208", name:"Terrestrial Ecology (060208)", description: "Terrestrial Ecology (060208)"},
        { value:"502", name:"Environmental Science And Management (0502)", description: "Group: Environmental Science And Management (0502),,"},
        { value:"50202", name:"Conservation and Biodiversity (050202)", description: "Conservation and Biodiversity (050202)"},
        { value:"50211", name:"Wildlife and Habitat Management (050211)", description: "Wildlife and Habitat Management (050211)"},
        { value:"603", name:"Evolutionary Biology (0603)", description: "Group: Evolutionary Biology (0603),,"},
        { value:"604", name:"Genetics (0604)", description: "Group: Genetics (0604),,"},
        { value:"402", name:"Geochemistry (0402)", description: "Group: Geochemistry (0402),,"},
        { value:"403", name:"Geology (0403)", description: "Group: Geology (0403),,"},
        { value:"404", name:"Geophysics (0404)", description: "Group: Geophysics (0404),,"},
        { value:"605", name:"Microbiology (0605)", description: "Group: Microbiology (0605),,"},
        { value:"None", name:"None", description: "None,,"},
        { value:"405", name:"Oceanography (0405)", description: "Group: Oceanography (0405),,"},
        { value:"699", name:"Other Biological Sciences (0699)", description: "Group: Other Biological Sciences (0699),,"},
        { value:"499", name:"Other Earth Sciences (0499)", description: "Group: Other Earth Sciences (0499),,"},
        { value:"599", name:"Other Environmental Sciences (0599)", description: "Group: Other Environmental Sciences (0599),,"},
        { value:"406", name:"Physical Geography And Environmental Geoscience (0406)", description: "Group: Physical Geography And Environmental Geoscience (0406),,"},
        { value:"606", name:"Physiology (0606)", description: "Group: Physiology (0606),,"},
        { value:"607", name:"Plant Biology (0607)", description: "Group: Plant Biology (0607),,"},
        { value:"503", name:"Soil Sciences (0503)", description: "Group: Soil Sciences (0503),,"},
        { value:"608", name:"Zoology (0608)", description: "Group: Zoology (0608),,"}])
    self.listSeo = ko.observableArray([{ value:"9601", name:"Air Quality (9601)", description: "Group: Air Quality (9601),,"},
        { value:"9602", name:"Atmosphere And Weather (9602)", description: "Group: Atmosphere And Weather (9602),,"},
        { value:"9603", name:"Climate And Climate Change (9603)", description: "Group: Climate And Climate Change (9603),,"},
        { value:"9604", name:"Control Of Pests, Diseases And Exotic Species (9604)", description: "Group: Control Of Pests, Diseases And Exotic Species (9604),,"},
        { value:"9605", name:"Ecosystem Assessment And Management (9605)", description: "Group: Ecosystem Assessment And Management (9605),,"},
        { value:"9606", name:"Environmental And Natural Resource Evaluation (9606)", description: "Group: Environmental And Natural Resource Evaluation (9606),,"},
        { value:"9607", name:"Environmental Policy, Legislation And Standards (9607)", description: "Group: Environmental Policy, Legislation And Standards (9607),,"},
        { value:"9608", name:"Flora, Fauna And Biodiversity (9608)", description: "Group: Flora, Fauna And Biodiversity (9608),,"},
        { value:"960805", name:"Flora, Fauna and Biodiversity at Regional or Larger Scales (960805)", description: "Flora, Fauna and Biodiversity at Regional or Larger Scales (960805)"},
        { value:"9609", name:"Land And Water Management (9609)", description: "Group: Land And Water Management (9609),,"},
        { value:"9610", name:"Natural Hazards (9610)", description: "Group: Natural Hazards (9610),,"},
        { value:"None", name:"None", description: "None,,"},
        { value:"9699", name:"Other Environment (9699)", description: "Group: Other Environment (9699),,"},
        { value:"9611", name:"Physical And Chemical Conditions Of Water (9611)", description: "Group: Physical And Chemical Conditions Of Water (9611),,"},
        { value:"9612", name:"Rehabilitation Of Degraded Environments (9612)", description: "Group: Rehabilitation Of Degraded Environments (9612),,"},
        { value:"9613", name:"Remnant Vegetation And Protected Conservation Areas (9613)", description: "Group: Remnant Vegetation And Protected Conservation Areas (9613),,"},
        { value:"9614", name:"Soils (9614)", description: "Group: Soils (9614),,"}])
    self.listResearch = ko.observableArray([{ value:"Agroecology", name:"Agroecology", description: "Observations on populations of species and communities and ecological processes that operate and influence biota in agricultural production systems.,,"},
        { value:"Behavioural Ecology", name:"Behavioural Ecology", description: "Behavioural ecology is the study of the fitness consequences of behaviour. It combines the study of animal behaviour with evolutionary biology and population ecology, and more recently, physiology and molecular biology. Observations are made on individuals in  such areas as habitat selection, foraging, anti-predator, mating, and parental care strategies; dispersal and migration, sexual selection; cooperation and conflict; communication; spacing and group behaviour; and social organisation.,,"},
        { value:"Biodiversity Inventory", name:"Biodiversity Inventory", description: "The systematic survey of fauna and flora at different locations to identify the composition and distribution on taxa.,,"},
        { value:"Species Composition", name:"Species Composition", description: "Species Composition"},
        { value:"Structural Assemblage", name:"Structural Assemblage", description: "Structural Assemblage"},
        { value:"Biogeography", name:"Biogeography", description: "Observations on a large scale of the spatial distributions of species and ecosystems in relation to climate and soil.,,"},
        { value:"Bioregional Inventory", name:"Bioregional Inventory", description: "The systematic survey of fauna and flora at different locations to identify the composition and distribution on taxa.,,"},
        { value:"Chemical Ecology", name:"Chemical Ecology", description: "Observations made on the origin, function and significance of natural chemicals that mediate interactions with and between organisms (e.g., insect pheromones)..,,"},
        { value:"Competition/Resource Partitioning", name:"Competition/Resource Partitioning", description: "Observations made on populations of two or more species coexisting in and competing for resources in the same habitat.,,"},
        { value:"Decomposition", name:"Decomposition", description: "The study of the process of decaying biomass.,,"},
        { value:"Disease Ecology", name:"Disease Ecology", description: "Observations made on populations, communities and ecosystems studying  the interactions between  Parasitic, bacterial and viral infections, their animal hosts and their environment. ,,"},
        { value:"Disturbances", name:"Disturbances", description: "Observations on environmental disturbances (e.g., changed fire regimes, climate change, invasive species) and their influence on populations, ecological community and ecosystems.,,"},
        { value:"Ecological Succession", name:"Ecological Succession", description: "Observations on the gradual and orderly process of change in species structure of ecological communities of an ecosystem over time.,,"},
        { value:"Ecophysiology", name:"Ecophysiology", description: "Observations on the interrelationship of an organism???s functioning and physiological adaptation to the environment (e.g., temperature extremes). ,,"},
        { value:"Ecosystem Modelling", name:"Ecosystem Modelling", description: "Ecosystem modelling is the practice of applying numerical tools that combine observations of species distributions, species interactions with environmental estimates of ecosystems to understand functional change in ecosystems. ,,"},
        { value:"Ecotoxicology", name:"Ecotoxicology", description: "Observations made on the effects of toxic chemicals on individuals of populations (e.g., stress of agricultural chemicals).,,"},
        { value:"Evolutionary Ecology", name:"Evolutionary Ecology", description: "Observations made on organisms to understand the evolutionary influences on ecological processes or the ecological influence on evolutionary processes (e.g., genetics, behaviour, life histories, mating systems).,,"},
        { value:"Fire Ecology", name:"Fire Ecology", description: "Observations made on fire behaviour, its effects on biota and ecosystems, including predictions about behaviour.,,"},
        { value:"Functional Ecology", name:"Functional Ecology", description: "The study of the roles or functions that species play in the community or ecosystem in which they occur.,,"},
        { value:"Global Ecology", name:"Global Ecology", description: "The study of the interactions among the Earth's species occurrence, ecological communities, functional complexity ecosystems, land, atmosphere and oceans at a whole of globe scale.,,"},
        { value:"Herbivory", name:"Herbivory", description: "The study of animals that feeds chiefly on grass and other plants.,,"},
        { value:"Landscape Ecology", name:"Landscape Ecology", description: "Observations made on many species simultaneously in relation to their environment with a focus on spatial patterns and processes related to them. ,,"},
        { value:"Long-Term Community Monitoring", name:"Long-Term Community Monitoring", description: "The systematic study of communities over long time frames.,,"},
        { value:"Long-Term Species Monitoring", name:"Long-Term Species Monitoring", description: "Observations made on populations of species where the focus is the study of trends in populations and ecological processes over long temporal scales.  L,,"},
        { value:"Macroecology", name:"Macroecology", description: "The study of relationships between organisms and their environment at large spatial scales to characterise and explain statistical patterns of abundance, distribution and diversity.,,"},
        { value:"Molecular Ecology", name:"Molecular Ecology", description: "Observations on organisms using molecular genetic approaches that investigate the interactions among species (including difficult to culture microbes), the genetics and evolution of ecologically important traits, the relatedness among individuals and (based on this information) their dispersal and behaviour, the movement of individuals across landscapes, the formation of new species and the consequences of hybridization between divergent lineages..,,"},
        { value:"None", name:"None", description: "None,,"},
        { value:"Other", name:"Other", description: "Other,,"},
        { value:"Paleoecology", name:"Paleoecology", description: "The study of fossil organisms and their associated remains, including their life cycle, living interactions, natural environment, and manner of death and burial to reconstruct the paleoenvironment.,,"},
        { value:"Pollination", name:"Pollination", description: "The study of the distribution of pollen (wind-born or transported by animals) and the efficiency of pollen fertilisation.,,"},
        { value:"Population Dynamics", name:"Population Dynamics", description: "Observations made on the abundance, distribution and growth of a group of individuals of a single species living and interacting in the same area, including predictions of population shifts.,,"},
        { value:"Predator-Prey Interactions", name:"Predator-Prey Interactions", description: "Observation made on the interaction of populations of predator(s) on prey species populations. ,,"},
        { value:"Productivity", name:"Productivity", description: "The study of the generation of biomass in an ecosystem.,,"},
        { value:"Restoration Ecology", name:"Restoration Ecology", description: "The study of renewing and restoring degraded, damaged, or destroyed ecosystems and habitats in the environment by active human intervention and action.,,"},
        { value:"Soil Ecology", name:"Soil Ecology", description: "The study of the interactions among soil organisms, and between biotic and abiotic aspects of the soil environment.,,"},
        { value:"Species Decline", name:"Species Decline", description: "Observations are made on the critical decline and/or disappearance of populations of a species  A specialised research area of population ecology.,,"},
        { value:"Species Distribution Modelling", name:"Species Distribution Modelling", description: "Species distribution modelling is the practice of applying numerical tools that combine observations of species occurrence or abundance with environmental estimates. They are used to gain ecological and evolutionary insights and to predict distributions across landscapes in space and time. ,,"},
        { value:"Symbyotic Interactions", name:"Symbyotic Interactions", description: "The study of the relation between two different kinds of organisms in which one receives benefits from the other by causing damage to it (usually not fatal damage _ mutualism, commensulaism, parasitism).,,"},
        { value:"Urban Ecology", name:"Urban Ecology", description: "The study of the relation of living organisms with each other and their surroundings in the context of built-up human environments.,,"}])
    self.listThreat = ko.observableArray([{ value:"Agrochemicals", name:"Agrochemicals", description: "Agrochemicals,,"},
        { value:"Nutrients", name:"Nutrients", description: "Nutrients"},
        { value:"Altered Water Flows", name:"Altered Water Flows", description: "Altered Water Flows,,"},
        { value:"Changed Hydrology", name:"Changed Hydrology", description: "Changed hydrology,,"},
        { value:"Sedimentation", name:"Sedimentation", description: "Sedimentation"},
        { value:"Climate Change", name:"Climate Change", description: "Climate Change,,"},
        { value:"disease", name:"Disease", description: "disease"},
        { value:"Exotic Animal Species", name:"Exotic Animal Species", description: "Exotic Animal Species,,"},
        { value:"Exotic Plant Species", name:"Exotic Plant Species", description: "Exotic Plant Species,,"},
        { value:"famine", name:"Famine", description: "famine"},
        { value:"Fire Regimes", name:"Fire Regimes", description: "Fire Regimes,,"},
        { value:"Habitat Fragmentation", name:"Habitat Fragmentation", description: "Habitat Fragmentation,,"},
        { value:"Human road kill", name:"Human road kill", description: "Human road kill"},
        { value:"Interacting Pressures", name:"Interacting Pressures", description: "Interacting Pressures,,"},
        { value:"Invasive Animal Species", name:"Invasive Animal Species", description: "Invasive Animal Species,,"},
        { value:"Invasive Plant Species", name:"Invasive Plant Species", description: "Invasive Plant Species,,"},
        { value:"Land-use change", name:"Land-use change", description: "Land-use change"},
        { value:"Natural Resource Use", name:"Natural Resource Use", description: "Natural Resource Use,,"},
        { value:"None", name:"None", description: "None,,"},
        { value:"Other", name:"Other", description: "Other,,"},
        { value:"over-consumption", name:"Over-consumption", description: "over-consumption"},
        { value:"over-population", name:"Over-population", description: "over-population"},
        { value:"Pollution", name:"Pollution", description: "Pollution,,"},
        { value:"Salinity", name:"Salinity", description: "Salinity,,"},
        { value:"Soil Erosion", name:"Soil Erosion", description: "Soil Erosion,,"},
        { value:"war", name:"War", description: "war"},
        { value:"Water Extraction", name:"Water Extraction", description: "Water extraction,,"}])
    self.listConservation = ko.observableArray([{ value:"Agrochemical Management", name:"Agrochemical Management", description: "Agrochemical Management"},
        { value:"Animal Health", name:"Animal Health", description: "Animal Health"},
        { value:"Biosecurity", name:"Biosecurity", description: "Biosecurity,,"},
        { value:"Critical Habitat", name:"Critical Habitat", description: "Critical habitat,,"},
        { value:"Environmental Water Management", name:"Environmental Water Management", description: "Environmental Water Management,,"},
        { value:"Fire Management", name:"Fire Management", description: "Fire Management,,"},
        { value:"Habitat Restoration", name:"Habitat Restoration", description: "Habitat Restoration,,"},
        { value:"human pressure on threatened ecosystems", name:"Human Population Density", description: "human pressure on threatened ecosystems"},
        { value:"Human Wildlife Interactions", name:"Human Wildlife Interactions", description: "Human Wildlife Interactions,,"},
        { value:"Landscape-Scale Management", name:"Landscape-Scale Management", description: "Landscape-scale Management,,"},
        { value:"Market-Based Approaches", name:"Market-Based Approaches", description: "Market-based Approaches,,"},
        { value:"Migratory Species", name:"Migratory Species", description: "Migratory species,,"},
        { value:"National Reserve System", name:"National Reserve System", description: "National Reserve System,,"},
        { value:"None", name:"None", description: "None,,"},
        { value:"Other", name:"Other", description: "Other,,"},
        { value:"Special Management Populations", name:"Special Management Populations", description: "Special Management Populations,,"},
        { value:"Threatened Ecological Communities", name:"Threatened Ecological Communities", description: "Threatened Ecological Communities,,"},
        { value:"Threatened Species", name:"Threatened Species", description: "Threatened Species,,"},
        { value:"Translocation/Re-Introduction/Ex Situ Conservation", name:"Translocation/Re-Introduction/Ex Situ Conservation", description: "Translocation/Re-introduction/Ex situ conservation,,"},
        { value:"Vertebrate/Invertebrate Pest Species Management", name:"Vertebrate/Invertebrate Pest Species Management", description: "Vertebrate/Invertebrate Pest Species Management,,"},
        { value:"Water Quality", name:"Water Quality", description: "Water Quality"},
        { value:"Weed Management", name:"Weed Management", description: "Weed Management,,"},
        { value:"Wildlife Corridors", name:"Wildlife Corridors", description: "Wildlife Corridors,,"}])


    self.extraFos = ko.observable('')
    self.extraSeo = ko.observable('')
    self.extraResearch = ko.observable('')
    self.extraThreat = ko.observable('')
    self.extraConservation = ko.observable('')

    self.addExtraFos = function() {
        self.addListItem(self.listFos, self.extraFos())
    }

    self.addExtraSeo = function() {
        self.addListItem(self.listSeo, self.extraSeo())
    }

    self.addExtraResearch = function() {
        self.addListItem(self.listResearch, self.extraResearch())
    }

    self.addExtraThreat = function() {
        self.addListItem(self.listThreat, self.extraThreat())
    }

    self.addExtraConservation = function() {
        self.addListItem(self.listConservation, self.extraConservation())
    }

    self.addListItem = function(list, item) {
        var found = false
        for (var i in list()) {
            if (list()[i].value == item) found = true
        }
        if (!found) list.push({value: item, name: item, description: ''})
    }

    //self.project = $.extend(self.project, projectVM);
    self.show = ko.observable(false);
    self.hideModal = function () {
        bootbox.confirm("You will lose unsaved changes. Are you sure you want to close this window?", function(result) {
            if (result) {
               self.show(false);
                $(window).on('beforeunload', function(){
                    $('*').css("cursor", "progress");
                });
                window.location.reload();
        }});
   }

    self.showModal = function() {
        self.show(true);
    };

    self.isProjectInfoValidated = function () {
        return ko.utils.unwrapObservable(self.projectViewModel.description);
    };

    self.isDatasetInfoValidated = function () {
        return ko.utils.unwrapObservable(self.datasetTitle) &&
               ko.utils.unwrapObservable(self.description);
    };

    self.isLocationDatesValidated = function () {
        return ko.utils.unwrapObservable(self.sites);
    };

    self.isDatasetSpeciesValidated = function () {
        // nothing to validate...only display fields currently
        return true;
    };

    self.isMaterialsValidated = function () {
        // nothing to validate...only display fields currently
        return true;
    };

    self.isMethodsValidated = function () {
        return ko.utils.unwrapObservable(self.methodName) &&
            ko.utils.unwrapObservable(self.methodAbstract);
    };

    self.isContactsValidated = function () {
        return ko.utils.unwrapObservable(self.datasetContactDetails) &&
                ko.utils.unwrapObservable(self.datasetContactName) &&
                ko.utils.unwrapObservable(self.datasetContactRole) &&
                ko.utils.unwrapObservable(self.datasetContactPhone) &&
                ko.utils.unwrapObservable(self.datasetContactEmail) &&
                ko.utils.unwrapObservable(self.datasetContactAddress) &&
                ko.utils.unwrapObservable(self.authorSurname) &&
                ko.utils.unwrapObservable(self.authorAffiliation);
    };

    self.isManagementValidated = function () {
        return true;
    };

    self.isValidationValid = function () {
        switch(ko.utils.unwrapObservable(self.selectedTab)) {
            case 'tab-1':
                return self.isProjectInfoValidated();
                break;
            case 'tab-2':
                return self.isDatasetInfoValidated();
                break;
            case 'tab-3':
                return true;
                break;
            case 'tab-4':
                return self.isLocationDatesValidated();
                break;
            case 'tab-5':
                return self.isDatasetSpeciesValidated();
                break;
            case 'tab-6':
                return self.isMaterialsValidated();
                break;
            case 'tab-7':
                return self.isMethodsValidated();
                break;
            case 'tab-8':
                return self.isContactsValidated();
                break;
            case 'tab-9':
                return self.isManagementValidated();
                break;
            default:
            return true;
        }
    };

    self.isAllValidationValid = function (index) {
        if (!self.isProjectInfoValidated()) {
            self.selectNextTab('#tab-1-' + index);
            return false;
        } else if (!self.isDatasetInfoValidated()) {
            self.selectNextTab('#tab-2-' + index);
            return false;
        } else if (!self.isLocationDatesValidated()) {
            self.selectNextTab('#tab-4-' + index);
            return false;
        } else if (!self.isDatasetSpeciesValidated()) {
            self.selectNextTab('#tab-5-' + index);
            return false;
        } else if (!self.isMaterialsValidated()) {
            self.selectNextTab('#tab-6-' + index);
            return false;
        } else if (!self.isMethodsValidated()) {
            self.selectNextTab('#tab-7-' + index);
            return false;
        } else if (!self.isContactsValidated()) {
            self.selectNextTab('#tab-8-' + index);
            return false;
        } else if (!self.isManagementValidated()) {
            self.selectNextTab('#tab-9-' + index);
            return false;
        }

        return true;
    };

    self.update = function(pActivity, caller){
        var url =  fcConfig.projectActivityUpdateUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(pActivity.asJS(caller), function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'updated') {
                   // self.updateLogo(data);
                    showAlert("Successfully updated ", "alert-success", self.placeHolder);

                    window.location.reload();
                } else {
                    self.showAlert(data.error ? data.error : "Error updating survey dataset", "alert-error", 'div.aekosAlert');
                }
            },
            error: function (data) {
                self.showAlert("Error updating the survey -" + data.status, "alert-error", 'div.aekosAlert');
            }
        });
    };

    self.showAlert = function(message, alerttype, target) {

        $(target).append('<div class="alert ' +  alerttype + ' aekosAlertDiv"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')

        setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
            $("div.alert." + alerttype + ".aekosAlertDiv").remove();
        }, 5000);
    }

    self.submit = function(index){

        if (self.isAllValidationValid(index)) {
            var current_time = Date.now();

            var submissionDate = moment(current_time).format("YYYY-MM-DDTHH:mm:ssZZ"); //moment(new Date(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
            //var utc = new Date().toJSON().slice(0,10);
            self.submissionRecords.push (new SubmissionRec(submissionDate, self.user, self.currentDatasetVersion(), 'Pending'));
          //  self.showAlert("Error updating the survey - error", "alert-error", 'div.aekosAlert');
            //setTimeout(function(){
              self.update (self, 'info');

            //}, 0);

        }
    };


};

var SubmissionRec = function (submitDateVal, submitterVal, datasetVersionVal, doiRef) {
    var self = this;

    self.submissionPublicationDate = ko.observable(submitDateVal);
    self.datasetSubmitter = ko.observable(submitterVal);
    self.datasetVersion = ko.observable(datasetVersionVal);
    self.submissionDoi = ko.observable(doiRef);

    self.displayDate = ko.computed (function(){
        return moment(self.submissionPublicationDate()).format("DD-MM-YYYY");
    })
}


var ProjectActivitiesSettingsViewModel = function (pActivitiesVM, placeHolder) {

    var self = $.extend(this, pActivitiesVM);
    var surveyInfoTab = '#survey-info-tab';
    self.placeHolder = placeHolder;
    self.speciesOptions =  [{id: 'ALL_SPECIES', name:'All species'},{id:'SINGLE_SPECIES', name:'Single species'}, {id:'GROUP_OF_SPECIES',name:'A selection or group of species'}];
    self.datesOptions = [60, 90, 120, 180];
    self.formNames = ko.observableArray($.map(self.pActivityForms ? self.pActivityForms : [], function (obj, i) {
        return obj.name;
    }));

    self.addProjectActivity = function () {
        self.reset();
        var args = {
            pActivity: [],
            pActivityForms: self.pActivityForms,
            projectId: self.projectId(),
            selected: true,
            sites: self.sites,
            organisationName: self.organisationName,
            startDate: self.projectStartDate
        };
        self.projectActivities.push(new ProjectActivity(args));
        initialiseValidator();
        self.refreshSurveyStatus();
        $(surveyInfoTab).tab('show');
        showAlert("Successfully added.", "alert-success", self.placeHolder);
    };

    self.updateStatus = function () {
        var current = self.current();
        var jsData = current.asJSAll();

        if (jsData.published) {
            return self.unpublish();
        }

        if(!current.isEndDateAfterStartDate()) {
            showAlert("Survey end date must be after start date", "alert-error", self.placeHolder);
            $('#survey-info-tab').tab('show');
        } else if (current.isInfoValid() &&
            current.species.isValid() &&
            jsData.pActivityFormName &&
            (jsData.sites && jsData.sites.length > 0)
        ) {
            jsData.published = true;
            return self.publish(jsData);
        } else {
            showAlert("Mandatory fields in 'Survey Info', 'Species', 'Survey Form' and 'Locations' tab must be completed before publishing the survey.", "alert-error", self.placeHolder);
        }
    };

    self.saveInfo = function () {
        return self.genericUpdate("info");
    };

    self.saveVisibility = function () {
        return self.genericUpdate("visibility");
    };

    self.saveForm = function () {
        return self.genericUpdate("form");
    };

    self.saveSpecies = function () {
        return self.genericUpdate("species");
    };

    self.saveAlert = function () {
        return self.genericUpdate("alert");
    };

    self.saveSites = function () {
        var jsData = self.current().asJS("sites");
        if (jsData.sites && jsData.sites.length > 0) {
            self.genericUpdate("sites");
        } else {
            showAlert("No site associated with this survey", "alert-error", self.placeHolder);
        }
    };

    self.saveSitesBeforeRedirect = function(redirectUrl) {
        var jsData = self.current().asJS("sites");
        if (jsData.sites && jsData.sites.length > 0) {
            self.genericUpdate("sites");
        }
        window.location.href = redirectUrl;
    };

    self.redirectToCreate = function(){
        var pActivity = self.current();
        self.saveSitesBeforeRedirect(fcConfig.siteCreateUrl + '&pActivityId=' + pActivity.projectActivityId());
    };

    self.redirectToSelect = function(){
        self.saveSitesBeforeRedirect(fcConfig.siteSelectUrl);
    };

    self.redirectToUpload = function(){
        self.saveSitesBeforeRedirect(fcConfig.siteUploadUrl);
    };

    self.deleteProjectActivity = function () {
        bootbox.confirm("Are you sure you want to delete this survey? Any survey forms that have been submitted will also be deleted.", function (result) {
            if (result) {
                var that = this;

                var pActivity;
                $.each(self.projectActivities(), function (i, obj) {
                    if (obj.current()) {
                        obj.status("deleted");
                        pActivity = obj;
                    }
                });

                if (pActivity.projectActivityId() === undefined) {
                    self.projectActivities.remove(pActivity);
                    if (self.projectActivities().length > 0) {
                        self.projectActivities()[0].current(true);
                    }
                    showAlert("Successfully deleted.", "alert-success", self.placeHolder);
                }
                else {
                    self.delete();
                }
            }
        });
    };

    // Once records are created, only info and visibility can be updated.
    var canSave = function (pActivity, caller){
        if (caller != "info" && pActivity.projectActivityId() === undefined) {
            showAlert("Please save 'Survey Info' details before applying other constraints.", "alert-error", self.placeHolder);
            return false;
        } else if (caller == "info" && !pActivity.isEndDateAfterStartDate()){
            showAlert("Survey end date must be after start date", "alert-error", self.placeHolder);
            return false;
        } else if(caller == "info" || caller == "visibility" || caller == "alert"){
            return true;
        }

        return !isDataAvailable(pActivity);
    };

    var isDataAvailable = function(pActivity){
        var result = true;
        $.ajax({
            url: fcConfig.activiyCountUrl + "/" + pActivity.projectActivityId(),
            type: 'GET',
            async: false,
            timeout: 10000,
            success: function (data) {
                if(data.total == 0){
                    result = false;
                } else {
                    showAlert("Error: Survey cannot be edited because records exist - to edit the survey, delete all records.", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Un handled error, please try again later.", "alert-error", self.placeHolder);
            }
        });
        return result;
    };

    self.updateLogo = function (data){
        var doc = data.doc;
        if (doc && doc.content && doc.content.documentId && doc.content.url) {
            $.each(self.projectActivities(), function (i, obj) {
                if (obj.current()) {
                    var logoDocument = obj.findDocumentByRole(obj.documents(), 'logo');
                    if (logoDocument) {
                        obj.removeLogoImage();
                        logoDocument.documentId = doc.content.documentId;
                        logoDocument.url = doc.content.url;
                        obj.documents.push(logoDocument);
                    }
                }
            });
        }
    };

    self.create = function (pActivity, caller){
        var pActivity = self.current();
        var url = fcConfig.projectActivityCreateUrl;
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(pActivity.asJS(caller), function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'created') {
                    $.each(self.projectActivities(), function (i, obj) {
                        if (obj.current() && !obj.projectActivityId()) {
                            obj.projectActivityId(result.projectActivityId);
                        }
                    });
                    self.updateLogo(data);
                    showAlert("Successfully created", "alert-success", self.placeHolder);
                } else {
                    showAlert(data.error ? data.error : "Error creating the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error creating the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.update = function(pActivity, caller){
        var url =  fcConfig.projectActivityUpdateUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(pActivity.asJS(caller), function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'updated') {
                    self.updateLogo(data);
                    showAlert("Successfully updated ", "alert-success", self.placeHolder);
                } else {
                    showAlert(data.error ? data.error : "Error updating the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error updating the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.delete = function(){
        var pActivity = self.current();
        var url =  fcConfig.projectActivityDeleteUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'DELETE',
            success: function (data) {
                if (data.error) {
                    showAlert("Error deleting the survey, please try again later.", "alert-error", self.placeHolder);
                } else {
                    self.projectActivities.remove(pActivity);
                    if (self.projectActivities().length > 0) {
                        self.projectActivities()[0].current(true);
                    }
                    showAlert("Successfully deleted.", "alert-success", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error deleting the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.publish = function(jsData){

        var url =  jsData.projectActivityId ? fcConfig.projectActivityUpdateUrl + "/" + jsData.projectActivityId : fcConfig.projectActivityCreateUrl;
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(jsData, function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message) {
                    var pActivityId = jsData.projectActivityId ? jsData.projectActivityId : result.projectActivityId;
                    var found = ko.utils.arrayFirst(self.projectActivities(), function(obj) {
                        return obj.projectActivityId() == pActivityId;
                    });
                    found ? found.published(true) : '';
                    showAlert("Successfully published, redirecting to survey list page.", "alert-success", self.placeHolder);
                    setTimeout(function() {
                        $('#activities-tab').tab('show');
                    }, 3000);

                } else{
                    showAlert(data.error ? data.error : "Error publishing the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error publishing the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };


    self.unpublish = function(){
        var pActivity = self.current();

        var url =  fcConfig.projectActivityUnpublishUrl + "/" + pActivity.projectActivityId();

        bootbox.confirm("Are you sure you want to unpublish this survey? All data associated with this survey will be lost.", function (result) {
            if (result) {
                blockUIWithMessage("Unpublishing the survey");
                $.ajax({
                    url: url,
                    type: 'POST',
                    data: {published: false},
                    contentType: 'application/json',
                    success: function (data) {
                        var result = data.resp;
                        if (result && result.message == 'updated') {
                            location.reload();
                        } else {
                            showAlert(data.error ? data.error : "Error unpublishing the survey", "alert-error", self.placeHolder);
                        }
                    },
                    error: function (data) {
                        showAlert("Error unpublishing the survey -" + data.status, "alert-error", self.placeHolder);
                    },
                    complete: function(){
                        $.unblockUI();
                    }
                });
            }
        });
    };

    self.genericUpdate = function (caller) {
        if (caller != 'alert' && !$('#project-activities-' + caller + '-validation').validationEngine('validate')) {
            return false;
        }
        var pActivity = self.current();
        if (!canSave(pActivity, caller)) {
            return;
        }
        pActivity.projectActivityId() ? self.update(pActivity, caller) : self.create(pActivity, caller);
    };

    self.refreshSurveyStatus = function() {
        $.each(self.projectActivities(), function (i, obj) {
            var allowed = false;
            $.ajax({
                url: fcConfig.activiyCountUrl + "/" + obj.projectActivityId(),
                type: 'GET',
                async: false,
                timeout: 10000,
                success: function (data) {
                    if(data.total == 0){
                        allowed = true;
                    }
                },
                error: function (data) {
                    console.log("Error retrieving survey status.", "alert-error", self.placeHolder);
                }
            });
            obj.transients.saveOrUnPublishAllowed(allowed);
        });

    };

    /**
     * checks if selected survey has survey info tab filled.
     * @returns {boolean}
     */
    self.isSurveyInfoFormFilled = ko.computed(function(){
        return !!(self.current() && self.current().isInfoValid())
    })

    /**
     * This function checks if the survey info tab is valid and returns an appropriate string to fill data-toggle
     * attribute on the anchor tag. This logic is used to disable all tabs except survey info tab. It helps to force
     * users to fill the survey info tab before moving to other tabs.
     * @returns {string} 'tab' or ''
     */
    self.dataToggleVal = function(){
        if(self.isSurveyInfoFormFilled()){
            return 'tab'
        } else {
            return ''
        }
    }

    /**
     * Checks if all mandatory survey fields are filled for survey to be published.
     * @returns {boolean}
     */
    self.isSurveyPublishable = function(){
        var current = self.current();
        var sites = current.sites();

        return (current.isInfoValid() &&
        current.species.isValid() &&
        current.pActivityFormName() &&
        (sites && sites.length > 0))
    }

    /**
     * Checks if survey data entry template is selected
     * @returns {boolean}
     */
    self.isPActivityFormNameFilled = function(){
        var current = self.current();
        return !!current.pActivityFormName();
    }

    /**
     * Checks if one or more sites are added to the survey
     * @returns {boolean}
     */
    self.isSiteSelected = function(){
        var sites = self.current().sites();
        return sites && sites.length > 0
    }

    /**
     * Auto save when all mandatory survey info fields are filled
     */
    self.isSurveyInfoFormFilled.subscribe(function(){
        if(self.isSurveyInfoFormFilled() && !self.isSurveySelected()){
            self.saveInfo();
        }
    })

    self.refreshSurveyStatus();
};

var ProjectActivity = function (params) {
    if(!params) params = {};
    var pActivity = params.pActivity ? params.pActivity : {};
    var pActivityForms = params.pActivityForms ? params.pActivityForms : [];
    var projectId = params.projectId ? params.projectId : "";
    var selected = params.selected ? params.selected : false;
    var sites = params.sites ? params.sites : [];
    var startDate = params.startDate ? params.startDate : "";
    var organisationName = params.organisationName ? params.organisationName : "";
    var project = params.project ? params.project : {};
    var user = params.user ? params.user : {};

    var self = $.extend(this, new pActivityInfo(pActivity, selected, startDate, organisationName));

    self.project = project;

    self.projectId = ko.observable(pActivity.projectId ? pActivity.projectId : projectId);
    self.restrictRecordToSites = ko.observable(pActivity.restrictRecordToSites);
    self.pActivityFormName = ko.observable(pActivity.pActivityFormName);
    self.species = new SpeciesConstraintViewModel(pActivity.species);
    self.visibility = new SurveyVisibilityViewModel(pActivity.visibility);
    self.alert = new AlertViewModel(pActivity.alert);

    self.usageGuide = ko.observable(pActivity.usageGuide ? pActivity.usageGuide : "");

    self.relatedDatasets = ko.observableArray (pActivity.relatedDatasets ? pActivity.relatedDatasets : []);

    self.typeFor = ko.observableArray(pActivity.typeFor ? pActivity.typeFor : [])
    self.typeSeo = ko.observableArray(pActivity.typeSeo ? pActivity.typeSeo : [])
    self.typeResearch = ko.observableArray(pActivity.typeResearch ? pActivity.typeResearch : [])
    self.typeThreat = ko.observableArray(pActivity.typeThreat ? pActivity.typeThreat : [])
    self.typeConservation = ko.observableArray(pActivity.typeConservation ? pActivity.typeConservation : [])

    self.lastUpdated = ko.observable(pActivity.lastUpdated ? pActivity.lastUpdated : "");

    self.dataSharingLicense = ko.observable(pActivity.dataSharingLicense ? pActivity.dataSharingLicense : "CC BY");

    self.transients = self.transients || {};
    self.transients.warning = ko.computed(function () {
        return self.projectActivityId() === undefined ? true : false;
    });
    self.transients.disableEmbargoUntil = ko.computed(function () {
        if(self.visibility.embargoOption() != 'DATE'){
            return true;
        }

        return false;
    });

    self.transients.availableSpeciesDisplayFormat = ko.observableArray([{
        name:'SCIENTIFICNAME(COMMONNAME)',
        displayName: 'Scientific name (Common name)'
    },{
        name:'COMMONNAME(SCIENTIFICNAME)',
        displayName: 'Common name (Scientific name)'
    },{
        name:'COMMONNAME',
        displayName: 'Common name'
    },{
        name:'SCIENTIFICNAME',
        displayName: 'Scientific name'
    }])

    var legalCustodianVal = ko.utils.unwrapObservable(project.legalCustodianOrganisation);

    if (legalCustodianVal != "" && organisationName != legalCustodianVal) {
        self.transients.custodianOptions = [organisationName, legalCustodianVal];
    } else {
        self.transients.custodianOptions = [organisationName];
    }

    self.transients.selectedCustodianOption = legalCustodianVal;

    self.sites = ko.observableArray();
    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : defaultSites.push(obj.siteId);
            self.sites.push(new SiteList(obj, defaultSites));
        });
    };
    self.loadSites(sites, pActivity.sites);

    // AEKOS submission records
    var submissionRecs = pActivity.submissionRecords ? pActivity.submissionRecords : [];

    submissionRecs.sort(function(b, a) {
        var v1 = parseInt(a.datasetVersion.substr(7, 8))
        var v2 = parseInt(b.datasetVersion.substr(7, 8))
        if (v1 < v2) {
            return -1;
        }
        if (v1 > v2) {
            return 1;
        }

        // names must be equal
        return 0;
    });

    var sortedSubmissionRecs = submissionRecs.sort();

    self.submissionRecords = ko.observableArray();

    self.loadSubmissionRecords = function (submissionRecs) {
        $.map(submissionRecs ? submissionRecs : [], function (obj, i) {
            self.submissionRecords.push(new SubmissionRec(obj.submissionPublicationDate, obj.datasetSubmitter, obj.datasetVersion, obj.submissionDoi));
        });
    };
    self.loadSubmissionRecords(sortedSubmissionRecs);

    var methodName = pActivity.methodName? pActivity.methodName : "";

    if ((pActivity.sites ? pActivity.sites.length : 0) > 0 && methodName != "") {
        self.transients.isAekosData = ko.observable(true);
    } else {
        self.transients.isAekosData = ko.observable(false);
    }

    /*   self.showModal = function (pActivity) {
     self.modal = ko.observable(new AekosWorkflowViewModel(pActivity));

     } */

    var images = [];
    $.each(pActivityForms, function (index, form) {
        if (form.name == self.pActivityFormName()) {
            images = form.images ? form.images : [];
        }
    });

    self.pActivityFormImages = ko.observableArray($.map(images, function (obj, i) {
        return new ImagesViewModel(obj);
    }));

    self.pActivityForms = pActivityForms;

    self.pActivityFormName.subscribe(function (formName) {
        self.pActivityFormImages.removeAll();
        $.each(self.pActivityForms, function (index, form) {
            if (form.name == formName && form.images) {
                for (var i = 0; i < form.images.length; i++) {
                    self.pActivityFormImages.push(new ImagesViewModel(form.images[i]));
                }
            }
        });
    });

    // New fields for Aekos Submission
    self.environmentalFeatures = ko.observableArray();
    self.environmentalFeaturesSuggest = ko.observable();

    self.transients.titleOptions = ['Assoc Prof', 'Dr', 'Miss', 'Mr', 'Mrs', 'Miss', 'Prof'];

    self.datasetContactRole = ko.observable('');
    self.datasetContactDetails = ko.observable('');
    self.datasetContactEmail = ko.observable('');
    self.datasetContactName = ko.observable('');
    self.datasetContactPhone = ko.observable('');
    self.datasetContactAddress = ko.observable('');

    self.authorGivenNames = ko.observable('');
    self.authorSurname = ko.observable('');
    self.authorAffiliation = ko.observable('');

   /* self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosModalView().show(true);
        $('.modal')[0].style.width = '90%'
        $('.modal')[0].style.height = '80%'
    };
*/

    /**
     * get number of sites selected for a survey
     * @returns {number}
     */
    self.getNumberOfSitesForSurvey = function () {
        var count = 0;
        var sites = self.sites();
        sites.forEach(function(site){
            if(site.added()){
                count ++;
            }
        });
        return count;
    }
    //
    //self.isSpeciesDisplayFormatChecked = ko.computed(function(){
    //    debugger;
    //    $(this).val() == self.speciesDisplayFormat()
    //})

    self.asJSAll = function () {
        var jsData = $.extend({},
            self.asJS("info"),
            self.asJS("access"),
            self.asJS("form"),
            self.asJS("species"),
            self.asJS("visibility"),
            self.asJS("alert"),
            self.asJS("sites"));
        return jsData;
    };

    self.asJS = function (by) {
        var jsData;

        if (by == "form") {
            jsData = {};
            jsData.pActivityFormName = self.pActivityFormName();
        }
        else if (by == "info") {
            var ignore = self.ignore.concat(['current', 'pActivityForms', 'pActivityFormImages',
                'access', 'species', 'sites', 'transients', 'endDate','visibility','pActivityFormName', 'restrictRecordToSites',
                'aekosModalView', 'project']);
            ignore = $.grep(ignore, function (item, i) {
                return item != "documents";
            });
            jsData = ko.mapping.toJS(self, {ignore: ignore});
            jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        }
        else if (by == "species") {
            jsData = {};
            jsData.species = self.species.asJson();
        }
        else if (by == "sites") {
            jsData = {};
            var sites = [];
            $.each(self.sites(), function (index, site) {
                if (site.added()) {
                    sites.push(site.siteId());
                }
            });
            jsData.sites = sites;
            jsData.restrictRecordToSites = self.restrictRecordToSites();
        }
        else if (by == "visibility") {
            jsData = {};
            var ignore = self.ignore.concat(['transients']);
            jsData.visibility = ko.mapping.toJS(self.visibility, {ignore: ignore});
        }
        else if (by == "alert") {
            jsData = {};
            var ignore = self.ignore.concat(['transients']);
            jsData.alert = ko.mapping.toJS(self.alert, {ignore: ignore});
        }

        return jsData;
    }

    self.aekosModalView = ko.observable(new AekosViewModel (self, project, user));

    //self.aekosModal = ko.observable(false);

    self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosModalView().show(true);
    };

};


// Custom binding for modal dialog
ko.bindingHandlers.bootstrapShowModal = {
    init: function (element, valueAccessor) {
    },
    update: function (element, valueAccessor) {
        var value = valueAccessor();

        if (ko.utils.unwrapObservable(value)) {
            $(element).modal('show');
            // this is to focus input field inside dialog
            $("input", element).focus();
        }
        else {
            $(element).modal('hide');
        }
    }
};

var SiteList = function (o, surveySites) {
    var self = this;
    if (!o) o = {};
    if (!surveySites) surveySites = {};

    self.siteId = ko.observable(o.siteId);
    self.name = ko.observable(o.name);
    self.added = ko.observable(false);
    self.siteUrl = ko.observable(fcConfig.siteViewUrl + "/" + self.siteId());
    self.ibra = ko.observable(o.extent.geometry.ibra)

    self.addSite = function () {
        self.added(true);
    };
    self.removeSite = function () {
        self.added(false);
    };

    self.load = function (surveySites) {
        $.each(surveySites, function (index, siteId) {
            if (siteId == self.siteId()) {
                self.added(true);
            }
        });
    };
    self.load(surveySites);

};

var SpeciesConstraintViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.type = ko.observable(o.type);
    self.allSpeciesLists = new SpeciesListsViewModel();
    self.singleSpecies = new SpeciesViewModel(o.singleSpecies);
    self.speciesLists = ko.observableArray($.map(o.speciesLists ? o.speciesLists : [], function (obj, i) {
        return new SpeciesList(obj);
    }));
    self.newSpeciesLists = new SpeciesList();
    self.speciesDisplayFormat = ko.observable(o.speciesDisplayFormat ||'SCIENTIFICNAME(COMMONNAME)')

    self.transients = {};
    self.transients.bioProfileUrl = ko.computed(function () {
        return fcConfig.bieUrl + '/species/' + self.singleSpecies.guid();
    });

    self.transients.bioSearch = ko.observable(fcConfig.speciesSearchUrl);
    self.transients.allowedListTypes = [
        {id: 'SPECIES_CHARACTERS', name: 'SPECIES_CHARACTERS'},
        {id: 'CONSERVATION_LIST', name: 'CONSERVATION_LIST'},
        {id: 'SENSITIVE_LIST', name: 'SENSITIVE_LIST'},
        {id: 'LOCAL_LIST', name: 'LOCAL_LIST'},
        {id: 'COMMON_TRAIT', name: 'COMMON_TRAIT'},
        {id: 'COMMON_HABITAT', name: 'COMMON_HABITAT'},
        {id: 'TEST', name: 'TEST'},
        {id: 'OTHER', name: 'OTHER'}];

    self.transients.showAddSpeciesLists = ko.observable(false);
    self.transients.showExistingSpeciesLists = ko.observable(false);

    self.transients.toggleShowAddSpeciesLists = function () {
        self.transients.showAddSpeciesLists(!self.transients.showAddSpeciesLists());
        if (self.transients.showAddSpeciesLists()) {
            self.transients.showExistingSpeciesLists(false);
        }
    };

    self.transients.toggleShowExistingSpeciesLists = function () {
        self.allSpeciesLists.transients.loading(true);
        self.transients.showExistingSpeciesLists(!self.transients.showExistingSpeciesLists());
        if (self.transients.showExistingSpeciesLists()) {
            self.allSpeciesLists.setDefault()
            self.transients.showAddSpeciesLists(false);
        }
    };

    self.addSpeciesLists = function (lists) {
        lists.transients.check(true);
        self.speciesLists.push(lists);
    };

    self.removeSpeciesLists = function (lists) {
        self.speciesLists.remove(lists);
    };

    self.allSpeciesInfoVisible = ko.computed(function () {
        return (self.type() == "ALL_SPECIES");
    });

    self.groupInfoVisible = ko.computed(function () {
        return (self.type() == "GROUP_OF_SPECIES");
    });

    self.singleInfoVisible = ko.computed(function () {
        return (self.type() == "SINGLE_SPECIES");
    });

    self.type.subscribe(function (type) {
        if (self.type() == "SINGLE_SPECIES") {
        } else if (self.type() == "GROUP_OF_SPECIES") {
        }
    });

    self.asJson = function () {
        var jsData = {};
        if (self.type() == "ALL_SPECIES") {
            jsData.type = self.type();
            jsData.speciesDisplayFormat = self.speciesDisplayFormat()
        }
        else if (self.type() == "SINGLE_SPECIES") {
            jsData.type = self.type();
            jsData.singleSpecies = ko.mapping.toJS(self.singleSpecies, {ignore: ['transients']});
            jsData.speciesDisplayFormat = self.speciesDisplayFormat()
        }
        else if (self.type() == "GROUP_OF_SPECIES") {
            jsData.type = self.type();
            jsData.speciesLists = ko.mapping.toJS(self.speciesLists, {ignore: ['listType', 'fullName', 'itemCount', 'description', 'listType', 'allSpecies', 'transients']});
            jsData.speciesDisplayFormat = self.speciesDisplayFormat()
        }

        return jsData;
    };

    self.isValid = function(){
        return ((self.type() == "ALL_SPECIES") || (self.type() == "SINGLE_SPECIES" && self.singleSpecies.guid()) ||
        (self.type() == "GROUP_OF_SPECIES" && self.speciesLists().length > 0))
    };

    self.saveNewSpeciesName = function () {
        if (!$('#project-activities-species-validation').validationEngine('validate')) {
            return;
        }

        var jsData = {};
        jsData.listName = self.newSpeciesLists.listName();
        jsData.listType = self.newSpeciesLists.listType();
        jsData.description = self.newSpeciesLists.description();
        jsData.listItems = "";

        var lists = ko.mapping.toJS(self.newSpeciesLists);
        $.each(lists.allSpecies, function (index, species) {
            if (index == 0) {
                jsData.listItems = species.name;
            } else {
                jsData.listItems = jsData.listItems + "," + species.name;
            }
        });
        // Add bulk species names.
        if (jsData.listItems == "") {
            jsData.listItems = self.newSpeciesLists.transients.bulkSpeciesNames();
        } else {
            jsData.listItems = jsData.listItems + "," + self.newSpeciesLists.transients.bulkSpeciesNames();
        }

        var model = JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
        var divId = 'project-activities-result-placeholder';
        $("#addNewSpecies-status").show();
        $.ajax({
            url: fcConfig.addNewSpeciesListsUrl,
            type: 'POST',
            data: model,
            contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    showAlert("Error :" + data.error, "alert-error", divId);
                }
                else {
                    showAlert("Successfully added the new species list - " + self.newSpeciesLists.listName() + " (" + data.id + ")", "alert-success", divId);
                    self.newSpeciesLists.dataResourceUid(data.id);
                    self.speciesLists.push(new SpeciesList(ko.mapping.toJS(self.newSpeciesLists)));
                    self.newSpeciesLists = new SpeciesList();
                    self.transients.toggleShowAddSpeciesLists();
                }
                $("#addNewSpecies-status").hide();
            },
            error: function (data) {
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
                $("#addNewSpecies-status").hide();
            }
        });
    };

};

var SpeciesListsViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.searchGuid = ko.observable();
    self.searchName = ko.observable();

    self.allSpeciesListsToSelect = ko.observableArray();
    self.offset = ko.observable(0);
    self.max = ko.observable(100);
    self.listCount = ko.observable();

    self.transients = {};
    self.transients.loading = ko.observable(false);
    self.transients.sortCol = ko.observable("listName");
    self.transients.sortOrder = ko.observable("asc");

    self.isNext = ko.computed(function () {
        var status = false;
        if (self.listCount() > 0) {
            if ((self.offset() + self.max()) < self.listCount()) {
                status = true;
            }
        }
        return status;
    });

    self.isPrevious = ko.computed(function () {
        return (self.offset() > 0);
    });

    self.next = function () {
        if (self.listCount() > 0) {
             if (self.offset() < self.listCount()) {
                self.offset(self.offset() + self.max());
                self.loadAllSpeciesLists(self.transients.sortCol(), self.transients.sortOrder());
            }
        }
    };

    self.previous = function () {
        if (self.offset() > 0) {
            var newOffset = self.offset() - self.max();
            self.offset(newOffset);
            self.loadAllSpeciesLists(self.transients.sortCol(), self.transients.sortOrder());
        }
    };

    self.sort = function(column, order) {
        if (!self.transients.loading()) {
            if (column == self.transients.sortCol()) {
                //toggle the order
                if (order == "asc") {
                    self.transients.sortOrder("desc");
                    $("#" + column + "_Hdr").removeClass("icon-arrow-up").addClass("icon-arrow-down");
                } else {
                    self.transients.sortOrder("asc");
                    $("#" + column + "_Hdr").removeClass("icon-arrow-down").addClass("icon-arrow-up");
                }
            } else {
                $("#" + self.transients.sortCol() + "_Hdr").removeClass("icon-arrow-up").removeClass("icon-arrow-down");
                $("#" + column + "_Hdr").removeClass("icon-arrow-down").addClass("icon-arrow-up");
                self.transients.sortCol(column)
                self.transients.sortOrder("asc");
            }
            self.loadAllSpeciesLists(self.transients.sortCol(), self.transients.sortOrder())
        }
    }

    self.loadAllSpeciesLists = function (sortCol, order) {
        self.transients.loading(true);
        var url = fcConfig.speciesListUrl + "?sort=" + sortCol + "&offset=" + self.offset() + "&max=" + self.max() + "&order=" + order;
        if (self.searchGuid()) {
            url += "&guid=" + self.searchGuid();
        }

        var divId = 'project-activities-result-placeholder';
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    showAlert("Error :" + data.text, "alert-error", divId);
                }
                else {
                    self.listCount(data.listCount);
                    self.allSpeciesListsToSelect($.map(data.lists ? data.lists : [], function (obj, i) {
                            return new SpeciesList(obj);
                        })
                    );
                    self.transients.loading(false);
                }
            },
            error: function (data) {
                var status = data.status;
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
            }
        });
    };

    self.clearSearch = function() {
        self.searchGuid(null);
        self.searchName(null);
        self.setDefault()
    }

    self.setDefault = function() {
        $("#" + self.transients.sortCol () + "_Hdr").removeClass("icon-arrow-up").removeClass("icon-arrow-down");
        self.transients.sortCol("listName");
        self.transients.sortOrder("asc");
        self.transients.loading(true);
        self.loadAllSpeciesLists(self.transients.sortCol(), self.transients.sortOrder());
        $("#listName_Hdr").addClass("icon-arrow-up").removeClass("icon-arrow-down");
    }

};

var SpeciesList = function (o) {
    var self = this;
    if (!o) o = {};

    self.listName = ko.observable(o.listName);
    self.dataResourceUid = ko.observable(o.dataResourceUid);

    self.listType = ko.observable(o.listType);
    self.fullName = ko.observable(o.fullName);
    self.itemCount = ko.observable(o.itemCount);

    // Only used for new species.
    self.description = ko.observable(o.description);
    self.listType = ko.observable(o.listType);
    self.allSpecies = ko.observableArray();
    self.addNewSpeciesName = function () {
        self.allSpecies.push(new SpeciesViewModel());
    };
    self.removeNewSpeciesName = function (species) {
        self.allSpecies.remove(species);
    };

    self.transients = {};
    self.transients.bulkSpeciesNames = ko.observable(o.bulkSpeciesNames);
    self.transients.url = ko.observable(fcConfig.speciesListsServerUrl + "/speciesListItem/list/" + o.dataResourceUid);
    self.transients.check = ko.observable(false);
};

var ImagesViewModel = function (image) {
    var self = this;
    if (!image) image = {};

    self.thumbnail = ko.observable(image.thumbnail);
    self.url = ko.observable(image.url);
};

var SurveyVisibilityViewModel = function (visibility) {
    var self = this;
    if (!visibility) {
        visibility = {};
    }

    self.embargoOption = ko.observable(visibility.embargoOption ? visibility.embargoOption : 'NONE');   // 'NONE', 'DAYS', 'DATE' -> See au.org.ala.ecodata.EmbargoOptions in Ecodata

    self.embargoForDays = ko.observable(visibility.embargoForDays ? visibility.embargoForDays : 10).extend({numeric:0});     // 1 - 180 days
    self.embargoUntil = ko.observable(visibility.embargoUntil).extend({simpleDate: true});
};

var AlertViewModel = function (alert) {
    var self = this;
    if (!alert) alert = {};
    self.allSpecies = ko.observableArray();
    self.emailAddresses = ko.observableArray();

    self.add = function () {
        if (!$('#project-activities-alert-validation').validationEngine('validate')) {
            return;
        }
        var species = {};
        species.name = self.transients.species.name();
        species.guid = self.transients.species.guid();

        var match = ko.utils.arrayFirst(self.allSpecies(), function(item) {
            return species.guid === item.guid();
        });

        if (!match) {
            self.allSpecies.push(new SpeciesViewModel(species));
        }
        self.transients.species.reset();
    };
    self.delete = function (species) {
        self.allSpecies.remove(species);
    };

    self.addEmail = function () {
        var emails = [];
        emails = self.transients.emailAddress().split(",");
        var invalidEmail = false;
        var message = "";
        $.each(emails, function (index, email) {
            if (!self.validateEmail(email)) {
                invalidEmail = true;
                message = email;
                return false;
            }
        });

        if (invalidEmail) {
            showAlert("Invalid email address (" + message + ")", "alert-error", "project-activities-result-placeholder");
        } else {
            $.each(emails, function (index, email) {
                if (self.emailAddresses.indexOf(email) < 0) {
                    self.emailAddresses.push(email);
                }
            });
            self.transients.emailAddress('');
        }
    };

    self.deleteEmail = function (email) {
        self.emailAddresses.remove(email);
    };

    self.transients = {};
    self.transients.species = new SpeciesViewModel();
    self.transients.emailAddress = ko.observable();
    self.transients.disableSpeciesAdd  = ko.observable(true);
    self.transients.disableAddEmail  = ko.observable(true);
    self.transients.emailAddress.subscribe(function(email) {
        return email ? self.transients.disableAddEmail(false): self.transients.disableAddEmail(true);
    });
    self.transients.species.guid.subscribe(function(guid) {
        return guid ? self.transients.disableSpeciesAdd(false) : self.transients.disableSpeciesAdd(true);
    });

    self.validateEmail = function(email){
        var expression = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return expression.test(email);
    };

    self.transients.bioProfileUrl = fcConfig.bieUrl + '/species/';
    self.transients.bioSearch = ko.observable(fcConfig.speciesSearchUrl);
    self.loadAlert = function (alert) {
        self.allSpecies($.map(alert.allSpecies ? alert.allSpecies : [], function (obj, i) {
                return new SpeciesViewModel(obj);
            })
        );

        self.emailAddresses($.map(alert.emailAddresses ? alert.emailAddresses : [], function (obj, i) {
                return obj;
            })
        );
    };

    self.loadAlert(alert);
};

/**
 * Custom validation function (used by the jquery-validation-engine), defined on the embargoUntil date field on the
 * survey admin visibility form
 */
function isEmbargoDateRequired(field, rules, i, options) {
    if ($('#embargoOptionDate:checked').val()) {
        if ($('#embargoUntilDate').val() == "") {
            rules.push('required');
        } else {
            var date = convertToIsoDate($('#embargoUntilDate').val(), 'dd-MM-yyyy');
            if (moment(date).isBefore(moment())) {
                return "The date must be in the future";
            } else if (moment(date).isAfter(new Date().setMonth(new Date().getMonth() + 12))) {
                return "The date cannot be more than 12 months in the future";
            }
        }
    }
}

function initialiseValidator() {
    var tabs = ['info', 'species', 'form', 'access', 'visibility', 'alert'];
    $.each(tabs, function (index, label) {
        $('#project-activities-' + label + '-validation').validationEngine();
    });
};

