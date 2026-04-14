import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:codepad_editor/main.dart';
import 'package:codepad_editor/models/editor_state.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => EditorState(),
        child: const CodePadApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
