var PaginationViewModel = function (o, caller) {
  var self = this;
  if (!o) o = {};
  if (!caller) caller = self;
  self.rppOptions = [10,25,30,50,100];
  self.resultsPerPage = ko.observable(25);
  self.totalResults = ko.observable();
  self.requestedPage = ko.observable();
  self.nextIndex = ko.observable();
  self.start = ko.observable();

  self.previousIndex = ko.pureComputed(function(){
    return self.requestedPage() <= 1 ? 1 : (self.requestedPage() - 1);
  });
  self.nextIndex  = ko.pureComputed(function(){
    var lastPage = Math.floor((self.totalResults() / self.resultsPerPage()));
    if (self.totalResults() % self.resultsPerPage()  != 0) {
      lastPage += 1;
    }
    if (lastPage == 0) {
      lastPage = 1;
    }
    return self.requestedPage() >= lastPage ? lastPage : (self.requestedPage() + 1);
  });

  self.info = ko.computed(function () {
    if (self.totalResults() > 0) {
      var start = 0;
      var message = "";

      //Start of the page
      if (self.requestedPage() == 1) {
        self.start(1);
        message = "Showing 1 to " + ((self.resultsPerPage() >= self.totalResults()) ? self.totalResults() : self.resultsPerPage()) + " of " + self.totalResults() + " results";
      }
      else if (self.requestedPage() > 0 && self.requestedPage() * self.resultsPerPage() >= self.totalResults()) {
        self.start(((self.totalResults() - self.resultsPerPage()) + 1));
        message = "Showing " + ((self.totalResults() - self.resultsPerPage()) + 1) + " to " + self.totalResults() + " of " + self.totalResults() + " results";
      }
      else if (self.requestedPage() > 0 && self.requestedPage() > 1) {
        self.start((((self.requestedPage() - 1) * self.resultsPerPage()) + 1));
        message =  "Showing " + (((self.requestedPage() - 1) * self.resultsPerPage()) + 1) + " to " +
        ((self.resultsPerPage() * self.requestedPage()) >= self.totalResults() ? self.totalResults() : (self.resultsPerPage() * self.requestedPage())) + " of " + self.totalResults() + " results";
      }
      return message;
    }
  });


  self.showPagination = ko.computed(function () {
    return self.totalResults() > 0
  }, this);

  self.next = function () {
    caller.refreshPage((self.requestedPage() + 1));
  };
  self.previous = function () {
    caller.refreshPage((self.requestedPage() == 1 ? self.requestedPage() : (self.requestedPage() - 1) ));
  };
  self.first = function () {
    caller.refreshPage(1);
  };
  self.last = function () {
    caller.refreshPage(Math.ceil((self.totalResults() / self.resultsPerPage())));
  };

  self.rppChanged = function() {
    caller.refreshPage(1);
  };

  self.refreshPage = function(rp){
    // Do nothing.
  };

  self.loadPagination = function(rp, total){
    self.requestedPage(rp);
    self.totalResults(total);
  };

};
