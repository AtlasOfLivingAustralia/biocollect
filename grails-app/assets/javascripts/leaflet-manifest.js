// leaflet
// Application copy of Leaflet 1.9.4 at leaflet/leaflet.js. images-client-plugin
// publishes Leaflet 0.7.3 at that same path, and asset-pipeline was selecting it.
// leaflet-geoman then throws while the activity map is created, so the site
// select2 never appears.
// require leaflet-0.7.7/leaflet.js

// from image-client-plugin
//= require leaflet/leaflet.measure.js
//= require leaflet/Control.FullScreen

// from ala-map-plugin
//= require ala-map-no-jquery-us-no-handlebars   //without jquery 2

//= require MapUtilities.js
//= require siteDisplay.js

// from biocollect
//= require leaflet-plugins-2.0.0/layer/tile/Google.js
