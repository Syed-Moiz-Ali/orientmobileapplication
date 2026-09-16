import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

/// Lifecycle grouping for the Bookings screen.
///
/// Derived only from real booking statuses — no lifecycle state is invented.
enum CustomerBookingGroup { upcoming, inService, history }

/// Presentation-only classification, ordering and formatting for the Customer
/// Bookings screen.
///
/// Status *labels* and *tones* are deliberately not redefined here: they come
/// from [CustomerBookingEntity.statusLabel] (the canonical
/// `AppStatusLabels.booking` vocabulary) and
/// `CustomerServiceTracking.bookingTone`, so Home, Status and Bookings can
/// never describe the same job differently.
abstract final class CustomerBookingsPresentation {
  CustomerBookingsPresentation._();

  /// The vehicle is already with the workshop.
  static const Set<BookingStatus> inWorkshopStatuses = {
    BookingStatus.approvalRequired,
    BookingStatus.vehicleReceived,
    BookingStatus.approved,
    BookingStatus.workAssigned,
    BookingStatus.inProgress,
  };

  /// Booked, but the vehicle has not reached the workshop yet.
  static const Set<BookingStatus> upcomingStatuses = {
    BookingStatus.pending,
    BookingStatus.confirmed,
  };

  static CustomerBookingGroup groupOf(BookingStatus status) {
    if (inWorkshopStatuses.contains(status)) {
      return CustomerBookingGroup.inService;
    }
    if (upcomingStatuses.contains(status)) {
      return CustomerBookingGroup.upcoming;
    }
    // completed, delivered and cancelled are all finished lifecycle entries.
    return CustomerBookingGroup.history;
  }

  /// Best-effort reading of the backend's separate date/time strings.
  ///
  /// The API carries `date`/`time` as plain strings, and this app writes
  /// day-first numeric dates itself (`dd/MM/yyyy`, see the booking flow), so
  /// those are understood alongside ISO values. Returns null when nothing can
  /// be read, so callers degrade to the raw value instead of inventing a date.
  /// No timezone conversion is performed.
  static DateTime? parseDateTime(String date, String time) {
    final parts = _parseDateParts(date);
    if (parts == null) return null;

    final parsedTime = _parseTime(time);
    return DateTime(
      parts.$1,
      parts.$2,
      parts.$3,
      parsedTime?.$1 ?? 0,
      parsedTime?.$2 ?? 0,
    );
  }

  /// True when the value is a clock time the compact date block can show.
  static bool isReadableTime(String raw) => _parseTime(raw) != null;

  /// Minutes since midnight for a real clock time, or null when the value is
  /// not a time this product can read (e.g. `morning`). Accepts both the
  /// workshop's `HH:mm` slots and 12-hour values.
  static int? minutesOfDay(String raw) {
    final parsed = _parseTime(raw);
    if (parsed == null) return null;
    return parsed.$1 * 60 + parsed.$2;
  }

  /// Identity for the same booking seen from two sources (the workshop feed and
  /// the device cache), so the two are never shown twice.
  ///
  /// Plates are compared without punctuation or case, and the date is compared
  /// as a real date because the API and the cache use different formats.
  static String identityKey({
    required String vehicleName,
    required String plateNumber,
    required String date,
  }) {
    final plate = plateNumber
        .replaceAll(RegExp('[^A-Za-z0-9]'), '')
        .toUpperCase();
    final parsed = parseDateTime(date, '');
    final day = parsed == null ? date.trim().toLowerCase() : isoDate(parsed);
    return '${vehicleName.trim().toLowerCase()}|$plate|$day';
  }

