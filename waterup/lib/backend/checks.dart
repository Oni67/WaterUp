bool isValidValue(String value) {
  RegExp valueRegExp = RegExp(r'^([1-9]\d*|0)(,\d{2})?$');
  return valueRegExp.hasMatch(value);
}

bool isValidDate(String date) {
  /* Date format, YYYY/MM/DD
   * r'^(19|20)\d\d/ checks for 19YY or 20YY
   * (0[1-9]|1[0-2]) checks that MM is equal or between 1 and 12
   * (0[1-9]|[12][0-9]|3[01]) checks that DD is equal or between 1 and 31
   */
  RegExp dateRegExp = RegExp(
    r'^((19|20)\d\d/(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01]))|' // YYYY/MM/DD
    r'((0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\d\d)|' // DD/MM/YYYY
    r'^\d{4}-\d{2}-\d{2}$', // YYYY-MM-DD
  );
  return dateRegExp.hasMatch(date);
}


bool isValidMethod(String method) {
  return method == 'C.C' || method == 'Din';
}

bool isValidTime(String regularidade) {
  return regularidade == 'diariamente' ||
      regularidade == 'semanalmente' ||
      regularidade == 'mensalmente' ||
      regularidade == 'anualmente';
}

String checkDate(String date) {
  String newDate = date;

  RegExp dateRegExpYYYY = RegExp(
    r'((0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\d\d)$', // DD/MM/YYYY
  );

  RegExp dateRegExpISO = RegExp(
    r'^\d{4}-\d{2}-\d{2}$', // YYYY-MM-DD
  );

  if (dateRegExpYYYY.hasMatch(date)) {
    // Convert DD/MM/YYYY to YYYY/MM/DD
    List<String> dateParts = date.split('/');
    newDate = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
  } else if (dateRegExpISO.hasMatch(date)) {
    // Accept YYYY-MM-DD format
    newDate = date;
  }

  return newDate;
}

bool isDateInPast(String date) {
    String NewDate = date;
    RegExp dateRegExpYYYY = RegExp(
      r'((0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\d\d)$', // DD/MM/YYYY
    );
    if (dateRegExpYYYY.hasMatch(date)) {
      // Convert DD/MM/YYYY to YYYY/MM/DD
      List<String> dateParts = date.split('/');
      NewDate = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
    }

    NewDate = NewDate.replaceAll('/', '-');
    DateTime currentDate = DateTime.now();
    DateTime enteredDate = DateTime.parse(NewDate);
    return currentDate.isAfter(enteredDate);
  }
