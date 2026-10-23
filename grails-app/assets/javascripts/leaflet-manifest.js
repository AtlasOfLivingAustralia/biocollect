// leaflet
// ala-map-plugin is on the assets classpath ahead of images-client-plugin, so
// asset-pipeline registers its Leaflet 1.9.4 instead of Leaflet 0.7.3.
// leaflet-geoman throws while the activity map is created if 0.7.3 is selected,
// so the site select2 never appears.
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
