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
    expect(find.byKey(const Key('nav-Create')), findsOneWidget);
    expect(find.byKey(const Key('nav-Chat')), findsOneWidget);
    expect(find.byKey(const Key('nav-Profile')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byKey(const Key('social-home-feed')), findsOneWidget);
    expect(find.text('Videos'), findsWidgets);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-Create')));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO Hub'), findsOneWidget);
    expect(find.text('Post • Home'), findsOneWidget);
    expect(find.text('Voice Party demo'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-Profile')));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO Friend'), findsOneWidget);
    expect(find.text('© 2026 MEWVIO Technologies. All rights reserved.'), findsOneWidget);
    expect(find.text('MEWVIO Wallet'), findsNothing);
    expect(find.byTooltip('MEWVIO Wallet'), findsNothing);
    await tester.tap(find.byTooltip('MEWVIO menu'));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO Wallet'), findsNothing);
    expect(find.text('Diamonds shop (demo)'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
