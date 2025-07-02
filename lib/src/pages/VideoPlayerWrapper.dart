import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/providers/VideoProvider.dart';
import 'package:myapp/src/pages/RecordingPage.dart';

class VideoPlayerWrapper extends ConsumerWidget {
  final String? pathParam;

  const VideoPlayerWrapper({super.key, this.pathParam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPath = pathParam ?? ref.watch(videoPathProvider);
    
    if (videoPath == null) {
      // If no path available, go back to recording page
      return const RecordingPage();
    }
    
    return VideoPlayerScreen(videoPath: videoPath);
  }
}
