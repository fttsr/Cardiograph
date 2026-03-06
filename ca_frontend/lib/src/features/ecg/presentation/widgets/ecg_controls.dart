import 'package:flutter/material.dart';

class EcgControls extends StatelessWidget {
  const EcgControls({
    super.key,
    required this.isRecording,
    required this.isSaving,
    required this.onToggleRecording,
    required this.onSave,
    required this.onAbort,
  });

  final bool isRecording;
  final bool isSaving;
  final VoidCallback onToggleRecording;
  final VoidCallback onSave;
  final VoidCallback onAbort;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : onToggleRecording,
            icon: Icon(
              isRecording ? Icons.pause : Icons.play_arrow,
            ),
            label: Text(isRecording ? 'Пауза' : 'Продолжить'),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Сохранить'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: isSaving ? null : onAbort,
                  child: const Text('Отмена'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
