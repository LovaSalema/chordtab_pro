import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChordEditModalWidget extends StatefulWidget {
  final String initialChord;
  final Function(String) onChordUpdated;

  const ChordEditModalWidget({
    Key? key,
    required this.initialChord,
    required this.onChordUpdated,
  }) : super(key: key);

  @override
  State<ChordEditModalWidget> createState() => _ChordEditModalWidgetState();
}

class _ChordEditModalWidgetState extends State<ChordEditModalWidget> {
  late TextEditingController _chordController;
  String _selectedRoot = 'I';
  String _selectedQuality = '';
  String _selectedExtension = '';

  final List<String> _roots = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
  final List<String> _qualities = ['', 'm', 'dim', 'aug', '+'];
  final List<String> _extensions = [
    '',
    '7',
    'maj7',
    '9',
    '11',
    '13',
    'sus4',
    'sus2',
    'add9'
  ];

  @override
  void initState() {
    super.initState();
    _chordController = TextEditingController(text: widget.initialChord);
    _parseInitialChord();
  }

  void _parseInitialChord() {
    String chord = widget.initialChord;
    if (chord.isNotEmpty) {
      // Simple parsing logic for Roman numerals
      if (chord.contains('VII')) {
        _selectedRoot = 'VII';
      } else if (chord.contains('VI')) {
        _selectedRoot = 'VI';
      } else if (chord.contains('IV')) {
        _selectedRoot = 'IV';
      } else if (chord.contains('III')) {
        _selectedRoot = 'III';
      } else if (chord.contains('II')) {
        _selectedRoot = 'II';
      } else if (chord.contains('V')) {
        _selectedRoot = 'V';
      } else if (chord.contains('I')) {
        _selectedRoot = 'I';
      }

      // Parse quality and extension
      String remaining = chord.replaceFirst(_selectedRoot, '');
      if (remaining.contains('dim')) {
        _selectedQuality = 'dim';
        remaining = remaining.replaceFirst('dim', '');
      } else if (remaining.contains('aug') || remaining.contains('+')) {
        _selectedQuality = remaining.contains('aug') ? 'aug' : '+';
        remaining = remaining.replaceFirst(RegExp(r'aug|\+'), '');
      } else if (remaining.contains('m')) {
        _selectedQuality = 'm';
        remaining = remaining.replaceFirst('m', '');
      }

      _selectedExtension = remaining.trim();
    }
  }

  void _updateChord() {
    String newChord = _selectedRoot + _selectedQuality + _selectedExtension;
    _chordController.text = newChord;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Edit Chord',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          TextField(
            controller: _chordController,
            decoration: InputDecoration(
              labelText: 'Chord Symbol',
              hintText: 'Enter Roman numeral chord',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'music_note',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 3.h),
          Text(
            'Quick Select',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          _buildQuickSelectSection('Root', _roots, _selectedRoot, (value) {
            setState(() {
              _selectedRoot = value;
              _updateChord();
            });
          }),
          SizedBox(height: 2.h),
          _buildQuickSelectSection('Quality', _qualities, _selectedQuality,
              (value) {
            setState(() {
              _selectedQuality = value;
              _updateChord();
            });
          }),
          SizedBox(height: 2.h),
          _buildQuickSelectSection('Extension', _extensions, _selectedExtension,
              (value) {
            setState(() {
              _selectedExtension = value;
              _updateChord();
            });
          }),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onChordUpdated(_chordController.text);
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildQuickSelectSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Text(
                  option.isEmpty ? 'None' : option,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onSecondary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _chordController.dispose();
    super.dispose();
  }
}
