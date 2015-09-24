package au.org.ala.biocollect.sightings

import grails.converters.JSON
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
import org.joda.time.format.DateTimeFormatter

import java.text.SimpleDateFormat

class SightingTagLib {
    //static defaultEncodeAs = [taglib:'html']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    static namespace = "si"

    def generateBiocacheLink = { attrs ->

        def baseUrl = "${grailsApplication.config.biocache.baseURL}/occurrences/search?q=*:*&fq=("

        //add stuff
        attrs.dataResourceUids.eachWithIndex { uid, idx ->
            if(idx > 0){
                baseUrl += " OR "
            }
            baseUrl += "data_resource_uid:${uid}"
        }
        baseUrl += ")"

        if(attrs.userId){
            baseUrl += "&fq=alau_user_id:${attrs.userId}"
        }

        out << baseUrl
    }

    /**
     * Get the hours or minutes part of the input date (or current date)
     *
     * @attr date REQUIRED - java.util.Date
     * @attr part REQUIRED - java.util.Calendar int field (HOUR or MINUTE)
     */
    def getDateTimeValue = { attrs ->
        def inputDate = attrs.date
        def part = attrs.part

        if (!inputDate) {
            inputDate = new Date()
        } else if (inputDate instanceof String && inputDate.length() > 18) {
            //DateTimeFormatter formatter = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ssZ");
            DateTimeFormatter formatter = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ss");
            DateTime dt = formatter.parseDateTime(inputDate.substring(0,19));
            inputDate = dt.toDate()
        }

        def output

        if (part == Calendar.HOUR) {
            SimpleDateFormat hourFormat = new SimpleDateFormat("HH");
            output = hourFormat.format(inputDate)
        } else if (part == Calendar.MINUTE) {
            SimpleDateFormat minFormat = new SimpleDateFormat("mm");
            output = minFormat.format(inputDate)
        } else if (part == "time" && attrs.date) {
            SimpleDateFormat minFormat = new SimpleDateFormat("HH:mm");
            output = minFormat.format(inputDate)
        } else if (part == "date" && attrs.date) {
            SimpleDateFormat minFormat = new SimpleDateFormat("dd-MM-yyyy");
            output = minFormat.format(inputDate)
        }

        out << output
    }

    /**
     * Get a List of tags for both record tags and any higher taxa names
     * and output as a JSON list
     *
     * @attr sighting REQUIRED
     */
    def getTags = { attrs ->
        def sighting = attrs.sighting
        def tags = []
        def fields = ["tags", "kingdom", "family"]

        fields.each {
            if (sighting.has(it)) {
                tags.addAll(sighting.get(it))
            }
        }

        out << (tags as JSON).toString()
    }
    /**
     * Add CSS class attribute to rendered datepicker select inputs
     *
     *
     */
    def customDatePicker = {attrs, body ->
        def unstyled = g.datePicker(attrs, body)
        def sizes = [day: 1, month: 2, year:1]
        def cssClass = attrs.class
        def styled = unstyled.replaceAll('name="\\S+_(day|month|year)"') { match, timeUnit ->
            //println match
            "${match} class=\"${cssClass}\""
        }
        out << styled
    }
}
