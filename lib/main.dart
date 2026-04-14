import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/editor_state.dart';
import 'screens/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => EditorState(),
      child: const CodePadApp(),
    ),
  );
}

class CodePadApp extends StatelessWidget {
  const CodePadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodePad Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF0E639C),
          secondary: const Color(0xFF4EC9B0),
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFD4D4D4),
          error: const Color(0xFFF44747),
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF323233),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF323233),
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2D2D2D),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFAEAFAD),
          selectionColor: Color(0xFF264F78),
          selectionHandleColor: Color(0xFF569CD6),
        ),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
    );
  }
}
