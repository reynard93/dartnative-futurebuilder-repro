import 'dart:async';

import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

void main() {
  // Platform bindings + (once you add plugins) their FFI symbols. Keep this
  // as the FIRST line of main() — see lib/dartnative_plugin_registrant.dart.
  DartNativePluginRegistrant.registerAll();
  // App-wide system chrome default for the white template: dark status-bar
  // icons over the light background, transparent strips. Screens can override
  // in initState; the navigator restores this default on pop.
  SystemChrome.defaultStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
  runApp(const FutureBuilderDisposeDemo());
}

class FutureBuilderDisposeDemo extends StatefulWidget {
  const FutureBuilderDisposeDemo({super.key});

  @override
  State<FutureBuilderDisposeDemo> createState() =>
      _FutureBuilderDisposeDemoState();
}

class _FutureBuilderDisposeDemoState extends State<FutureBuilderDisposeDemo> {
  final _completion = Completer<int>();
  Timer? _removeTimer;
  Timer? _completeTimer;
  bool _showFuture = true;
  String _phase = '1. FutureBuilder mounted.\nThe future is pending.';

  @override
  void initState() {
    super.initState();
    print('ISSUE42: Demo started; FutureBuilder will mount with a pending future.');
    _removeTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _showFuture = false;
        _phase = '2. FutureBuilder removed.\nThe future is still pending.';
      });
      print('ISSUE42: Removing FutureBuilder from the real widget tree.');
    });
    _completeTimer = Timer(const Duration(seconds: 9), () {
      if (!mounted) return;
      setState(() {
        _phase = '3. Future completed after removal.\nCheck the dn run console.';
      });
      print('ISSUE42: Completing the pending future after removal.');
      _completion.complete(42);
    });
  }

  @override
  void dispose() {
    _removeTimer?.cancel();
    _completeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      brightness: Brightness.light,
      appBar: AppBar(
        title: const Text(
          'FutureBuilder disposal - #42',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _phase,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            if (_showFuture)
              FutureBuilder<int>(
                future: _completion.future,
                builder: (_, snapshot) => Text(
                  'FutureBuilder snapshot: ${snapshot.connectionState}',
                  textAlign: TextAlign.center,
                ),
              )
            else
              const Text(
                'FutureBuilder is no longer in this widget tree.',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            const Text(
              'Automatic reproduction: remove at 5 seconds, '
              'complete at 9 seconds.\n\n'
              'SDK errors are not caught or suppressed. '
              'The console is the failure evidence.\n\n'
              'Press R in dn run to restart the demonstration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B6B70),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
