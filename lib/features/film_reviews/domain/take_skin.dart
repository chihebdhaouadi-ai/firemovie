/// The background a take card is drawn with. Every user owns both skins.
enum TakeSkin {
  /// The plain card background.
  normal('normal'),

  /// An animated lightning storm behind the take.
  electricThunder('electric_thunder');

  const TakeSkin(this.apiValue);

  final String apiValue;

  /// The skin for a server value; unknown or missing values fall back to
  /// [normal] so older takes keep their look.
  static TakeSkin fromApi(String? value) {
    for (final skin in TakeSkin.values) {
      if (skin.apiValue == value) return skin;
    }
    return TakeSkin.normal;
  }
}
