import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show MewvioApp;
import 'account_repository.dart';

class AccountBootstrap extends StatefulWidget {
  const AccountBootstrap({super.key});
  @override
  State<AccountBootstrap> createState() => _AccountBootstrapState();
}

class _AccountBootstrapState extends State<AccountBootstrap> {
  late Future<AccountRepository> _repository = _initialize();

  Future<AccountRepository> _initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL',
          defaultValue: 'https://swbsevzhudttiwwlcdwl.supabase.co'),
      publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY',
          defaultValue: 'sb_publishable_2GgGavPqGxSlpqfnqcQJ0Q_fG2DzelS'),
    );
    return SupabaseAccountRepository(Supabase.instance.client);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AccountRepository>(
        future: _repository,
        builder: (context, snapshot) {
          final repository = snapshot.data;
          if (repository != null) return MewvioApp(accounts: repository);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: SafeArea(child: Center(
              child: snapshot.hasError
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Unable to start MEWVIO. Please try again.'),
                      FilledButton(
                        onPressed: () => setState(() => _repository = _initialize()),
                        child: const Text('Retry'),
                      ),
                    ])
                  : const CircularProgressIndicator(),
            ))),
          );
        },
      );
}
