package au.org.ala.biocollect.au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import org.joda.time.DateTime
import org.joda.time.DateTimeUtils
import org.joda.time.DateTimeZone
import org.joda.time.Interval
import org.joda.time.Period
import spock.lang.Specification

/**
 * Tests for the DateUtils class.
 */
class DateUtilsSpec extends Specification {

    def cleanup() {
        DateTimeUtils.setCurrentMillisSystem()
    }

    def "parsing supports ISO8601"() {

        when:
        def dateTime = DateUtils.parse("2014-02-01T00:00:00.000+00:00")

        then:
        dateTime.getYear() == 2014
        dateTime.getMonthOfYear() == 2
        dateTime.getDayOfMonth() == 1
        dateTime.getHourOfDay() == 0
    }

    def "parsing supports ISO8601 without milliseconds"() {
        when:
        def dateTime = DateUtils.parse("2014-02-01T00:00:00Z")

        then:
        dateTime.getYear() == 2014
        dateTime.getMonthOfYear() == 2
        dateTime.getDayOfMonth() == 1
        dateTime.getHourOfDay() == 0
    }

    def "parsing supports Java approximation of ISO8601"() {
        when:
        def dateTime = DateUtils.parse("2014-02-01T00:00:00+0000")

        then:
        dateTime.getYear() == 2014
        dateTime.getMonthOfYear() == 2
        dateTime.getDayOfMonth() == 1
        dateTime.getHourOfDay() == 0
    }

    def "dates are formatted in ISO8601 (without milliseconds)"() {
        when:
        def dateTime = new DateTime(2014, 1, 1, 0, 0, 0, DateTimeZone.UTC)

        then:
        DateUtils.format(dateTime) == '2014-01-01T00:00:00Z'
    }

    def "#date aligns to a period correctly"(String date, period, year, month, day) {

        when:
        DateTime toAlign = DateUtils.parse(date)
        def result = DateUtils.alignToPeriod(toAlign, Period.months(period))

        then:
        result.getYear() == year
        result.getMonthOfYear() == month
        result.getDayOfMonth() == day

        where:
        date                   | period | year | month | day
        "2014-02-03T00:00:00Z" | 3      | 2014 | 1     | 1
        "2014-04-01T00:00:00Z" | 3      | 2014 | 4     | 1
        "2014-03-01T23:59:00Z" | 3      | 2014 | 1     | 1
        "2014-02-28T23:59:00Z" | 1      | 2014 | 2     | 1
        "2014-03-01T00:00:00Z" | 1      | 2014 | 3     | 1
    }

    def "dates can be grouped"() {

        setup:
        def data = ["2014-01-03T00:00:00Z", "2014-02-03T00:00:00Z", "2014-03-03T00:00:00Z", "2014-04-03T00:00:00Z"]

        when:
        def results = DateUtils.groupByDateRange(data, {it}, Period.months(1))

        then:
        results.size() == 4
        results.values()[0] == ["2014-01-03T00:00:00Z"]
        results.values()[1] == ["2014-02-03T00:00:00Z"]
        results.values()[2] == ["2014-03-03T00:00:00Z"]
        results.values()[3] == ["2014-04-03T00:00:00Z"]

    }

    def "dates can be grouped when a start date is specified"() {

        setup:
        def data = ["2014-01-03T00:00:00Z", "2014-02-03T00:00:00Z", "2014-03-03T00:00:00Z", "2014-04-03T00:00:00Z"]
        def startDate = DateUtils.parse("2014-01-01T00:00:00Z")
        def period = Period.months(1)
        when:
        def results = DateUtils.groupByDateRange(data, {it}, period, startDate)

        then:
        results.size() == 4
        results.values()[0] == ["2014-01-03T00:00:00Z"]
        results.values()[1] == ["2014-02-03T00:00:00Z"]
        results.values()[2] == ["2014-03-03T00:00:00Z"]
        results.values()[3] == ["2014-04-03T00:00:00Z"]
        results.containsKey(new Interval(startDate, period))

    }

    def "the current financial year can be calculated from the current time"() {
        when: "The current date is the last day of the 2013/2014 financial year"
        DateTime date = new DateTime(2014, 06, 30, 23, 59)
        DateTimeUtils.setCurrentMillisFixed(date.getMillis())

        then: "The year 2013 should be returned"
        DateUtils.currentFinancialYear() == 2013

        when: "The current date is the first day of the 2014/2015 financial year"
        date = new DateTime(2014, 07, 01, 0, 1)
        DateTimeUtils.setCurrentMillisFixed(date.getMillis())

        then: "The year 2014 should be returned"
        DateUtils.currentFinancialYear() == 2014
    }

}
