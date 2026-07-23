# HydroQ Flutter MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete HydroQ Flutter MVP for remote hydroponic-water monitoring, including authentication, live pH/EC/TDS/volume status, reports, alerts, education, plant profiles, custom recipes, settings, offline states, and push-notification navigation.

**Architecture:** Use a feature-first Flutter structure. Riverpod controllers own presentation state, repositories isolate backend contracts, Dio handles REST traffic and token refresh, a WebSocket gateway handles realtime events, and secure/local storage keeps tokens plus clearly timestamped cached data. The UI uses three primary tabs—Beranda, Edukasi, and Profil—with reports and alert history nested under Beranda.

**Tech Stack:** Flutter 3.44.3, Dart 3.12.2, flutter_riverpod 3.3.2, go_router 17.3.0, dio 5.10.0, web_socket_channel 3.0.3, flutter_secure_storage 10.3.1, shared_preferences 2.5.5, fl_chart 1.2.0, firebase_core 4.12.1, firebase_messaging 16.4.3, flutter_local_notifications 22.1.0, intl 0.20.3, freezed 3.2.5, freezed_annotation 3.1.0, json_serializable 6.14.0, build_runner 2.15.2.

## Global Constraints

- Product language is Indonesian for the MVP.
- The official user-facing product name is `HydroQ`; preserve the exact capitalization everywhere.
- The Flutter project directory and Dart package name are `hydroq`.
- `DESIGN_SYSTEM.md` is the source of truth for colors, typography, spacing, radius, elevation, component states, accessibility, and responsive behavior.
- MVP theme is light-only and uses Poppins Regular, Medium, and SemiBold as locally bundled assets.
- UI tasks must consume shared design tokens and focused components; do not hardcode visual colors, spacing, radius, shadows, or status labels inside feature screens.
- Android minimum SDK is 23 because secure storage 10.x requires Android 6.0 or newer.
- Bottom navigation contains exactly Beranda, Edukasi, and Profil.
- Reports remain inside Beranda.
- One active tank is exposed in the MVP, but all repository methods keep `tankId` explicit.
- EC is authoritative; TDS is display-oriented and supplied by the backend.
- The Flutter client never computes authoritative warning, critical, recovery, cooldown, or alert-deduplication states.
- Cached sensor values always display their timestamp and age.
- Built-in plant profiles are read-only; custom recipes are editable.
- No automatic dosing, pH correction, pump control, camera, social features, AI recommendations, category filters, or multi-tank switching UI.
- Use Material 3 and an eight-point spacing rhythm.
- Use text and icons in addition to status colors.
- Every task must finish with passing tests and a focused commit.

---

## Design-System Execution Rules

1. Read `DESIGN_SYSTEM.md` before starting any task that creates or changes UI.
2. Task 3 must land before feature-screen work begins; later tasks import its tokens and shared components.
3. Golden tests cover the default, warning, critical, stale, offline, loading, empty, and large-text states identified in the design system.
4. Feature widgets may choose layout based on available width, but may not redefine the palette, type scale, spacing scale, radius scale, or elevation.
5. Plant imagery must use a consistent aspect ratio and `BoxFit.cover`; missing images use a neutral botanical placeholder rather than a broken image icon.
6. No authenticated page repeats the HydroQ wordmark as decoration; page titles describe the current destination.

---

## File Map

```text
hydroq/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── bootstrap.dart
│   │   ├── routing/app_router.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       ├── app_radius.dart
│   │       ├── app_shadows.dart
│   │       ├── app_spacing.dart
│   │       ├── app_theme.dart
│   │       ├── app_typography.dart
│   │       └── status_visuals.dart
│   ├── core/
│   │   ├── config/app_config.dart
│   │   ├── errors/app_exception.dart
│   │   ├── formatting/measurement_formatters.dart
│   │   ├── networking/api_client.dart
│   │   ├── networking/auth_interceptor.dart
│   │   ├── realtime/realtime_gateway.dart
│   │   ├── realtime/web_socket_realtime_gateway.dart
│   │   ├── storage/cache_store.dart
│   │   ├── storage/session_store.dart
│   │   ├── widgets/app_async_view.dart
│   │   ├── widgets/app_empty_state.dart
│   │   ├── widgets/app_error_state.dart
│   │   ├── widgets/app_search_field.dart
│   │   ├── widgets/app_section_header.dart
│   │   ├── widgets/app_skeleton.dart
│   │   └── widgets/app_status_badge.dart
│   └── features/
│       ├── auth/
│       ├── shell/
│       ├── dashboard/
│       ├── reports/
│       ├── alerts/
│       ├── education/
│       ├── plant_profile/
│       ├── profile/
│       ├── tank_settings/
│       ├── device_status/
│       ├── recipes/
│       └── notifications/
├── test/
│   ├── core/
│   ├── features/
│   ├── fixtures/
│   └── helpers/
├── integration_test/
│   └── app_flow_test.dart
├── analysis_options.yaml
├── pubspec.yaml
└── .github/workflows/flutter.yml
```

---

### Task 1: Scaffold the Flutter Project and Lock the Toolchain

**Files:**
- Create: `hydroq/pubspec.yaml`
- Create: `hydroq/analysis_options.yaml`
- Create: `hydroq/lib/main.dart`
- Create: `hydroq/lib/app/bootstrap.dart`
- Create: `hydroq/lib/core/config/app_config.dart`
- Modify: `hydroq/android/app/src/main/AndroidManifest.xml`
- Modify: `hydroq/ios/Runner/Info.plist`
- Test: `hydroq/test/core/config/app_config_test.dart`

**Interfaces:**
- Consumes: none.
- Produces: `AppConfig.fromEnvironment()`, `bootstrap()`, and the package root used by every later task.

- [ ] **Step 1: Create the Flutter application**

Run:

```bash
cd /mnt/data/hydroponic-app-spec
flutter create --org com.hydroq --platforms android,ios hydroq
cd hydroq
```

Expected: Flutter creates an application named `hydroq` and exits with `All done!`.

Set the native launcher display name immediately after creation:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:label="HydroQ"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>HydroQ</string>
<key>CFBundleName</key>
<string>HydroQ</string>
```

Keep the generated package identifier provisional during local MVP work. Replace it with an organization-owned reverse-domain identifier before store signing.

- [ ] **Step 2: Replace dependencies with the approved baseline**

Replace `pubspec.yaml` with:

```yaml
name: hydroq
description: HydroQ mobile monitoring for hydroponic nutrient water.
publish_to: none
version: 0.1.0+1

environment:
  sdk: '>=3.12.2 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.3.2
  go_router: ^17.3.0
  dio: ^5.10.0
  web_socket_channel: ^3.0.3
  flutter_secure_storage: ^10.3.1
  shared_preferences: ^2.5.5
  fl_chart: ^1.2.0
  firebase_core: ^4.12.1
  firebase_messaging: ^16.4.3
  flutter_local_notifications: ^22.1.0
  intl: ^0.20.3
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.15.2
  freezed: ^3.2.5
  json_serializable: ^6.14.0

flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/images/plants/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
          weight: 400
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
```

Create asset directories, retrieve the approved Poppins weights from the official Google Fonts repository, and resolve packages:

```bash
mkdir -p assets/images/plants assets/fonts
curl -L https://raw.githubusercontent.com/google/fonts/main/ofl/poppins/Poppins-Regular.ttf -o assets/fonts/Poppins-Regular.ttf
curl -L https://raw.githubusercontent.com/google/fonts/main/ofl/poppins/Poppins-Medium.ttf -o assets/fonts/Poppins-Medium.ttf
curl -L https://raw.githubusercontent.com/google/fonts/main/ofl/poppins/Poppins-SemiBold.ttf -o assets/fonts/Poppins-SemiBold.ttf
flutter pub get
```

Expected: `Got dependencies!` and no YAML parsing errors.

- [ ] **Step 3: Enable strict analysis**

Replace `analysis_options.yaml` with:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    always_use_package_imports: true
    avoid_dynamic_calls: true
    directives_ordering: true
    prefer_final_locals: true
    require_trailing_commas: true
    sort_constructors_first: true
    use_build_context_synchronously: true
```

- [ ] **Step 4: Write the failing configuration test**

Create `test/core/config/app_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/config/app_config.dart';

void main() {
  test('rejects a missing API base URL', () {
    expect(
      () => AppConfig(apiBaseUrl: '', realtimeBaseUrl: ''),
      throwsArgumentError,
    );
  });

  test('derives realtime URL from the API URL', () {
    final config = AppConfig.fromValues(
      apiBaseUrl: 'https://api.hydroq.test',
    );

    expect(config.realtimeBaseUrl, 'wss://api.hydroq.test');
  });
}
```

- [ ] **Step 5: Run the test and verify failure**

Run:

```bash
flutter test test/core/config/app_config_test.dart
```

Expected: FAIL because `AppConfig` does not exist.

- [ ] **Step 6: Implement environment configuration and bootstrap**

Create `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  AppConfig({
    required this.apiBaseUrl,
    required this.realtimeBaseUrl,
  }) {
    if (apiBaseUrl.isEmpty || realtimeBaseUrl.isEmpty) {
      throw ArgumentError('API and realtime base URLs must not be empty.');
    }
  }

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    );
    return AppConfig.fromValues(apiBaseUrl: apiBaseUrl);
  }

  factory AppConfig.fromValues({required String apiBaseUrl}) {
    final apiUri = Uri.parse(apiBaseUrl);
    final realtimeScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    return AppConfig(
      apiBaseUrl: apiUri.toString().replaceFirst(RegExp(r'/$'), ''),
      realtimeBaseUrl: apiUri
          .replace(scheme: realtimeScheme)
          .toString()
          .replaceFirst(RegExp(r'/$'), ''),
    );
  }

  final String apiBaseUrl;
  final String realtimeBaseUrl;
}
```

Create `lib/app/bootstrap.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydroq/app/app.dart';
import 'package:hydroq/core/config/app_config.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const HydroQApp(),
    ),
  );
}
```

Create a temporary `lib/app/app.dart` so the project compiles before Task 3:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydroq/core/config/app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw StateError('AppConfig must be overridden during bootstrap.'),
);

class HydroQApp extends StatelessWidget {
  const HydroQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HydroQ',
      home: Scaffold(body: Center(child: Text('HydroQ'))),
    );
  }
}
```

Replace `lib/main.dart` with:

```dart
import 'package:hydroq/app/bootstrap.dart';

