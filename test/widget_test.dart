import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/main.dart';

import 'support/fake_accounts.dart';

void main() {
  testWidgets('The four-in-one social app exposes five navigation actions', (tester) async {
    final accounts = FakeAccounts();
    addTearDown(accounts.changes.close);
    await tester.pumpWidget(MewvioApp(accounts: accounts));
    expect(find.byKey(const Key('nav-Home')), findsOneWidget);
    expect(find.byKey(const Key('nav-Videos')), findsOneWidget);
    expect(find.byKey(const Key('nav-Chat')), findsOneWidget);
    expect(find.byKey(const Key('nav-Profile')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byKey(const Key('social-home-feed')), findsOneWidget);
    expect(find.text('Videos'), findsWidgets);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-Profile')));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO Friend'), findsOneWidget);
    expect(find.text('MEWVIO Wallet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
