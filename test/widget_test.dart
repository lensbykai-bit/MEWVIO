import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/main.dart';

import 'support/fake_accounts.dart';

void main() {
  testWidgets('The video-first shell exposes five navigation actions', (tester) async {
    final accounts = FakeAccounts();
    addTearDown(accounts.changes.close);
    await tester.pumpWidget(MewvioApp(accounts: accounts));
    expect(find.byKey(const Key('nav-Home')), findsOneWidget);
    expect(find.byKey(const Key('nav-Match')), findsOneWidget);
    expect(find.byKey(const Key('nav-Chat')), findsOneWidget);
    expect(find.byKey(const Key('nav-Profile')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Match'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
