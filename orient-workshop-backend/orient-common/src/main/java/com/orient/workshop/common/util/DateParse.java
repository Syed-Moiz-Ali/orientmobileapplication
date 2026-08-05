package com.orient.workshop.common.util;

import com.orient.workshop.common.exception.BadRequestException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * Shared date parsing helpers. Any unparseable value is converted to a 400 response
 * instead of a raw DateTimeParseException leaking as a 500.
 */
public final class DateParse {

    private DateParse() {
    }

    public static LocalDateTime parseLocalDateTime(String value, String fieldName) {
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDateTime.parse(value, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        } catch (DateTimeParseException e) {
            throw new BadRequestException("Invalid " + fieldName + " '" + value
                    + "'. Expected format: yyyy-MM-dd'T'HH:mm:ss");
        }
    }

    public static LocalDate parseLocalDate(String value, String fieldName) {
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (DateTimeParseException e) {
            throw new BadRequestException("Invalid " + fieldName + " '" + value
                    + "'. Expected format: yyyy-MM-dd");
        }
    }
}
