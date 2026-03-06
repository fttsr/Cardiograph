import 'package:ca_frontend/src/core/di/di.dart';
import 'package:ca_frontend/src/features/ecg/presentation/bloc/ecg_bloc.dart';
import 'package:ca_frontend/src/features/ecg/presentation/bloc/ecg_event.dart';
import 'package:ca_frontend/src/features/ecg/presentation/bloc/ecg_state.dart';
import 'package:ca_frontend/src/features/ecg/presentation/widgets/ecg_controls.dart';
import 'package:ca_frontend/src/features/ecg/presentation/widgets/ecg_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class EcgScreen extends StatelessWidget {
  const EcgScreen({super.key, required this.device});
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EcgBloc>()..add(EcgStarted(device)),
      child: BlocListener<EcgBloc, EcgBlocState>(
        listenWhen: (prev, curr) =>
            prev.flowStatus != curr.flowStatus ||
            prev.message != curr.message,
        listener: (context, s) {
          if (s.flowStatus == EcgFlowStatus.failure &&
              s.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(s.message!)));
          }

          if (s.flowStatus == EcgFlowStatus.saved) {
            Navigator.of(context).maybePop(true);
          }

          if (s.flowStatus == EcgFlowStatus.aborted) {
            Navigator.of(context).maybePop(false);
          }
        },
        child: BlocBuilder<EcgBloc, EcgBlocState>(
          builder: (context, s) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'ЭКГ — ${s.deviceName.isEmpty ? "Кардиограф" : s.deviceName}',
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!s.connected)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: const Text(
                          'Соединение с устройством потеряно',
                        ),
                      ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: EcgGraph(
                          heartRate: s.heartRate,
                          isRecording: s.isRecording,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'ЧСС',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.heartRate?.toString() ??
                                        '--',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'уд/мин',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Осталось',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${s.remainingSeconds}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'сек',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    EcgControls(
                      isRecording: s.isRecording,
                      isSaving: s.isSaving,
                      onToggleRecording: () =>
                          context.read<EcgBloc>().add(
                            const EcgToggleRecordingPressed(),
                          ),
                      onSave: () => context.read<EcgBloc>().add(
                        const EcgSavePressed(),
                      ),
                      onAbort: () => context.read<EcgBloc>().add(
                        const EcgAbortPressed(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
