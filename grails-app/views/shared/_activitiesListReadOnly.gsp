<!-- This section is bound to a secondary KO viewModel. The following line prevents binding
         to the main viewModel. -->
<!-- ko stopBinding: true -->
<div class="row-fluid space-after" id="activityListContainer">
    <p data-bind="visible: activities().length > 0">Click column titles to sort. Click activity type to view the activity details.</p>
    <p data-bind="visible: activities().length == 0">
        This project currently has no activities listed.
    </p>
    <table class="table table-condensed" id="activities">
        <thead>
        <tr data-bind="visible: activities().length > 0">
            <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="type">Type</th>
            <th width="30%" class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="description">Description</th>
            <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="startDate">From</th>
            <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="endDate">To</th>
            <g:if test="${showSites}">
                <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="siteName">Site</th>
            </g:if>
            <th class="status" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="progress">Status</th>
        </tr>
        </thead>
        <tbody data-bind="foreach:activities" id="activityList">
        <tr>
            <td>
                <span data-bind="text:type,click:viewActivity" class="clickable"></span>
            </td>
            <td>
                <span data-bind="text:description"></span>
            </td>
            <td><span data-bind="text:startDateForDisplay"></span></td>
            <td><span data-bind="text:endDateForDisplay"></span></td>
            <g:if test="${showSites}">
                <td><a data-bind="text:siteName,click:$parent.openSite"></a></td>
            </g:if>
            <td><span data-bind="text:progress"></span></td>
        </tr>
        </tbody>
    </table>
</div>
<asset:script type="text/javascript">
    $(window).load(function () {
        function ActivitiesViewModel(activities, sites) {
            var self = this;
            this.loadActivities = function (activities) {
                var acts = ko.observableArray([]);
                $.each(activities, function (i, act) {
                    var activity = {
                        activityId: act.activityId,
                        siteId: act.siteId,
                        siteName: self.lookupSiteName(act.siteId),
                        type: act.type,
                        description: act.description,
                        startDate: ko.observable(act.startDate).extend({simpleDate:false}),
                        endDate: ko.observable(act.endDate).extend({simpleDate:false}),
                        plannedStartDate: ko.observable(act.plannedStartDate).extend({simpleDate:false}),
                        plannedEndDate: ko.observable(act.plannedEndDate).extend({simpleDate:false}),
                        progress: ko.computed(function() {
                            if (!act.progress) {
                                return 'Started';
                            }
                            return act.progress.charAt(0).toUpperCase() + act.progress.slice(1);
                        }),
                        outputs: ko.observableArray([]),
                        collector: act.collector,
                        metaModel: act.model || {},
                        viewActivity: function () {
                            document.location.href = fcConfig.activityViewUrl + "/" + this.activityId +
                                "?returnTo=" + here;
                        },
                        printActivity: function() {
                            open(fcConfig.activityPrintUrl + "/" + this.activityId, "fieldDataPrintWindow");
                        },
                        del: function () {
                            var self = this;
                            // confirm first
                            bootbox.confirm("Delete this activity? Are you sure?", function(result) {
                                if (result) {
                                    $.getJSON(fcConfig.activityDeleteUrl + '/' + self.activityId,
                                        function (data) {
                                            if (data.code < 400) {
                                                document.location.reload();
                                            } else {
                                                alert("Failed to delete activity - error " + data.code);
                                            }
                                        });
                                }
                            });
                        }
                    };
                    activity.startDateForDisplay = ko.computed(function() {
                        return (activity.progress() === 'Planned') ?
                            activity.plannedStartDate.formattedDate() : activity.startDate.formattedDate();
                    });
                    activity.endDateForDisplay = ko.computed(function() {
                        return (activity.progress() === 'Planned') ?
                            activity.plannedEndDate.formattedDate() : activity.endDate.formattedDate();
                    });
                    $.each(act.outputs, function (j, out) {
                        activity.outputs.push({
                            outputId: out.outputId,
                            name: out.name,
                            collector: out.collector,
                            assessmentDate: out.assessmentDate,
                            scores: out.scores
                        });
                    });
                    acts.push(activity);
                });
                return acts;
            };
            self.lookupSiteName = function (siteId) {
                var site;
                if (siteId !== undefined && siteId !== '') {
                    site = $.grep(sites, function(obj, i) {
                            return (obj.siteId === siteId);
                    });
                    if (site.length > 0) {
                         return site[0].name;
                    }
                }
                return '';
            };
            self.activities = self.loadActivities(activities);
            self.activitiesSort = {};
            self.activitiesSort.by = ko.observable("");
            self.activitiesSort.order = ko.observable("");
            self.sortActivities = function () {
                var field = self.activitiesSort.by(),
                    order = self.activitiesSort.order();
                self.activities.sort(function (left, right) {
                    var l = ko.utils.unwrapObservable(left[field]),
                        r = ko.utils.unwrapObservable(right[field]);
                    return l == r ? 0 : (l < r ? -1 : 1);
                });
                if (order === 'desc') {
                    self.activities.reverse();
                }
            };
            self.sortBy = function (data, event) {
                var element = event.currentTarget;
                state = $(element).find('i').hasClass('icon-chevron-up');
                self.activitiesSort.order(state ? 'desc' : 'asc');
                self.activitiesSort.by($(element).data('column'));
                self.sortActivities();
            };
            self.openSite = function () {
                var siteId = this.siteId;
                if (siteId !== '') {
                    document.location.href = fcConfig.siteViewUrl + '/' + siteId;
                }
            };
        }

        var activitiesViewModel = new ActivitiesViewModel(${activities ?: []}, ${sites ?: []});
        ko.applyBindings(activitiesViewModel, document.getElementById('activityListContainer'));
    });

</asset:script>
<!-- /ko -->
