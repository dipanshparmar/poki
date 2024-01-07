String getCapitalizedString(String str) {
  // if empty
  if (str.isEmpty) {
    return str;
  }

  // if only one char is there
  if (str.length == 1) {
    return str.toUpperCase();
  }

  // else, capitalize the string
  final splitted = str.split(' ');

  for (int i = 0; i < splitted.length; i++) {
    final currentString = splitted[i];

    // if current string is empty, skip it
    if (currentString.isEmpty) {
      continue;
    }

    // if current char only has one char
    if (currentString.length == 1) {
      splitted[i] = currentString.toUpperCase();
    } else {
      splitted[i] = currentString[0].toUpperCase() +
          currentString.substring(1).toLowerCase();
    }
  }

  return splitted.join(' ');
}
