
/* data structures for handling output targets */
Output = function (name, scores, existingTargets, root) {
    var self = this;
    this.name = name;
    this.outcomeTarget = ko.observable(function () {
        // find any existing outcome value for this output
        var outcomeValue = "";
        $.each(existingTargets, function (j, existingTarget) {
            if (existingTarget.outcomeTarget && existingTarget.outputLabel === self.name) {
                outcomeValue = existingTarget.outcomeTarget;
                return false; // end the loop
            }
        });
        return outcomeValue;
    }());
    this.outcomeTarget.subscribe(function() {
        if (root.targetsEditable()) {
            self.isSaving(true);
            root.saveOutputTargets();
        }
    });
    this.scores = $.map(scores, function (score, index) {
        var targetValue = 0;
        var matchingTarget = _.find(existingTargets, function(target) { return target.scoreId == score.scoreId} );
        if (matchingTarget) {
            targetValue = matchingTarget.target;
        }
        return new OutputTarget(score, name, targetValue, index === 0, root);
    });
    this.isSaving = ko.observable(false);
};
Output.prototype.toJSON = function () {
    // we need to produce a flat target structure (for backwards compatibility)
    var self = this,
        targets = $.map(this.scores, function (score) {
            var js = score.toJSON();

            return js;
        });
    // add the outcome target
    targets.push({outputLabel:self.name, outcomeTarget: self.outcomeTarget()});
    return targets;
};
Output.prototype.clearSaving = function () {
    this.isSaving(false);
    $.each(this.scores, function (i, score) { score.isSaving(false) });
};

OutputTarget = function (score, outputName, value, isFirst, root) {
    var self = this;
    this.outputLabel = outputName;
    this.scoreLabel = score.label;
    this.target = ko.observable(value).extend({numericString:1});
    this.isSaving = ko.observable(false);
    this.isFirst = isFirst;
    this.units = score.units;
    this.scoreId = score.scoreId;
    this.target.subscribe(function() {
        if (root.targetsEditable()) {
            self.isSaving(true);
            root.saveOutputTargets();
        }
    });
};
OutputTarget.prototype.toJSON = function () {
    var clone = ko.toJS(this);
    delete clone.isSaving;
    delete clone.isFirst;
    return clone;
};

var Outcome = function (target) {
    var self = this;
    this.outputLabel = target.outputLabel;
    this.outcomeText = target.outcomeText;
    this.isSaving = ko.observable(false);
};

Outcome.prototype.toJSON = function () {
    var clone = ko.toJS(this);
    delete clone.isSaving;
    return clone;
};
function OutputTargets(activities, targets, targetsEditable, scores, config) {

    var self = this;
    var defaults = {
        saveTargetsUrl: fcConfig.projectUpdateUrl
    };
    var options = $.extend(defaults, config);

    var activityTypes = _.uniq(_.pluck(activities, 'type'));

    // Find all scores that are derived from the supplied activities.
    var relevantScores = _.filter(scores, function(score) {
        return _.some(score.entityTypes, function(scoreActivity) {
            return _.contains(activityTypes, scoreActivity);
        });
    });

    self.targetsEditable = targetsEditable;

    self.findTargetByScore = function(score) {
        var target = null;
        _.find(self.outputTargets(), function(outputTarget) {
            target = _.find(outputTarget.scores, function(target) {
                return target.scoreId == score.scoreId;
            });
            return target;
        });
        return target;
    };

    self.findOutputTargetByScore = function(score) {
        return _.find(self.outputTargets(), function(outputTarget) {
            return _.find(outputTarget.scores, function(target) {
                return target.scoreId == score.scoreId;
            });
        });
    };

    self.containsAny = function(list1, list2) {
        return _.some(list1, function(item1) {
            return _.contains(list2, item1);
        });
    };

    self.safeToRemove = function(activityType) {

        var result = true;
        if (self.onlyActivityOfType(activityType)) { // If there is more than 1 activity of the same type, it's safe to remove the activity
            var scoresByActivity = _.filter(scores, function(score) {
                return _.contains(score.entityTypes, activityType);
            });

            // Check first if the score has a target, and if so, if any other activities can contribute to this target
            result = !_.some(scoresByActivity, function(score) {
                var target = self.findTargetByScore(score);
                var hasTarget = (target && target.target() && target.target() != '0');
                if (!hasTarget) {
                    return false;
                }
                var otherActivities = _.reject(score.entityTypes, function(type) { return type == activityType});

                return !self.containsAny(otherActivities, activityTypes);
            });
        }
        return result;
    };

    self.onlyActivityOfType = function(activityType) {
        var activitiesByType = _.filter(activities, function(activity) { return activity.type == activityType });
        return activitiesByType && activitiesByType.length == 1;
    };

    self.removeTargetsAssociatedWithActivityType = function(activityType) {
        var scoresForActivity = _.filter(scores, function(score) {
            return _.contains(score.entityTypes, activityType);
        });
        $.each(scoresForActivity, function(i, score) {
            var otherActivityTypes = _.filter(score.entityTypes, function (type) {
                return type != activityType
            });
            var otherActivities = _.filter(activities, function (activity) {
                return _.contains(otherActivityTypes, activity.type);
            });
            if (otherActivities.length == 0) {
                var outputTarget = self.findOutputTargetByScore(score);
                if (outputTarget) {
                    outputTarget.scores = _.reject(outputTarget.scores, function(target) { return target.scoreId == score.scoreId });
                    if (outputTarget.scores.length == 0) {
                        self.outputTargets(_.reject(self.outputTargets(), function(t) { return t === outputTarget} ));
                    }
                }

            }
        });
    };

    self.outputTargets = ko.observableArray([]);
    self.saveOutputTargets = function() {
        var targets = [];
        $.each(self.outputTargets(), function (i, target) {
            $.merge(targets, target.toJSON());
        });

        var json = JSON.stringify({outputTargets:targets});

        return $.ajax({
            url: options.saveTargetsUrl,
            type: 'POST',
            data: json,
            contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    alert(data.detail + ' \n' + data.error);
                }
            },
            error: function (data) {
                var status = data.status;
                alert('An unhandled error occurred: ' + data.status);
            },
            complete: function(data) {
                $.each(self.outputTargets(), function(i, target) {
                    // The timeout is here to ensure the save indicator is visible long enough for the
                    // user to notice.
                    setTimeout(function(){target.clearSaving();}, 1000);
                });
            }
        });

    };

    self.loadOutputTargets = function () {
        var scoresByOutputType = _.groupBy(relevantScores, function(score) {
            return score.outputType;
        });
        _.each(scoresByOutputType, function(scoresForOutputType, outputType) {

            self.outputTargets.push(new Output(outputType, scoresForOutputType, targets, self));
        });
    }();
}