Future<void> main() => bootstrap();
```

- [ ] **Step 7: Verify analysis and tests**

Run:

```bash
flutter analyze
flutter test test/core/config/app_config_test.dart
```

Expected: no analyzer issues and two passing tests.

- [ ] **Step 8: Commit**

```bash
git add hydroq
git commit -m "chore: scaffold HydroQ Flutter app"
```

---

### Task 2: Define Shared Domain Types, Status Priority, and Formatters

**Files:**
- Create: `hydroq/lib/core/models/measurement_status.dart`
- Create: `hydroq/lib/core/models/range_value.dart`
- Create: `hydroq/lib/core/models/sensor_snapshot.dart`
- Create: `hydroq/lib/core/formatting/measurement_formatters.dart`
- Test: `hydroq/test/core/models/measurement_status_test.dart`
- Test: `hydroq/test/core/formatting/measurement_formatters_test.dart`

**Interfaces:**
- Consumes: Flutter/Dart SDK only.
- Produces: `MeasurementStatus`, `OverallStatus`, `ParameterKind`, `RangeValue`, `SensorSnapshot`, `statusPriority()`, `formatPh()`, `formatEc()`, `formatTds()`, `formatVolume()`, and `formatReadingAge()`.

- [ ] **Step 1: Write failing status-priority tests**

Create `test/core/models/measurement_status_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/models/measurement_status.dart';

void main() {
  test('critical outranks warning and normal', () {
    expect(statusPriority(MeasurementStatus.critical), greaterThan(statusPriority(MeasurementStatus.warning)));
    expect(statusPriority(MeasurementStatus.warning), greaterThan(statusPriority(MeasurementStatus.normal)));
  });

  test('aggregate status uses incomplete when one sensor is unavailable', () {
    expect(
      aggregateOverallStatus([
        MeasurementStatus.normal,
        MeasurementStatus.unavailable,
        MeasurementStatus.normal,
      ]),
      OverallStatus.incomplete,
    );
  });

  test('critical outranks incomplete', () {
    expect(
      aggregateOverallStatus([
        MeasurementStatus.critical,
        MeasurementStatus.unavailable,
      ]),
      OverallStatus.critical,
    );
  });
}
```

Create `test/core/formatting/measurement_formatters_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/formatting/measurement_formatters.dart';

void main() {
  test('formats sensor values using stable units', () {
    expect(formatPh(6.234), '6,23');
    expect(formatEc(1.845), '1.85 mS/cm');
    expect(formatTds(1150.4), '1.150 ppm');
    expect(formatVolume(42.54), '42,5 L');
  });

  test('formats cached reading age in Indonesian', () {
    final now = DateTime.utc(2026, 7, 23, 12);
    expect(
      formatReadingAge(now.subtract(const Duration(minutes: 8)), now: now),
      '8 menit lalu',
    );
  });
}
```

- [ ] **Step 2: Verify the tests fail**

Run:

```bash
flutter test test/core/models/measurement_status_test.dart test/core/formatting/measurement_formatters_test.dart
```

Expected: FAIL because the imported files do not exist.

- [ ] **Step 3: Implement enums and aggregation**

Create `lib/core/models/measurement_status.dart`:

```dart
enum MeasurementStatus {
  normal,
  warning,
  critical,
  stale,
  unavailable,
}

enum OverallStatus {
  normal,
  warning,
  critical,
  stale,
  offline,
  incomplete,
  unconfigured,
}

enum ParameterKind { ph, nutrient, volume }

int statusPriority(MeasurementStatus status) => switch (status) {
      MeasurementStatus.normal => 0,
      MeasurementStatus.stale => 1,
      MeasurementStatus.unavailable => 2,
      MeasurementStatus.warning => 3,
      MeasurementStatus.critical => 4,
    };

OverallStatus aggregateOverallStatus(List<MeasurementStatus> statuses) {
  if (statuses.any((status) => status == MeasurementStatus.critical)) {
    return OverallStatus.critical;
  }
  if (statuses.any((status) => status == MeasurementStatus.warning)) {
    return OverallStatus.warning;
  }
  if (statuses.any((status) => status == MeasurementStatus.unavailable)) {
    return OverallStatus.incomplete;
  }
  if (statuses.any((status) => status == MeasurementStatus.stale)) {
    return OverallStatus.stale;
  }
  return OverallStatus.normal;
}
```

- [ ] **Step 4: Implement immutable shared models**

Create `lib/core/models/range_value.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'range_value.freezed.dart';
part 'range_value.g.dart';

@freezed
abstract class RangeValue with _$RangeValue {
  const factory RangeValue({
    required double minimum,
    required double maximum,
  }) = _RangeValue;

  factory RangeValue.fromJson(Map<String, Object?> json) =>
      _$RangeValueFromJson(json);
}
```

Create `lib/core/models/sensor_snapshot.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydroq/core/models/measurement_status.dart';

part 'sensor_snapshot.freezed.dart';
part 'sensor_snapshot.g.dart';

@freezed
abstract class SensorSnapshot with _$SensorSnapshot {
  const factory SensorSnapshot({
    required String tankId,
    required DateTime recordedAt,
    required DateTime receivedAt,
    double? ph,
    double? ecMsCm,
    double? tdsPpm,
    double? volumeLiters,
    double? volumePercent,
    @Default(<String, MeasurementStatus>{})
    Map<String, MeasurementStatus> parameterStatuses,
    required OverallStatus overallStatus,
  }) = _SensorSnapshot;

  factory SensorSnapshot.fromJson(Map<String, Object?> json) =>
      _$SensorSnapshotFromJson(json);
}
```

Generate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated `.freezed.dart` and `.g.dart` files for both models.

- [ ] **Step 5: Implement Indonesian measurement formatting**

Create `lib/core/formatting/measurement_formatters.dart`:

```dart
import 'package:intl/intl.dart';

final NumberFormat _decimal2 = NumberFormat('0.00', 'id_ID');
final NumberFormat _decimal1 = NumberFormat('0.0', 'id_ID');
final NumberFormat _integer = NumberFormat.decimalPattern('id_ID');

String formatPh(double? value) => value == null ? '—' : _decimal2.format(value);

String formatEc(double? value) =>
    value == null ? '—' : '${_decimal2.format(value)} mS/cm';

String formatTds(double? value) =>
    value == null ? '—' : '${_integer.format(value.round())} ppm';

String formatVolume(double? value) =>
    value == null ? '—' : '${_decimal1.format(value)} L';

String formatReadingAge(DateTime timestamp, {DateTime? now}) {
  final difference = (now ?? DateTime.now()).difference(timestamp);
  if (difference.inSeconds < 60) return '${difference.inSeconds} detik lalu';
  if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
  if (difference.inHours < 24) return '${difference.inHours} jam lalu';
  return '${difference.inDays} hari lalu';
}
```

- [ ] **Step 6: Run tests and code generation checks**

Run:

```bash
flutter test test/core/models/measurement_status_test.dart test/core/formatting/measurement_formatters_test.dart
flutter analyze
```

Expected: all tests pass and no analyzer issues.

- [ ] **Step 7: Commit**

```bash
git add hydroq/lib/core hydroq/test/core
git commit -m "feat: add sensor domain types and formatters"
```

---

### Task 3: Implement the HydroQ Design Foundation, Router, and Three-Tab Shell

**Files:**
- Create: `hydroq/lib/app/theme/app_colors.dart`
- Create: `hydroq/lib/app/theme/app_spacing.dart`
- Create: `hydroq/lib/app/theme/app_radius.dart`
- Create: `hydroq/lib/app/theme/app_shadows.dart`
- Create: `hydroq/lib/app/theme/app_typography.dart`
- Create: `hydroq/lib/app/theme/status_visuals.dart`
- Create: `hydroq/lib/app/theme/app_theme.dart`
- Create: `hydroq/lib/core/widgets/app_status_badge.dart`
- Create: `hydroq/lib/app/routing/app_router.dart`
- Modify: `hydroq/lib/app/app.dart`
- Create: `hydroq/lib/features/shell/presentation/main_shell.dart`
- Create: `hydroq/lib/features/dashboard/presentation/dashboard_screen.dart`
- Create: `hydroq/lib/features/education/presentation/education_screen.dart`
- Create: `hydroq/lib/features/profile/presentation/profile_screen.dart`
- Test: `hydroq/test/app/theme/app_theme_test.dart`
- Test: `hydroq/test/features/shell/main_shell_test.dart`

**Interfaces:**
- Consumes: `MeasurementStatus` and `OverallStatus` from Task 2; `appConfigProvider` from Task 1.
- Produces: stable visual tokens (`AppColors`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTypography`), status visual extensions, `AppStatusBadge`, route names in `AppRoute`, `routerProvider`, `MainShell`, and the light-only HydroQ `ThemeData` consumed by every later UI task.

- [ ] **Step 1: Write failing theme and shell tests**

Create `test/app/theme/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/app/theme/app_colors.dart';
import 'package:hydroq/app/theme/app_theme.dart';
import 'package:hydroq/app/theme/app_typography.dart';

void main() {
  test('HydroQ light theme uses locked brand foundations', () {
    final theme = AppTheme.light;

    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, AppColors.green500);
    expect(theme.scaffoldBackgroundColor, AppColors.neutral50);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);
    expect(theme.navigationBarTheme.height, 72);
  });
}
```

Create `test/features/shell/main_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/features/shell/presentation/main_shell.dart';

void main() {
  testWidgets('shows exactly three primary destinations', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(
          currentIndex: 0,
          onDestinationSelected: _noop,
          child: Text('Beranda'),
        ),
      ),
    );

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Edukasi'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });
}

void _noop(int _) {}
```

- [ ] **Step 2: Verify both tests fail**

Run:

```bash
flutter test test/app/theme/app_theme_test.dart test/features/shell/main_shell_test.dart
```

Expected: FAIL because the design-token files and `MainShell` do not exist.

- [ ] **Step 3: Implement color, spacing, radius, and shadow tokens**

Create `lib/app/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const green50 = Color(0xFFECF9F0);
  static const green100 = Color(0xFFD8F3E1);
  static const green200 = Color(0xFFB5E7C6);
  static const green300 = Color(0xFF7FD49B);
  static const green400 = Color(0xFF3DC469);
  static const green500 = Color(0xFF12B347);
  static const green600 = Color(0xFF0D963B);
  static const green700 = Color(0xFF087A32);
  static const green800 = Color(0xFF075F2A);
  static const green900 = Color(0xFF064921);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral25 = Color(0xFFFBFCFB);
  static const neutral50 = Color(0xFFF7F9F7);
  static const neutral100 = Color(0xFFF0F3F1);
  static const neutral200 = Color(0xFFE5EAE7);
  static const neutral300 = Color(0xFFD1D8D4);
  static const neutral400 = Color(0xFFA6AEA9);
  static const neutral500 = Color(0xFF747C77);
  static const neutral600 = Color(0xFF5D655F);
  static const neutral700 = Color(0xFF414843);
  static const neutral800 = Color(0xFF292F2B);
  static const neutral900 = Color(0xFF171B18);

  static const success = Color(0xFF159447);
  static const successSoft = Color(0xFFEAF7EF);
  static const warning = Color(0xFFD98200);
  static const warningSoft = Color(0xFFFFF4DD);
  static const critical = Color(0xFFC9363E);
  static const criticalSoft = Color(0xFFFDEBED);
  static const information = Color(0xFF2676C9);
  static const informationSoft = Color(0xFFEAF3FC);
  static const offline = Color(0xFF6F7772);
  static const offlineSoft = Color(0xFFEFF1F0);
  static const stale = Color(0xFFA26312);
  static const staleSoft = Color(0xFFFFF3E3);
}
```