  static (int, int, int)? _parseDateParts(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    // Pick the first date-like token out of the value. Backend values wrap the
    // date in weekday names, clock times or words like `at`, and the wrapper is
    // not part of the date.
    final datePart = (_dateToken.firstMatch(value)?.group(0) ?? value).trim();

    final numeric = RegExp(
      r'^(\d{1,4})[./-](\d{1,2})[./-](\d{1,4})$',
    ).firstMatch(datePart);
    if (numeric != null) {
      final first = int.parse(numeric.group(1)!);
      final second = int.parse(numeric.group(2)!);
      final third = int.parse(numeric.group(3)!);

      // `yyyy-MM-dd` (and `yyyy/MM/dd`) lead with the year.
      if (numeric.group(1)!.length == 4) {
        return _validDate(first, second, third);
      }
      // Day-first is this product's own convention. Only a second component
      // that cannot be a month (`09/22/2026`) is read month-first instead.
      if (second > 12 && first <= 12) return _validDate(third, first, second);
      return _validDate(third, second, first);
    }

    // Month-name dates, day-first (`22 Sep 2026`, `22-Sep-2026`) …
    final dayFirst = RegExp(
      r'^(\d{1,2})[-\s./]*([A-Za-z]{3,9})\.?,?[-\s./]*(\d{4})$',
    ).firstMatch(datePart);
    if (dayFirst != null) {
      final month = _monthFromName(dayFirst.group(2)!);
      if (month == null) return null;
      return _validDate(
        int.parse(dayFirst.group(3)!),
        month,
        int.parse(dayFirst.group(1)!),
      );
    }

    // … and month-first (`Sep 22, 2026`).
    final monthFirst = RegExp(
      r'^([A-Za-z]{3,9})\.?,?[-\s./]*(\d{1,2}),?[-\s./]*(\d{4})$',
    ).firstMatch(datePart);
    if (monthFirst != null) {
      final month = _monthFromName(monthFirst.group(1)!);
      if (month == null) return null;
      return _validDate(
        int.parse(monthFirst.group(3)!),
        month,
        int.parse(monthFirst.group(2)!),
      );
    }

    // Compact `yyyyMMdd` and epoch timestamps are machine formats the backend
    // may deliver instead of a formatted date.
    final compact = RegExp(r'^\d{8}$').firstMatch(datePart);
    if (compact != null) {
      return _validDate(
        int.parse(datePart.substring(0, 4)),
        int.parse(datePart.substring(4, 6)),
        int.parse(datePart.substring(6, 8)),
      );
    }

    final epoch = RegExp(r'^\d{10}$|^\d{13}$').firstMatch(datePart);
    if (epoch != null) {
      final seconds = datePart.length == 10;
      final millis = int.parse(datePart) * (seconds ? 1000 : 1);
      final date = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
      return (date.year, date.month, date.day);
    }

    // Anything else is only trusted when it is unambiguous ISO text.
    final iso = DateTime.tryParse(datePart);
    if (iso == null) return null;
    return (iso.year, iso.month, iso.day);
  }

  static (int, int, int)? _validDate(int year, int month, int day) {
    // Reject impossible values instead of letting DateTime normalise them
    // (31/02 would otherwise silently become 03/03).
    if (year < 1900 || year > 2200) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return (year, month, day);
  }

  /// Finds the first date-like token inside a backend value, so wrappers such
  /// as a weekday prefix or `at 09:00` never hide the date.
  static final RegExp _dateToken = RegExp(
    r'\b\d{4}[./-]\d{1,2}[./-]\d{1,4}\b'
    r'|\b\d{1,4}[./-]\d{1,2}[./-]\d{1,4}\b'
    r'|\b\d{1,2}[-\s][A-Za-z]{3,9}\.?,?[-\s,]?\s*\d{4}\b'
    r'|\b[A-Za-z]{3,9}\.?,?\s*\d{1,2},?\s*\d{4}\b'
    r'|\b\d{13}\b|\b\d{10}\b|\b\d{8}\b',
  );

