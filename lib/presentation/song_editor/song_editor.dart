import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chords_edit_widget.dart';
import './widgets/metadata_edit_widget.dart';
import './widgets/structure_edit_widget.dart';
import './widgets/undo_redo_toolbar_widget.dart';

class SongEditor extends StatefulWidget {
  const SongEditor({Key? key}) : super(key: key);

  @override
  State<SongEditor> createState() => _SongEditorState();
}

class _SongEditorState extends State<SongEditor>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // Song data
  Map<String, dynamic>? _songData;
  Map<String, dynamic>? _originalSongData;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tempoController = TextEditingController();

  // State
  String _selectedKey = '';
  String _selectedTuning = '';
  List<Map<String, dynamic>> _sections = [];
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  String _titleError = '';

  // Undo/Redo system
  List<Map<String, dynamic>> _undoHistory = [];
  List<Map<String, dynamic>> _redoHistory = [];
  int _maxHistorySize = 50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _tempoController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _hasUnsavedChanges) {
      _autoSave();
    }
  }

  void _loadSongData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _songData = Map<String, dynamic>.from(args);
      _originalSongData = Map<String, dynamic>.from(args);

      _titleController.text = _songData?['title'] ?? '';
      _tempoController.text = (_songData?['tempo'] ?? 120).toString();
      _selectedKey = _songData?['key'] ?? '';
      _selectedTuning = _songData?['tuning'] ?? '';
      _sections = List<Map<String, dynamic>>.from(_songData?['sections'] ?? []);

      _saveToHistory();
      setState(() {});
    }
  }

  void _saveToHistory() {
    final currentState = {
      'title': _titleController.text,
      'tempo': int.tryParse(_tempoController.text) ?? 120,
      'key': _selectedKey,
      'tuning': _selectedTuning,
      'sections': List<Map<String, dynamic>>.from(_sections),
    };

    _undoHistory.add(Map<String, dynamic>.from(currentState));
    if (_undoHistory.length > _maxHistorySize) {
      _undoHistory.removeAt(0);
    }
    _redoHistory.clear();
  }

  void _undo() {
    if (_undoHistory.length > 1) {
      _redoHistory.add(_undoHistory.removeLast());
      final previousState = _undoHistory.last;

      setState(() {
        _titleController.text = previousState['title'];
        _tempoController.text = previousState['tempo'].toString();
        _selectedKey = previousState['key'];
        _selectedTuning = previousState['tuning'];
        _sections = List<Map<String, dynamic>>.from(previousState['sections']);
        _hasUnsavedChanges = true;
      });

      HapticFeedback.lightImpact();
    }
  }

  void _redo() {
    if (_redoHistory.isNotEmpty) {
      final nextState = _redoHistory.removeLast();
      _undoHistory.add(Map<String, dynamic>.from(nextState));

      setState(() {
        _titleController.text = nextState['title'];
        _tempoController.text = nextState['tempo'].toString();
        _selectedKey = nextState['key'];
        _selectedTuning = nextState['tuning'];
        _sections = List<Map<String, dynamic>>.from(nextState['sections']);
        _hasUnsavedChanges = true;
      });

      HapticFeedback.lightImpact();
    }
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges) return;

    try {
      await _performSave(showMessage: false);
    } catch (e) {
      // Silent auto-save failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: AppTheme.lightTheme.appBarTheme.elevation,
          leading: InkWell(
            onTap: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _showUnsavedChangesDialog();
                if (shouldPop) Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Song',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
              ),
              if (_hasUnsavedChanges)
                Text(
                  'Unsaved changes',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.warning,
                    fontSize: 10.sp,
                  ),
                ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 2.w),
              child: TextButton(
                onPressed: _hasUnsavedChanges ? _cancelChanges : null,
                child: Text(
                  'Cancel',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color:
                        _hasUnsavedChanges ? AppTheme.error : AppTheme.inactive,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: ElevatedButton(
                onPressed:
                    _hasUnsavedChanges && !_isSaving ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasUnsavedChanges ? AppTheme.accent : AppTheme.inactive,
                  foregroundColor: AppTheme.lightTheme.colorScheme.surface,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: _hasUnsavedChanges ? 2 : 0,
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
                        'Save Changes',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(12.h),
            child: Column(
              children: [
                UndoRedoToolbarWidget(
                  canUndo: _undoHistory.length > 1,
                  canRedo: _redoHistory.isNotEmpty,
                  onUndo: _undo,
                  onRedo: _redo,
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.accent,
                  unselectedLabelColor: AppTheme.inactive,
                  indicatorColor: AppTheme.accent,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle:
                      AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  unselectedLabelStyle:
                      AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                  tabs: [
                    Tab(text: 'Metadata'),
                    Tab(text: 'Structure'),
                    Tab(text: 'Chords'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              MetadataEditWidget(
                titleController: _titleController,
                tempoController: _tempoController,
                selectedKey: _selectedKey,
                selectedTuning: _selectedTuning,
                titleError: _titleError,
                onKeyChanged: (key) {
                  setState(() {
                    _selectedKey = key;
                    _markAsChanged();
                    _saveToHistory();
                  });
                },
                onTuningChanged: (tuning) {
                  setState(() {
                    _selectedTuning = tuning;
                    _markAsChanged();
                    _saveToHistory();
                  });
                },
                onTitleChanged: () {
                  _markAsChanged();
                  _saveToHistory();
                },
                onTempoChanged: () {
                  _markAsChanged();
                  _saveToHistory();
                },
              ),
              StructureEditWidget(
                sections: _sections,
                onSectionsChanged: (sections) {
                  setState(() {
                    _sections = sections;
                    _markAsChanged();
                    _saveToHistory();
                  });
                },
              ),
              ChordsEditWidget(
                sections: _sections,
                onSectionsChanged: (sections) {
                  setState(() {
                    _sections = sections;
                    _markAsChanged();
                    _saveToHistory();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have unsaved changes. What would you like to do?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Editing',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inactive,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, false);
              await _saveChanges();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: Text(
              'Save & Exit',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _cancelChanges() {
    if (_originalSongData != null) {
      setState(() {
        _titleController.text = _originalSongData!['title'] ?? '';
        _tempoController.text = (_originalSongData!['tempo'] ?? 120).toString();
        _selectedKey = _originalSongData!['key'] ?? '';
        _selectedTuning = _originalSongData!['tuning'] ?? '';
        _sections = List<Map<String, dynamic>>.from(
            _originalSongData!['sections'] ?? []);
        _hasUnsavedChanges = false;
        _undoHistory.clear();
        _redoHistory.clear();
        _saveToHistory();
      });

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Changes cancelled',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
          ),
          backgroundColor: AppTheme.inactive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      await _performSave();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _performSave({bool showMessage = true}) async {
    final updatedSong = {
      ..._songData!,
      "title": _titleController.text.trim(),
      "key": _selectedKey,
      "tempo": int.tryParse(_tempoController.text) ?? 120,
      "tuning": _selectedTuning,
      "sections": _sections,
      "updatedAt": DateTime.now().toIso8601String(),
    };

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    final existingSongs = prefs.getStringList('songs') ?? [];
    final updatedSongs = existingSongs.map((songJson) {
      final song = json.decode(songJson);
      if (song['id'] == updatedSong['id']) {
        return json.encode(updatedSong);
      }
      return songJson;
    }).toList();

    await prefs.setStringList('songs', updatedSongs);

    if (mounted) {
      setState(() => _hasUnsavedChanges = false);

      if (showMessage) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Song "${_titleController.text.trim()}" updated successfully!',
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
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Song title is required');
      _tabController.animateTo(0); // Switch to metadata tab
      isValid = false;
    } else if (_titleController.text.trim().length < 2) {
      setState(() => _titleError = 'Song title must be at least 2 characters');
      _tabController.animateTo(0);
      isValid = false;
    } else {
      setState(() => _titleError = '');
    }

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
      _tabController.animateTo(0);
      isValid = false;
    }

    return isValid;
  }
}
