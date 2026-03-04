import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/app_box.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AppBox appBox;
  final GetProfileUsecase getProfile;
  final SaveProfileUsecase saveProfile;

  ProfileBloc({
    required this.appBox,
    required this.getProfile,
    required this.saveProfile,
  }) : super(ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileSaveRequested>(_onSave);
  }

  Future<void> _onLoad(
    ProfileLoadRequested e,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(loading: true, error: null, saved: false),
    );
    try {
      final userId = appBox.userId;
      if (userId == null || userId.isEmpty) {
        emit(state.copyWith(loading: false));
        return;
      }

      final profile = await getProfile(userId);

      emit(
        state.copyWith(
          loading: false,
          firstName: profile['first_name'] as String?,
          lastName: profile['last_name'] as String?,
          middleName: profile['middle_name'] as String?,
          phone: profile['phone'] as String?,
          email: profile['email'] as String?,
          dateOfBirth: profile['date_of_birth'] as String?,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(loading: false, error: err.toString()),
      );
    }
  }

  Future<void> _onSave(
    ProfileSaveRequested e,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(saving: true, error: null, saved: false),
    );
    try {
      final userId = appBox.userId;
      if (userId == null || userId.isEmpty) {
        emit(
          state.copyWith(
            saving: false,
            error: 'Нет user_id в сессии',
          ),
        );
        return;
      }

      await saveProfile(
        userId: userId,
        firstName: e.firstName,
        lastName: e.lastName,
        middleName: e.middleName,
        phone: e.phone,
        email: e.email,
        dateOfBirth: e.dateOfBirth,
      );

      emit(state.copyWith(saving: false, saved: true));
    } catch (err) {
      emit(
        state.copyWith(
          saving: false,
          error: err.toString(),
          saved: false,
        ),
      );
    }
  }
}