Create `lib/app/theme/app_spacing.dart`:

```dart
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const huge = 48.0;
  static const massive = 64.0;
}
```

Create `lib/app/theme/app_radius.dart`:

```dart
abstract final class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xLarge = 24.0;
  static const full = 999.0;
}
```

Create `lib/app/theme/app_shadows.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const low = <BoxShadow>[
    BoxShadow(color: Color(0x0D171B18), blurRadius: 10, offset: Offset(0, 2)),
  ];
  static const medium = <BoxShadow>[
    BoxShadow(color: Color(0x17171B18), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const high = <BoxShadow>[
    BoxShadow(color: Color(0x24171B18), blurRadius: 40, offset: Offset(0, 18)),
  ];
}
```

- [ ] **Step 4: Implement typography and semantic status visuals**

Create `lib/app/theme/app_typography.dart`:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'Poppins';
  static const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];

  static const textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, height: 1.25, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 28, height: 1.29, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 24, height: 1.33, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 20, height: 1.4, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 18, height: 1.44, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 1.57),
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, height: 1.5),
    labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 1.43, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, height: 1.45, fontWeight: FontWeight.w500),
  );

  static const sensorValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w600,
    fontFeatures: tabularFigures,
  );
}
```

Create `lib/app/theme/status_visuals.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:hydroq/app/theme/app_colors.dart';
import 'package:hydroq/core/models/measurement_status.dart';

class StatusVisuals {
  const StatusVisuals({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData icon;
}

extension MeasurementStatusVisuals on MeasurementStatus {
  StatusVisuals get visuals => switch (this) {
        MeasurementStatus.normal => const StatusVisuals(label: 'Normal', foreground: AppColors.success, background: AppColors.successSoft, icon: Icons.check_circle_outline),
        MeasurementStatus.warning => const StatusVisuals(label: 'Peringatan', foreground: AppColors.warning, background: AppColors.warningSoft, icon: Icons.warning_amber_rounded),
        MeasurementStatus.critical => const StatusVisuals(label: 'Kritis', foreground: AppColors.critical, background: AppColors.criticalSoft, icon: Icons.error_outline),
        MeasurementStatus.stale => const StatusVisuals(label: 'Data terlambat', foreground: AppColors.stale, background: AppColors.staleSoft, icon: Icons.schedule),
        MeasurementStatus.unavailable => const StatusVisuals(label: 'Tidak tersedia', foreground: AppColors.offline, background: AppColors.offlineSoft, icon: Icons.sensors_off_outlined),
      };
}

extension OverallStatusVisuals on OverallStatus {
  StatusVisuals get visuals => switch (this) {
        OverallStatus.normal => const StatusVisuals(label: 'Normal', foreground: AppColors.success, background: AppColors.successSoft, icon: Icons.check_circle_outline),
        OverallStatus.warning => const StatusVisuals(label: 'Peringatan', foreground: AppColors.warning, background: AppColors.warningSoft, icon: Icons.warning_amber_rounded),
        OverallStatus.critical => const StatusVisuals(label: 'Kritis', foreground: AppColors.critical, background: AppColors.criticalSoft, icon: Icons.error_outline),
        OverallStatus.stale => const StatusVisuals(label: 'Data terlambat', foreground: AppColors.stale, background: AppColors.staleSoft, icon: Icons.schedule),
        OverallStatus.offline => const StatusVisuals(label: 'Offline', foreground: AppColors.offline, background: AppColors.offlineSoft, icon: Icons.cloud_off_outlined),
        OverallStatus.incomplete => const StatusVisuals(label: 'Data tidak lengkap', foreground: AppColors.information, background: AppColors.informationSoft, icon: Icons.info_outline),
        OverallStatus.unconfigured => const StatusVisuals(label: 'Belum dikonfigurasi', foreground: AppColors.offline, background: AppColors.offlineSoft, icon: Icons.tune),
      };
}
```

- [ ] **Step 5: Implement the light-only HydroQ theme**

Create `lib/app/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:hydroq/app/theme/app_colors.dart';
import 'package:hydroq/app/theme/app_radius.dart';
import 'package:hydroq/app/theme/app_spacing.dart';
import 'package:hydroq/app/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.green500,
      brightness: Brightness.light,
      primary: AppColors.green500,
      onPrimary: AppColors.neutral0,
      secondary: AppColors.green700,
      onSecondary: AppColors.neutral0,
      error: AppColors.critical,
      onError: AppColors.neutral0,
      surface: AppColors.neutral0,
      onSurface: AppColors.neutral900,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.neutral700,
        displayColor: AppColors.neutral900,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral900,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.neutral0,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
          side: BorderSide(color: AppColors.neutral100),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: AppColors.green700,
          side: const BorderSide(color: AppColors.neutral200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium), borderSide: const BorderSide(color: AppColors.neutral200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium), borderSide: const BorderSide(color: AppColors.green500, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium), borderSide: const BorderSide(color: AppColors.critical, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium), borderSide: const BorderSide(color: AppColors.critical, width: 1.5)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.neutral0,
        indicatorColor: AppColors.green50,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => AppTypography.textTheme.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected) ? AppColors.green700 : AppColors.neutral500,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.green500 : AppColors.neutral400,
        )),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.neutral100, thickness: 1, space: 1),
    );
  }
}
```

- [ ] **Step 6: Implement the reusable status badge**

Create `lib/core/widgets/app_status_badge.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:hydroq/app/theme/app_radius.dart';
import 'package:hydroq/app/theme/app_spacing.dart';
import 'package:hydroq/app/theme/status_visuals.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({required this.visuals, super.key});

  final StatusVisuals visuals;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status ${visuals.label}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: visuals.background,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(visuals.icon, size: 16, color: visuals.foreground),
              const SizedBox(width: AppSpacing.xs),
              Text(visuals.label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: visuals.foreground, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Implement the three-tab shell and temporary screens**

Create `lib/features/shell/presentation/main_shell.dart`:

```dart
import 'package:flutter/material.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.currentIndex, required this.onDestinationSelected, required this.child, super.key});

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.eco_outlined), selectedIcon: Icon(Icons.eco), label: 'Edukasi'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

Create `lib/features/dashboard/presentation/dashboard_screen.dart`:

```dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Beranda')),
      body: Center(child: Text('Beranda')),
    );
  }
}
```

Create `lib/features/education/presentation/education_screen.dart`:

```dart
import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Edukasi')),
      body: Center(child: Text('Edukasi')),
    );
  }
}
```

Create `lib/features/profile/presentation/profile_screen.dart`:

```dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Center(child: Text('Profil')),
    );
  }
}
```

- [ ] **Step 8: Implement nested navigation and wire HydroQ**

Create `lib/app/routing/app_router.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hydroq/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hydroq/features/education/presentation/education_screen.dart';
import 'package:hydroq/features/profile/presentation/profile_screen.dart';
import 'package:hydroq/features/shell/presentation/main_shell.dart';

enum AppRoute {
  login,
  dashboard,
  reports,
  alerts,
  education,
  plantDetail,
  profile,
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          child: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: AppRoute.dashboard.name,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/education',
                name: AppRoute.education.name,
                builder: (context, state) => const EducationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
```

Replace `lib/app/app.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydroq/app/routing/app_router.dart';
import 'package:hydroq/app/theme/app_theme.dart';
import 'package:hydroq/core/config/app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw StateError('AppConfig must be overridden during bootstrap.'),
);

