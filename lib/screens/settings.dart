import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsProvider with ChangeNotifier {
  double _playbackSpeed = 1.0;
  bool _isDarkMode = false;

  double get playbackSpeed => _playbackSpeed;
  bool get isDarkMode => _isDarkMode;

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Playback Speed Setting
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Playback Speed',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge, // Updated to bodyLarge
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: settingsProvider.playbackSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label:
                          '${settingsProvider.playbackSpeed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        settingsProvider.setPlaybackSpeed(value);
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '${settingsProvider.playbackSpeed.toStringAsFixed(1)}x',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Divider(),

              // Dark Mode Setting
              SwitchListTile(
                title: Text('Dark Mode'),
                value: settingsProvider.isDarkMode,
                onChanged: (value) {
                  settingsProvider.toggleThemeMode();
                },
              ),
              Divider(),

              // Placeholder for Future Settings
              ListTile(
                title: Text('Language Preference'),
                subtitle: Text('English (default)'),
                onTap: () {
                  // Future feature: Language selection dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Language settings coming soon!')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
