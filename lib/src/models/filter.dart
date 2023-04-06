/// Filter is a JSON object that determines which events will be sent in a subscription.
class Filter {
  /// List of event IDs or prefixes that the subscription should include.
  List<String>? ids;

  /// List of public keys or prefixes. Only events from authors with a public key in this list will be included.
  List<String>? authors;

  /// List of event kinds that should be included in the subscription.
  List<int>? kinds;

  /// List of event IDs that are referenced in an "e" tag and should be included in the subscription.
  List<String>? e;

  /// List of public keys that are referenced in a "p" tag and should be included in the subscription.
  List<String>? p;

  /// List of tags that are referenced in a "t" tag and should be included in the subscription.
  List<String>? t;

  /// Timestamp indicating the oldest event that should be included in the subscription.
  int? since;

  /// Timestamp indicating the newest event that should be included in the subscription.
  int? until;

  /// Maximum number of events to be returned in the initial query.
  int? limit;

  /// Default constructor.
  Filter({
    this.ids,
    this.authors,
    this.kinds,
    this.e,
    this.p,
    this.t,
    this.since,
    this.until,
    this.limit,
  });

  /// Deserialize a filter from a JSON.
  Filter.fromJson(Map<String, dynamic> json) {
    ids =
        json['ids'] == null ? null : List<String>.from(json['ids'] as Iterable);
    authors = json['authors'] == null
        ? null
        : List<String>.from(json['authors'] as Iterable);
    kinds = json['kinds'] == null
        ? null
        : List<int>.from(json['kinds'] as Iterable);
    e = json['#e'] == null ? null : List<String>.from(json['#e'] as Iterable);
    p = json['#p'] == null ? null : List<String>.from(json['#p'] as Iterable);
    t = json['#t'] == null ? null : List<String>.from(json['#t'] as Iterable);
    since = json['since'] as int?;
    until = json['until'] as int?;
    limit = json['limit'] as int?;
  }

  /// Serialize a filter to JSON.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (ids != null) {
      data['ids'] = ids;
    }
    if (authors != null) {
      data['authors'] = authors;
    }
    if (kinds != null) {
      data['kinds'] = kinds;
    }
    if (e != null) {
      data['#e'] = e;
    }
    if (p != null) {
      data['#p'] = p;
    }
    if (t != null) {
      data['#t'] = t;
    }
    if (since != null) {
      data['since'] = since;
    }
    if (until != null) {
      data['until'] = until;
    }
    if (limit != null) {
      data['limit'] = limit;
    }
    return data;
  }
}
