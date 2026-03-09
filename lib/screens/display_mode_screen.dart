/// Display Mode screen (Customer View) for QuickQueue Pro.
///
/// Full-screen display showing the currently-being-served token number
/// with large animated text, auto-updating from Firestore.
/// Includes optional Text-to-Speech announcement.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class DisplayModeScreen extends StatefulWidget {
  const DisplayModeScreen({super.key});

  @override
  State<DisplayModeScreen> createState() => _DisplayModeScreenState();
}

class _DisplayModeScreenState extends State<DisplayModeScreen>
    with TickerProviderStateMixin {
  late final String _vendorId;
  final FlutterTts _tts = FlutterTts();
  int? _lastSpokenToken;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _vendorId = context.read<AuthProvider>().currentUser!.uid;

    // Pulse animation for the "Now Serving" indicator.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initTts();

    // Enter immersive full-screen mode.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(2.0);
    await _tts.setPitch(0.15);
  }

  /// Announce the token number via TTS.
  Future<void> _speakToken(int tokenNumber) async {
    if (_lastSpokenToken != tokenNumber) {
      _lastSpokenToken = tokenNumber;
      await _tts.speak('Now serving token number $tokenNumber');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    // Restore system UI.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.read<OrderProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: GestureDetector(
        // Tap anywhere to exit display mode.
        onDoubleTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    theme.colorScheme.surface,
                    theme.colorScheme.surface,
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),

            // Main content
            Center(
              child: StreamBuilder<OrderModel?>(
                stream: orderProvider.latestReadyOrderStream(_vendorId),
                builder: (context, snapshot) {
                  final readyOrder = snapshot.data;

                  if (readyOrder != null) {
                    // Announce via TTS.
                    _speakToken(readyOrder.tokenNumber);
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App branding
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'QuickQueue Pro',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // "Now Serving" label
                      Text(
                        'NOW SERVING',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          letterSpacing: 6,
                          fontWeight: FontWeight.w300,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Token number with AnimatedSwitcher
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 1.0)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: readyOrder != null
                            ? Text(
                                '#${readyOrder.tokenNumber}',
                                key: ValueKey(readyOrder.tokenNumber),
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: -2,
                                ),
                              )
                            : Text(
                                '--',
                                key: const ValueKey('no-token'),
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Order items (if available)
                      if (readyOrder != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ORDER READY',
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Items in order
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: readyOrder.items.entries.map((entry) {
                            return Chip(
                              label: Text(
                                '${entry.key} × ${entry.value}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ] else
                        Text(
                          'Waiting for orders...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.35),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Exit hint at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Double-tap to exit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),

            // Back button (top-left, subtle)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
