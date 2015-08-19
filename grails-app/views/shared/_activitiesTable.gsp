<r:require module="datepicker"/>
<!-- This section is bound to a secondary KO viewModel. The following line prevents binding
         to the main viewModel. -->
<!-- ko stopBinding: true -->
<div class="row-fluid space-after" id="activityListContainer">
    <div class="pull-right">
        <button data-bind="click:$root.expandActivities, visible: activities().length > 0" type="button" class="btn btn-link">Expand all</button>
        <button data-bind="click:collapseActivities, visible: activities().length > 0" type="button" class="btn btn-link">Collapse all</button>
        <button data-bind="click:newActivity" type="button" class="btn">Add new activity</button>
    </div>
    <p data-bind="visible: activities().length == 0">
        This project currently has no activities listed.
    </p>
    <table class="table table-condensed" id="activities">
        <thead>
        <tr data-bind="visible: activities().length > 0">
            <th width="2%"></th>
            <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="type">Type</th>
            <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="startDate">From</th>
            <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="endDate">To</th>
            <g:if test="${showSites}">
                <th class="sort" data-bind="sortIcon:activitiesSort,click:sortBy" data-column="siteName">Site</th>
            </g:if>
            <th></th>
        </tr>
        </thead>
        <tbody data-bind="foreach:activities" id="activityList">
        <tr>
            <!-- first 2 td elements toggle the accordion -->
            <td data-bind="attr:{href:'#'+activityId}" data-toggle="collapse" class="accordion-toggle">
                <div><a data-bind="text:toggleState()"></a></div>
            </td>
            <td data-bind="attr:{href:'#'+activityId}" data-toggle="collapse" class="accordion-toggle">
                <span data-bind="text:type"></span>
            </td>
            <td><span data-bind="clickToPickDate:startDate"></span></td>
            <td><span data-bind="clickToPickDate:endDate"></span></td>
            <g:if test="${showSites}">
                <td><a data-bind="text:siteName,click:$parent.openSite"></a></td>
            </g:if>
            <td style="width:86px;">
                <span data-bind="visible:(endDate.hasChanged() || startDate.hasChanged())" class="btn-group">
                    <button data-bind="click:save" type="button" class="btn btn-mini btn-success">Save</button>
                    <button data-bind="click:revert" type="button" class="btn btn-mini btn-warning">Cancel</button>
                </span>
                <i data-bind="click:del, visible:!(endDate.hasChanged() || startDate.hasChanged())"
                   class="icon-remove pull-right" title="Delete activity"></i>
            </td>
        </tr>
        <tr class="hidden-row">
            <td></td>
            <td colspan="5">
                <div class="collapse" data-bind="attr: {id:activityId}, css: {in:isInitiallyOpen()}">
                    <ul class="unstyled well well-small">
                        <!-- ko foreachModelOutput:metaModel.outputs -->
                        <li class="output-summary">
                            <div class="row-fluid">
                                <span class="span4">
                                    <a data-bind="text:name, attr: {href:editLink}"></a></span>
                                <span class="span5">
                                    <ul data-bind="foreach:scores">
                                        <li data-bind="text:key + ' = ' + value"></li>
                                    </ul>
                                </span>
                                <span class="span2 offset1">
                                    <a data-bind="attr: {href:editLink}">
                                        <span data-bind="text: outputId == '' ? 'Add data' : 'Edit data'"></span>
                                        <i data-bind="attr: {title: outputId == '' ? 'Add data' : 'Edit data'}" class="icon-edit"></i>
                                    </a>
                                </span>
                            </div>
                        </li>
                        <!-- /ko -->
                    </ul>
                </div>
            </td>
        </tr>
        </tbody>
    </table>
</div>
<r:script>
    $(window).load(function () {
        var collapseState = amplify.store.sessionStorage('output-accordion-state');
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
                        startDate: ko.observable(act.startDate).extend({simpleDate:false}),
                        endDate: ko.observable(act.endDate).extend({simpleDate:false}),
                        outputs: ko.observableArray([]),
                        collector: act.collector,
                        metaModel: act.model || {},
                        isInitiallyOpen: function () {
                            return ($.inArray(this.activityId, collapseState) > -1);
                        },
                        toggleState: function () {
                            return this.isInitiallyOpen() ? "\u25BC" : "\u25BA";
                        },
                        revert: function () {
                            this.startDate.date(this.startDate.originalValue);
                            this.endDate.date(this.endDate.originalValue);
                        },
                        save: function () {
                            var act = {activityId: this.activityId};
                            if (this.startDate.hasChanged()) {
                                act.startDate = this.startDate();
                            }
                            if (this.endDate.hasChanged()) {
                                act.endDate = this.endDate();
                            }
                            $.ajax({
                                url: fcConfig.activityUpdateUrl + "/" + this.activityId,
                                type: 'POST',
                                data: ko.toJSON(act),
                                contentType: 'application/json',
                                success: function (data) {
                                    if (data.error) {
                                        alert(data.detail + ' \n' + data.error);
                                    } else {
                                        document.location.reload();
                                    }
                                },
                                error: function (data) {
                                    var status = data.status;
                                    alert('An unhandled error occurred: ' + data.status);
                                }
                            });
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
            self.newActivity = function () {
                var context = '',
                    projectId = "${project?.projectId}",
                    siteId = "${site?.siteId}",
                    returnTo = '?returnTo=' + document.location.href;
                if (projectId) {
                    context = '&projectId=' + projectId;
                } else if (siteId) {
                    context = '&siteId=' + siteId;
                }
                document.location.href = fcConfig.activityCreateUrl + returnTo + context;
            };
            self.expandActivities = function () {
                // the check is required as 'show' seems to act like a toggle and the collapse code
                // does not always know the correct state
                $('#activityList div.collapse').each(function() {
                    if (!$(this).hasClass('in')) {
                        $(this).collapse('show');
                    }
                });
            };
            self.collapseActivities = function () {
                $('#activityList div.collapse').each(function() {
                    if ($(this).hasClass('in')) {
                        $(this).collapse('hide');
                    }
                });
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

</r:script>
<!-- /ko -->
