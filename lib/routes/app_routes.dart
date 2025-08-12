import 'package:flutter/material.dart';
import '../presentation/song_library/song_library.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/song_detail_view/song_detail_view.dart';
import '../presentation/song_creation/song_creation.dart';
import '../presentation/song_editor/song_editor.dart';
import '../presentation/settings/settings.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String songLibrary = '/song-library';
  static const String splash = '/splash-screen';
  static const String songDetailView = '/song-detail-view';
  static const String songCreation = '/song-creation';
  static const String songEditor = '/song-editor';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    songLibrary: (context) => const SongLibrary(),
    splash: (context) => const SplashScreen(),
    songDetailView: (context) => const SongDetailView(),
    songCreation: (context) => const SongCreation(),
    songEditor: (context) => const SongEditor(),
    settings: (context) => const Settings(),
    // TODO: Add your other routes here
  };
}
