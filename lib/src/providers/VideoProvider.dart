import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'VideoProvider.g.dart';

@riverpod
class VideoPath extends _$VideoPath {
  @override
  String? build() {
    return null;
  }

  void setVideoPath(String? path) {
    state = path;
  }

  void clearVideoPath() {
    state = null;
  }
}
