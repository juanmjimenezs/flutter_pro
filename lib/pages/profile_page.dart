import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';
import '../pages/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String title = 'Profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _updatePassword(BuildContext context) async {
    try {
      await authService.value.resetPasswordFromCurrentPassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        email: _emailController.text,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateUsername(BuildContext context) async {
    try {
      await authService.value.updateUsername(
        username: _usernameController.text,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    }
  }

  void _showUpdateUsernameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Username'),
            content: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'New Username',
                hintText: 'Enter your new username',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _updateUsername(context),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _updatePassword(context),
                child: const Text('Change'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement account deletion logic
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void logout() async {
      // Get the context before the async operation
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        await authService.value.signOut();

        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      } on FirebaseAuthException catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.message}')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 24),
          Text(
            authService.value.currentUser?.displayName ?? 'User Name',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Update Username'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUpdateUsernameDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete My Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
