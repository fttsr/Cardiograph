import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/storage/app_box.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneNameController = TextEditingController();
  final _emailNameController = TextEditingController();

  DateTime? _birthDate;

  bool _filledOnce = false;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneNameController.dispose();
    _emailNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await sl<AppBox>().clearSession();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _save(BuildContext context) {
    context.read<ProfileBloc>().add(
          ProfileSaveRequested(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            middleName: _middleNameController.text.trim(),
            phone: _phoneNameController.text.trim(),
            email: _emailNameController.text.trim(),
            dateOfBirth: _birthDate?.toIso8601String().split('T').first,
          ),
        );
  }

  void _fillControllersIfNeeded(ProfileState state) {
    if (_filledOnce) return;

    final hasAny =
        (state.firstName != null) ||
        (state.lastName != null) ||
        (state.middleName != null) ||
        (state.phone != null) ||
        (state.email != null) ||
        (state.dateOfBirth != null);

    if (!hasAny) return;

    _firstNameController.text = state.firstName ?? '';
    _lastNameController.text = state.lastName ?? '';
    _middleNameController.text = state.middleName ?? '';
    _phoneNameController.text = state.phone ?? '';
    _emailNameController.text = state.email ?? '';

    _birthDate = (state.dateOfBirth != null && state.dateOfBirth!.isNotEmpty)
        ? DateTime.tryParse(state.dateOfBirth!)
        : null;

    _filledOnce = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.saved != c.saved || p.error != c.error,
        listener: (context, state) {
          if (state.saved) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          _fillControllersIfNeeded(state);

          return Scaffold(
            appBar: AppBar(title: const Text('Профиль')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.loading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                  ],

                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Фамилия',
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Имя',
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _middleNameController,
                    label: 'Отчество',
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickBirthDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Дата рождения',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _birthDate != null ? _formatDate(_birthDate!) : 'Выберите дату',
                        style: TextStyle(
                          color: _birthDate != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _phoneNameController,
                    label: 'Телефон',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _emailNameController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: state.saving ? null : () => _save(context),
                    child: state.saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Сохранить'),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => _logout(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Выйти из аккаунта'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}