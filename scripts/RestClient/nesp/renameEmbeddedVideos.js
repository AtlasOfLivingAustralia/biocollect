print("Start replacing...");

var counter = 0

db.document.find({role:"embeddedVideo"}).forEach(function(e) {
    var projectId = e.projectId
    var project = null

    if (projectId != undefined) {
        project = db.project.findOne({projectId: projectId})
    }

    if (project != null)
    {
        var associatedProgram = project.associatedProgram

        if ((associatedProgram != undefined) && (associatedProgram != null) ) {
            if (associatedProgram.includes("NESP 1") || associatedProgram.includes("NESP 2")) {
                if (e.embeddedVideo) {
                    const youtube = "https://youtu.be/";
                    const youtubecom = "https://www.youtube.com/watch?v="
                    const vimeo = "https://vimeo.com/";

                    if (e.embeddedVideo.includes(vimeo)) {
                        e.embeddedVideo = e.embeddedVideo.replace("vimeo.com", "player.vimeo.com/video");
                        db.document.save(e);

                        print("Project Id: " + projectId)
                        print("Associated Program: " + associatedProgram)
                        print("Replaced vimeo in document id: " + e.documentId)

                        counter++
                    } else if (e.embeddedVideo.includes(youtube)) {
                        e.embeddedVideo = e.embeddedVideo.replace("https://youtu.be", "https://www.youtube.com/embed");
                        db.document.save(e);

                        print("Project Id: " + projectId)
                        print("Associated Program: " + associatedProgram)
                        print("Replaced youtube in document id: " + e.documentId)

                        counter++
                    } else if (e.embeddedVideo.includes(youtubecom)) {
                        e.embeddedVideo = e.embeddedVideo.replace("watch?v=", "embed/");
                        db.document.save(e);

                        print("Project Id: " + projectId)
                        print("Associated Program: " + associatedProgram)
                        print("Replaced youtube in document id: " + e.documentId)

                        counter++
                    }
                }
            }
        }
    }
})


print("Total douments replaced: " + counter);
print("End replacing.");
