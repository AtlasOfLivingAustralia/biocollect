package au.org.ala.biocollect.merit

import grails.testing.web.controllers.ControllerUnitTest
import org.apache.poi.ss.usermodel.Sheet
import org.apache.poi.ss.usermodel.Workbook
import org.apache.poi.ss.usermodel.WorkbookFactory
import spock.lang.Specification

/*
 * Copyright (C) 2022 Atlas of Living Australia
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
 *
 * Created by Temi on 25/5/22.
 */

class ReportControllerSpec extends Specification implements ControllerUnitTest<ReportController> {
    def setup() {
        controller.grailsApplication.config.report.download = [
                [header  : 'Group',
                 property: 'group'],
                [header  : 'Count',
                 property: 'count']
        ]
    }

    void "should export report into an excel sheet"(){
        given:
        File file = File.createTempFile('test', '.xlsx')
        String body = '{"sheet 1": [{"count": 88,"group": "group 1"}],"sheet 2": [{"count": 88,"group": "group 4"}]}'
        request.method = "POST"
        request.JSON = body

        when:
        controller.downloadReport()
        file.append(response.getContentAsByteArray())
        Workbook workbook = WorkbookFactory.create(file)

        then:
        workbook.numberOfSheets == 2
        Sheet paSheet1 = workbook.getSheet('sheet 1')
        paSheet1.physicalNumberOfRows == 2
        Sheet paSheet2 = workbook.getSheet('sheet 2')
        paSheet2.physicalNumberOfRows == 2
        file.delete()
    }
}
