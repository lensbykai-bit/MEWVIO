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
    expect(find.byKey(const Key('nav-Friends')), findsOneWidget);
    expect(find.byKey(const Key('nav-Inbox')), findsOneWidget);
    expect(find.byKey(const Key('nav-Profile')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
