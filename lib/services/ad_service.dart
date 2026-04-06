/// No-op ad service stub (google_mobile_ads removed to avoid Firebase crash).
abstract class AdServiceBase {
  Future<void> initialize();
  Future<void> showInterstitialIfReady(int levelsCompleted);
  Future<bool> showRewardedAd();
  void setAdsRemoved(bool removed);
  void dispose();
}

class AdService implements AdServiceBase {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showInterstitialIfReady(int levelsCompleted) async {}

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  void setAdsRemoved(bool removed) {}

  @override
  void dispose() {}
}
