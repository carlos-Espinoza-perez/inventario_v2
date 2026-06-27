class FuzzySearch {
  static String removeDiacritics(String str) {
    var withDia = 'áàäâãåÁÀÄÂÃÅéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛñÑçÇ';
    var withoutDia = 'aaaaaaAAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUnNcC';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  static int levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost
        ].reduce((min, e) => e < min ? e : min);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  static bool isMatch(String queryWord, String targetText) {
    final normQuery = removeDiacritics(queryWord).toLowerCase();
    final normTarget = removeDiacritics(targetText).toLowerCase();

    if (normTarget.contains(normQuery)) return true;

    // Check if any word in the target is close enough to the query
    final targetWords = normTarget.split(RegExp(r'\s+'));
    for (final tWord in targetWords) {
      if (tWord.isEmpty) continue;
      
      // If the query word is very short, exact match or 1 typo is better
      if (normQuery.length <= 3) {
        if (tWord.startsWith(normQuery)) return true;
        int distance = levenshteinDistance(normQuery, tWord);
        if (distance <= 1 && normQuery.length >= 3) return true;
      } else {
        int distance = levenshteinDistance(normQuery, tWord);
        // Allow 1 typo for words length 4-5, 2 typos for 6+
        int allowedTypos = normQuery.length >= 6 ? 2 : 1;
        if (distance <= allowedTypos) return true;
        
        // Also check if the query is a prefix with typo (e.g. "levi" matching "levis")
        if (tWord.length > normQuery.length) {
           int prefixDistance = levenshteinDistance(normQuery, tWord.substring(0, normQuery.length));
           if (prefixDistance <= allowedTypos) return true;
        }
      }
    }
    return false;
  }
}
