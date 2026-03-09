import 'package:flutter/material.dart';
import '../models/queue_model.dart';

class QueueTokenCard extends StatelessWidget {
  const QueueTokenCard({
    super.key,
    required this.queue,
    this.onCancel,
    this.showVendorActions = false,
  });

  final QueueModel queue;
  final VoidCallback? onCancel;
  final bool showVendorActions;

  Color get _statusColor {
    switch (queue.status) {
      case 'waiting':   return Colors.orange;
      case 'serving':   return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (queue.status) {
      case 'waiting':   return Icons.hourglass_empty;
      case 'serving':   return Icons.sync;
      case 'completed': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default:          return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Token circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${queue.tokenNumber}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(queue.vendorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        queue.status[0].toUpperCase() +
                            queue.status.substring(1),
                        style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  if (queue.isWaiting) ...[
                    const SizedBox(height: 4),
                    Text(
                      '~${queue.estimatedWaitMinutes} min wait',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                  if (showVendorActions && queue.customerName != null) ...[
                    const SizedBox(height: 4),
                    Text('Customer: ${queue.customerName}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (onCancel != null && queue.isWaiting)
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                tooltip: 'Cancel token',
                onPressed: onCancel,
              ),
          ],
        ),
      ),
    );
  }
}
