import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileSaveRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? email;
  final String? dateOfBirth;

  const ProfileSaveRequested({
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.email,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    middleName,
    phone,
    email,
    dateOfBirth,
  ];
}
