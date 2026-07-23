#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter tidak ditemukan di PATH. Instal Flutter 3.44.x stable lalu buka terminal baru." >&2
  exit 1
fi

printf 'Menggunakan: '
flutter --version | head -n 1

if [[ ! -d android ]]; then
  backup="$(mktemp -d)"
  trap 'rm -rf "$backup"' EXIT
  cp -R lib test integration_test web pubspec.yaml analysis_options.yaml "$backup/"

  case "$(uname -s)" in
    Darwin) platforms="android,ios,web,macos" ;;
    Linux) platforms="android,web,linux" ;;
    *) platforms="android,web" ;;
  esac

  flutter create --org com.hydroq --project-name hydroq --platforms="$platforms" .
  rm -rf lib test integration_test web
  mkdir -p lib test integration_test web
  cp -R "$backup/lib/." lib/
  cp -R "$backup/test/." test/
  cp -R "$backup/integration_test/." integration_test/
  cp -R "$backup/web/." web/
  cp "$backup/pubspec.yaml" "$backup/analysis_options.yaml" .
  rm -rf "$backup"
  trap - EXIT
fi

if [[ -f android/app/src/main/AndroidManifest.xml ]]; then
  sed -i.bak 's/android:label="hydroq"/android:label="HydroQ"/' android/app/src/main/AndroidManifest.xml
  rm -f android/app/src/main/AndroidManifest.xml.bak
fi
if [[ -f ios/Runner/Info.plist ]]; then
  sed -i.bak 's/<string>hydroq<\/string>/<string>HydroQ<\/string>/' ios/Runner/Info.plist
  rm -f ios/Runner/Info.plist.bak
fi

flutter pub get
flutter analyze
flutter test
flutter build web --release
printf '\nHydroQ siap dan build Web release berhasil. Jalankan: flutter run -d web-server --web-port 8080\n'
