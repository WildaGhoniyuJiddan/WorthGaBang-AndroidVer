import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/providers.dart';
import '../../../l10n/strings.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/profile_api.dart';

/// Tab Profil: foto, nama, pengaturan (biometric/tilt/tema), feedback, logout.
class ProfileContentScreen extends ConsumerStatefulWidget {
  const ProfileContentScreen({super.key});

  @override
  ConsumerState<ProfileContentScreen> createState() =>
      _ProfileContentScreenState();
}

class _ProfileContentScreenState
    extends ConsumerState<ProfileContentScreen> {
  final _picker = ImagePicker();
  final _kesan = TextEditingController();
  final _saran = TextEditingController();
  int _rating = 5;
  bool _sendingFeedback = false;
  bool _bioAvailable = false;
  bool _bioEnabled = false;
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadBio();
  }

  @override
  void dispose() {
    _kesan.dispose();
    _saran.dispose();
    super.dispose();
  }

  Future<void> _loadBio() async {
    final repo = ref.read(tokenStorageProvider);
    final available =
        await ref.read(biometricServiceProvider).isAvailable;
    final enabled = await repo.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _bioAvailable = available;
        _bioEnabled = enabled;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final xfile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    try {
      final user = await ref
          .read(profileApiProvider)
          .updateProfile(photoPath: xfile.path);
      ref.read(authControllerProvider.notifier).setUser(user);
      if (mounted) {
        setState(() => _localPhotoPath = xfile.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.photoUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _editName(String current) async {
    final ctrl = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editNameTitle),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              labelText: AppStrings.nameLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancelButton),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text(AppStrings.saveButton),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    try {
      final user =
          await ref.read(profileApiProvider).updateProfile(name: name);
      ref.read(authControllerProvider.notifier).setUser(user);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _sendFeedback() async {
    setState(() => _sendingFeedback = true);
    try {
      await ref.read(profileApiProvider).sendFeedback(
            rating: _rating,
            kesan: _kesan.text.trim(),
            saran: _saran.text.trim(),
          );
      if (!mounted) return;
      _kesan.clear();
      _saran.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.feedbackSent)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _sendingFeedback = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutTitle),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.logoutButton),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final settings = ref.watch(settingsControllerProvider).orDefault;

    ImageProvider? avatar;
    if (_localPhotoPath != null) {
      avatar = FileImage(File(_localPhotoPath!));
    } else if (user?.photoUrl != null) {
      avatar = NetworkImage(user!.photoUrl!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundImage: avatar,
                          child: avatar == null
                              ? Text(
                                  (user?.name.isNotEmpty == true
                                          ? user!.name[0]
                                          : '?')
                                      .toUpperCase(),
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.camera_alt,
                                size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user?.name ?? '-',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () =>
                            _editName(user?.name ?? ''),
                      ),
                    ],
                  ),
                  Text(user?.email ?? '',
                      style:
                          const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.settingsSection,
                style: Theme.of(context).textTheme.titleMedium),
            if (_bioAvailable)
              SwitchListTile(
                title:
                    const Text(AppStrings.biometricSetting),
                subtitle:
                    const Text(AppStrings.biometricSubtitle),
                value: _bioEnabled,
                onChanged: (v) async {
                  await ref
                      .read(tokenStorageProvider)
                      .setBiometricEnabled(v);
                  setState(() => _bioEnabled = v);
                },
              ),
            SwitchListTile(
              title: const Text(AppStrings.tiltSetting),
              subtitle:
                  const Text(AppStrings.tiltSubtitle),
              value: settings.tiltEnabled,
              onChanged: (v) => ref
                  .read(settingsControllerProvider.notifier)
                  .setTiltEnabled(v),
            ),
            ListTile(
              title: const Text(AppStrings.themeSetting),
              trailing: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined)),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(s.first),
              ),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.feedbackSection,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () =>
                      setState(() => _rating = i + 1),
                ),
              ),
            ),
            TextField(
              controller: _kesan,
              decoration: const InputDecoration(
                labelText: AppStrings.kesanLabel,
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _saran,
              decoration: const InputDecoration(
                labelText: AppStrings.saranLabel,
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed:
                  _sendingFeedback ? null : _sendFeedback,
              icon: const Icon(Icons.send_outlined),
              label:
                  const Text(AppStrings.sendFeedbackButton),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label:
                  const Text(AppStrings.logoutButton),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
