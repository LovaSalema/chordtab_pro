import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ChordInputWidget extends StatefulWidget {
  final String initialChords;
  final Function(String) onChordsChanged;

  const ChordInputWidget({
    Key? key,
    required this.initialChords,
    required this.onChordsChanged,
  }) : super(key: key);

  @override
  State<ChordInputWidget> createState() => _ChordInputWidgetState();
}

class _ChordInputWidgetState extends State<ChordInputWidget> {
  late TextEditingController _controller;
  String? _errorText;

  final List<String> romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
  final List<String> modifiers = [
    'm',
    '7',
    'maj7',
    'dim',
    'aug',
    '9',
    '11',
    '13'
  ];
  final List<String> timeSignatures = ['4/4', '3/4', '2/4', '6/8'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialChords);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _errorText != null
              ? AppTheme.error
              : AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chord Progression',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 12.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              style: AppTheme.getMonospaceStyle(
                isLight: true,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'I - V - vi - IV',
                hintStyle: AppTheme.getMonospaceStyle(
                  isLight: true,
                  fontSize: 16.sp,
                ).copyWith(color: AppTheme.inactive),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                _validateChords(value);
                widget.onChordsChanged(value);
              },
            ),
          ),
          if (_errorText != null) ...[
            SizedBox(height: 1.h),
            Text(
              _errorText!,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.error,
                fontSize: 11.sp,
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Text(
            'Roman Numerals',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.inactive,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: romanNumerals.map((numeral) {
              return _buildChordButton(numeral, isPrimary: true);
            }).toList(),
          ),
          SizedBox(height: 2.h),
          Text(
            'Modifiers',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.inactive,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: modifiers.map((modifier) {
              return _buildChordButton(modifier, isPrimary: false);
            }).toList(),
          ),
          SizedBox(height: 2.h),
          Text(
            'Time Signatures',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.inactive,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: timeSignatures.map((signature) {
              return _buildChordButton(signature, isPrimary: false);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChordButton(String text, {required bool isPrimary}) {
    return InkWell(
      onTap: () => _insertChord(text),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.h,
        ),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.accent.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? AppTheme.accent
                : AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppTheme.getMonospaceStyle(
            isLight: true,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ).copyWith(
            color: isPrimary
                ? AppTheme.accent
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _insertChord(String chord) {
    final currentText = _controller.text;
    final selection = _controller.selection;

    String newText;
    if (selection.isValid) {
      newText = currentText.replaceRange(
        selection.start,
        selection.end,
        chord,
      );
    } else {
      newText = currentText + (currentText.isEmpty ? '' : ' ') + chord;
    }

    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset:
          selection.isValid ? selection.start + chord.length : newText.length,
    );

    _validateChords(newText);
    widget.onChordsChanged(newText);
  }

  void _validateChords(String chords) {
    if (chords.isEmpty) {
      setState(() => _errorText = null);
      return;
    }

    final chordPattern = RegExp(r'^[IVXivx]+[m]?[0-9]*[+\-#b]*[\s\-\|]*$');
    final parts = chords.split(RegExp(r'[\s\-\|]+'));

    for (final part in parts) {
      if (part.isNotEmpty && !chordPattern.hasMatch(part)) {
        setState(() => _errorText = 'Invalid chord notation: $part');
        return;
      }
    }

    setState(() => _errorText = null);
  }
}
