/*
 * Copyright (C) 2013 Atlas of Living Australia
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

package au.org.ala.biocollect.merit

/**
 * Enum class for static content (Setting Page)
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
enum SettingPageType {
    TITLE ("title", "Title", "fielddata.title.text"),
    ABOUT ("about","About","fielddata.about.text"),
    DESCRIPTION ("description","Description","fielddata.description.text"),
    FOOTER ("footer","Footer","fielddata.footer.text"),
    ANNOUNCEMENT ("announcement","Announcement","fielddata.announcement.text"),
    HELP ("help","Help","fielddata.help.text"),
    NEWS ("news","News","fielddata.news.text"),
    CONTACTS ("contacts","Contacts","fielddata.contacts.text"),
    INTRO ("intro","User Introduction","fielddata.introduction.text"),
    DECLARATION ('declaration', "Legal Declaration", "fielddata.declaration.text"),
    REPORT_SUBMITTED_EMAIL('reportSubmitted', 'Report has been submitted email body text', 'fielddata.reportSubmitted.emailText'),
    REPORT_APPROVED_EMAIL('reportApproved', 'Report has been approved email body text', 'fielddata.reportApproved.emailText'),
    REPORT_REJECTED_EMAIL('reportRejected', 'Report has been rejected email body text', 'fielddata.reportRejected.emailText'),
    REPORT_SUBMITTED_EMAIL_SUBJECT_LINE('reportSubmittedSubject', 'Subject line for the \'Report has been submitted\' email', 'fielddata.reportSubmitted.emailSubject'),
    REPORT_APPROVED_EMAIL_SUBJECT_LINE('reportApprovedSubject', 'Subject line for the \'Report has been approved\' email', 'fielddata.reportApproved.emailSubject'),
    REPORT_REJECTED_EMAIL_SUBJECT_LINE('reportRejectedSubject', 'Subject line for the \'Report has been rejected\' email', 'fielddata.reportRejected.emailSubject'),
    PLAN_SUBMITTED_EMAIL('planSubmitted', 'Project plan has been submitted email body text', 'fielddata.planSubmitted.emailText'),
    PLAN_APPROVED_EMAIL('planApproved', 'Project plan has been approved email body text', 'fielddata.planApproved.emailText'),
    PLAN_REJECTED_EMAIL('planRejected', 'Project plan has been rejected email body text', 'fielddata.planRejected.emailText'),
    PLAN_SUBMITTED_EMAIL_SUBJECT_LINE('planSubmittedSubject', 'Subject line for the \'Project plan has been submitted\' email', 'fielddata.planSubmitted.emailSubject'),
    PLAN_APPROVED_EMAIL_SUBJECT_LINE('planApprovedSubject', 'Subject line for the \'Project plan has been approved\' email', 'fielddata.planApproved.emailSubject'),
    PLAN_REJECTED_EMAIL_SUBJECT_LINE('planRejectedSubject', 'Subject line for the \'Project plan has been rejected\' email', 'fielddata.planRejected.emailSubject'), 
    GREEN_ARMY_REPORT_SUBMITTED_EMAIL('greenArmyReportSubmitted', 'Report has been submitted email body text', 'fielddata.greenArmyReportSubmitted.emailText'),
    GREEN_ARMY_REPORT_APPROVED_EMAIL('greenArmyReportApproved', 'Report has been approved email body text', 'fielddata.greenArmyReportApproved.emailText'),
    GREEN_ARMY_REPORT_REJECTED_EMAIL('greenArmyReportRejected', 'Report has been rejected email body text', 'fielddata.greenArmyReportRejected.emailText'),
    GREEN_ARMY_REPORT_SUBMITTED_EMAIL_SUBJECT_LINE('greenArmyReportSubmittedSubject', 'Subject line for the \'Report has been submitted\' email', 'fielddata.greenArmyReportSubmitted.emailSubject'),
    GREEN_ARMY_REPORT_APPROVED_EMAIL_SUBJECT_LINE('greenArmyReportApprovedSubject', 'Subject line for the \'Report has been approved\' email', 'fielddata.greenArmyReportApproved.emailSubject'),
    GREEN_ARMY_REPORT_REJECTED_EMAIL_SUBJECT_LINE('greenArmyReportRejectedSubject', 'Subject line for the \'Report has been rejected\' email', 'fielddata.greenArmyReportRejected.emailSubject'),
    THIRD_PARTY_PHOTO_CONSENT_DECLARATION('thirdPartyPhotoConsent', 'Declaration text for consent from third parties who appear in images', 'fielddata.thirdPartyConsent.text'),
    NEW_CITIZEN_SCIENCE_PROJECT_INTRO('newCitizenScienceProjectIntro', 'Introductory text following the creation of a new Citizen Science Project', 'fielddata.citizenScience.newProjectIntro'),
    CITIZEN_SCIENCE_GETTING_STARTED('citizenScienceGettingStarted', 'How to use project finder?', 'fielddata.citizenScience.gettingStarted'),
    CITIZEN_SCIENCE_WHAT_IS_THIS('citizenScienceWhatIsThis', 'What is project finder?', 'fielddata.citizenScience.whatIsThis'),
    ORGANISATION_LIST_PAGE_HEADER('organisationListHeader', 'Header content for the organisation list page', 'fielddata.organisationListHeader'),
    SURVEY_METHODS("surveyMethods", "Survey methods listed here will be used to generate content of drop-down in project activity. Use comma to separate entries. Make sure you enter data from default hub's (ala) settings page.", "fielddata.survey.methods"),
    SURVEY_SPECIES_ALL("surveySpeciesAll", "Descriptive text for the 'all species' option on the Survey configuration's Species tab", "fielddata.survey.species.all"),
    SURVEY_SPECIES_SINGLE("surveySpeciesSingle", "Descriptive text for the 'single species' option on the Survey configuration's Species dialog", "fielddata.survey.species.single"),
    SURVEY_SPECIES_GROUP("surveySpeciesGroup", "Descriptive text for the 'selection or group' option on the Survey configuration's Species dialog", "fielddata.survey.species.group"),
    SURVEY_DEFAULT("surveySpeciesDefault", "Descriptive text for the 'selection or default' option on the Survey configuration's Species dialog", "fielddata.survey.species.default"),
    WORKS_SCHEDULE_INTRO("worksScheduleIntro", "How does work schedule function?", "fielddata.works.scheduleIntro")

    String name
    String title
    String key

    public SettingPageType(name, title, key) {
        this.name = name
        this.title = title
        this.key = key
    }

    public static SettingPageType getForName(String name) {
        for(SettingPageType s : values()){
            if (s.name == name){
                return s
            }
        }
    }

    public static SettingPageType getForKey(String key) {
        for(SettingPageType s : values()){
            if (s.key == key){
                return s
            }
        }
    }
}
