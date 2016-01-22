function AudioViewModel(config, files) {
    var self = this;

    var recorder = null;

    self.transients = {};
    self.transients.recording = ko.observable(false);
    self.files = ko.observableArray();

    if (!_.isUndefined(files) && !_.isEmpty(files)) {
        files.forEach(function (file) {
            if (_.isUndefined(file.url)) {
                file.url = config.downloadUrl + file.filename;
            }
            self.files.push(new AudioItem(file));
        });
    }

    self.transients.html5AudioSupport = ko.pureComputed(function () {
        var supported = false;
        if (Modernizr.getusermedia) {
            supported = true;
        }

        // Chrome only allows html 5 media support under secure origins, so make sure we are using HTTPS in Chrome
        // (this check is mostly to prevent JS errors on local dev machines, since prod will be running under https)
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        var isHttps = window.location.protocol == "https";
        if (isChrome && !isHttps) {
            supported = false;
        }

        return false && supported; // audio recording implementation is incomplete...disable until it's finished
    });

    // incomplete: see
    // - http://audior.ec/blog/recording-mp3-using-only-html5-and-javascript-recordmp3-js/
    // - http://obem.be/2015/03/23/experiments-recording-audio-in-browser.html
    self.startRecording = function () {
        if (_.isUndefined(recorder) || recorder == null) {
            window.AudioContext = window.AudioContext || window.webkitAudioContext;
            navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia);
            var audioContext = new AudioContext;

            navigator.getUserMedia({audio: true}, function (mediaStream) {
                var input = audioContext.createMediaStreamSource(mediaStream);
                recorder = new Recorder(input, {
                    numChannels: 1
                });

                record();
            }, function (error) {
                console.error(error);
            });
        } else {
            record();
        }
    };

    self.stopRecording = function () {
        if (recorder != null) {
            recorder.stop();
            recorder.exportWAV(doneEncoding);
        }
        self.transients.recording(false);
    };

    self.remove = function (data) {
        if (data.documentId) {
            // change status when image is already in ecodata
            data.status('deleted')
        } else {
            self.files.remove(data);
        }
    };

    self.toJSON = function() {
        return ko.mapping.toJS(self.files);
    };

    function doneEncoding(blob) {
        Recorder.forceDownload(blob, "myRecording.wav");
    }

    function record() {
        recorder.clear();
        recorder.record();
        self.transients.recording(true);
    }
}

function AudioItem(audio) {
    var self = this;

    var sanitizedName = audio.name.replace(/[^a-zA-Z0-9]/g, "");
    self.documentId = ko.observable(audio.documentId || '');
    self.activityId = ko.observable(audio.activityId || '');
    self.id = ko.observable(sanitizedName);
    self.url = ko.observable(audio.url);

    self.contentType = ko.observable(audio.contentType);
    self.filename = ko.observable(audio.name);
    self.name = ko.observable(audio.name);
    self.filesize = ko.observable(audio.filesize);
    self.formattedSize = ko.pureComputed(function () {
        return formatBytes(audio.filesize);
    });
    self.status = ko.observable(audio.status || "active");
    self.staged = ko.observable(true);
    self.attribution = ko.observable(audio.attribution);
    self.notes = ko.observable(audio.notes);

    self.transients = {};
    self.transients.downloadUrl = ko.pureComputed(function() {
        return audio.url + "&forceDownload=true"
    });

    self.toJSON = function() {
        var js = ko.mapping.toJS(self);
        delete js.transients;

        return js;
    };
}