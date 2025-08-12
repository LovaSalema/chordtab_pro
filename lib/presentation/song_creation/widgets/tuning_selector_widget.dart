import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TuningSelectorWidget extends StatelessWidget {
  final String selectedTuning;
  final Function(String) onTuningSelected;

  const TuningSelectorWidget({
    Key? key,
    required this.selectedTuning,
    required this.onTuningSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tunings = [
      {'name': 'Standard', 'notes': 'E-A-D-G-B-E'},
      {'name': 'Drop D', 'notes': 'D-A-D-G-B-E'},
      {'name': 'DADGAD', 'notes': 'D-A-D-G-A-D'},
      {'name': 'Open G', 'notes': 'D-G-D-G-B-D'},
      {'name': 'Open D', 'notes': 'D-A-D-F#-A-D'},
      {'name': 'Half Step Down', 'notes': 'Eb-Ab-Db-Gb-Bb-Eb'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instrument Tuning',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: selectedTuning.isEmpty ? null : selectedTuning,
            decoration: InputDecoration(
              hintText: 'Select tuning',
              hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.inactive,
                fontSize: 16.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.accent,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.5.h,
              ),
            ),
            items: tunings.map((tuning) {
              return DropdownMenuItem<String>(
                value: tuning['name'],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tuning['name']!,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      tuning['notes']!,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.inactive,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onTuningSelected(value);
              }
            },
            dropdownColor: AppTheme.lightTheme.colorScheme.surface,
            icon: CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
