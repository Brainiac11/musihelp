import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:music_notes/music_notes.dart';
import 'package:myapp/src/utilities/ScaleTypes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScalePattern selectedScalePattern = kScalePatterns[0];
  Scale<Note> selectedScale = kScaleGroups[0][0];
  int selectedScalePatternIndex = 0;
  int selectedScaleIndex = 0;
  ValueKey keySelectionValueKey = ValueKey(0);

  Scale<Note> getSelectedScale(){
    return selectedScale;
  } 

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Home Page')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording button in the center
            CupertinoButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/recording_page');
              },
              color: CupertinoTheme.of(context).primaryColor,
              child: Text(
                'Start Recording',
                style: TextStyle(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  fontSize: 18,
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.3),
            
            // Existing buttons at the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/settings');
                  },
                  color: CupertinoTheme.of(context).primaryColor,
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryContrastingColor,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                CupertinoButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setModalState) {
                            return Container(
                              height: 300,
                              color: CupertinoColors.systemBackground
                                  .resolveFrom(context),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(
                                    context,
                                  ),
                                  fontSize: 22.0,
                                ),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          "${selectedScale
                                              .degree(ScaleDegree.i)} ${selectedScalePattern.name ?? ""}",
                                          style: TextStyle(
                                            color: CupertinoColors.label
                                                .resolveFrom(context),
                                          ),
                                        ).animate().fadeIn(),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 32.0,
                                              scrollController:
                                                  FixedExtentScrollController(
                                                    initialItem:
                                                        selectedScalePatternIndex,
                                                  ),
                                              onSelectedItemChanged:
                                                  (int value) {
                                                    setState(() {
                                                      selectedScalePatternIndex =
                                                          value;
                                                      selectedScalePattern =
                                                          kScalePatterns[value];
                                                      selectedScaleIndex = 0;
                                                      keySelectionValueKey =
                                                          ValueKey(0);
                                                    });
                                                    setModalState(() {
                                                      
                                                    });
                                                  },
                                              children: [
                                                for (var scale
                                                    in kScalePatterns)
                                                  Text(
                                                    scale.name ??
                                                        scale.toString(),
                                                    style: TextStyle(
                                                      color: CupertinoColors
                                                          .label
                                                          .resolveFrom(context),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              key: keySelectionValueKey,
                                              itemExtent: 32.0,
                                              scrollController:
                                                  FixedExtentScrollController(
                                                    initialItem:
                                                        keySelectionValueKey
                                                            .value,
                                                  ),
                                              onSelectedItemChanged: (int value) {
                                                setState(() {
                                                  selectedScaleIndex = value;
                                                  selectedScale =
                                                      selectedScalePattern.on(
                                                        kScaleNotes[value],
                                                      );
                                                });
                                                setModalState(() => {});
                                                if (kDebugMode) {
                                                  print(
                                                    "value: $value $selectedScale",
                                                  );
                                                }
                                              },
                                      
                                              children: [
                                                for (var scale
                                                    in kScaleGroupsInverse[selectedScalePatternIndex])
                                                  Text(
                                                    scale
                                                        .degree(ScaleDegree.i)
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: CupertinoColors
                                                          .label
                                                          .resolveFrom(context),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(),
                                  ],
                                ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  color: CupertinoTheme.of(context).primaryColor,
                  child: Text(
                    'Scale Selection',
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryContrastingColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
    );
  }
}