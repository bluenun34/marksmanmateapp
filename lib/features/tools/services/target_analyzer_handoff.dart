import '../../shoot_log/widgets/session_photo_picker.dart';

/// Passes an annotated target photo from the analyzer into the shoot log flow.
class TargetAnalyzerHandoff {
  TargetAnalyzerHandoff._();

  static SessionPhotoDraft? _pendingTargetPhoto;

  static void setTargetPhoto(SessionPhotoDraft draft) {
    _pendingTargetPhoto = draft;
  }

  static SessionPhotoDraft? takeTargetPhoto() {
    final draft = _pendingTargetPhoto;
    _pendingTargetPhoto = null;
    return draft;
  }
}
