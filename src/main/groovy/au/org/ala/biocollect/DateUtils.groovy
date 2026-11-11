package au.org.ala.biocollect

import groovy.transform.EqualsAndHashCode

import java.time.Clock
import java.time.LocalDate
import java.time.OffsetDateTime
import java.time.Period
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeFormatterBuilder
import java.time.temporal.ChronoField
import java.time.temporal.ChronoUnit

/**
 * Utilities for working with fieldcapture / ecodata ISO8601 dates.
 */
class DateUtils {

    static Clock clock = Clock.systemDefaultZone()

    /** Fieldcapture / Ecodata work with ISO8601 formatted dates */
    private static DateTimeFormatter ISO_PARSER = new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd'T'HH:mm:ss")
            .optionalStart()
            .appendFraction(ChronoField.NANO_OF_SECOND, 1, 9, true)
            .optionalEnd()
            .optionalStart()
            .appendOffsetId()
            .optionalEnd()
            .toFormatter()
            .withZone(ZoneOffset.UTC)
    private static DateTimeFormatter JAVA_OFFSET_PARSER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssXX")
            .withZone(ZoneOffset.UTC)
    private static DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssXXX")
    private static DateTimeFormatter DISPLAY_DATE_FORMATTER = DateTimeFormatter.ofPattern("dd-MM-yyyy")
            .withZone(ZoneId.systemDefault())
    private static DateTimeFormatter DISPLAY_DATE_FORMATTER_WITH_TIME = DateTimeFormatter.ofPattern("dd-MM-yyyy h:mm:ss a")
            .withZone(ZoneId.systemDefault())
    private static DateTimeFormatter DISPLAY_DATE_FORMATTER_WITH_TIME_NOSPACE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss")
            .withZone(ZoneId.systemDefault())
    private static DateTimeFormatter MONTH_ONLY_FORMATTER = DateTimeFormatter.ofPattern("MMMM yyyy")
            .withZone(ZoneId.systemDefault())

    /**
     * A half-open date range [start, end) used to group records.
     */
    @EqualsAndHashCode
    static class DateRange {
        final OffsetDateTime start
        final OffsetDateTime end

        DateRange(OffsetDateTime start, Period period) {
            this.start = start
            this.end = start.plus(period)
        }

        DateRange(OffsetDateTime start, OffsetDateTime end) {
            this.start = start
            this.end = end
        }

        boolean isBefore(OffsetDateTime instant) {
            return !end.isAfter(instant)
        }

        boolean contains(OffsetDateTime instant) {
            return instant != null && !instant.isBefore(start) && instant.isBefore(end)
        }
    }

    /**
     * Aligns the supplied date to the start of the calendar period it falls into.
     * For example, 03/1/2014 aligned to a 3 month period falls into January-March, so
     * 01/01/2014 is returned. A fixed offset is retained.
     */
    static OffsetDateTime alignToPeriod(OffsetDateTime toAlign, Period period) {
        return alignToPeriod(toAlign.toZonedDateTime(), period).toOffsetDateTime()
    }

    /**
     * Aligns {@code toAlign} to the start of its calendar period and keeps {@code toAlign}'s zone,
     * so later {@code plus(period)} calls follow that zone's daylight-saving rules.
     */
    static ZonedDateTime alignToPeriod(ZonedDateTime toAlign, Period period) {
        ZonedDateTime periodStart = toAlign
                .withMonth(1)
                .withDayOfMonth(1)
                .withHour(0)
                .withMinute(0)
                .withSecond(0)
                .withNano(0)

        ZonedDateTime intervalStart = periodStart
        ZonedDateTime intervalEnd = intervalStart.plus(period)
        while (!intervalEnd.isAfter(toAlign)) {
            intervalStart = intervalEnd
            intervalEnd = intervalStart.plus(period)
        }
        return intervalStart
    }

    /**
     * Parses a String formatted as approximately ISO8601. The Java time zone offset format of +0000 is supported
     * as well as the ISO8601 +00:00 form.
     *
     * @param dateString the string to parse.
     * @return an {@link OffsetDateTime} in UTC, or null when the input is empty.
     */
    static OffsetDateTime parse(String dateString) {
        if (!dateString) {
            return null
        }
        if (dateString =~ /\+[0-9]{4}/) {
            return ZonedDateTime.parse(dateString, JAVA_OFFSET_PARSER).toOffsetDateTime()
        }
        return ZonedDateTime.parse(dateString, ISO_PARSER).toOffsetDateTime()
    }

    static OffsetDateTime parseDisplayDate(String displayDateString) {
        LocalDate date = LocalDate.parse(displayDateString, DateTimeFormatter.ofPattern("dd-MM-yyyy"))
        return date.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime()
    }

    static OffsetDateTime now() {
        return OffsetDateTime.now(clock)
    }

    static int daysRemaining(OffsetDateTime start, OffsetDateTime end) {
        if (end.isBefore(start)) {
            return 0
        }
        return 1 + (int) ChronoUnit.DAYS.between(start.toLocalDate(), end.toLocalDate())
    }

    /**
     * @return the first year in the current financial year (July-June). For example, during 2014/2015 this returns 2014.
     */
    static int currentFinancialYear() {
        return now().minusMonths(6).year
    }

    static String format(Date date) {
        return format(OffsetDateTime.ofInstant(date.toInstant(), ZoneId.systemDefault()))
    }

    static String format(OffsetDateTime date) {
        return DATE_FORMATTER.format(date)
    }

    static String displayFormat(OffsetDateTime date) {
        return DISPLAY_DATE_FORMATTER.format(date)
    }

    static String displayFormatWithTime(String isoDate) {
        return DISPLAY_DATE_FORMATTER_WITH_TIME.format(parse(isoDate))
    }

    static String displayFormatWithTimeNoSpace(String isoDate) {
        return DISPLAY_DATE_FORMATTER_WITH_TIME_NOSPACE.format(parse(isoDate))
    }

    static String isoToDisplayFormat(String isoDate) {
        try {
            return displayFormat(parse(isoDate))
        }
        catch (Exception e) {
            return ""
        }
    }

    /**
     * Groups the supplied data into time intervals defined by the supplied start date and period.
     * If no start date is supplied, it is the earliest date in the supplied data.
     */
    static LinkedHashMap<DateRange, List> groupByDateRange(List data, Closure dateAccessor, Period period, OffsetDateTime startDate = null, OffsetDateTime endDate = null) {
        def results = new LinkedHashMap()

        if ((!startDate || !endDate) && !data) {
            return results
        }

        if (!startDate) {
            def start = dateAccessor(data.min(dateAccessor))
            startDate = parse(start)
        }
        if (!endDate) {
            def end = dateAccessor(data.max(dateAccessor))
            endDate = parse(end)
        }

        DateRange interval = new DateRange(startDate, period)
        while (interval.isBefore(endDate) || interval.contains(endDate)) {
            def periodData = data.findAll {
                interval.contains(parse(dateAccessor(it)))
            }

            results << [(interval): periodData]
            interval = new DateRange(interval.end, period)
        }
        results
    }

    static String formatSingleMonthInterval(DateRange interval) {
        return MONTH_ONLY_FORMATTER.format(interval.start)
    }
}
