import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picflow/theme/app_theme.dart';
import 'package:picflow/theme/app_colors.dart';

void main() {
  testWidgets('App theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          title: 'PicFlow',
          theme: AppTheme.lightTheme,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('PicFlow')),
          ),
        ),
      ),
    );

    expect(find.text('PicFlow'), findsOneWidget);
  });
}
