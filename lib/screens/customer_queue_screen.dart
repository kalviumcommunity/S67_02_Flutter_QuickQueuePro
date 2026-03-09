import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../models/vendor_model.dart';
import '../widgets/vendor_card.dart';
import '../widgets/queue_token_card.dart';

class CustomerQueueScreen extends StatefulWidget {
  const CustomerQueueScreen({super.key});

  @override
  State<CustomerQueueScreen> createState() => _CustomerQueueScreenState();
}

class _CustomerQueueScreenState extends State<CustomerQueueScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _joinQueue(VendorModel vendor) async {
    final qp = context.read<QueueProvider>();
    final ok = await qp.joinQueue(vendor.id);
    if (!mounted) return;
    if (ok) {
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${vendor.name}\'s queue!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(qp.errorMessage ?? 'Failed to join queue'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QueueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Vendors'),
            Tab(text: 'My Tokens'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Vendor List ──────────────────────────────────────
          RefreshIndicator(
            onRefresh: qp.fetchVendors,
            child: qp.isLoading
                ? const Center(child: CircularProgressIndicator())
                : qp.vendors.isEmpty
                    ? const Center(child: Text('No vendors available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: qp.vendors.length,
                        itemBuilder: (_, i) => VendorCard(
                          vendor: qp.vendors[i],
                          onJoin: () => _joinQueue(qp.vendors[i]),
                        ),
                      ),
          ),
          // ── My Queue Tokens ───────────────────────────────────
          RefreshIndicator(
            onRefresh: qp.fetchMyQueue,
            child: qp.isLoading
                ? const Center(child: CircularProgressIndicator())
                : qp.myQueues.isEmpty
                    ? const Center(child: Text('You have no active tokens'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: qp.myQueues.length,
                        itemBuilder: (_, i) => QueueTokenCard(
                          queue: qp.myQueues[i],
                          onCancel: () => qp.cancelQueue(qp.myQueues[i].id),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
