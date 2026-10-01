import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_language.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme.dart';

const _genders = {
  'male': 'genderMale',
  'female': 'genderFemale',
  'other': 'genderOther',
  'prefer_not': 'genderPreferNot',
};

/// Collects name, age, gender, height and weight. Shown once after sign-up
/// (before the home page), and again from "Edit profile".
class ProfileSetupScreen extends StatefulWidget {
  final Profile? initial;
  final VoidCallback onSaved;

  const ProfileSetupScreen({super.key, this.initial, required this.onSaved});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final _nameController = TextEditingController(
    text: widget.initial?.fullName ??
        AuthService.currentUser?.userMetadata?['full_name'] as String?,
  );
  late final _ageController =
      TextEditingController(text: widget.initial?.age?.toString());
  late final _heightController =
      TextEditingController(text: _format(widget.initial?.heightCm));
  late final _weightController =
      TextEditingController(text: _format(widget.initial?.weightKg));
  late String? _gender = widget.initial?.gender;

  bool _busy = false;
  String? _error;

  static String? _format(double? v) =>
      v == null ? null : (v == v.roundToDouble() ? v.toInt().toString() : '$v');

  bool get _isEditing => widget.initial?.isComplete ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    if (name.isEmpty) {
      setState(() => _error = context.t('nameRequiredError'));
      return;
    }
    if (age == null || age < 1 || age > 120) {
      setState(() => _error = context.t('ageRequiredError'));
      return;
    }
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await DataService.saveProfile(
        fullName: name,
        age: age,
        gender: _gender,
        heightCm: height != null && height > 0 ? height : null,
        weightKg: weight != null && weight > 0 ? weight : null,
        language: appLanguage.value,
      );
      if (!mounted) return;
      widget.onSaved();
      if (_isEditing) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _error = AuthService.describeError(e, context.t('genericError')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(_isEditing ? 'editProfile' : 'setupTitle')),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: AuthService.signOut,
              child: Text(context.t('signOut')),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (!_isEditing) ...[
                  Text(context.t('setupSubtitle')),
                  const SizedBox(height: 24),
                ],
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: context.t('fullNameLabel'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: context.t('ageLabel'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(context.t('genderLabel')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _genders.entries)
                      ChoiceChip(
                        label: Text(context.t(entry.value)),
                        selected: _gender == entry.key,
                        onSelected: (_) => setState(() => _gender = entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: context.t('heightLabel'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: context.t('weightLabel'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: tealDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(context.t(_isEditing ? 'save' : 'continueButton')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
