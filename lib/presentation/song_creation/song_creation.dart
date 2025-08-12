import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chord_input_widget.dart';
import './widgets/key_signature_selector_widget.dart';
import './widgets/song_structure_builder_widget.dart';
import './widgets/tempo_input_widget.dart';
import './widgets/title_input_widget.dart';
import './widgets/tuning_selector_widget.dart';

class SongCreation extends StatefulWidget {
  const SongCreation({Key? key}) : super(key: key);

  @override
  State<SongCreation> createState() => _SongCreationState();
}

class _SongCreationState extends State<SongCreation> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tempoController =
      TextEditingController(text: '120');

  String _selectedKey = '';
  String _selectedTuning = '';
  List<Map<String, dynamic>> _sections = [];
  String _titleError = '';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _mockSongs = [
    {
      "id": "1",
      "title": "Autumn Leaves",
      "key": "G Major",
      "tempo": 120,
      "tuning": "Standard",
      "sections": [
        {
          "id": "1",
          "name": "A",
          "chords": "Cmaj7 - F7 - Bm7b5 - E7",
          "timeSignature": "4/4"
        },
        {
          "id": "2",
          "name": "B",
          "chords": "Am7 - D7 - Gmaj7 - Gmaj7",
          "timeSignature": "4/4"
        }
      ],
      "createdAt": "2025-08-10T15:30:00.000Z",
      "updatedAt": "2025-08-12T07:38:41.165496"
    },
    {
      "id": "2",
      "title": "Blue Moon",
      "key": "C Major",
      "tempo": 100,
      "tuning": "Standard",
      "sections": [
        {
          "id": "1",
          "name": "Verse",
          "chords": "I - vi - IV - V",
          "timeSignature": "4/4"
        },
        {
          "id": "2",
          "name": "Chorus",
          "chords": "vi - IV - I - V",
          "timeSignature": "4/4"
        }
      ],
      "createdAt": "2025-08-11T09:15:00.000Z",
      "updatedAt": "2025-08-11T14:22:00.000Z"
    }
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _tempoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: EdgeInsets.all(2.w),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Create Song',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSong,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.lightTheme.colorScheme.surface,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.surface,
                        ),
                      ),
                    )
                  : Text(
                      'Save',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleInputWidget(
                controller: _titleController,
                errorText: _titleError.isEmpty ? null : _titleError,
              ),
              SizedBox(height: 3.h),
              KeySignatureSelectorWidget(
                selectedKey: _selectedKey,
                onKeySelected: (key) {
                  setState(() => _selectedKey = key);
                },
              ),
              SizedBox(height: 3.h),
              TempoInputWidget(
                controller: _tempoController,
                onTempoSelected: (tempo) {
                  setState(() {
                    _tempoController.text = tempo.toString();
                  });
                },
              ),
              SizedBox(height: 3.h),
              TuningSelectorWidget(
                selectedTuning: _selectedTuning,
                onTuningSelected: (tuning) {
                  setState(() => _selectedTuning = tuning);
                },
              ),
              SizedBox(height: 3.h),
              SongStructureBuilderWidget(
                sections: _sections,
                onSectionsChanged: (sections) {
                  setState(() => _sections = sections);
                },
              ),
              SizedBox(height: 3.h),
              ChordInputWidget(
                initialChords: '',
                onChordsChanged: (chords) {
                  // Update the current section's chords if any section is selected
                  if (_sections.isNotEmpty) {
                    setState(() {
                      _sections.last['chords'] = chords;
                    });
                  }
                },
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSong() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      final newSong = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": _titleController.text.trim(),
        "key": _selectedKey,
        "tempo": int.tryParse(_tempoController.text) ?? 120,
        "tuning": _selectedTuning,
        "sections": _sections,
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
      };

      // Simulate saving to local storage
      final prefs = await SharedPreferences.getInstance();
      final existingSongs = prefs.getStringList('songs') ?? [];
      final updatedSongs = List<String>.from(existingSongs)
        ..add(json.encode(newSong));

      await prefs.setStringList('songs', updatedSongs);

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Song "${_titleController.text.trim()}" saved successfully!',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to song library
        Navigator.pushReplacementNamed(context, '/song-library');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save song. Please try again.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate title
    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Song title is required');
      isValid = false;
    } else if (_titleController.text.trim().length < 2) {
      setState(() => _titleError = 'Song title must be at least 2 characters');
      isValid = false;
    } else {
      setState(() => _titleError = '');
    }

    // Validate tempo
    final tempo = int.tryParse(_tempoController.text);
    if (tempo == null || tempo < 40 || tempo > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempo must be between 40 and 200 BPM',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      isValid = false;
    }

    return isValid;
  }
}
