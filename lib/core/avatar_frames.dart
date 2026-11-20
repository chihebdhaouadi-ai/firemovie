/// Key of the frame every user starts with (the "Newcomer" cadre).
const defaultFrameKey = 'bronze';

/// Frames that ship with the app (`assets/lottie/frame_<key>.json`).
const knownFrameKeys = {'bronze', 'gold', 'explorer', 'debater', 'legend'};

/// [key] when the app has that frame, otherwise the default one, so a frame
/// added on the server before the app knows it never breaks an avatar.
String frameKeyOrDefault(String? key) =>
    knownFrameKeys.contains(key) ? key! : defaultFrameKey;
