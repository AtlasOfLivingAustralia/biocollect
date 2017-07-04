function Risks(risks, key) {
    var self = this;

    var savedRisks = amplify.store(key);
    if (savedRisks) {
        var restored = JSON.parse(savedRisks);
        if (restored.risks) {
            $('#restoredRiskData').show();
            risks = restored.risks;
        }
    }

    self.risks = new RisksViewModel(risks);

    self.addRisks = function(){
        self.risks.rows.push(new RisksRowViewModel());
    };
    self.removeRisk = function(risk) {
        self.risks.rows.remove(risk);
    };

    self.overAllRiskHighlight = ko.computed(function () {
        return getClassName(self.risks.overallRisk());
    });

    self.saveRisks = function(){
        if (!$('#risk-validation').validationEngine('validate'))
            return;
        self.risks.saveWithErrorDetection(function() {location.reload();});
    };

};

function RisksViewModel (risks) {
    var self = this;
    self.overallRisk = ko.observable();
    self.status = ko.observable();
    self.rows = ko.observableArray();
    self.load = function(risks) {
        if (!risks) {
            risks = {};
        }
        self.overallRisk(orBlank(risks.overallRisk));
        self.status(orBlank(risks.status));
        if (risks.rows) {
            self.rows($.map(risks.rows, function (obj) {
                return new RisksRowViewModel(obj);
            }));
        }
        else {
            self.rows.push(new RisksRowViewModel());
        }
    };
    self.modelAsJSON = function() {
        var tmp = {};
        tmp = ko.mapping.toJS(self);
        tmp['status'] = 'active';
        var jsData = {"risks": tmp};
        var json = JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
        return json;
    };
    self.load(risks);
};

function RisksRowViewModel (risksRow) {
    var self = this;
    if(!risksRow) risksRow = {};
    self.threat = ko.observable(risksRow.threat);
    self.description = ko.observable(risksRow.description);
    self.likelihood = ko.observable(risksRow.likelihood);
    self.consequence = ko.observable(risksRow.consequence);
    self.currentControl = ko.observable(risksRow.currentControl);
    self.residualRisk = ko.observable(risksRow.residualRisk);
    self.riskRating = ko.computed(function (){
        if (self.likelihood() == '' && self.consequence() == '')
            return;

        var riskCol = ["Insignificant","Minor","Moderate","Major","Extreme"];
        var riskTable = [
            ["Almost Certain","Medium","Significant","High","High","High"],
            ["Likely","Low","Medium","Significant","High","High"],
            ["Possible","Low","Medium","Medium","Significant","High"],
            ["Unlikely","Low","Low","Medium","Medium","Significant"],
            ["Remote","Low","Low","Low","Medium","Medium"]
        ];
        var riskRating = "";
        var riskRowIndex = -1;

        for(var i = 0; i < riskTable.length; i++) {
            if(riskTable[i][0] == this.likelihood()){
                riskRowIndex = i;
                break;
            }
        }

        if(riskRowIndex >= 0){
            for(var i = 0; i < riskCol.length; i++) {
                if(riskCol[i] == this.consequence()){
                    riskRating = riskTable[riskRowIndex][i+1];
                    break;
                }
            }
        }
        return riskRating;
    }, this);
};

function getClassName(val){
    var className = '';
    if(val == 'High')
        className = 'badge badge-important';
    else if (val == 'Significant')
        className = 'badge badge-warning';
    else if (val == 'Medium')
        className = 'badge badge-info';
    else if (val == 'Low')
        className = 'badge badge-success';
    return className;
}