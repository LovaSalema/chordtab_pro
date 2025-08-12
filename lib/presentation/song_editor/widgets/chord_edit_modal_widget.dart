import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChordEditModalWidget extends StatefulWidget {
  final String initialChord;
  final Function(String) onSave;

  const ChordEditModalWidget({
    Key? key,
    required this.initialChord,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ChordEditModalWidget> createState() => _ChordEditModalWidgetState();
}

class _ChordEditModalWidgetState extends State<ChordEditModalWidget> {
  late TextEditingController _chordController;
  bool _isRomanNumeral = false;
  String _validationError = '';

  // Chord components
  final List<String> roots = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B'
  ];
  final List<String> romanNumerals = [
    'I',
    'ii',
    'iii',
    'IV',
    'V',
    'vi',
    'vii°'
  ];
  final List<String> qualities = ['', 'm', 'dim', 'aug', '+'];
  final List<String> extensions = ['', '7', 'maj7', 'add9', 'sus2', 'sus4'];
  final List<String> alterations = ['', '#5', 'b5', '#11', 'b9', '#9'];

  @override
  void initState() {
    super.initState();
    _chordController = TextEditingController(text: widget.initialChord);
    _isRomanNumeral = _detectRomanNumeral(widget.initialChord);
    _chordController.addListener(_validateChord);
  }

  @override
  void dispose() {
    _chordController.dispose();
    super.dispose();
  }

  bool _detectRomanNumeral(String chord) {
    final romanPattern = RegExp(r'^[ivxIVX]+');
    return romanPattern.hasMatch(chord);
  }

  void _validateChord() {
    final chord = _chordController.text.trim();
    if (chord.isEmpty) {
      setState(() => _validationError = '');
      return;
    }

    if (_isValidChord(chord)) {
      setState(() => _validationError = '');
    } else {
      setState(() => _validationError = 'Invalid chord notation');
    }
  }

  bool _isValidChord(String chord) {
    if (chord.isEmpty) return false;

    final chordPattern = RegExp(
        r'^[A-G][#b]?(maj7?|min7?|m7?|7|dim|aug|sus[24]?|add[29]|[+°])?(/[A-G][#b]?)?$');
    final romanPattern = RegExp(r'^[ivxIVX]+[°+]?[67]?$');

    return chordPattern.hasMatch(chord) ||
        romanPattern.hasMatch(chord) ||
        chord == 'N.C.' ||
        chord == '%' ||
        chord == 'X';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildNotationToggle(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  _buildChordInput(),
                  SizedBox(height: 3.h),
                  if (_isRomanNumeral)
                    _buildRomanNumeralInterface()
                  else
                    _buildStandardChordInterface(),
                  SizedBox(height: 3.h),
                  _buildQuickChords(),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.initialChord.isEmpty ? 'Add Chord' : 'Edit Chord',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.inactive,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotationToggle() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isRomanNumeral = false),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color:
                      !_isRomanNumeral ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'Standard',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: !_isRomanNumeral
                          ? AppTheme.lightTheme.colorScheme.surface
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isRomanNumeral = true),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: _isRomanNumeral ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'Roman Numeral',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: _isRomanNumeral
                          ? AppTheme.lightTheme.colorScheme.surface
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChordInput() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _validationError.isEmpty
              ? AppTheme.lightTheme.colorScheme.outline
              : AppTheme.error,
          width: _validationError.isEmpty ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chord Notation',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _chordController,
            style: AppTheme.getMonospaceStyle(
              isLight: true,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ).copyWith(
              color: _validationError.isEmpty
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.error,
            ),
            decoration: InputDecoration(
              hintText: _isRomanNumeral
                  ? 'e.g., V7, ii7, vii°'
                  : 'e.g., Cmaj7, Am, F#dim',
              hintStyle: AppTheme.getMonospaceStyle(
                isLight: true,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
              ).copyWith(
                color: AppTheme.inactive,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
            ],
          ),
          if (_validationError.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.error,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  _validationError,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStandardChordInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChordSection('Root Note', roots),
        SizedBox(height: 2.h),
        _buildChordSection('Quality', qualities),
        SizedBox(height: 2.h),
        _buildChordSection('Extensions', extensions),
        SizedBox(height: 2.h),
        _buildChordSection('Alterations', alterations),
      ],
    );
  }

  Widget _buildRomanNumeralInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChordSection('Roman Numeral', romanNumerals),
        SizedBox(height: 2.h),
        _buildChordSection('Extensions', ['', '7', '6', '9', '11', '13']),
      ],
    );
  }

  Widget _buildChordSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            return InkWell(
              onTap: () => _appendToChord(option),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  option.isEmpty ? 'Clear' : option,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickChords() {
    final quickChords = _isRomanNumeral
        ? ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°', 'V7', 'ii7', 'IM7']
        : [
            'C',
            'Dm',
            'Em',
            'F',
            'G',
            'Am',
            'B°',
            'C7',
            'Dm7',
            'Cmaj7',
            'N.C.',
            '%'
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Insert',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: quickChords.map((chord) {
            return InkWell(
              onTap: () => _setChord(chord),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.accent,
                    width: 1,
                  ),
                ),
                child: Text(
                  chord,
                  style: AppTheme.getMonospaceStyle(
                    isLight: true,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ).copyWith(
                    color: AppTheme.accent,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                side: BorderSide(color: AppTheme.inactive),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.inactive,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _validationError.isEmpty &&
                      _chordController.text.trim().isNotEmpty
                  ? _saveChord
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.lightTheme.colorScheme.surface,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                elevation: 0,
              ),
              child: Text(
                'Save Chord',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _appendToChord(String addition) {
    if (addition.isEmpty) {
      _chordController.clear();
    } else {
      _chordController.text += addition;
    }
  }

  void _setChord(String chord) {
    _chordController.text = chord;
  }

  void _saveChord() {
    final chord = _chordController.text.trim();
    if (chord.isNotEmpty && _validationError.isEmpty) {
      widget.onSave(chord);
      Navigator.pop(context);
      HapticFeedback.lightImpact();
    }
  }
}
