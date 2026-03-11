import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/location_service.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'data_privacy_screen.dart';
import 'dart:io'; // Added import for File

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, userProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context, userProvider),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Farm Settings"),
                      const SizedBox(height: 15),
                      _buildSettingsList(context, userProvider),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Device & App"),
                      const SizedBox(height: 15),
                      _buildAppInfo(context),
                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, UserProvider userProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text("Farm Account", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            backgroundImage: userProvider.avatar == 'custom' && userProvider.customAvatarPath != null
                ? FileImage(File(userProvider.customAvatarPath!))
                : null,
            child: userProvider.avatar == 'custom' && userProvider.customAvatarPath != null
                ? null
                : Icon(
                    _getAvatarIcon(userProvider.avatar),
                    size: 45,
                    color: Colors.green,
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Mylavaram Farmers Cooperative",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit Profile"),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  Widget _buildSettingsList(BuildContext context, UserProvider userProvider) {
    return _buildSection(
      context,
      title: "Personal Details",
      items: [
        _buildInfoTile(Icons.person_outline, "Farmer Name", userProvider.name),
        _buildLocationTile(context, userProvider),
      ],
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return _buildSection(
      context,
      title: "App Preferences",
      items: [
        Consumer<UserProvider>(
          builder: (context, userProvider, _) => _buildToggleTile(
            Icons.notifications_active_outlined,
            "Harvest Notifications",
            userProvider.notificationsEnabled,
            (val) => userProvider.toggleNotifications(val),
          ),
        ),
        _buildNavigationTile(
          context,
          Icons.privacy_tip_outlined,
          "Data & Privacy",
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPrivacyScreen())),
        ),
        _buildNavigationTile(
          context,
          Icons.settings_suggest_outlined,
          "Backend Settings",
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }

  Widget _buildLocationTile(BuildContext context, UserProvider userProvider) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.map_outlined, color: Colors.green),
          title: const Text("Farm Location", style: TextStyle(fontSize: 14, color: Colors.grey)),
          subtitle: Text(userProvider.currentLocation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
          trailing: TextButton(
            onPressed: () => _showManualLocationDialog(context, userProvider),
            child: const Text("EDIT"),
          ),
        ),
        const Divider(height: 1, indent: 50),
        SwitchListTile(
          secondary: const Icon(Icons.gps_fixed_rounded, color: Colors.green),
          title: const Text("Use Automatic Location", style: TextStyle(fontSize: 14)),
          value: userProvider.locationMode == "auto",
          activeThumbColor: Colors.green,
          onChanged: (val) async {
            userProvider.updateLocationMode(val ? "auto" : "manual");
            if (val) {
              userProvider.updateCurrentLocation("Detecting...");
              LocationData loc = await LocationService.getCurrentLocation();
              userProvider.updateCurrentLocation(loc.cityName);
            }
          },
        ),
      ],
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }

  Widget _buildNavigationTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showManualLocationDialog(BuildContext context, UserProvider userProvider) {
    final controller = TextEditingController(text: userProvider.manualLocation);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Manual Location"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your farm location"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              userProvider.updateManualLocation(controller.text.trim());
              userProvider.updateLocationMode("manual");
              Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getAvatarIcon(String avatar) {
    switch (avatar) {
      case 'nature': return Icons.nature_people;
      case 'agriculture': return Icons.agriculture;
      case 'eco': return Icons.eco;
      case 'person':
      default: return Icons.person;
    }
  }
}

