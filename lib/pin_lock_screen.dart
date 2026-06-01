import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fem_health_provider.dart';

class PINLockScreen extends StatefulWidget {
  const PINLockScreen({super.key});

  @override
  State<PINLockScreen> createState() => _PINLockScreenState();
}

class _PINLockScreenState extends State<PINLockScreen> {
  String _pin = '';
  bool _error = false;
  bool _verified = false;

  void _handleKeyPress(String key) {
    if (_verified) return;
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
        _error = false;
      });
      if (_pin.length == 4) {
        _checkPin();
      }
    }
  }

  void _handleBackspace() {
    if (_verified) return;
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = false;
      });
    }
  }

  void _checkPin() {
    final correctPin = context.read<FemHealthProvider>().settings.pinCode;
    if (_pin == correctPin) {
      setState(() {
        _verified = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          context.read<FemHealthProvider>().onUnlock();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _error = true;
            _pin = '';
          });
        }
      });
    }
  }

  void _triggerBiometrics() {
    final correctPin = context.read<FemHealthProvider>().settings.pinCode;
    setState(() {
      _pin = correctPin;
    });
    _checkPin();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<FemHealthProvider>();
    final biometricsEnabled = provider.settings.biometricsEnabled;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 48),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _verified
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : _error
                          ? Colors.red.withValues(alpha: 0.1)
                          : colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _verified
                          ? Icons.verified_user
                          : _error
                          ? Icons.error_outline
                          : Icons.lock_outline,
                      color: _verified
                          ? const Color(0xFF10B981)
                          : _error
                          ? Colors.redAccent
                          : colors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Privacy Assured',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your data is encrypted and stored securely. We prioritize your confidentiality.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _error
                        ? 'Incorrect PIN, try again'
                        : _verified
                        ? 'Access Granted'
                        : 'Confirm current PIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: _error
                          ? Colors.redAccent
                          : _verified
                          ? const Color(0xFF10B981)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final hasVal = _pin.length > index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasVal
                              ? (_verified ? const Color(0xFF10B981) : colors.primary)
                              : Colors.transparent,
                          border: Border.all(
                            color: hasVal
                                ? (_verified ? const Color(0xFF10B981) : colors.primary)
                                : Colors.grey.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 24,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        if (!biometricsEnabled) return const SizedBox();
                        return IconButton(
                          onPressed: _triggerBiometrics,
                          icon: Icon(
                            Icons.fingerprint,
                            color: colors.primary,
                            size: 30,
                          ),
                        );
                      }
                      if (index == 10) {
                        return _buildKeypadButton('0');
                      }
                      if (index == 11) {
                        return IconButton(
                          onPressed: _handleBackspace,
                          icon: const Icon(Icons.backspace_outlined, size: 24),
                        );
                      }
                      return _buildKeypadButton('${index + 1}');
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hint: default passcode is ${provider.settings.pinCode}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    final colors = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: () => _handleKeyPress(digit),
      style: ElevatedButton.styleFrom(
        foregroundColor: colors.onSurface,
        backgroundColor: colors.surface,
        elevation: 0,
        shape: const CircleBorder(),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
        padding: EdgeInsets.zero,
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
