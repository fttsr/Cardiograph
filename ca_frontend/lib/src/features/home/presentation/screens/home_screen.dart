import 'package:ca_frontend/src/features/bluetooth/presentation/screens/bluetooth_connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/di/di.dart';
import '../../../../core/storage/app_box.dart';

import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatAgo(DateTime? dateTime) {
    if (dateTime == null) return "Нет данных";
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return "только что";
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} мин назад";
    }
    if (diff.inHours < 24) return "${diff.inHours}ч назад";
    return "${diff.inDays}д назад";
  }

  @override
  Widget build(BuildContext context) {
    final hiveBox = sl<Box>();
    final appBox = sl<AppBox>();

    return BlocProvider(
      create: (_) =>
          sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: ValueListenableBuilder(
        valueListenable: hiveBox.listenable(
          keys: const ['lastEcgTime', 'lastPdfOpenTime'],
        ),
        builder: (context, _, __) {
          final lastEcgTime = appBox.lastEcgTime;
          final lastPdfOpenTime = appBox.lastPdfOpenTime;

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            final firstName = state.firstName;
                            return Text(
                              (firstName == null ||
                                      firstName.trim().isEmpty)
                                  ? "Привет!"
                                  : "Привет, $firstName",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 28),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfileScreen(),
                              ),
                            );

                            if (updated == true &&
                                context.mounted) {
                              context.read<ProfileBloc>().add(
                                const ProfileLoadRequested(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Готовы начать?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),
                    _actionButton(
                      context,
                      title: 'Начать процедуру',
                      icon: Icons.play_arrow,
                      color: const Color.fromARGB(
                        255,
                        64,
                        103,
                        245,
                      ),
                      textColor: Colors.white,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BluetoothConnectionScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    _actionButton(
                      context,
                      title: "Предыдущие Результаты",
                      icon: Icons.manage_history,
                      color: Colors.white,
                      textColor: Colors.black,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                // const ResultsScreen(),
                                const HomeScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    _actionButton(
                      context,
                      title: "Инструкция",
                      icon: Icons.menu_book,
                      color: Colors.white,
                      textColor: Colors.black,
                      onPressed: () {},
                    ),

                    const SizedBox(height: 120),

                    const Text(
                      "Недавняя активность",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Column(
                      children: [
                        _activityItem(
                          icon: Icons.check_circle,
                          title: "Выполнение процедуры",
                          time: _formatAgo(lastEcgTime),
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _activityItem(
                          icon: Icons.bar_chart,
                          title: "Просмотр результатов",
                          time: _formatAgo(lastPdfOpenTime),
                          color: const Color.fromARGB(
                            255,
                            64,
                            103,
                            245,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required Color textColor,
  }) {
    return Center(
      child: SizedBox(
        height: 78,
        width: 350,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: textColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      height: 67,
      width: 350,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
