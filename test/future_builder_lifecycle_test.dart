import 'dart:async';

import 'package:dartnative/dartnative.dart';
import 'package:dartnative/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('FutureBuilder ignores completion after dispose', () async {
    final completion = Completer<int>();
    final widget = FutureBuilder<int>(
      future: completion.future,
      builder: (_, snapshot) => const SizedBox(),
    );
    final state = widget.createState();
    stateSetWidget(state, widget);
    stateSetMounted(state, value: true);
    state.initState();
    state.dispose();
    stateSetMounted(state, value: false);
    completion.complete(1);
    await Future<void>.delayed(Duration.zero);
  });
}
