# DartNative FutureBuilder disposal reproduction

Minimal runnable reproduction for [DartNative/dartnative#42](https://github.com/DartNative/dartnative/issues/42).

A pending future completes after its `FutureBuilder` state is disposed. The SDK's own callback calls `setState()` and throws `setState() called after dispose()`.

## Run

Install the [DartNative SDK](https://dartnative.com/docs/getting-started/) and make `dn` available on PATH. Use `dn`, not plain `dart test` or Flutter: the test must run the compiled DartNative implementation rather than its declaration stubs.

```sh
git clone https://github.com/reynard93/dartnative-futurebuilder-repro.git
cd dartnative-futurebuilder-repro
dn pub get --no-example
dn test --no-pub --no-test-assets --reporter expanded test/future_builder_lifecycle_test.dart
```

No phone, emulator, application credentials, plugin registration, or native platform project is needed. This is an SDK lifecycle test, not a visual demo app.

## Result

On the tested SDK, the test **fails intentionally as a regression reproduction**, with exit code 1:

```text
setState() called after dispose()
package:dartnative/src/core.dart 166:12              State.setState
package:dartnative/src/widgets/builders.dart 325:9   _FutureBuilderState._subscribe.<fn>
```

After an SDK fix, the same test should pass unchanged with exit code 0. It does not catch or accept the assertion as success.

- [Captured failing test output](evidence/failing-test.txt)
- [SDK version and compiled build identity](evidence/sdk-version.txt)
- [Complete reproduction source](test/future_builder_lifecycle_test.dart)

Captured on macOS arm64, 2026-09-20, framework revision `9689ca2d76`, compiled SDK stamp `db1e0369d1dbdb3d`. Only the temporary checkout path in the test output is normalized to `<repro-root>`.

## Scope

The test creates the real SDK `FutureBuilder` state and drives its lifecycle through `stateSetWidget` and `stateSetMounted` from `package:dartnative/src/core.dart`: mounted initialization, disposal, unmounting, then completion of a `Completer`. These internal hooks are deliberate test machinery, not an application workaround. The test itself never calls `setState()`.

This confirms the success-after-disposal callback failure. It does not claim device navigation coverage, error-completion coverage, or future-replacement coverage. No screenshots are included: there is no UI surface in this reproduction, and the actual test output provides the relevant evidence.

Only the reproduction, manifest, instructions, and text evidence are published. SDK binaries, generated package configuration, local paths, and application files are excluded. The test package version is pinned; transitive dependencies resolve through the installed SDK and pub because DartNative SDK-local package paths are machine-specific.
