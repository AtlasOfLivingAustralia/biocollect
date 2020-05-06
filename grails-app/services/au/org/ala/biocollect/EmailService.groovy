package au.org.ala.biocollect

import au.org.ala.biocollect.merit.UserService
import grails.plugins.mail.MailService

/**
 * Sends email messages to notify interested parties of changes.
 */
class EmailService {

    MailService mailService
    UserService userService
    def grailsApplication

    def sendEmail(String subjectLine, String body, Collection recipients, Collection ccList = [], String replyAddress = null, String senderEmail = null, Collection bccList = []) {
        replyAddress = replyAddress ?: grailsApplication.config.biocollect.system.email.address
        String sender = (senderEmail ?: grailsApplication.config.biocollect.system.email.sender) ?: replyAddress

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
                bccList = bccList.findAll {it ==~ emailFilter}
            }
            log.info("Sending email: ${subjectLine} to: ${recipients}, cc:${ccList}, body: ${body}")

            mailService.sendMail {
                async true
                if (recipients) {to recipients}
                if (ccList) {cc ccList}
                if (bccList) {bcc bccList}
                from sender
                replyTo replyAddress
                subject subjectLine
                html body

            }
            [ success: true, message: "Successfully sent email."]
        }
        catch (Exception e) {
            log.error("Failed to send email: ", e)
            [ success: false, message: e.message]
        }
    }

}
