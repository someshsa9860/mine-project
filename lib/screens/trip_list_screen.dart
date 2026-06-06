import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trip_model.dart';
import '../services/api_service.dart';
import '../widgets/trip_list_unit.dart';

final tripListProvider = FutureProvider<List<TripModel>>((ref) async {
  return await ApiService().fetchTripsFromServer();
});

class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  @override
  void initState() {
    super.initState();

    /// 🔥 Auto-refresh silently when page is opened again
    Future.microtask(() {
      ref.refresh(tripListProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('List of Trips')),
      body: SafeArea(
        child: tripAsync.when(
          data: (trips) {
            if (trips.isEmpty) {
              return const Center(child: Text("No trips available"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(tripListProvider);
              },
              child: ListView.builder(
                itemCount: trips.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  return TripListUnit(trip: trips[index]);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }
}
