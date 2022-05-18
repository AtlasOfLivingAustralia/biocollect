BioCollect 
==========

## Build status

### Master branch
[![Travis Build](https://travis-ci.org/AtlasOfLivingAustralia/biocollect.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/biocollect)

### Develop branch
[![Travis Build](https://travis-ci.org/AtlasOfLivingAustralia/biocollect.svg?branch=develop)](https://travis-ci.org/AtlasOfLivingAustralia/biocollect)

## About
This repo is a fork of the [fieldcapture-hubs repo](https://github.com/AtlasOfLivingAustralia/fieldcapture-hubs) where the plugin has been promoted to become the host app. From the moment of creation of this repo BioCollect and Merit will go separate ways.

The resulting project has been significantly refactored. All the MERIT inherited server side code base is now under the package name `au.org.ala.biocollect.merit`. It would be convenient to organically remove all the code that we won't be using in biocollect.

New server side classes that are custom to BioCollect should be under the package name `au.org.ala.biocollect`

## General Information

### Technologies
  * Grails framework: 5.1.2
  * Java 8
  * Knockout JS
  * JQuery 3.4.1
  * Gradle
  

### Development Setup

* This project requires you to run the [ecodata project](https://github.com/AtlasOfLivingAustralia/ecodata) on port `8080`.

* [Use this guide to setup Biocollect in Intellij](setup.md)


### Running Grails4 version
Run BioCollect:
```
./gradlew bootRun
```

To run BioCollect with support for hot-reloading of changes to the ecodata-client-plugin & ala-map-plugin, clone the ecodata-client-plugin & ala-map-plugin repositories into the same parent folder as the BioCollect project.
Run BioCollect with additional parameters:
```
./gradlew :bootRun -Dgrails.run.active=true -Pinplace=true
```

Note the leading colon before the bootRun task - this is required as when inplace=true gradle is configured in a multi-project build configuration.


### Running Javascript automatic tests
* Executing the tests requires node.js
* It is recommended to install the Intellij node.js and karma plugins.
* To install the test dependencies, run the following command in the repo root folder:
```
  npm install
```
* After that you can run the test directly from Intellij by right-clicking on the `karma.conf.js` file.
