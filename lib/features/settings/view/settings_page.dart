import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/view/profile_page_wrapper.dart';
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildSettingsContent(state.user);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Build the settings content
  Widget _buildSettingsContent(dynamic user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Profile Section
        _buildUserProfileSection(user),
        
        const SizedBox(height: 24),
        
        // General Preferences Section
        _buildGeneralPreferencesSection(),
        
        const SizedBox(height: 24),
        
        // Account Section
        _buildAccountSection(),
      ],
    );
  }

  /// Build user profile section
  Widget _buildUserProfileSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
              child: Text(
                user.initialLetter,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(user.username),
            subtitle: Text('Member since ${_formatDate(user.createdAt)}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfilePageWrapper(),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ),
        ),
      ],
    );
  }

  /// Build general preferences section
  Widget _buildGeneralPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Preferences',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
        const SizedBox(height: 12),
        // SwitchListTile(
        //   title: const Text('Allow Notifications'),
        //   subtitle: const Text('Receive updates on your preserved thoughts.'),
        //   value: _notifications,
        //   onChanged: (val) => setState(() => _notifications = val),
        //   secondary: const Icon(Icons.notifications_active_outlined),
        // ),
      ],
    );
  }

  /// Build account section
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              // ListTile(
              //   leading: const Icon(Icons.person_outline),
              //   title: const Text('Manage Profile'),
              //   subtitle: const Text('Update your personal information.'),
              //   trailing: const Icon(Icons.arrow_forward_ios),
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const ProfilePageWrapper(),
              //       ),
              //     );
              //   },
              // ),
              // const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Sign out from your account.'),
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Handle logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const LogoutUser());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return 'Today';
    }
  }
} 