class UrlMappings {

	static mappings = {
        name recent: "/recent"(controller: "sightings")
        name mine: "/mine"(controller: "sightings", action:"user")
        name spotter: "/spotter/$id"(controller: "sightings", action:"user")
        "/identify"(view:"/identify/identify")
        "/identify_fragment_nomap"(view:"/identify/identify_fragment_nomap")
        "/uploads/$file**"(controller:"sightingImage", action:"index")
        "/"(controller: "submitSighting", action:"index")
        "/$id**"(controller: "submitSighting", action:"index")
        "/edit/$id**"(controller: "submitSighting", action:"edit")
        "/edit/$id/$guid"(controller: "submitSighting", action:"edit")
//        "/$controller/$action?/$id?(.$format)?"{
//            constraints {
//                // apply constraints here
//            }
//        }

        // "/"(view:"/index")
        "500"(view:'/error')
	}
}
