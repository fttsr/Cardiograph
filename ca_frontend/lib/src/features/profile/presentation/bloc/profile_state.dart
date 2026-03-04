import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool loading;
  final bool saving;
  final bool saved;
  final String? error;

  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? email;
  final String? dateOfBirth;

  const ProfileState({
    required this.loading,
    required this.saving,
    required this.saved,
    this.error,
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.email,
    this.dateOfBirth,
  });

  factory ProfileState.initial() => const ProfileState(
    loading: false,
    saving: false,
    saved: false,
  );

  ProfileState copyWith({
    bool? loading,
    bool? saving,
    bool? saved,
    String? error,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    String? dateOfBirth,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      error: error,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    saving,
    saved,
    error,
    firstName,
    lastName,
    middleName,
    phone,
    email,
    dateOfBirth,
  ];
}
