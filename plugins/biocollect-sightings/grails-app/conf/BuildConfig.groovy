grails.servlet.version = "3.0" /*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */ // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.work.dir = "target/work"
grails.project.target.level = 1.7
grails.project.source.level = 1.7
//grails.project.war.file = "target/${appName}-${appVersion}.war"

grails.project.fork = [
        run: false,
        test: false
]

grails.project.dependency.resolver = "maven" // or ivy
grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // specify dependency exclusions here; for example, uncomment this to disable ehcache:
        // excludes 'ehcache'
    }
    log "error" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve
    legacyResolve false // whether to do a secondary resolve on plugin installation, not advised and here for backwards compatibility

    repositories {
        mavenLocal()
        mavenRepo "http://nexus.ala.org.au/content/groups/public/"
    }

    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes e.g.
        compile 'org.apache.tika:tika-core:1.6'
        compile "com.drewnoakes:metadata-extractor:2.6.2"
        compile "org.imgscalr:imgscalr-lib:4.2"
        compile 'joda-time:joda-time:2.3'
    }

    plugins {
        // plugins for the build system only
        build ":tomcat:7.0.55.2"
        build (":release:3.1.1", ":rest-client-builder:2.1.1") {
            export = false
        }
        compile ':cache:1.1.8'
        compile ":cache-headers:1.1.7"
        compile ":mail:1.0.7"
        runtime ":jquery:1.11.1"
        runtime ":resources:1.2.14"
        runtime ":ala-auth:1.3.1"
        runtime ":ala-bootstrap2:2.2"
    }
}
