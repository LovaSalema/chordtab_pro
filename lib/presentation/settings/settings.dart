import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chord_notation_selector_widget.dart';
import './widgets/default_settings_widget.dart';
import './widgets/font_size_selector_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/theme_selector_widget.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Settings state variables
  String _selectedTheme = 'system';
  String _selectedFontSize = 'medium';
  String _selectedChordNotation = 'roman';
  String _exportFormat = 'text';
  bool _enableSharing = true;

  Map<String, dynamic> _defaults = {
    'keySignature': 'C',
    'tempo': 120,
    'timeSignature': '4/4',
    'tuning': 'Standard',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedTheme = prefs.getString('theme') ?? 'system';
        _selectedFontSize = prefs.getString('fontSize') ?? 'medium';
        _selectedChordNotation = prefs.getString('chordNotation') ?? 'roman';
        _exportFormat = prefs.getString('exportFormat') ?? 'text';
        _enableSharing = prefs.getBool('enableSharing') ?? true;

        _defaults = {
          'keySignature': prefs.getString('defaultKeySignature') ?? 'C',
          'tempo': prefs.getInt('defaultTempo') ?? 120,
          'timeSignature': prefs.getString('defaultTimeSignature') ?? '4/4',
          'tuning': prefs.getString('defaultTuning') ?? 'Standard',
        };
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading settings",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', _selectedTheme);
      await prefs.setString('fontSize', _selectedFontSize);
      await prefs.setString('chordNotation', _selectedChordNotation);
      await prefs.setString('exportFormat', _exportFormat);
      await prefs.setBool('enableSharing', _enableSharing);

      await prefs.setString('defaultKeySignature', _defaults['keySignature']);
      await prefs.setInt('defaultTempo', _defaults['tempo']);
      await prefs.setString('defaultTimeSignature', _defaults['timeSignature']);
      await prefs.setString('defaultTuning', _defaults['tuning']);

      HapticFeedback.lightImpact();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error saving settings",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 24,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              SettingsSectionWidget(
                title: 'Appearance',
                children: [
                  SettingsItemWidget(
                    title: 'Theme',
                    subtitle: _getThemeDisplayName(),
                    iconName: 'palette',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _showThemeSelector,
                  ),
                  SettingsItemWidget(
                    title: 'Chord Font Size',
                    subtitle: _getFontSizeDisplayName(),
                    iconName: 'text_fields',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _showFontSizeSelector,
                  ),
                  SettingsItemWidget(
                    title: 'Chord Notation',
                    subtitle: _getChordNotationDisplayName(),
                    iconName: 'music_note',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _showChordNotationSelector,
                  ),
                ],
              ),

              // Default Settings Section
              SettingsSectionWidget(
                title: 'Default Settings',
                children: [
                  DefaultSettingsWidget(
                    defaults: _defaults,
                    onDefaultChanged: _onDefaultChanged,
                  ),
                ],
              ),

              // Export Preferences Section
              SettingsSectionWidget(
                title: 'Export Preferences',
                children: [
                  SettingsItemWidget(
                    title: 'Default Export Format',
                    subtitle: _exportFormat.toUpperCase(),
                    iconName: 'file_download',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _showExportFormatSelector,
                  ),
                  SettingsItemWidget(
                    title: 'Enable Sharing',
                    subtitle: 'Allow sharing songs with other apps',
                    iconName: 'share',
                    trailing: Switch(
                      value: _enableSharing,
                      onChanged: (value) {
                        setState(() {
                          _enableSharing = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ),
                ],
              ),

              // Data Management Section
              SettingsSectionWidget(
                title: 'Data Management',
                children: [
                  SettingsItemWidget(
                    title: 'Export All Songs',
                    subtitle: 'Save all songs to device storage',
                    iconName: 'backup',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _exportAllSongs,
                  ),
                  SettingsItemWidget(
                    title: 'Import Songs',
                    subtitle: 'Load songs from device storage',
                    iconName: 'file_upload',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _importSongs,
                  ),
                  SettingsItemWidget(
                    title: 'Clear All Data',
                    subtitle: 'Delete all songs and reset settings',
                    iconName: 'delete_forever',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 20,
                      color: AppTheme.error,
                    ),
                    onTap: _showClearDataDialog,
                  ),
                ],
              ),

              // About Section
              SettingsSectionWidget(
                title: 'About',
                children: [
                  SettingsItemWidget(
                    title: 'App Version',
                    subtitle: '1.0.0+1',
                    iconName: 'info',
                  ),
                  SettingsItemWidget(
                    title: 'Developer',
                    subtitle: 'ChordTab Pro Team',
                    iconName: 'person',
                    trailing: CustomIconWidget(
                      iconName: 'open_in_new',
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: "Developer information",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                  ),
                  SettingsItemWidget(
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    iconName: 'privacy_tip',
                    trailing: CustomIconWidget(
                      iconName: 'open_in_new',
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: "Opening privacy policy...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                  ),
                  SettingsItemWidget(
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    iconName: 'assignment',
                    trailing: CustomIconWidget(
                      iconName: 'open_in_new',
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: "Opening terms of service...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeDisplayName() {
    switch (_selectedTheme) {
      case 'light':
        return 'Light Theme';
      case 'dark':
        return 'Dark Theme';
      case 'system':
        return 'Follow System';
      default:
        return 'Follow System';
    }
  }

  String _getFontSizeDisplayName() {
    switch (_selectedFontSize) {
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      default:
        return 'Medium';
    }
  }

  String _getChordNotationDisplayName() {
    switch (_selectedChordNotation) {
      case 'roman':
        return 'Roman Numerals';
      case 'nashville':
        return 'Nashville Numbers';
      default:
        return 'Roman Numerals';
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              ThemeSelectorWidget(
                selectedTheme: _selectedTheme,
                onThemeChanged: (theme) {
                  setState(() {
                    _selectedTheme = theme;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Chord Font Size',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              FontSizeSelectorWidget(
                selectedFontSize: _selectedFontSize,
                onFontSizeChanged: (fontSize) {
                  setState(() {
                    _selectedFontSize = fontSize;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChordNotationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Chord Notation Style',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              ChordNotationSelectorWidget(
                selectedNotation: _selectedChordNotation,
                onNotationChanged: (notation) {
                  setState(() {
                    _selectedChordNotation = notation;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportFormatSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              title: const Text('Text Format'),
              subtitle: const Text('Plain text with chord notation'),
              leading: Radio<String>(
                value: 'text',
                groupValue: _exportFormat,
                onChanged: (value) {
                  setState(() {
                    _exportFormat = value!;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('PDF Format'),
              subtitle: const Text('Formatted document for printing'),
              leading: Radio<String>(
                value: 'pdf',
                groupValue: _exportFormat,
                onChanged: (value) {
                  setState(() {
                    _exportFormat = value!;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDefaultChanged(String key, dynamic value) {
    setState(() {
      _defaults[key] = value;
    });
    _saveSettings();
  }

  void _exportAllSongs() {
    Fluttertoast.showToast(
      msg: "Exporting all songs...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    // Implement actual export functionality here
  }

  void _importSongs() {
    Fluttertoast.showToast(
      msg: "Opening file picker...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    // Implement actual import functionality here
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your songs and reset all settings to defaults. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset to default values
      setState(() {
        _selectedTheme = 'system';
        _selectedFontSize = 'medium';
        _selectedChordNotation = 'roman';
        _exportFormat = 'text';
        _enableSharing = true;
        _defaults = {
          'keySignature': 'C',
          'tempo': 120,
          'timeSignature': '4/4',
          'tuning': 'Standard',
        };
      });

      HapticFeedback.lightImpact();
      Fluttertoast.showToast(
        msg: "All data cleared successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error clearing data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