class HydroQApp extends ConsumerWidget {
  const HydroQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'HydroQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 9: Verify and commit**

Run:

```bash
flutter test test/app/theme/app_theme_test.dart test/features/shell/main_shell_test.dart
flutter analyze
```

Expected: both tests pass; the theme uses the locked HydroQ tokens; the shell exposes exactly three destinations; analyzer reports no issues.

```bash
git add hydroq/lib/app hydroq/lib/core/widgets/app_status_badge.dart hydroq/lib/features/shell hydroq/lib/features/dashboard hydroq/lib/features/education hydroq/lib/features/profile hydroq/test/app hydroq/test/features/shell
git commit -m "feat: add HydroQ design foundation and navigation shell"
```

---

### Task 4: Implement API Errors, Secure Sessions, Dio, and Token Refresh

**Files:**
- Create: `hydroq/lib/core/errors/app_exception.dart`
- Create: `hydroq/lib/core/storage/session_store.dart`
- Create: `hydroq/lib/core/networking/api_client.dart`
- Create: `hydroq/lib/core/networking/auth_interceptor.dart`
- Test: `hydroq/test/core/networking/api_client_test.dart`
- Test: `hydroq/test/core/errors/app_exception_test.dart`

**Interfaces:**
- Consumes: `AppConfig` from Task 1.
- Produces: `SessionStore`, `SessionTokens`, `ApiClient`, `ApiErrorPayload`, `AppException`, and `AuthInterceptor`.

- [ ] **Step 1: Write failing API error tests**

Create `test/core/errors/app_exception_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/errors/app_exception.dart';

void main() {
  test('maps backend field errors without parsing message text', () {
    final exception = AppException.fromJson({
      'code': 'validation_failed',
      'message': 'Data tidak valid.',
      'fieldErrors': {
        'email': ['Format email tidak valid.'],
      },
      'traceId': 'trace-123',
    });

    expect(exception.code, 'validation_failed');
    expect(exception.fieldErrors['email'], ['Format email tidak valid.']);
    expect(exception.traceId, 'trace-123');
  });
}
```

- [ ] **Step 2: Run the test and verify failure**

Run:

```bash
flutter test test/core/errors/app_exception_test.dart
```

Expected: FAIL because `AppException` does not exist.

- [ ] **Step 3: Implement structured errors**

Create `lib/core/errors/app_exception.dart`:

```dart
class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
    this.traceId,
    this.statusCode,
  });

  factory AppException.fromJson(
    Map<String, Object?> json, {
    int? statusCode,
  }) {
    final rawFieldErrors = json['fieldErrors'];
    final parsedFieldErrors = <String, List<String>>{};
    if (rawFieldErrors is Map<String, Object?>) {
      for (final entry in rawFieldErrors.entries) {
        final value = entry.value;
        if (value is List<Object?>) {
          parsedFieldErrors[entry.key] = value.whereType<String>().toList();
        }
      }
    }
    return AppException(
      code: json['code'] as String? ?? 'unknown_error',
      message: json['message'] as String? ?? 'Terjadi kesalahan.',
      fieldErrors: parsedFieldErrors,
      traceId: json['traceId'] as String?,
      statusCode: statusCode,
    );
  }

  final String code;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? traceId;
  final int? statusCode;

  @override
  String toString() => 'AppException($code, $message)';
}
```

- [ ] **Step 4: Implement secure token storage**

Create `lib/core/storage/session_store.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class SessionStore {
  SessionStore(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  Future<SessionTokens?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return SessionTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> write(SessionTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: tokens.accessToken),
      _storage.write(key: _refreshKey, value: tokens.refreshToken),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }
}
```

- [ ] **Step 5: Implement Dio client and one-at-a-time refresh**

Create `lib/core/networking/api_client.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:hydroq/core/config/app_config.dart';
import 'package:hydroq/core/errors/app_exception.dart';

class ApiClient {
  ApiClient(AppConfig config)
      : dio = Dio(
          BaseOptions(
            baseUrl: '${config.apiBaseUrl}/v1',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {'Accept': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final data = error.response?.data;
          if (data is Map<String, Object?>) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error: AppException.fromJson(
                  data,
                  statusCode: error.response?.statusCode,
                ),
              ),
            );
            return;
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
}
```

Create `lib/core/networking/auth_interceptor.dart`:

```dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hydroq/core/storage/session_store.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required Dio dio, required SessionStore sessionStore})
      : _dio = dio,
        _sessionStore = sessionStore;

  final Dio _dio;
  final SessionStore _sessionStore;
  Future<SessionTokens?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await _sessionStore.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode != 401 ||
        error.requestOptions.extra['retried'] == true) {
      handler.next(error);
      return;
    }

    final tokens = await _sessionStore.read();
    if (tokens == null) {
      handler.next(error);
      return;
    }

    _refreshFuture ??= _refresh(tokens.refreshToken);
    final refreshed = await _refreshFuture;
    _refreshFuture = null;
    if (refreshed == null) {
      await _sessionStore.clear();
      handler.next(error);
      return;
    }

    final request = error.requestOptions;
    request.extra['retried'] = true;
    request.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
    final response = await _dio.fetch<Object?>(request);
    handler.resolve(response);
  }

  Future<SessionTokens?> _refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data;
      if (data == null) return null;
      final tokens = SessionTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      await _sessionStore.write(tokens);
      return tokens;
    } on DioException {
      return null;
    }
  }
}
```

Update `onRequest` so requests with `options.extra['skipAuth'] == true` immediately call `handler.next(options)` before reading storage.

- [ ] **Step 6: Add a client construction test**

Create `test/core/networking/api_client_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/config/app_config.dart';
import 'package:hydroq/core/networking/api_client.dart';

void main() {
  test('uses the versioned API base path', () {
    final client = ApiClient(
      AppConfig.fromValues(apiBaseUrl: 'https://api.hydroq.test'),
    );

    expect(client.dio.options.baseUrl, 'https://api.hydroq.test/v1');
  });
}
```

- [ ] **Step 7: Verify and commit**

Run:

```bash
flutter test test/core/errors/app_exception_test.dart test/core/networking/api_client_test.dart
flutter analyze
```

Expected: all tests pass.

```bash
git add hydroq/lib/core/errors hydroq/lib/core/storage hydroq/lib/core/networking hydroq/test/core
git commit -m "feat: add secure sessions and authenticated API client"
```

---

### Task 5: Implement Email/Password Authentication and Router Redirects

**Files:**
- Create: `hydroq/lib/features/auth/domain/user.dart`
- Create: `hydroq/lib/features/auth/data/auth_repository.dart`
- Create: `hydroq/lib/features/auth/presentation/auth_controller.dart`
- Create: `hydroq/lib/features/auth/presentation/login_screen.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Test: `hydroq/test/features/auth/login_screen_test.dart`
- Test: `hydroq/test/features/auth/auth_controller_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, `SessionStore`, and `AppException` from Task 4.
- Produces: `AuthRepository`, `AuthController`, `AuthState`, `currentUserProvider`, and route protection.

- [ ] **Step 1: Write the failing login validation test**

Create `test/features/auth/login_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('requires a valid email and password', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Verify failure**

Run:

```bash
flutter test test/features/auth/login_screen_test.dart
```

Expected: FAIL because `LoginScreen` does not exist.

- [ ] **Step 3: Implement user and repository contracts**

Create `lib/features/auth/domain/user.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
```

Create `lib/features/auth/data/auth_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:hydroq/core/networking/api_client.dart';
import 'package:hydroq/core/storage/session_store.dart';
import 'package:hydroq/features/auth/domain/user.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient, required SessionStore sessionStore})
      : _dio = apiClient.dio,
        _sessionStore = sessionStore;

  final Dio _dio;
  final SessionStore _sessionStore;

  Future<User> login({required String email, required String password}) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(extra: {'skipAuth': true}),
    );
    final data = response.data!;
    await _sessionStore.write(
      SessionTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      ),
    );
    return User.fromJson(data['user']! as Map<String, Object?>);
  }

  Future<User?> restore() async {
    final tokens = await _sessionStore.read();
    if (tokens == null) return null;
    final response = await _dio.get<Map<String, Object?>>('/auth/me');
    return User.fromJson(response.data!);
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } finally {
      await _sessionStore.clear();
    }
  }
}
```

- [ ] **Step 4: Implement authentication state**

Create `lib/features/auth/presentation/auth_controller.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydroq/features/auth/data/auth_repository.dart';
import 'package:hydroq/features/auth/domain/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final user = await ref.read(authRepositoryProvider).restore();
    return user == null ? const Unauthenticated() : Authenticated(user);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      return Authenticated(user);
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(Unauthenticated());
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository must be overridden at bootstrap.'),
);

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);
```

- [ ] **Step 5: Implement the login screen**

Create `lib/features/auth/presentation/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydroq/app/theme/app_colors.dart';
import 'package:hydroq/app/theme/app_spacing.dart';
import 'package:hydroq/features/auth/presentation/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'HydroQ',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.green500,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Pantau hidroponikmu', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    const Text('Masuk untuk melihat kondisi air dari mana saja.'),
                    const SizedBox(height: AppSpacing.xxl),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)
                            ? null
                            : 'Masukkan email yang valid.';
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) >= 8
                          ? null
                          : 'Kata sandi minimal 8 karakter.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk'),
                    ),
                    if (auth.hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Login gagal. Periksa email, kata sandi, dan koneksi internet.',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}
```

- [ ] **Step 6: Add auth redirect logic**

Modify `app_router.dart` to add `/login`, watch `authControllerProvider`, and redirect:

```dart
final auth = ref.watch(authControllerProvider);
final router = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final authState = auth.valueOrNull;
    final atLogin = state.matchedLocation == '/login';
    if (auth.isLoading || authState is AuthLoading) return null;
    if (authState is! Authenticated) return atLogin ? null : '/login';
    return atLogin ? '/dashboard' : null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: AppRoute.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        child: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: AppRoute.dashboard.name,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/education',
              name: AppRoute.education.name,
              builder: (context, state) => const EducationScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRoute.profile.name,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

- [ ] **Step 7: Register concrete dependencies in bootstrap**

In `bootstrap.dart`, create `FlutterSecureStorage`, `SessionStore`, `ApiClient`, add `AuthInterceptor`, and override `authRepositoryProvider`:

```dart
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(),
);
final sessionStore = SessionStore(secureStorage);
final apiClient = ApiClient(config);
apiClient.dio.interceptors.insert(
  0,
  AuthInterceptor(dio: apiClient.dio, sessionStore: sessionStore),
);
final authRepository = AuthRepository(
  apiClient: apiClient,
  sessionStore: sessionStore,
);
```

Add these providers beside their classes:

```dart
final apiClientProvider = Provider<ApiClient>(
  (ref) => throw StateError('ApiClient must be overridden during bootstrap.'),
);

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => throw StateError('SessionStore must be overridden during bootstrap.'),
);
```

Then replace `bootstrap()` with this concrete dependency graph:

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  const secureStorage = FlutterSecureStorage(aOptions: AndroidOptions());
  final sessionStore = SessionStore(secureStorage);
  final apiClient = ApiClient(config);
  apiClient.dio.interceptors.insert(
    0,
    AuthInterceptor(dio: apiClient.dio, sessionStore: sessionStore),
  );
  final authRepository = AuthRepository(
    apiClient: apiClient,
    sessionStore: sessionStore,
  );

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        apiClientProvider.overrideWithValue(apiClient),
        sessionStoreProvider.overrideWithValue(sessionStore),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const HydroQApp(),
    ),
  );
}
```

- [ ] **Step 8: Generate, test, and commit**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/auth/login_screen_test.dart
flutter analyze
```

Expected: login validation test passes and analysis succeeds.

```bash
git add hydroq/lib/features/auth hydroq/lib/app hydroq/lib/core hydroq/test/features/auth
git commit -m "feat: add email password authentication"
```

---

### Task 6: Implement Active Tank, Current Snapshot, and the Main Water-Condition Card

**Files:**
- Create: `hydroq/lib/features/dashboard/domain/tank.dart`
- Create: `hydroq/lib/features/dashboard/domain/dashboard_state.dart`
- Create: `hydroq/lib/features/dashboard/data/dashboard_repository.dart`
- Create: `hydroq/lib/features/dashboard/presentation/dashboard_controller.dart`
- Create: `hydroq/lib/features/dashboard/presentation/widgets/water_condition_card.dart`
- Replace: `hydroq/lib/features/dashboard/presentation/dashboard_screen.dart`
- Test: `hydroq/test/features/dashboard/water_condition_card_test.dart`

**Interfaces:**
- Consumes: `ApiClient`, shared sensor models, and formatters.
- Produces: `Tank`, `DashboardState`, `DashboardRepository`, `dashboardControllerProvider`, and `WaterConditionCard`.

- [ ] **Step 1: Write the failing dashboard-card test**

Create `test/features/dashboard/water_condition_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydroq/core/models/measurement_status.dart';
import 'package:hydroq/core/models/sensor_snapshot.dart';
import 'package:hydroq/features/dashboard/domain/tank.dart';
import 'package:hydroq/features/dashboard/presentation/widgets/water_condition_card.dart';

void main() {
  testWidgets('shows pH, EC, TDS, liters, percentage, and status text', (tester) async {
    final snapshot = SensorSnapshot(
      tankId: 'tank-1',
      recordedAt: DateTime.utc(2026, 7, 23, 10),
      receivedAt: DateTime.utc(2026, 7, 23, 10),
      ph: 6.2,
      ecMsCm: 1.8,
      tdsPpm: 1150,
      volumeLiters: 42.5,
      volumePercent: 71,
      parameterStatuses: const {
        'ph': MeasurementStatus.normal,
        'ec': MeasurementStatus.warning,
        'volume': MeasurementStatus.normal,
      },
      overallStatus: OverallStatus.warning,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WaterConditionCard(
            tank: const Tank(
              id: 'tank-1',
              name: 'Tangki Utama',
              capacityLiters: 60,
              minimumSafeVolumeLiters: 15,
              activeProfileName: 'Selada',
              deviceId: 'device-1',
            ),
            snapshot: snapshot,
          ),
        ),
      ),
    );

    expect(find.text('6,20'), findsOneWidget);
    expect(find.text('1,80 mS/cm'), findsOneWidget);
    expect(find.text('1.150 ppm'), findsOneWidget);
    expect(find.text('42,5 L'), findsOneWidget);
    expect(find.text('71%'), findsOneWidget);
    expect(find.text('Peringatan'), findsWidgets);
  });
}
```

