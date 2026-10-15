BioCollect 
==========

## Build status

### Master branch
[![Build Status](https://github.com/AtlasOfLivingAustralia/biocollect/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/AtlasOfLivingAustralia/biocollect/actions)

### Develop branch
[![Build Status](https://github.com/AtlasOfLivingAustralia/biocollect/actions/workflows/build.yml/badge.svg?branch=develop)](https://github.com/AtlasOfLivingAustralia/biocollect/actions)

## About
This repo is a fork of the [fieldcapture-hubs repo](https://github.com/AtlasOfLivingAustralia/fieldcapture-hubs) where the plugin has been promoted to become the host app. From the moment of creation of this repo BioCollect and Merit will go separate ways.

The resulting project has been significantly refactored. All the MERIT inherited server side code base is now under the package name `au.org.ala.biocollect.merit`. It would be convenient to organically remove all the code that we won't be using in biocollect.

New server side classes that are custom to BioCollect should be under the package name `au.org.ala.biocollect`

## General Information

### Technologies
  * Grails framework: 8.0.0
  * Java 25
  * Groovy 5
  * Gradle 9.8.0 (via the Gradle wrapper, `./gradlew`)
  * Knockout JS
  * jQuery
  * Bootstrap 5

### Prerequisites

* This project requires you to run the [ecodata project](https://github.com/AtlasOfLivingAustralia/ecodata) on port `8080`.

* An external configuration file is required at `/data/biocollect/config/biocollect-config.properties` (or as configured in `application.yml`). External configuration is built into Grails; no plugin is needed.

* [Use this guide to setup BioCollect in IntelliJ](setup.md)

### Running BioCollect

Everything runs through the Gradle wrapper (the legacy Grails wrapper has been removed). `gradle.properties` sets `inplace=false`, so the default build uses the published plugin artifacts:

```
./gradlew bootRun
```

To develop against sibling checkouts of ecodata-client-plugin and ala-map-plugin, enable the in-place build. The leading colon is required because Gradle is then a multi-project build:

```
./gradlew :bootRun -Pinplace=true
```

BioCollect runs on port `8087` in development mode by default.

### Running Javascript automatic tests
* Executing the tests requires node.js
* It is recommended to install the Intellij node.js and karma plugins.
* To install the test dependencies, run the following command in the repo root folder:
```
  npm install
```
* After that you can run the test directly from Intellij by right-clicking on the `karma.conf.js` file, or from the command line:
```
  node_modules/karma/bin/karma start karma.conf.js --single-run --browsers ChromeHeadless
```