  static int? _monthFromName(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.length < 3) return null;
    for (var index = 0; index < 12; index++) {
      final short = _months[index].toLowerCase();
      final long = _monthsLong[index].toLowerCase();
      if (value == short || value == long) return index + 1;
      // `sept`, `septem` … are unambiguous as long as the month matches.
      if (long.startsWith(value)) return index + 1;
    }
    return null;
  }

  /// Soonest first. Entries whose date cannot be read keep their incoming
  /// order and are appended unchanged.
  static List<CustomerBookingEntity> sortByUpcoming(
    List<CustomerBookingEntity> bookings,
  ) => _sort(bookings, ascending: true);

  /// Most recent first, with the same graceful fallback.
  static List<CustomerBookingEntity> sortByRecent(
    List<CustomerBookingEntity> bookings,
  ) => _sort(bookings, ascending: false);

  static List<CustomerBookingEntity> _sort(
    List<CustomerBookingEntity> bookings, {
    required bool ascending,
  }) {
    final dated = <(DateTime, int, CustomerBookingEntity)>[];
    final undated = <(int, CustomerBookingEntity)>[];

    for (var index = 0; index < bookings.length; index++) {
      final booking = bookings[index];
      final parsed = parseDateTime(booking.date, booking.time);
      if (parsed == null) {
        undated.add((index, booking));
      } else {
        dated.add((parsed, index, booking));
      }
    }

    dated.sort((a, b) {
      final byDate = ascending ? a.$1.compareTo(b.$1) : b.$1.compareTo(a.$1);
      return byDate != 0 ? byDate : a.$2.compareTo(b.$2);
    });

    return [
      ...dated.map((entry) => entry.$3),
      ...undated.map((entry) => entry.$2),
    ];
  }

  /// `Tue, 22 Sep 2026`, or the raw backend value when it cannot be read.
  static String dateLabel(String raw) {
    final parsed = parseDateTime(raw, '');
    if (parsed == null) return raw.trim();
    return '${_weekdays[parsed.weekday - 1]}, ${parsed.day} '
        '${_months[parsed.month - 1]} ${parsed.year}';
  }

  /// `2026-09-22` for a real date.
  ///
  /// The booking API and the date labels share this one format, so what the
  /// customer is shown and what is submitted can never drift apart.
  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// `Tuesday, 22 September 2026` — the fuller appointment date used where the
  /// screen has room to present the appointment properly.
  static String longDateLabel(String raw) {
    final parsed = parseDateTime(raw, '');
    if (parsed == null) return raw.trim();
    return '${_weekdaysLong[parsed.weekday - 1]}, ${parsed.day} '
        '${_monthsLong[parsed.month - 1]} ${parsed.year}';
  }

  /// Day-of-month for a compact date block, e.g. `22`.
  ///
  /// Empty when the date cannot be read, so a row can degrade to its raw value
  /// instead of inventing a day.
  static String dayOfMonthLabel(String raw) {
    final parsed = parseDateTime(raw, '');
    return parsed == null ? '' : '${parsed.day}';
  }

  /// Uppercase short month for a compact date block, e.g. `SEP`.
  static String monthLabel(String raw) {
    final parsed = parseDateTime(raw, '');
    return parsed == null ? '' : _months[parsed.month - 1].toUpperCase();
  }

  /// `22 Sep 2026` — the appointment date without the weekday, for dense
  /// secondary lines.
  static String compactDateLabel(String raw) {
    final parsed = parseDateTime(raw, '');
    if (parsed == null) return raw.trim();
    return '${parsed.day} ${_months[parsed.month - 1]} ${parsed.year}';
  }

  /// `9:00 AM`, or the raw backend value when it cannot be read.
  static String timeLabel(String raw) {
    final parsed = _parseTime(raw);
    if (parsed == null) return raw.trim();
    final (hour, minute) = parsed;
    final period = hour >= 12 ? 'PM' : 'AM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display:${minute.toString().padLeft(2, '0')} $period';
  }

  /// `Tue, 22 Sep 2026 · 9:00 AM`, degrading to whichever part is readable.
  static String scheduleLabel(String date, String time) {
    final datePart = dateLabel(date);
    final timePart = timeLabel(time);
    if (datePart.isEmpty) return timePart;
    if (timePart.isEmpty) return datePart;
    return '$datePart \u00b7 $timePart';
  }

  /// Human readable reference for one booking, preferring the identifiers the
  /// customer is meant to see: the public booking reference first, then the job
  /// card reference. Returns an empty string when neither exists so the UI can
  /// simply omit it — an internal database id is never shown as a reference.
  static String referenceOf(CustomerBookingEntity booking) {
    final bookingRef = booking.bookingRef.trim();
    if (bookingRef.isNotEmpty) return bookingRef;
    return booking.jobCardRef.trim();
  }

  static (int, int)? _parseTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final twelveHour = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AaPp])\.?[Mm]\.?$',
    ).firstMatch(value);
    if (twelveHour != null) {
      var hour = int.parse(twelveHour.group(1)!);
      final minute = int.parse(twelveHour.group(2)!);
      final isPm = twelveHour.group(3)!.toLowerCase() == 'p';
      if (hour == 12) {
        hour = isPm ? 12 : 0;
      } else if (isPm) {
        hour += 12;
      }
      return (hour.clamp(0, 23), minute.clamp(0, 59));
    }

    final twentyFourHour = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    if (twentyFourHour != null) {
      final hour = int.parse(twentyFourHour.group(1)!);
      final minute = int.parse(twentyFourHour.group(2)!);
      if (hour > 23 || minute > 59) return null;
      return (hour, minute);
    }

    return null;
  }

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdaysLong = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _monthsLong = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
