import 'package:flutter/material.dart';

import '../widget/themeOption.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode currentThemeMode;
  
  const SettingsPage({
    super.key, 
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode _themeMode;
  bool _notifications = true;
  bool _ephemeralStyle = false;
  bool _detailedAI = false;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentThemeMode != widget.currentThemeMode) {
      setState(() {
        _themeMode = widget.currentThemeMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('General Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      themeOption('Light', ThemeMode.light, _themeMode, (mode) {
                        setState(() {
                          _themeMode = mode;
                        });
                        widget.onThemeModeChanged(mode);
                      }),
                      themeOption('Dark', ThemeMode.dark, _themeMode, (mode) {
                        setState(() {
                          _themeMode = mode;
                        });
                        widget.onThemeModeChanged(mode);
                      }),
                      themeOption('System', ThemeMode.system, _themeMode, (mode) {
                        setState(() {
                          _themeMode = mode;
                        });
                        widget.onThemeModeChanged(mode);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // SwitchListTile(
          //   title: const Text('Allow Notifications'),
          //   subtitle: const Text('Receive updates on your preserved thoughts.'),
          //   value: _notifications,
          //   onChanged: (val) => setState(() => _notifications = val),
          //   secondary: const Icon(Icons.notifications_active_outlined),
          // ),
         
          const SizedBox(height: 24),
          
          const SizedBox(height: 24),
          
          //! do not delete this function just work this later
          // const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
          // ListTile(
          //   leading: const Icon(Icons.person_outline),
          //   title: const Text('Manage Profile'),
          //   subtitle: const Text('Update your personal information.'),
          //   trailing: ElevatedButton(
          //     onPressed: () {},
          //     child: const Text('Edit'),
          //   ),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.logout, color: Colors.red),
          //   title: const Text('Logout', style: TextStyle(color: Colors.red)),
          //   subtitle: const Text('Sign out from your account.'),
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }

  
} 