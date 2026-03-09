import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../widgets/queue_token_card.dart';

class VendorDashboardScreen extends StatefulWidget {
  final String vendorId;

  const VendorDashboardScreen({super.key, required this.vendorId});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueProvider>().fetchVendorQueue(widget.vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QueueProvider>();
    final waiting = qp.vendorQueue.where((q) => q.isWaiting).toList();
    final serving = qp.vendorQueue.where((q) => q.isServing).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Queue'),
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => qp.fetchVendorQueue(widget.vendorId),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats Bar ──────────────────────────────────────────
          Container(
            color: const Color(0xFF4A90D9).withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(label: 'Waiting', count: waiting.length, color: Colors.orange),
                _StatChip(label: 'Serving', count: serving.length, color: Colors.green),
                _StatChip(label: 'Total',
                    count: qp.vendorQueue.length, color: const Color(0xFF4A90D9)),
              ],
            ),
          ),
          // ── Serve Next Button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Serve Next Customer',
                  style: TextStyle(fontSize: 16)),
              onPressed: waiting.isEmpty || qp.isLoading
                  ? null
                  : () => qp.serveNext(widget.vendorId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50C878),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // ── Queue List ─────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => qp.fetchVendorQueue(widget.vendorId),
              child: qp.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : qp.vendorQueue.isEmpty
                      ? const Center(child: Text('No customers in queue'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: qp.vendorQueue.length,
                          itemBuilder: (_, i) => QueueTokenCard(
                            queue: qp.vendorQueue[i],
                            showVendorActions: true,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
