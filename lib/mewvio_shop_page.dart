import 'package:flutter/material.dart';

const _violet = Color(0xFF6739E9);
const _pink = Color(0xFFEC54BE);
const _ink = Color(0xFF211452);

class MewvioShopPage extends StatefulWidget {
  const MewvioShopPage({super.key});
  @override
  State<MewvioShopPage> createState() => _MewvioShopPageState();
}

class _MewvioShopPageState extends State<MewvioShopPage> {
  int selectedTab = 0;
  int demoBalance = 0;
  final List<String> activity = [];
  static const bundles = <(int, String)>[
    (50, '0.49'), (120, '0.99'), (300, '2.49'),
    (650, '4.99'), (1400, '9.99'), (3000, '19.99')
  ];
  static const gifts = <(String, String, int)>[
    ('🌹', 'Rose', 1), ('💝', 'Heart', 10),
    ('🐻', 'Teddy', 50), ('🐱', 'Cat', 100),
    ('🎆', 'Fireworks', 150), ('👑', 'Crown', 300),
  ];

  void notify(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );

  void showBundle(int amount, String price) {
    showModalBottomSheet<void>(
      context: context, showDragHandle: true,
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.diamond_rounded, color: _violet, size: 56),
          const SizedBox(height: 10),
          Text('$amount Diamonds', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('US\$$price', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 14),
          const Text('Cambodia beta preview. No real payment is taken and no diamonds are sold yet.',
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close preview')),
        ]),
      )),
    );
  }

  void showGift(String name, int cost) {
    if (demoBalance < cost) {
      notify('Demo wallet is empty. Real purchases are disabled.');
      return;
    }
    setState(() {
      demoBalance -= cost;
      activity.insert(0, '$name demo gift: -$cost gems');
    });
  }

  Widget topBanner() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF35136F), _violet, _pink]),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.diamond_rounded, color: Colors.white, size: 28),
        SizedBox(width: 8),
        Text('MEWVIO WALLET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        Spacer(),
        Text('BETA • DEMO', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
      const SizedBox(height: 15),
      Text('$demoBalance 💎', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32)),
      const SizedBox(height: 5),
      const Text('No real money or redeemable balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
    ]),
  );

  Widget tile({required Widget child}) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEDE6FA)),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(15, 19, 15, 30),
    children: [
      const Row(children: [
        Expanded(child: Text('MEWVIO Shop', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _ink))),
        Icon(Icons.shopping_bag_rounded, color: _pink, size: 27),
      ]),
      const SizedBox(height: 5),
      const Text('Cambodia Beta • Shop Preview', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      topBanner(),
      const SizedBox(height: 17),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(4, (i) {
          const names = ['Diamonds', 'Gifts', 'VIP', 'Avatar'];
          final active = selectedTab == i;
          return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
            selected: active,
            selectedColor: const Color(0xFFE9DCFF),
            label: Text(names[i], style: TextStyle(color: active ? _violet : _ink, fontWeight: FontWeight.bold)),
            onSelected: (_) => setState(() => selectedTab = i),
          ));
        })),
      ),
      const SizedBox(height: 17),
      if (selectedTab == 0) ...[
        const Text('Diamond Packs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: bundles.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: .86),
          itemBuilder: (context, i) {
            final b = bundles[i];
            return InkWell(
              onTap: () => showBundle(b.$1, b.$2),
              borderRadius: BorderRadius.circular(17),
              child: tile(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.diamond_rounded, color: _violet, size: 35),
                const SizedBox(height: 6),
                Text('${b.$1}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                Text('US\$${b.$2}', style: const TextStyle(color: _pink, fontSize: 12, fontWeight: FontWeight.bold)),
              ])),
            );
          },
        ),
      ] else if (selectedTab == 1) ...[
        const Text('Virtual Gifts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: gifts.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: .82),
          itemBuilder: (context, i) {
            final g = gifts[i];
            return InkWell(
              onTap: () => showGift(g.$2, g.$3),
              borderRadius: BorderRadius.circular(17),
              child: tile(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(g.$1, style: const TextStyle(fontSize: 32)),
                Text(g.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${g.$3} 💎', style: const TextStyle(color: _violet, fontSize: 12)),
              ])),
            );
          },
        ),
      ] else if (selectedTab == 2) ...[
        tile(child: const Column(children: [
          Icon(Icons.workspace_premium_rounded, color: _pink, size: 52),
          SizedBox(height: 10),
          Text('MEWVIO VIP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text('Profile badges and themes • Planned feature'),
          SizedBox(height: 12),
          Text('Not available for purchase in beta', style: TextStyle(color: Colors.black54)),
        ])),
      ] else ...[
        tile(child: const Column(children: [
          Icon(Icons.face_retouching_natural_rounded, color: _violet, size: 50),
          SizedBox(height: 12),
          Text('Avatar Items', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text('Frames, stickers and effects • Coming soon'),
        ])),
      ],
      const SizedBox(height: 21),
      const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _ink)),
      const SizedBox(height: 8),
      tile(child: Text(activity.isEmpty ? 'No transactions yet • Beta preview only' : activity.join('\n'),
        style: const TextStyle(color: Colors.black54))),
      const SizedBox(height: 18),
      const Text('Real payments, KHQR, PayPal, Google Play Billing and balances require verified backend integration. No payment processing is enabled.',
        style: TextStyle(color: Colors.black54, fontSize: 12), textAlign: TextAlign.center),
    ],
  );
}
