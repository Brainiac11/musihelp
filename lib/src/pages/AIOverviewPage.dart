import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/providers/VideoProvider.dart';

class AIOverviewPage extends ConsumerStatefulWidget {
  final String? videoPath;

  const AIOverviewPage({super.key, this.videoPath});

  @override
  ConsumerState<AIOverviewPage> createState() => _AIOverviewPageState();
}

class _AIOverviewPageState extends ConsumerState<AIOverviewPage> {
  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  String _analysisResult = '';

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _startAnalysis();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(videoPathProvider.notifier).setVideoPath(widget.videoPath!);
      });
    }
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisComplete = true;
        _analysisResult = 'AI analysis complete! The video has been processed and analyzed for musical content. Here you would see insights about tempo, key, rhythm patterns, and other musical elements detected in your performance.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoPath = ref.watch(videoPathProvider) ?? widget.videoPath;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.activeBlue,
          ),
        ),
        middle: const Text('AI Overview'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.waveform_path_ecg,
                      size: 50,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AI-Powered Music Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      videoPath != null 
                          ? 'Analyzing your musical performance...'
                          : 'No video available for analysis',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      width: 1,
                    ),
                  ),
                  child: videoPath == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle,
                                size: 50,
                                color: CupertinoColors.systemOrange,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Video Found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please record or select a video first to enable AI analysis.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _isAnalyzing
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoActivityIndicator(
                                    radius: 20,
                                    color: CupertinoTheme.of(context).primaryContrastingColor,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Analyzing Video...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Our AI is processing your musical performance',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoTheme.of(context).primaryContrastingColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : _analysisComplete
                              ? SingleChildScrollView(
                                  child: Column(
                                    spacing: 12.0,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.checkmark_circle_fill,
                                            color: CupertinoColors.systemGreen,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Analysis Complete',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: CupertinoTheme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: CupertinoTheme.of(context).barBackgroundColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _analysisResult,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      
                                      Row(
                                        spacing: 12.0,
                                        children: [
                                          Expanded(
                                            child: CupertinoButton(
                                              color: CupertinoTheme.of(context).barBackgroundColor,
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                context.push('/video_player?path=${Uri.encodeComponent(videoPath)}');
                                              },
                                              child: const Text('View Video'),
                                            ),
                                          ),

                                          Expanded(
                                            child: CupertinoButton(
                                                                               
                                              color: CupertinoTheme.of(context).barBackgroundColor,
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                _startAnalysis();
                                              },
                                              child: const Text('Re-analyze'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoButton(
                                                  color: CupertinoTheme.of(context).primaryContrastingColor,
                                                  onPressed: () {
                                                    HapticFeedback.lightImpact();
                                                    
                                                  },
                                                    child: Text('View Analysis')
                                                      .animate(
                                                      onPlay: (controller) => controller.repeat(),
                                                      )
                                                      .shimmer(
                                                      duration: const Duration(seconds: 2),
                                                      color: CupertinoColors.systemMint,
                                                      angle: 45.0,
                                                      curve: Curves.linear
                                                      ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'Ready to analyze your video',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              if (videoPath == null)
                CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/recording_page');
                  },
                  child: const Text('Record Video'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
