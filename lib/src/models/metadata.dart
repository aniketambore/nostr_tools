/// Metadata of a user based on kind 0.
class Metadata {
  /// The URL of the user's banner image.
  String? banner;

  /// The LUD06 of the user's metadata.
  String? lud06;

  /// The LUD16 of the user's metadata.
  String? lud16;

  /// The user's website URL.
  String? website;

  /// The URL of the user's profile picture.
  String? picture;

  /// The user's display name.
  String? display_name;

  /// The user's name.
  String? name;

  /// A short description about the user.
  String? about;

  /// The user's username.
  String? username;

  /// The user's display name.
  String? displayName;

  /// The NIP05 of the user's metadata.
  String? nip05;

  /// The number of users that the user is following.
  int? followingCount;

  /// The number of users that are following the user.
  int? followersCount;

  /// Whether the NIP05 of the user's metadata is valid or not.
  bool? nip05valid;

  /// The user's Zap service ID.
  String? zapService;

  /// Creates a new instance of [Metadata].
  Metadata({
    this.banner,
    this.lud06,
    this.lud16,
    this.website,
    this.picture,
    this.display_name,
    this.name,
    this.about,
    this.username,
    this.displayName,
    this.nip05,
    this.followingCount,
    this.followersCount,
    this.nip05valid,
    this.zapService,
  });

  /// Creates a new [Metadata] object from a JSON map.
  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        banner: json['banner'] as String?,
        lud06: json['lud06'] as String?,
        lud16: json['lud16'] as String?,
        website: json['website'] as String?,
        picture: json['picture'] as String?,
        display_name: json['display_name'] as String?,
        name: json['name'] as String?,
        about: json['about'] as String?,
        username: json['username'] as String?,
        displayName: json['displayName'] as String?,
        nip05: json['nip05'] as String?,
        followingCount: json['followingCount'] is String
            ? int.parse(json['followingCount'] as String)
            : json['followingCount'] as int?,
        followersCount: json['followersCount'] is String
            ? int.parse(json['followersCount'] as String)
            : json['followersCount'] as int?,
        nip05valid: json['nip05valid'] is String
            ? json['nip05valid'] == 'true'
            : json['nip05valid'] as bool?,
        zapService: json['zapService'] as String?,
      );
}
