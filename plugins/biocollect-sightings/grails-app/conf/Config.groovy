/*
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
 */
grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination

// bootstrap 3
grails.plugins.twitterbootstrap.fixtaglib = true

// log4j configuration
log4j = {
// Example of changing the log pattern for the default console
// appender:
       appenders {
              environments {
                     production {
                            rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "${loggingDir}/${appName}.log", threshold: org.apache.log4j.Level.ERROR, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
                     }
                     development {
                            console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n"), threshold: org.apache.log4j.Level.DEBUG
                     }
                     test {
                            rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "/tmp/${appName}", threshold: org.apache.log4j.Level.DEBUG, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
                     }
              }
       }
       root {
              // change the root logger to my tomcatLog file
              error 'tomcatLog'
              warn 'tomcatLog'
              additivity = true
       }

       error   'au.org.ala.cas.client',
               'grails.spring.BeanBuilder',
               'grails.plugin.webxml',
               'grails.plugin.cache.web.filter',
               'grails.app.services.org.grails.plugin.resource',
               'grails.app.taglib.org.grails.plugin.resource',
               'grails.app.resourceMappers.org.grails.plugin.resource'

       debug   'grails.app'
}