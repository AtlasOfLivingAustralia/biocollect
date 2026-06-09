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
  * Grails framework: 7.1.1
  * Java 17
  * Groovy 4
  * Gradle 8.14.4 (via the Gradle wrapper, `./gradlew`)
  * Knockout JS
  * jQuery
  * Bootstrap 5

### Prerequisites

* This project requires you to run the [ecodata project](https://github.com/AtlasOfLivingAustralia/ecodata) on port `8080`.

* An external configuration file is required at `/data/biocollect/config/biocollect-config.properties` (or as configured in `application.yml`). External configuration is built into Grails 7; no plugin is needed.

* BioCollect builds with its plugins in-place by default (`inplace=true` in `gradle.properties`). `settings.gradle` includes [ecodata-client-plugin](https://github.com/AtlasOfLivingAustralia/ecodata-client-plugin) and [ala-map-plugin](https://github.com/AtlasOfLivingAustralia/ala-map-plugin) as subprojects, so both repositories must be cloned into the same parent folder as BioCollect:

```
parent-folder/
├── biocollect/
├── ecodata-client-plugin/
└── ala-map-plugin/
```

* The ALA dependency stack (ala-auth, ala-ws-security-plugin, ala-ws-plugin, userdetails-service-client `8.0.0-SNAPSHOT`, ala-admin-plugin `3.0.0-SNAPSHOT`, ala-bootstrap5 `2.0.0-SNAPSHOT`, ala-cas-client `4.0.0-SNAPSHOT`) currently resolves from `mavenLocal()`. Until these snapshots are published to the ALA nexus, build each dependency from its `grails7` branch and install it locally with `./gradlew publishToMavenLocal`.

* [Use this guide to setup BioCollect in IntelliJ](setup.md)

### Running BioCollect

Everything runs through the Gradle wrapper (the legacy Grails wrapper has been removed). With the plugin repositories cloned as siblings, run:

```
./gradlew :bootRun -Dgrails.run.active=true
```

Note the leading colon before the `bootRun` task - this is required because with `inplace=true` (the default) Gradle is configured as a multi-project build. This mode supports hot-reloading of changes to the ecodata-client-plugin and ala-map-plugin.

To build against the published plugin artifacts instead of the sibling repositories, opt out of the in-place build:

```
./gradlew bootRun -Pinplace=false
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
