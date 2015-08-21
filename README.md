Biocollect [![Travis Build](https://travis-ci.org/AtlasOfLivingAustralia/biocollect.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/biocollect)
==========

## About
This repo is a fork of the [fieldcapture-hubs repo](https://github.com/AtlasOfLivingAustralia/fieldcapture-hubs) where the plugin has been promoted to become the host app. From the moment of creation of this repo Biocollect and Merit will go separate ways.

The resulting project has been significantly refactored. All the MERIT inherited server side code base is now under the package name `au.org.ala.biocollect.merit`. It would be convenient to organically remove all the code that we won't be using in biocollect.

New server side classes that are custom to Biocollect should be under the package name `au.org.ala.biocollect`

### Sightings plugin
In an effort to integrate the pigeonhole sightings functionality into biocollect, a embedded Grails plugin has been implemented that contains refactored code from the [pigeonhole project](https://github.com/AtlasOfLivingAustralia/pigeonhole) to work with Bootstrap 2 and resolve other library conflicts with the host app.

The plugin can be found in this repo in the following directory:
```
  ./plugins/biocollect-sightings/
```

The only bit of functionality that is partly functional at the moment is the sightings submission page. ATM this can be access in url: `http://<host>:<port>/biocollect/ala/submitSighting`

The reason for having it in a plugin for the time being are the following:
* Avoid conflicts in web client side resources (css, js, ...)
* We need to identify the piece of functionality and code base associated that we really need to reuse.
* In the future we might think we are better of using the sighting functionality as a service though the pigeonhole project and removing a plugin dependency is trivial.

Once we know what we need, we might be able to promote the code base to the biocollect host app. Meanwhile the current arrangement should be enough to get by.

## General Information

### Technologies
  * Grails framework: 2.4.5
  * TODO

### Setup
* This project requires you to run the [ecodata project](https://github.com/AtlasOfLivingAustralia/ecodata) on port `8080`.
* You will need the following local directories:
```
  /data/biocollect/config
  /data/biocollect/images
```
* Add the external config file.
* The app is expected to run in port 8087 locally. Just add the option `-Dserver.port=8087` to the run-app command:
![Imgur](http://i.imgur.com/syIKPgy.png)

### Running Javascript automatic Âtests
* Executing the tests requires node.js
* It is recommended to install the Intellij node.js and karma plugins.
* To install the test dependencies, run the following command in the repo root folder:
```
  npm install
```
* After that you can run the test directly from Intellij by right-clicking on the `karma.conf.js` file.
