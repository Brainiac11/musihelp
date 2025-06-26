import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io' show Platform, Process, File;

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? pickedVideo;

  Future<void> _pickVideo() async {
    try {
      XFile? video;
      
      if (Platform.isWindows) {
        // On Windows, use file picker to select video files instead of camera
        // since camera delegate setup is complex
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
        
        if (result != null && result.files.single.path != null) {
          video = XFile(result.files.single.path!);
        }
      } else {
        // On other platforms, use camera (temporary recording, not saved to gallery)
        video = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5), // Optional: limit duration
        );
      }
      
      setState(() {
        pickedVideo = video;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error picking video: $e');
      }
    }
  }

  Widget _buildVideoPreview() {
    if (pickedVideo == null) return const SizedBox.shrink();
    
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              color: CupertinoColors.black,
              child: const Icon(
                CupertinoIcons.videocam_fill,
                size: 50,
                color: CupertinoColors.white,
              ),
            ),
            // Video info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      CupertinoColors.black.withValues(alpha: 0.8),
                      CupertinoColors.black.withAlpha(0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pickedVideo!.name,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Platform.isAndroid || Platform.isIOS 
                          ? 'Temporary recording • Tap to preview'
                          : 'Video ready for processing',
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Play button overlay
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _playVideo,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.play_fill,
                  color: CupertinoColors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo() async {
    if (pickedVideo == null) return;
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    try {
      if (Platform.isWindows) {
        // On Windows, try multiple approaches
        try {
          // First try: Use Start-Process with PowerShell
          final result = await Process.run(
            'powershell',
            ['-Command', 'Start-Process', '"${pickedVideo!.path}"'],
            runInShell: true,
          );
          if (result.exitCode != 0) {
            throw Exception('PowerShell failed');
          }
        } catch (e) {
          // Fallback: Use cmd with start command
          await Process.run(
            'cmd',
            ['/c', 'start', '""', '"${pickedVideo!.path}"'],
            runInShell: true,
          );
        }
      } else if (Platform.isMacOS) {
        // On macOS, open with the default video player
        await Process.run('open', [pickedVideo!.path]);
      } else if (Platform.isLinux) {
        // On Linux, try to open with xdg-open
        await Process.run('xdg-open', [pickedVideo!.path]);
      } else if (Platform.isAndroid || Platform.isIOS) {
        // For mobile platforms, show in-app video player
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: pickedVideo!.path),
          ),
        );
      } else {
        if (kDebugMode) {
          print('Video playback not supported for this platform');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing video: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/');
          },
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.activeBlue,
          ),
        ),
        middle: const Text('Recording Page'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is the Recording Page',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            CupertinoButton(
              onPressed: _pickVideo,
              color: CupertinoTheme.of(context).primaryColor,
              child: Text(
                Platform.isWindows ? 'Select Video' : 'Record Video',
                style: TextStyle(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                ),
              ),
            ),
            if (pickedVideo != null) ...[
              const SizedBox(height: 20),
              Text(
                Platform.isWindows 
                    ? 'Video selected: ${pickedVideo!.name}'
                    : 'Video recorded: ${pickedVideo!.name}',
                style: const TextStyle(fontSize: 14),
              ),
              if (Platform.isAndroid || Platform.isIOS)
                const Text(
                  '(Temporary - not saved to gallery)',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              const SizedBox(height: 20),
              _buildVideoPreview(),
            ],
          ],
        ),
      ),
    );
  }
}

// In-app video player screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Auto-play the video
        _controller.play();
        
        // Hide controls after 3 seconds
        _hideControlsAfterDelay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load video: $e';
        });
      }
      if (kDebugMode) {
        print('Error initializing video player: $e');
      }
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Video player
            Center(
              child: _isLoading
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                          radius: 20,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading video...',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : _hasError
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: CupertinoColors.systemRed,
                              size: 50,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load video',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CupertinoButton.filled(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _hasError = false;
                                });
                                _initializeVideoPlayer();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _toggleControls,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
            ),
            
            // Top controls (close button)
            if (_showControls)
              Positioned(
                top: 20,
                left: 20,                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            
            // Center play/pause button
            if (_showControls && !_isLoading && !_hasError)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                          _hideControlsAfterDelay();
                        }
                      });
                    },
                    child: Icon(
                      _controller.value.isPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            
            // Bottom controls
            if (_showControls && !_isLoading && !_hasError)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: CupertinoColors.systemBlue,
                          bufferedColor: CupertinoColors.systemGrey,
                          backgroundColor: CupertinoColors.systemGrey4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}