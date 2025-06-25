import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/utilities/ScaleType.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatScaleTypeName(ScaleType type) {
    String total = "";
    for(int i = 0; i < type.name.length; i++){
      String char = type.name[i];
      if(char == char.toUpperCase()){
        total += " $char";
      }else{
        if(i==0){
          total+= char.toUpperCase();
        } else{
        total += char;
        }
      }
    }
    return total.substring(0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Home Page')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
                        return Container(
                          height: 250,
                          color: CupertinoColors.systemBackground.resolveFrom(
                            context,
                          ),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: CupertinoColors.label.resolveFrom(context),
                              fontSize: 22.0,
                            ),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: CupertinoPicker(
                                itemExtent: 32.0,
                                onSelectedItemChanged: (int value) {},
                                children:
                                    ScaleType.values.map((scaleType) {
                                      return Text(
                                        _formatScaleTypeName(scaleType),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
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
