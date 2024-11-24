import 'package:flutter/material.dart';
import 'localization.dart';

class SettingsScreen extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChange;
  final ValueChanged<Color> onThemeChange;

  const SettingsScreen({
    Key? key,
    required this.currentLanguage,
    required this.onLanguageChange,
    required this.onThemeChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> themeColors = [
      Colors.purple[50]!,
      Colors.pink[50]!,
      Colors.blue[50]!,
      Colors.green[50]!,
      Colors.orange[50]!,
      Colors.teal[50]!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getText('settings', currentLanguage)),
      ),
      body: ListView(
        children: [
          // 언어 설정
          ListTile(
            title: Text(AppLocalizations.getText('language', currentLanguage)),
            trailing: DropdownButton<String>(
              value: currentLanguage,
              items: [
                DropdownMenuItem(
                  value: 'ko',
                  child: Text('한국어'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  onLanguageChange(value); // 언어 변경 반영
                  Navigator.pop(context); // 화면 닫기
                }
              },
            ),
          ),
          // 테마 색상 설정
          ListTile(
            title: Text(AppLocalizations.getText('theme', currentLanguage)),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: themeColors.map((color) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        onThemeChange(color); // 테마 변경 반영
                        Navigator.pop(context); // 화면 닫기
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
