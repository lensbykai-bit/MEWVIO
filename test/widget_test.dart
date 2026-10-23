import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/main.dart';
import 'package:mewvio/mewvio_creator_page.dart';

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
    // Real camera initialization may remain pending without a native device.
    // Advance route animation without waiting for camera frames to settle.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MewvioCreatorPage), findsOneWidget);
    expect(find.text('PHOTO'), findsOneWidget);
    expect(find.text('TEXT'), findsOneWidget);
    expect(find.byKey(const Key('creator-shutter')), findsOneWidget);
    expect(find.byTooltip('Flip camera'), findsOneWidget);
    Navigator.of(tester.element(find.byType(MewvioCreatorPage))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-Profile')));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO Friend'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile Photo'), findsOneWidget);
    expect(find.text('Cover Photo'), findsOneWidget);
    expect(find.byKey(const Key('pick-avatar-photo')), findsOneWidget);
    expect(find.byKey(const Key('pick-cover-photo')), findsOneWidget);
    Navigator.of(tester.element(find.byType(MainShell))).pop();
    await tester.pumpAndSettle();
    // The profile copyright is below the lazily built photo grid; parity checks
    // validate the footer in the guest and signed-in profile source files.
    expect(find.text('MEWVIO Wallet'), findsNothing);
    expect(find.byTooltip('MEWVIO Wallet'), findsNothing);
    await tester.tap(find.byTooltip('MEWVIO menu'));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO Wallet'), findsNothing);
    expect(find.text('Diamonds shop (demo)'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
