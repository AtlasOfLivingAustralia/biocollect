package au.org.ala.biocollect.au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import spock.lang.Specification

import java.time.Clock
import java.time.LocalDateTime
import java.time.OffsetDateTime
import java.time.Period
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime

/**
 * Tests for the DateUtils class.
 */
class DateUtilsSpec extends Specification {

    def cleanup() {
        DateUtils.clock = Clock.systemDefaultZone()
    }

    def "parsing supports ISO8601"() {

        when:
        def dateTime = DateUtils.parse("2014-02-01T00:00:00.000+00:00")

        then:
        dateTime.getYear() == 2014
        dateTime.getMonthValue() == 2
        dateTime.getDayOfMonth() == 1
        dateTime.getHour() == 0
    }

    def "parsing supports ISO8601 without milliseconds"() {
        when:
        def dateTime = DateUtils.parse("2014-02-01T00:00:00Z")

        then:
        dateTime.getYear() == 2014
        dateTime.getMonthValue() == 2
        dateTime.getDayOfMonth() == 1
        dateTime.getHour() == 0
    }

    def "parsing supports Java approximation of ISO8601"() {
        when:
        def dateTime = DateUtils.parse("2014-02-01T00:00:00+0000")

        then:
        dateTime.getYear() == 2014
        dateTime.getMonthValue() == 2
        dateTime.getDayOfMonth() == 1
        dateTime.getHour() == 0
    }

    def "dates are formatted in ISO8601 (without milliseconds)"() {
        when:
        def dateTime = OffsetDateTime.of(2014, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC)

        then:
        DateUtils.format(dateTime) == '2014-01-01T00:00:00Z'
    }

    def "#date aligns to a period correctly"(String date, period, year, month, day) {

        when:
        OffsetDateTime toAlign = DateUtils.parse(date)
        def result = DateUtils.alignToPeriod(toAlign, Period.ofMonths(period))

        then:
        result.getYear() == year
        result.getMonthValue() == month
        result.getDayOfMonth() == day

        where:
        date                   | period | year | month | day
        "2014-02-03T00:00:00Z" | 3      | 2014 | 1     | 1
        "2014-04-01T00:00:00Z" | 3      | 2014 | 4     | 1
        "2014-03-01T23:59:00Z" | 3      | 2014 | 1     | 1
        "2014-02-28T23:59:00Z" | 1      | 2014 | 2     | 1
        "2014-03-01T00:00:00Z" | 1      | 2014 | 3     | 1
    }

    def "zoned alignment keeps daylight-saving offsets through a six month period"() {
        given:
        ZoneId sydney = ZoneId.of('Australia/Sydney')
        ZonedDateTime toAlign = ZonedDateTime.of(2024, 8, 15, 12, 0, 0, 0, sydney)

        when:
        ZonedDateTime result = DateUtils.alignToPeriod(toAlign, Period.ofMonths(6))
        ZonedDateTime periodEnd = result.plus(Period.ofMonths(6))

        then:
        result.toLocalDateTime() == LocalDateTime.of(2024, 7, 1, 0, 0)
        result.offset == ZoneOffset.ofHours(10)
        periodEnd.toLocalDateTime() == LocalDateTime.of(2025, 1, 1, 0, 0)
        periodEnd.offset == ZoneOffset.ofHours(11)
        DateUtils.format(periodEnd.withZoneSameInstant(ZoneOffset.UTC).toOffsetDateTime()) == '2024-12-31T13:00:00Z'
    }

    def "dates can be grouped"() {

        setup:
        def data = ["2014-01-03T00:00:00Z", "2014-02-03T00:00:00Z", "2014-03-03T00:00:00Z", "2014-04-03T00:00:00Z"]

        when:
        def results = DateUtils.groupByDateRange(data, {it}, Period.ofMonths(1))

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
        def period = Period.ofMonths(1)
        when:
        def results = DateUtils.groupByDateRange(data, {it}, period, startDate)

        then:
        results.size() == 4
        results.values()[0] == ["2014-01-03T00:00:00Z"]
        results.values()[1] == ["2014-02-03T00:00:00Z"]
        results.values()[2] == ["2014-03-03T00:00:00Z"]
        results.values()[3] == ["2014-04-03T00:00:00Z"]
        results.containsKey(new DateUtils.DateRange(startDate, period))

    }

    def "the current financial year can be calculated from the current time"() {
        when: "The current date is the last day of the 2013/2014 financial year"
        DateUtils.clock = Clock.fixed(
                ZonedDateTime.of(2014, 6, 30, 23, 59, 0, 0, ZoneId.systemDefault()).toInstant(),
                ZoneId.systemDefault())

        then: "The year 2013 should be returned"
        DateUtils.currentFinancialYear() == 2013

        when: "The current date is the first day of the 2014/2015 financial year"
        DateUtils.clock = Clock.fixed(
                ZonedDateTime.of(2014, 7, 1, 0, 1, 0, 0, ZoneId.systemDefault()).toInstant(),
                ZoneId.systemDefault())

        then: "The year 2014 should be returned"
        DateUtils.currentFinancialYear() == 2014
    }

}