- [ ] **Step 2: Implement tank and dashboard state models**

Create `lib/features/dashboard/domain/tank.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tank.freezed.dart';
part 'tank.g.dart';

@freezed
abstract class Tank with _$Tank {
  const factory Tank({
    required String id,
    required String name,
    required double capacityLiters,
    required double minimumSafeVolumeLiters,
    String? activeProfileName,
    String? deviceId,
  }) = _Tank;

  factory Tank.fromJson(Map<String, Object?> json) => _$TankFromJson(json);
}
```

Create `lib/features/dashboard/domain/dashboard_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydroq/core/models/sensor_snapshot.dart';
import 'package:hydroq/features/dashboard/domain/tank.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required Tank tank,
    required SensorSnapshot snapshot,
    @Default(false) bool reconnecting,
    @Default(false) bool usingCachedData,
  }) = _DashboardState;
}
```

- [ ] **Step 3: Implement repository and controller**

Create `lib/features/dashboard/data/dashboard_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:hydroq/core/models/sensor_snapshot.dart';
import 'package:hydroq/core/networking/api_client.dart';
import 'package:hydroq/features/dashboard/domain/tank.dart';

class DashboardRepository {
  DashboardRepository(ApiClient client) : _dio = client.dio;
  final Dio _dio;

  Future<Tank> fetchActiveTank() async {
    final response = await _dio.get<Map<String, Object?>>('/tanks/active');
    return Tank.fromJson(response.data!);
  }

  Future<SensorSnapshot> fetchSnapshot(String tankId) async {
    final response = await _dio.get<Map<String, Object?>>('/tanks/$tankId/snapshot');
    return SensorSnapshot.fromJson(response.data!);
  }
}
```

Create `lib/features/dashboard/presentation/dashboard_controller.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydroq/features/dashboard/data/dashboard_repository.dart';
import 'package:hydroq/features/dashboard/domain/dashboard_state.dart';

class DashboardController extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final tank = await repository.fetchActiveTank();
    final snapshot = await repository.fetchSnapshot(tank.id);
    return DashboardState(tank: tank, snapshot: snapshot);
  }

  Future<void> refreshSnapshot() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final snapshot = await ref.read(dashboardRepositoryProvider).fetchSnapshot(current.tank.id);
    state = AsyncData(current.copyWith(snapshot: snapshot, usingCachedData: false));
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => throw StateError('DashboardRepository must be overridden.'),
);

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardState>(DashboardController.new);
```

- [ ] **Step 4: Implement status badge and water card**

