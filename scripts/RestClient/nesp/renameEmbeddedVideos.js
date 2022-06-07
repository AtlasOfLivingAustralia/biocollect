print("Start replacing...");

db.document.find({role:"embeddedVideo"}).forEach(function(e) {
    if (e.embeddedVideo) {
        const youtube = "https://youtu.be/";
        const youtubecom = "https://www.youtube.com/"
        const vimeo = "https://vimeo.com/";

        if (e.embeddedVideo.includes(vimeo))
        {
            e.embeddedVideo = e.embeddedVideo.replace("vimeo.com", "player.vimeo.com/video");
            db.document.save(e);
            print("Replaced vimeo in document id: " + e.documentId)
        }
        else if (e.embeddedVideo.includes(youtube))
        {
            e.embeddedVideo = e.embeddedVideo.replace("https://youtu.be", "https://www.youtube.com/embed");
            db.document.save(e);
            print("Replaced youtube in document id: " + e.documentId)
        }
        else if (e.embeddedVideo.includes(youtubecom))
        {
            e.embeddedVideo = e.embeddedVideo.replace("watch?v=", "embed/");
            db.document.save(e);
            print("Replaced youtube in document id: " + e.documentId)
        }
    }
})

print("End replacing");