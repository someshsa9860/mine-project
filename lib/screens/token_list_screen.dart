import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/token_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../widgets/token_unit.dart';

final tokenListProvider = FutureProvider<List<TokenModel>>((ref) async {
  return await ApiService().fetchTokensFromServer();
});

class TokenListScreen extends ConsumerStatefulWidget {
  const TokenListScreen({super.key});

  @override
  ConsumerState<TokenListScreen> createState() => _TokenListScreenState();
}

class _TokenListScreenState extends ConsumerState<TokenListScreen> {
  @override
  void initState() {
    super.initState();
    // 🔁 Refresh silently after first frame
    Future.microtask(() => ref.refresh(tokenListProvider));
  }

  Future<void> _onRefresh() async {
    await ref.refresh(tokenListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final tokenAsync = ref.watch(tokenListProvider);
    final box = HiveService.instance.box;

    return Scaffold(
      appBar: AppBar(title: const Text('List of Tokens')),
      body: SafeArea(
        child: tokenAsync.when(
          data: (tokensOri) {
            return ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (BuildContext context, value, Widget? child) {
                var tokens = tokensOri
                    .where(
                      (e) => !HiveService.instance.deletedTokens.contains(e.id),
                    )
                    .toList();

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: tokens.isEmpty
                      ? const Center(child: Text("No tokens available"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: tokens.length,
                          itemBuilder: (context, index) {
                            return TokenListUnit(token: tokens[index]);
                          },
                        ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }
}
