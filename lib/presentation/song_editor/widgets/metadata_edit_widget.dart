import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../song_creation/widgets/key_signature_selector_widget.dart';
import '../../song_creation/widgets/tempo_input_widget.dart';
import '../../song_creation/widgets/title_input_widget.dart';
import '../../song_creation/widgets/tuning_selector_widget.dart';

class MetadataEditWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController tempoController;
  final String selectedKey;
  final String selectedTuning;
  final String titleError;
  final Function(String) onKeyChanged;
  final Function(String) onTuningChanged;
  final VoidCallback onTitleChanged;
  final VoidCallback onTempoChanged;

  const MetadataEditWidget({
    Key? key,
    required this.titleController,
    required this.tempoController,
    required this.selectedKey,
    required this.selectedTuning,
    required this.titleError,
    required this.onKeyChanged,
    required this.onTuningChanged,
    required this.onTitleChanged,
    required this.onTempoChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.accent,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Metadata',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Modify song title, key signature, tempo, and tuning',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          TitleInputWidget(
            controller: titleController,
            errorText: titleError.isEmpty ? null : titleError,
          ),
          SizedBox(height: 3.h),
          KeySignatureSelectorWidget(
            selectedKey: selectedKey,
            onKeySelected: onKeyChanged,
          ),
          SizedBox(height: 3.h),
          TempoInputWidget(
            controller: tempoController,
            onTempoSelected: (tempo) {
              tempoController.text = tempo.toString();
              onTempoChanged();
            },
          ),
          SizedBox(height: 3.h),
          TuningSelectorWidget(
            selectedTuning: selectedTuning,
            onTuningSelected: onTuningChanged,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
