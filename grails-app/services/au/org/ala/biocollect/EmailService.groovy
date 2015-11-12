package au.org.ala.biocollect

import au.org.ala.biocollect.merit.UserService
import grails.plugin.mail.MailService

/**
 * Sends email messages to notify interested parties of changes.
 */
class EmailService {

    MailService mailService
    UserService userService
    def grailsApplication

    def sendEmail(String subjectLine, String body, Collection recipients, Collection ccList = []) {
        String systemEmailAddress = grailsApplication.config.biocollect.system.email.address
        String sender = grailsApplication.config.biocollect.system.email.sender ?: systemEmailAddress
        try {
            // This is to prevent spamming real users while testing.
            String emailFilter = grailsApplication.config.emailFilter
            if (emailFilter) {
                if (!ccList instanceof Collection) {
                    ccList = [ccList]
                }

                recipients = recipients.findAll {it ==~ emailFilter}
                if (!recipients) {
                    // The email won't be sent unless we have a to address - use the submitting user since
                    // the purpose of this is testing.
                    recipients = [userService.getUser().userName]
                }

                ccList = ccList.findAll {it ==~ emailFilter}
            }
            log.info("Sending email: ${subjectLine} to: ${recipients}, cc:${ccList}, body: ${body}")

            mailService.sendMail {
                to recipients
                if (ccList) {cc ccList}
                from sender
                replyTo systemEmailAddress
                subject subjectLine
                html body

            }
        }
        catch (Exception e) {
            log.error("Failed to send email: ", e)
        }
    }

}