Reuse `AppStatusBadge` and the status-visual extensions from Task 3, then create `lib/features/dashboard/presentation/widgets/water_condition_card.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:hydroq/app/theme/app_spacing.dart';
import 'package:hydroq/app/theme/app_typography.dart';
import 'package:hydroq/app/theme/status_visuals.dart';
import 'package:hydroq/core/formatting/measurement_formatters.dart';
import 'package:hydroq/core/models/sensor_snapshot.dart';
import 'package:hydroq/core/widgets/app_status_badge.dart';
import 'package:hydroq/features/dashboard/domain/tank.dart';

class WaterConditionCard extends StatelessWidget {
  const WaterConditionCard({required this.tank, required this.snapshot, super.key});

  final Tank tank;
  final SensorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Kondisi air saat ini', style: theme.textTheme.titleLarge)),
                AppStatusBadge(visuals: snapshot.overallStatus.visuals),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < 520 ? constraints.maxWidth : (constraints.maxWidth - (AppSpacing.md * 2)) / 3;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _MetricBlock(width: width, label: 'pH', value: formatPh(snapshot.ph), detail: 'Kadar keasaman'),
                    _MetricBlock(width: width, label: 'Nutrisi', value: formatEc(snapshot.ecMsCm), detail: formatTds(snapshot.tdsPpm)),
                    _MetricBlock(width: width, label: 'Volume', value: formatVolume(snapshot.volumeLiters), detail: '${snapshot.volumePercent?.round() ?? 0}%'),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(value: (snapshot.volumePercent ?? 0).clamp(0, 100) / 100),
          ],
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.width, required this.label, required this.value, required this.detail});
  final double width;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: AppSpacing.xxs),
          Text(value, style: AppTypography.sensorValue),
          const SizedBox(height: AppSpacing.xxs),
          Text(detail),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Replace the dashboard screen**

Replace `dashboard_screen.dart` with a `ConsumerWidget` that watches `dashboardControllerProvider`, shows a scrollable header with tank name, active profile, last update age, notification icon, `WaterConditionCard`, and temporary section headings for `Laporan` and `Peringatan terbaru`. Use `RefreshIndicator` to call `refreshSnapshot()`.

Use this exact content structure:

```dart
return state.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stack) => Center(
    child: FilledButton(
      onPressed: () => ref.invalidate(dashboardControllerProvider),
      child: const Text('Coba lagi'),
    ),
  ),
  data: (data) => RefreshIndicator(
    onRefresh: () => ref.read(dashboardControllerProvider.notifier).refreshSnapshot(),
    child: ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(data.tank.name, style: Theme.of(context).textTheme.headlineSmall),
        Text(data.tank.activeProfileName ?? 'Belum memilih profil tanaman'),
        Text('Diperbarui ${formatReadingAge(data.snapshot.receivedAt)}'),
        const SizedBox(height: AppSpacing.md),
        WaterConditionCard(tank: data.tank, snapshot: data.snapshot),
        const SizedBox(height: AppSpacing.xl),
        Text('Laporan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xl),
        Text('Peringatan terbaru', style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  ),
);
```

- [ ] **Step 6: Register repository, generate, test, and commit**

Add `dashboardRepositoryProvider.overrideWithValue(DashboardRepository(apiClient))` to bootstrap.

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dashboard/water_condition_card_test.dart
flutter analyze
```

Expected: widget test passes and analysis succeeds.

```bash
git add hydroq/lib/features/dashboard hydroq/lib/core/widgets hydroq/lib/app hydroq/test/features/dashboard
git commit -m "feat: add current tank monitoring dashboard"
```

---

### Task 7: Add Realtime Updates, Reconnect State, Polling Fallback, and Snapshot Cache

**Files:**
- Create: `hydroq/lib/core/realtime/realtime_gateway.dart`
- Create: `hydroq/lib/core/realtime/web_socket_realtime_gateway.dart`
- Create: `hydroq/lib/core/storage/cache_store.dart`
- Modify: `hydroq/lib/features/dashboard/presentation/dashboard_controller.dart`
- Modify: `hydroq/lib/features/dashboard/presentation/dashboard_screen.dart`
- Test: `hydroq/test/features/dashboard/dashboard_controller_test.dart`

**Interfaces:**
- Consumes: `SessionStore`, `AppConfig`, `SensorSnapshot`, and `DashboardRepository`.
- Produces: `RealtimeGateway`, `RealtimeEvent`, `CacheStore`, live snapshot updates, one-minute fallback polling, and cached startup state.

- [ ] **Step 1: Write a failing controller update test**

Create `test/features/dashboard/dashboard_controller_test.dart` using a fake gateway stream and fake repository. Assert that sending a `SnapshotUpdated` event replaces `state.snapshot` without re-fetching reports.

Use the following event in the test:

```dart
controller.add(
  SnapshotUpdated(
    SensorSnapshot(
      tankId: 'tank-1',
      recordedAt: DateTime.utc(2026, 7, 23, 12, 1),
      receivedAt: DateTime.utc(2026, 7, 23, 12, 1),
      ph: 6.1,
      ecMsCm: 1.7,
      tdsPpm: 1088,
      volumeLiters: 41,
      volumePercent: 68,
      overallStatus: OverallStatus.normal,
    ),
  ),
);
```

Expected assertion: `container.read(dashboardControllerProvider).value!.snapshot.ph == 6.1`.

- [ ] **Step 2: Define realtime contracts**

Create `lib/core/realtime/realtime_gateway.dart`:

```dart
import 'package:hydroq/core/models/sensor_snapshot.dart';

sealed class RealtimeEvent {
  const RealtimeEvent();
}

class SnapshotUpdated extends RealtimeEvent {
  const SnapshotUpdated(this.snapshot);
  final SensorSnapshot snapshot;
}

class DeviceDisconnected extends RealtimeEvent {
  const DeviceDisconnected();
}

class DeviceReconnected extends RealtimeEvent {
  const DeviceReconnected();
}

abstract interface class RealtimeGateway {
  Stream<RealtimeEvent> connect({required String tankId, required String accessToken});
  Future<void> close();
}
```

- [ ] **Step 3: Implement WebSocket parsing**

Create `lib/core/realtime/web_socket_realtime_gateway.dart`:

```dart
import 'dart:convert';

import 'package:hydroq/core/config/app_config.dart';
import 'package:hydroq/core/models/sensor_snapshot.dart';
import 'package:hydroq/core/realtime/realtime_gateway.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketRealtimeGateway implements RealtimeGateway {
  WebSocketRealtimeGateway(this._config);
  final AppConfig _config;
  WebSocketChannel? _channel;

  @override
  Stream<RealtimeEvent> connect({required String tankId, required String accessToken}) {
    final uri = Uri.parse('${_config.realtimeBaseUrl}/v1/realtime').replace(
      queryParameters: {'tankId': tankId, 'token': accessToken},
    );
    _channel = WebSocketChannel.connect(uri);
    return _channel!.stream.map((raw) {
      final json = jsonDecode(raw as String) as Map<String, Object?>;
      return switch (json['type']) {
        'snapshot.updated' => SnapshotUpdated(
            SensorSnapshot.fromJson(json['data']! as Map<String, Object?>),
          ),
        'device.disconnected' => const DeviceDisconnected(),
        'device.reconnected' => const DeviceReconnected(),
        _ => throw FormatException('Unknown realtime event: ${json['type']}'),
      };
    });
  }

  @override
  Future<void> close() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
```

- [ ] **Step 4: Implement timestamped cache storage**

Create `lib/core/storage/cache_store.dart` using `SharedPreferencesAsync`:

```dart
import 'dart:convert';

import 'package:hydroq/core/models/sensor_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheStore {
  CacheStore(this._preferences);
  static const _snapshotKey = 'cached_snapshot';
  final SharedPreferencesAsync _preferences;

  Future<void> saveSnapshot(SensorSnapshot snapshot) =>
      _preferences.setString(_snapshotKey, jsonEncode(snapshot.toJson()));

  Future<SensorSnapshot?> readSnapshot() async {
    final raw = await _preferences.getString(_snapshotKey);
    if (raw == null) return null;
    return SensorSnapshot.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }
}
```

- [ ] **Step 5: Extend DashboardController lifecycle**

Update `DashboardController.build()` to:

1. Load cached snapshot first when the network call fails.
2. After successful API load, cache the snapshot.
3. Read the access token from `SessionStore`.
4. Subscribe to `RealtimeGateway.connect()`.
5. Replace current snapshot and cache it for `SnapshotUpdated`.
6. Set `reconnecting: true` on stream error.
7. Start `Timer.periodic(const Duration(minutes: 1), ...)` while disconnected.
8. Cancel polling after a realtime event resumes.
9. Register `ref.onDispose()` to cancel timers, subscriptions, and close the gateway.

The controller must keep realtime state separate from report providers.

- [ ] **Step 6: Show cached and reconnecting indicators**

In `dashboard_screen.dart`, insert these labels under the update age:

```dart
if (data.usingCachedData)
  const Text('Menampilkan data tersimpan. Periksa waktu pembaruan.'),
if (data.reconnecting)
  const Row(
    children: [
      SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)),
      SizedBox(width: 8),
      Text('Menghubungkan ulang…'),
    ],
  ),
```

- [ ] **Step 7: Register providers, test, and commit**

Override `realtimeGatewayProvider`, `cacheStoreProvider`, and `sessionStoreProvider` in bootstrap.

Run:

```bash
flutter test test/features/dashboard/dashboard_controller_test.dart
flutter analyze
```

Expected: live-update test passes and no analyzer issues.

```bash
git add hydroq/lib/core/realtime hydroq/lib/core/storage hydroq/lib/features/dashboard hydroq/test/features/dashboard
git commit -m "feat: add realtime monitoring and cached fallback"
```

---

### Task 8: Implement Report Preview, Detailed Reports, and Charts

**Files:**
- Create: `hydroq/lib/features/reports/domain/sensor_report.dart`
- Create: `hydroq/lib/features/reports/data/report_repository.dart`
- Create: `hydroq/lib/features/reports/presentation/report_controller.dart`
- Create: `hydroq/lib/features/reports/presentation/widgets/report_chart.dart`
- Create: `hydroq/lib/features/reports/presentation/widgets/report_preview.dart`
- Create: `hydroq/lib/features/reports/presentation/report_screen.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Modify: `hydroq/lib/features/dashboard/presentation/dashboard_screen.dart`
- Test: `hydroq/test/features/reports/report_controller_test.dart`
- Test: `hydroq/test/features/reports/report_preview_test.dart`

**Interfaces:**
- Consumes: active tank ID from dashboard state and `ApiClient`.
- Produces: `ReportMetric`, `NutrientUnit`, `ReportPeriod`, `SensorReport`, `ReportQuery`, `reportControllerProvider`, `ReportPreview`, and `ReportScreen`.

- [ ] **Step 1: Write failing query-switching tests**

Create `test/features/reports/report_controller_test.dart` asserting:

```dart
expect(controller.state.query.metric, ReportMetric.ph);
controller.setMetric(ReportMetric.nutrient);
expect(controller.state.query.metric, ReportMetric.nutrient);
controller.setNutrientUnit(NutrientUnit.tds);
expect(controller.state.query.nutrientUnit, NutrientUnit.tds);
controller.setPeriod(ReportPeriod.week);
expect(controller.state.query.period, ReportPeriod.week);
```

The fake repository must record one fetch per changed query.

- [ ] **Step 2: Define report models**

Create `lib/features/reports/domain/sensor_report.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_report.freezed.dart';
part 'sensor_report.g.dart';

enum ReportMetric { ph, nutrient, volume }
enum NutrientUnit { ec, tds }
enum ReportPeriod { day, week, month }

@freezed
abstract class ReportPoint with _$ReportPoint {
  const factory ReportPoint({required DateTime timestamp, required double value}) = _ReportPoint;
  factory ReportPoint.fromJson(Map<String, Object?> json) => _$ReportPointFromJson(json);
}

@freezed
abstract class SensorReport with _$SensorReport {
  const factory SensorReport({
    required List<ReportPoint> points,
    required double average,
    required double minimum,
    required double maximum,
    required int sampleCount,
    required int warningCount,
    required int criticalCount,
    required int abnormalDurationSeconds,
    @Default(false) bool incomplete,
  }) = _SensorReport;
  factory SensorReport.fromJson(Map<String, Object?> json) => _$SensorReportFromJson(json);
}

@freezed
abstract class ReportQuery with _$ReportQuery {
  const factory ReportQuery({
    @Default(ReportMetric.ph) ReportMetric metric,
    @Default(NutrientUnit.ec) NutrientUnit nutrientUnit,
    @Default(ReportPeriod.day) ReportPeriod period,
  }) = _ReportQuery;
}
```

- [ ] **Step 3: Implement repository and controller**

`ReportRepository.fetch()` must call:

```text
GET /tanks/{tankId}/reports?parameter=ph|ec|tds|volume&period=day|week|month
```

Map `ReportMetric.nutrient` to either `ec` or `tds` according to `NutrientUnit`.

`ReportController` must keep the current query and `AsyncValue<SensorReport>` in one immutable state, preserve the old report while loading a new query, and expose `setMetric`, `setNutrientUnit`, `setPeriod`, and `reload`.

- [ ] **Step 4: Build one reusable line chart**

Create `report_chart.dart` with `fl_chart`. It must:

- Return an explanatory empty state when `points.isEmpty`.
- Use `LineChartData` with one line series.
- Format bottom titles according to the selected period.
- Expose a `Semantics` label containing average, minimum, maximum, and sample count.
- Display a visible `Data historis belum lengkap` banner when `report.incomplete` is true.

Core line data:

```dart
LineChartBarData(
  isCurved: true,
  barWidth: 3,
  dotData: const FlDotData(show: false),
  spots: [
    for (var index = 0; index < report.points.length; index++)
      FlSpot(index.toDouble(), report.points[index].value),
  ],
)
```

- [ ] **Step 5: Build preview and detail screens**

`ReportPreview` must contain:

- Three top-level choices: pH, EC/TDS, Volume.
- A nested EC/TDS segmented control visible only for nutrient.
- Day, Week, Month period choices.
- One chart.
- Average, minimum, maximum, warning count, and critical count cards.
- A `Lihat laporan lengkap` button.

`ReportScreen` reuses the same controller and chart but also shows sample count and total abnormal duration.

- [ ] **Step 6: Add nested route and dashboard preview**

Add `/dashboard/reports` named `AppRoute.reports`. Replace the temporary `Laporan` heading on the dashboard with `ReportPreview(tankId: data.tank.id, compact: true)`.

- [ ] **Step 7: Generate, test, and commit**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/reports
flutter analyze
```

Expected: report query and widget tests pass.

```bash
git add hydroq/lib/features/reports hydroq/lib/features/dashboard hydroq/lib/app/routing hydroq/test/features/reports
git commit -m "feat: add historical reports and charting"
```

---

### Task 9: Implement Recent Alerts, Full Alert History, and Unread Count

**Files:**
- Create: `hydroq/lib/features/alerts/domain/alert_event.dart`
- Create: `hydroq/lib/features/alerts/data/alert_repository.dart`
- Create: `hydroq/lib/features/alerts/presentation/alert_controller.dart`
- Create: `hydroq/lib/features/alerts/presentation/widgets/recent_alerts.dart`
- Create: `hydroq/lib/features/alerts/presentation/alert_history_screen.dart`
- Modify: `hydroq/lib/features/dashboard/presentation/dashboard_screen.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Test: `hydroq/test/features/alerts/recent_alerts_test.dart`

**Interfaces:**
- Consumes: active tank ID and `ApiClient`.
- Produces: `AlertEvent`, `AlertSeverity`, `AlertLifecycleStatus`, `alertHistoryProvider`, `unreadAlertCountProvider`, and alert routes.

- [ ] **Step 1: Write failing alert-card tests**

Create a widget test that renders an ongoing critical EC alert and asserts the visible strings:

```text
EC kritis
2,40 mS/cm
Target 1,20–1,80
Sedang berlangsung
```

- [ ] **Step 2: Define alert models**

Create `alert_event.dart` with Freezed fields matching the spec:

```dart
enum AlertSeverity { warning, critical, recovered }
enum AlertLifecycleStatus { ongoing, resolved }
```

Include `id`, `tankId`, `parameter`, `severity`, `status`, `measuredValue`, `targetMinimum`, `targetMaximum`, `startedAt`, `endedAt`, and `lastUpdatedAt`.

- [ ] **Step 3: Implement repository endpoints**

Use:

```text
GET /tanks/{tankId}/alerts?limit=5
GET /tanks/{tankId}/alerts
GET /alerts/unread-count
POST /alerts/read
```

`markAllRead()` sends an empty JSON object and invalidates unread count after success.

- [ ] **Step 4: Implement recent and full-history state**

Create separate providers so dashboard alert refresh does not rebuild report state:

```dart
final recentAlertsProvider = FutureProvider.family<List<AlertEvent>, String>(...);
final alertHistoryProvider = FutureProvider.family<List<AlertEvent>, String>(...);
final unreadAlertCountProvider = FutureProvider<int>(...);
```

- [ ] **Step 5: Build alert UI**

`RecentAlerts` displays up to five rows and an empty state. `AlertHistoryScreen` displays newest first, start/end time, duration, ongoing marker, target range, and recovery state. Do not add filters.

- [ ] **Step 6: Add navigation and unread badge**

Add `/dashboard/alerts` named `AppRoute.alerts`. The dashboard notification icon reads `unreadAlertCountProvider`; tapping it marks alerts read and opens history. Replace the temporary alert heading with `RecentAlerts`.

- [ ] **Step 7: Test and commit**

Run:

```bash
flutter test test/features/alerts
flutter analyze
```

Expected: alert widget tests pass.

```bash
git add hydroq/lib/features/alerts hydroq/lib/features/dashboard hydroq/lib/app/routing hydroq/test/features/alerts
git commit -m "feat: add alert history and unread state"
```

---

### Task 10: Implement Education Search and the Two-Column Plant Grid

**Files:**
- Create: `hydroq/lib/features/education/domain/plant_profile.dart`
- Create: `hydroq/lib/features/education/data/education_repository.dart`
- Create: `hydroq/lib/features/education/presentation/education_controller.dart`
- Create: `hydroq/lib/features/education/presentation/widgets/plant_card.dart`
- Replace: `hydroq/lib/features/education/presentation/education_screen.dart`
- Test: `hydroq/test/features/education/education_screen_test.dart`

**Interfaces:**
- Consumes: `ApiClient`.
- Produces: `PlantProfile`, `EducationRepository`, debounced `EducationController`, search result states, and a design-system-compliant `PlantCard` using the shared radius, spacing, typography, and surface tokens.

- [ ] **Step 1: Write failing search tests**

Create a widget test with a fake repository containing Selada and Pakcoy. Enter `sela`, advance the test clock by 350 milliseconds, and assert only Selada remains. Enter `xyz`, advance again, and assert `Tanaman tidak ditemukan`.

- [ ] **Step 2: Define PlantProfile**

Create a Freezed model containing every field from the spec:

```dart
id, name, aliases, description, imageUrl, difficulty,
phRange, ecRange, tdsRange, waterTemperatureRange,
growthDuration, nutrientTips, commonProblems
```

Represent optional ranges with `RangeValue?` and tips/problems as `List<String>`.

- [ ] **Step 3: Implement repository search**

Use:

```text
GET /plants
GET /plants?q={trimmed query}
GET /plants/{plantId}
```

Do not treat a network error as an empty list.

- [ ] **Step 4: Implement a 300 ms debounce controller**

The controller owns `query`, `AsyncValue<List<PlantProfile>> results`, and a `Timer?`. `search(String value)` trims input, cancels the old timer, and schedules repository loading after `Duration(milliseconds: 300)`. Dispose the timer with `ref.onDispose`.

- [ ] **Step 5: Build the education screen**

The screen must contain:

- Title `Edukasi Tanaman`.
- Introductory copy.
- Search field with clear button.
- `GridView.builder` with two columns when width is at least 360 px and one column below 360 px.
- No category filter.
- Plant card image, name, difficulty, pH range, and EC range, styled exactly from `DESIGN_SYSTEM.md` with no local color/radius constants.
- Separate loading, no-result, and network-error states.

- [ ] **Step 6: Add plant-detail route**

Add `/education/plants/:plantId` named `AppRoute.plantDetail`. For now, route to a temporary scaffold that displays the `plantId`; Task 11 replaces it.

- [ ] **Step 7: Generate, test, and commit**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/education
flutter analyze
```

Expected: search and empty-state tests pass.

```bash
git add hydroq/lib/features/education hydroq/lib/app/routing hydroq/test/features/education
git commit -m "feat: add searchable plant education grid"
```

---

### Task 11: Implement Plant Detail, Apply Profile, and Copy as Custom Recipe

**Files:**
- Create: `hydroq/lib/features/plant_profile/data/plant_profile_repository.dart`
- Create: `hydroq/lib/features/plant_profile/presentation/plant_detail_controller.dart`
- Create: `hydroq/lib/features/plant_profile/presentation/plant_detail_screen.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Test: `hydroq/test/features/plant_profile/plant_detail_screen_test.dart`

**Interfaces:**
- Consumes: `PlantProfile`, active tank ID, `ApiClient`, and recipe route from Task 13.
- Produces: plant detail state, profile application confirmation, and recipe-draft navigation data.

- [ ] **Step 1: Write failing action tests**

Create a widget test asserting that:

- Tapping `Gunakan profil ini` opens a confirmation dialog.
- Confirming calls `applyProfile(tankId: 'tank-1', plantId: 'lettuce')` once.
- Tapping `Salin sebagai resep kustom` navigates with the plant ranges as draft data.

- [ ] **Step 2: Implement repository operations**

Use:

```text
GET /plants/{plantId}
POST /tanks/{tankId}/active-profile
Body: {"plantProfileId":"lettuce"}
```

- [ ] **Step 3: Implement controller state**

The controller loads plant detail, exposes `applyToTank(String tankId)`, and uses an `AsyncValue<void>` action state so the main content remains visible while the action is in progress.

- [ ] **Step 4: Build the detail screen**

Display image, name, description, difficulty, pH, EC, TDS, optional water temperature, growth duration, nutrient tips, and common problems. Built-in values are read-only. Show both actions at the bottom using responsive stacked buttons.

- [ ] **Step 5: Refresh dependent state**

After successful profile application:

```dart
ref.invalidate(dashboardControllerProvider);
ref.invalidate(activeProfileProvider);
```

Show `Profil tanaman berhasil digunakan.` and return to Beranda.

- [ ] **Step 6: Replace route, test, and commit**

Run:

```bash
flutter test test/features/plant_profile
flutter analyze
```

Expected: action tests pass.

```bash
git add hydroq/lib/features/plant_profile hydroq/lib/app/routing hydroq/test/features/plant_profile
git commit -m "feat: add plant profile detail and activation"
```

---

### Task 12: Implement Profile Hub, Tank Settings, and Device Status

**Files:**
- Create: `hydroq/lib/features/profile/domain/user_preferences.dart`
- Create: `hydroq/lib/features/profile/data/profile_repository.dart`
- Replace: `hydroq/lib/features/profile/presentation/profile_screen.dart`
- Create: `hydroq/lib/features/tank_settings/presentation/tank_settings_screen.dart`
- Create: `hydroq/lib/features/device_status/domain/device.dart`
- Create: `hydroq/lib/features/device_status/presentation/device_status_screen.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Test: `hydroq/test/features/tank_settings/tank_settings_screen_test.dart`

**Interfaces:**
- Consumes: authenticated user, active tank, and `ApiClient`.
- Produces: profile hub routes, validated tank update payloads, device sensor-availability UI, and `ProfileMenuTile` composition matching `DESIGN_SYSTEM.md`.

- [ ] **Step 1: Write failing tank-validation tests**

Assert these exact messages:

```text
Kapasitas harus lebih dari 0 liter.
Volume minimum harus lebih kecil dari kapasitas.
Panjang, lebar, dan tinggi tangki harus lebih dari 0.
```

- [ ] **Step 2: Implement profile repository**

Use:

```text
GET /profile
PATCH /profile
GET /tanks/{tankId}
PATCH /tanks/{tankId}
GET /devices/{deviceId}
POST /auth/change-password
```

- [ ] **Step 3: Build Profile hub**

Display user name/email plus shared `ProfileMenuTile` rows with soft green icon containers, title, supporting copy, and chevron for:

- Pengaturan Tangki
- Status Perangkat
- Profil Tanaman Aktif
- Resep Kustom
- Pengaturan Notifikasi
- Pengaturan Satuan
- Ubah Kata Sandi
- Keluar

Logout calls `AuthController.logout()`.

- [ ] **Step 4: Build Tank Settings form**

Fields:

- Tank name.
- Capacity liters.
- Length, width, and height.
- Minimum safe volume.

Use numeric keyboard, decimal input support, frontend validation, loading state, backend field errors, and a success snackbar. The backend remains authoritative.

- [ ] **Step 5: Build Device Status screen**

Show device name/identifier, connection state, last contact, pH/EC/level sensor availability, and optional firmware/hardware details. If no device is associated, show `Belum ada perangkat yang terhubung` and do not display pairing controls.

- [ ] **Step 6: Add routes, test, and commit**

Add nested routes under `/profile/tank`, `/profile/device`, and `/profile/change-password`.

Run:

```bash
flutter test test/features/tank_settings
flutter analyze
```

Expected: validation tests pass.

```bash
git add hydroq/lib/features/profile hydroq/lib/features/tank_settings hydroq/lib/features/device_status hydroq/lib/app/routing hydroq/test/features/tank_settings
git commit -m "feat: add profile tank and device settings"
```

---

### Task 13: Implement Custom Recipes and Validation

**Files:**
- Create: `hydroq/lib/features/recipes/domain/custom_recipe.dart`
- Create: `hydroq/lib/features/recipes/domain/recipe_validator.dart`
- Create: `hydroq/lib/features/recipes/data/recipe_repository.dart`
- Create: `hydroq/lib/features/recipes/presentation/recipe_list_screen.dart`
- Create: `hydroq/lib/features/recipes/presentation/recipe_form_screen.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Test: `hydroq/test/features/recipes/recipe_validator_test.dart`
- Test: `hydroq/test/features/recipes/recipe_form_screen_test.dart`

**Interfaces:**
- Consumes: active tank, backend physical-limit metadata, and optional `PlantProfile` draft.
- Produces: `CustomRecipe`, `RecipeDraft`, `RecipeValidationResult`, recipe CRUD, and activation.

- [ ] **Step 1: Write failing validator tests**

Create tests covering:

```dart
expect(validateRecipe(validDraft, limits), isEmpty);
expect(validateRecipe(draftWithPhMinAboveMax, limits)['phMinimum'], 'pH minimum harus lebih kecil dari pH maksimum.');
expect(validateRecipe(draftWithEcAboveLimit, limits)['ecMaximum'], 'EC berada di luar batas yang diizinkan perangkat.');
expect(validateRecipe(draftWithVolumeAboveCapacity, limits)['minimumVolumeLiters'], 'Volume minimum harus lebih kecil dari kapasitas tangki.');
```

- [ ] **Step 2: Define models and limits**

`CustomRecipe` fields exactly match the spec. `RecipePhysicalLimits` must be loaded from `GET /recipes/limits` and includes minimum/maximum allowed pH, EC, warning margin, persistence duration, and active tank capacity.

- [ ] **Step 3: Implement deterministic validation**

Create `recipe_validator.dart` returning `Map<String, String>`. It must reject empty names, min >= max, values outside backend limits, and minimum volume >= capacity. Do not calculate authoritative alert severity.

- [ ] **Step 4: Implement repository endpoints**

Use:

```text
GET /recipes
POST /recipes
PATCH /recipes/{recipeId}
DELETE /recipes/{recipeId}
POST /tanks/{tankId}/active-recipe
GET /recipes/limits
```

- [ ] **Step 5: Build recipe list and form**

The list marks the active recipe and supports create, edit, delete confirmation, and activate. The form supports a plant-profile draft, pH/EC ranges, minimum volume, warning margin, and persistence duration. TDS is display-only and updates from backend conversion metadata.

- [ ] **Step 6: Preserve historical semantics**

After an active recipe is edited, invalidate future dashboard/profile state only. Do not mutate or relabel previously loaded alert history values.

- [ ] **Step 7: Route, test, and commit**

Add `/profile/recipes`, `/profile/recipes/new`, and `/profile/recipes/:recipeId/edit`.

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/recipes
flutter analyze
```

Expected: validator and form tests pass.

```bash
git add hydroq/lib/features/recipes hydroq/lib/app/routing hydroq/test/features/recipes
git commit -m "feat: add custom nutrient recipes"
```

---

### Task 14: Add Notification Preferences, FCM Registration, Foreground Alerts, and Deep Links

**Files:**
- Create: `hydroq/lib/features/notifications/domain/notification_preferences.dart`
- Create: `hydroq/lib/features/notifications/data/notification_repository.dart`
- Create: `hydroq/lib/features/notifications/presentation/notification_settings_screen.dart`
- Create: `hydroq/lib/features/notifications/services/push_notification_service.dart`
- Modify: `hydroq/lib/app/bootstrap.dart`
- Modify: `hydroq/lib/app/routing/app_router.dart`
- Test: `hydroq/test/features/notifications/push_notification_service_test.dart`

**Interfaces:**
- Consumes: Firebase project configuration, `GoRouter`, authenticated user session, and backend device-token endpoint.
- Produces: user-controlled notification preferences, permission status, token registration, foreground notifications, and alert-context routing.

- [ ] **Step 1: Configure Firebase interactively**

Run from `hydroq/`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Select Android and iOS for the Firebase project supplied by the backend developer.

Expected: `lib/firebase_options.dart` and platform Firebase configuration files are generated.

- [ ] **Step 2: Define preferences and repository**

Fields:

```dart
enabledGlobally, phAlerts, nutrientAlerts, volumeAlerts, recoveryAlerts
```

Endpoints:

```text
GET /preferences/notifications
PATCH /preferences/notifications
POST /devices/push-token
DELETE /devices/push-token
```

- [ ] **Step 3: Implement PushNotificationService**

Initialize Firebase, request permission, create an Android channel with ID `hydroq_alerts`, visible name `HydroQ Alerts`, and high importance, register `FirebaseMessaging.instance.getToken()`, listen to `onMessage`, `onMessageOpenedApp`, and `getInitialMessage()`, and route payloads with `alertId` to `/dashboard/alerts?highlight={alertId}`.

Foreground notification title/body come from the backend payload; do not recreate alert logic locally.

- [ ] **Step 4: Build notification settings**

Use switches for all five preferences. Show permission state as `Diizinkan`, `Ditolak`, or `Belum diminta`. If denied, monitoring remains usable and the page explains how to open operating-system notification settings.

- [ ] **Step 5: Write service-routing tests**

Use a fake message stream and fake router callback. Assert that a message containing:

```json
{"type":"alert","alertId":"alert-123"}
```

causes one navigation call to `/dashboard/alerts?highlight=alert-123`.

- [ ] **Step 6: Bootstrap, route, test, and commit**

Initialize Firebase before `runApp`, create the push service after router creation, and add `/profile/notifications`.

Run:

```bash
flutter test test/features/notifications
flutter analyze
```

Expected: routing test passes.

```bash
git add hydroq/lib/features/notifications hydroq/lib/firebase_options.dart hydroq/android hydroq/ios hydroq/lib/app hydroq/test/features/notifications
git commit -m "feat: add push notifications and preferences"
```

---

### Task 15: Harden Loading, Empty, Offline, Stale, Partial-Failure, and Session-Expiry States

**Files:**
- Create: `hydroq/lib/core/widgets/app_async_view.dart`
- Create: `hydroq/lib/core/widgets/app_empty_state.dart`
- Create: `hydroq/lib/features/dashboard/domain/snapshot_freshness_policy.dart`
- Modify: dashboard, reports, alerts, education, profile, recipes screens
- Test: `hydroq/test/features/dashboard/snapshot_freshness_policy_test.dart`
- Test: `hydroq/test/features/dashboard/dashboard_states_test.dart`

**Interfaces:**
- Consumes: all feature states.
- Produces: consistent retry/empty/error presentation and deterministic stale/offline mapping.

- [ ] **Step 1: Write failing freshness-policy tests**

Use configurable thresholds:

```dart
const policy = SnapshotFreshnessPolicy(
  staleAfter: Duration(minutes: 2),
  offlineAfter: Duration(minutes: 10),
);
```

Assert:

- 90 seconds old => current.
- 3 minutes old => stale.
- 11 minutes old => offline.
- Explicit backend offline => offline immediately.

- [ ] **Step 2: Implement freshness policy**

Create:

```dart
enum FreshnessState { current, stale, offline }

class SnapshotFreshnessPolicy {
  const SnapshotFreshnessPolicy({required this.staleAfter, required this.offlineAfter});
  final Duration staleAfter;
  final Duration offlineAfter;

  FreshnessState evaluate({required DateTime receivedAt, required DateTime now, bool explicitlyOffline = false}) {
    if (explicitlyOffline) return FreshnessState.offline;
    final age = now.difference(receivedAt);
    if (age >= offlineAfter) return FreshnessState.offline;
    if (age >= staleAfter) return FreshnessState.stale;
    return FreshnessState.current;
  }
}
```

Threshold values must come from backend configuration when exposed; use two and ten minutes only as MVP UI defaults.

- [ ] **Step 3: Implement shared async and empty widgets**

`AppAsyncView<T>` accepts `AsyncValue<T>`, a data builder, retry callback, cached content, and context-specific error text. `AppEmptyState` accepts icon, title, description, and optional action. Neither widget parses backend messages.

- [ ] **Step 4: Add every explicit state from the spec**

Implement and test:

- No device connected.
- Device offline with last-contact time.
- Stale data with reading age.
- Partial sensor failure that preserves healthy sensor values.
- Backend unreachable with cached snapshot.
- Session refresh failure returning to login.
- Notification permission denied without blocking monitoring.
- No historical data without drawing a zero chart.
- Education network error distinct from zero search results.
- Unsaved recipe confirmation before leaving a dirty form.

- [ ] **Step 5: Add accessibility semantics**

Provide semantic labels for status icons, notification badge, charts, progress indicator, plant images, and sensor values. Verify text scale 1.5 does not clip the three dashboard parameter blocks; they must wrap vertically.

- [ ] **Step 6: Run state tests and commit**

Run:

```bash
flutter test test/features/dashboard/snapshot_freshness_policy_test.dart test/features/dashboard/dashboard_states_test.dart
flutter analyze
```

Expected: all state tests pass.

```bash
git add hydroq/lib/core/widgets hydroq/lib/features hydroq/test/features/dashboard
git commit -m "fix: harden offline error and accessibility states"
```

---

### Task 16: Add Contract Fixtures, Full Integration Flow, and CI

**Files:**
- Create: `hydroq/test/fixtures/current_snapshot.json`
- Create: `hydroq/test/fixtures/realtime_snapshot_event.json`
- Create: `hydroq/test/fixtures/report.json`
- Create: `hydroq/test/fixtures/alert.json`
- Create: `hydroq/test/fixtures/plant_profile.json`
- Create: `hydroq/test/fixtures/custom_recipe.json`
- Create: `hydroq/test/core/contracts/contract_fixture_test.dart`
- Create: `hydroq/test/goldens/design_system_states_test.dart`
- Create: `hydroq/test/goldens/` baseline images generated by the approved harness
- Create: `hydroq/integration_test/app_flow_test.dart`
- Create: `hydroq/.github/workflows/flutter.yml`
- Modify: `hydroq/README.md`

**Interfaces:**
- Consumes: all previous tasks.
- Produces: executable schema fixtures, end-to-end confidence, CI, and onboarding documentation.

- [ ] **Step 1: Create backend-contract fixtures**

Each JSON file must contain a complete valid example using the exact frontend property names. The snapshot fixture must include parameter status and overall status. The report fixture must include points and every summary. The alert fixture must preserve the target range active at event time. The plant fixture must include optional temperature and tips. The recipe fixture must include warning margin and persistence duration.

- [ ] **Step 2: Write fixture parsing tests**

Create `contract_fixture_test.dart` that loads each asset from disk, parses it through the production `fromJson`, serializes back through `toJson`, and asserts identifiers plus critical numeric values survive the round trip.

- [ ] **Step 3: Add design-system golden coverage**

Create `test/goldens/design_system_states_test.dart` using `matchesGoldenFile` for these fixed 390×844 logical-pixel scenarios:

```text
01-dashboard-normal.png
02-dashboard-warning.png
03-dashboard-critical.png
04-dashboard-stale.png
05-dashboard-offline.png
06-dashboard-loading.png
07-education-grid.png
08-education-empty.png
09-profile.png
10-dashboard-text-scale-1-5.png
```

Pump every scenario inside `MaterialApp(theme: AppTheme.light)` and set `tester.view.devicePixelRatio = 1`, `tester.view.physicalSize = const Size(390, 844)`. Generate baselines once with:

```bash
flutter test test/goldens/design_system_states_test.dart --update-goldens
```

Then run the same command without `--update-goldens` in normal verification. Review every generated image before committing it; golden files are implementation artifacts, not replacements for widget assertions.

- [ ] **Step 4: Add integration fakes**

Create in-memory repositories that simulate:

1. Successful login.
2. Dashboard snapshot load.
3. Realtime pH update.
4. Warning event, critical escalation, and recovery event supplied by backend state.
5. Plant-profile activation changing target ranges.
6. Custom recipe creation and activation.
7. Device disconnect and reconnect.
8. Notification route to alert history.

The integration test must never infer alert severity from numeric values; fake backend events provide state explicitly.

- [ ] **Step 5: Implement the integration test**

`integration_test/app_flow_test.dart` performs:

```text
Login → Beranda → observe live update → open report → open alerts →
Edukasi → search Selada → apply profile → Profil → create recipe →
activate recipe → simulate offline/reconnect → open alert from notification.
```

Assert visible Indonesian copy at every transition.

- [ ] **Step 6: Add CI**

Create `.github/workflows/flutter.yml`:

```yaml
name: Flutter CI

on:
  pull_request:
  push:
    branches: [master, main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.3'
          channel: stable
          cache: true
      - run: flutter pub get
        working-directory: hydroq
      - run: dart run build_runner build --delete-conflicting-outputs
        working-directory: hydroq
      - run: flutter analyze
        working-directory: hydroq
      - run: flutter test
        working-directory: hydroq
      - run: flutter test test/goldens/design_system_states_test.dart
        working-directory: hydroq
```

- [ ] **Step 7: Document local startup and backend contract**

README must include:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter test
```

Document that Android emulator uses `10.0.2.2`, physical devices need a reachable LAN or HTTPS backend, Firebase configuration is required for push notifications, and the application expects `/v1` REST plus `/v1/realtime` WebSocket contracts.

- [ ] **Step 8: Run the complete verification suite**

Run:

```bash
cd /mnt/data/hydroponic-app-spec/hydroq
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test test/goldens/design_system_states_test.dart
flutter test integration_test/app_flow_test.dart
```

Expected:

```text
No issues found!
All tests passed!
```

- [ ] **Step 9: Commit the completed MVP plan implementation**

```bash
git add hydroq
git commit -m "test: add contracts integration coverage and CI"
```

---

## Final Acceptance Checklist

- [ ] All user-facing product naming uses the exact `HydroQ` capitalization.
- [ ] App package/project identifier is `hydroq`, and the application title is `HydroQ`.
- [ ] Poppins Regular, Medium, and SemiBold load from bundled assets without runtime font fetching.
- [ ] Feature screens contain no locally invented palette, spacing, radius, elevation, or status-label constants.
- [ ] Design-system golden tests are reviewed and pass.

- [ ] User can log in with email and password.
- [ ] Beranda communicates tank condition within five seconds.
- [ ] pH, EC, TDS, liters, percentage, target ranges, and timestamps are visible.
- [ ] Normal, warning, critical, stale, offline, incomplete, and unconfigured states are distinguishable by text and icon.
- [ ] Realtime updates do not rebuild report state.
- [ ] Realtime failure falls back to one-minute polling and cached values remain timestamped.
- [ ] Reports support day, week, and month without downloading raw long-range history.
- [ ] Alert lifecycle is displayed from backend-provided state and does not spam locally.
- [ ] Edukasi uses search plus a plant grid with no category filter.
- [ ] Plant detail can apply a built-in profile or seed a custom recipe.
- [ ] Profile contains tank, device, recipes, notifications, units, password, and logout.
- [ ] Built-in profiles cannot be edited.
- [ ] Custom recipe validation uses backend physical limits.
- [ ] Push notifications navigate to alert context.
- [ ] Device offline, stale data, partial sensor failure, backend outage, no history, no results, and notification denial have explicit UI.
- [ ] Contract fixtures parse through production models.
- [ ] Unit, widget, integration, analysis, and CI checks pass.

