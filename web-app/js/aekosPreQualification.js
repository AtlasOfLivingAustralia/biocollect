/**
 * Created by koh032 on 17/07/2017.
 */
AEKOS.PreQualification = function () {

    var self = this;

    self.questions = ko.observableArray([{question: "Is the data package finalised?", exitAnswer: "no", exitAnswerMsg: "The data package cannot be submitted to AEKOS for publishing until it is 'finalised'. Please finalise the data package and re-submit. To finalise the dataset, please esure that the following are completed."},
        {question: "Is the dataset for the terristrial ecological(land based ecosystems) data?", exitAnswer: "no", exitAnswerMsg: "Coastal , marine, socio-economic and other data is not suitable for the AEKOS repository and should be sent to other data infrastructure."},
        {question: "Is the dataset only comprised of museum or herbarioum collections records?", exitAnswer: "yes", exitAnswerMsg: "Museum and herbarium collection datasets are not appropriate for inclusion in the AEKOS repository."},
        {question: "Was the data collected opportunistically?", exitAnswer: "yes", exitAnswerMsg: "Data collected opportunistically is not appropriate for inclusion in the AEKOS repository."},
        {question: "Is the data structured using published sampling methods?", exitAnswer: "no", exitAnswerMsg: "Only datasets collected by and structured using published sampling methods are appropriate for inclusion in the AEKOS repository."},
        {question: "Is the data only species and location data (ie. Species occurrence data without associated environmental informations)?", exitAnswer: "yes", exitAnswerMsg: "The AEKOS data repository is for structured plot-based ecological and ecosystem datasets only. Species occurrence data is held by the Atlas of Living Australia. Occurrence data in this dataset can be harvested directly by the ALA into that repository."}
    ]);

    self.addObservableAnswerToQuestion = function () {
        $.each(self.questions(), function (i, obj) {
          obj.answer = ko.observable('');
        });
    };

    self.addObservableAnswerToQuestion ();
};