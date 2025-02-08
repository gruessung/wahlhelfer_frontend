class SessionData {
  final int id;
  final String sessionUuid;
  final String name;
  final int cntPages;
  final int cntEntriesPerPage;
  final int cntEntriesTotal;
  final Map<String, dynamic> diff;
  final Map<String, dynamic> summary;
  final List<Entry> entries;  // entries als Liste von Entry-Objekten

  SessionData({
    required this.id,
    required this.sessionUuid,
    required this.name,
    required this.cntPages,
    required this.cntEntriesPerPage,
    required this.cntEntriesTotal,
    required this.diff,
    required this.summary,
    required this.entries
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    var entriesJson = json['entries'] as List<dynamic>;
    List<Entry> entriesList = entriesJson.map((entryJson) => Entry.fromJson(entryJson)).toList();


    return SessionData(
      id: json['id'],
      sessionUuid: json['session_uuid'],
      name: json['name'],
      cntPages: json['cnt_pages'],
      cntEntriesPerPage: json['cnt_entries_per_page'],
      cntEntriesTotal: json['cnt_entries_total'],
      diff: json['diff'],
      summary: json['summary'],
      entries: entriesList
    );
  }
}


class Entry {
  final int entryNo;
  final int pageNo;
  final bool mark1;
  final bool mark2;

  Entry({
    required this.entryNo,
    required this.pageNo,
    required this.mark1,
    required this.mark2,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      entryNo: json['entry_no'],
      pageNo: json['page_no'],
      mark1: json['mark1'],
      mark2: json['mark2'],
    );
  }
}