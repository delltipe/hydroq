$ErrorActionPreference = "Stop"

Write-Host "HydroQ setup" -ForegroundColor Green
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter tidak ditemukan di PATH. Instal Flutter 3.44.x stable lalu buka terminal baru."
}

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $ProjectRoot
flutter --version | Select-Object -First 1

if (-not (Test-Path "android")) {
  Write-Host "Membuat platform runner Android, Web, dan Windows..."
  $Backup = Join-Path $env:TEMP ("hydroq-source-" + [guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Path $Backup | Out-Null
  Copy-Item lib, test, integration_test, web, pubspec.yaml, analysis_options.yaml -Destination $Backup -Recurse -Force

  flutter create --org com.hydroq --project-name hydroq --platforms=android,web,windows .

  Remove-Item lib, test, integration_test, web -Recurse -Force
  New-Item -ItemType Directory -Path lib, test, integration_test, web | Out-Null
  Copy-Item (Join-Path $Backup "lib\*") lib -Recurse -Force
  Copy-Item (Join-Path $Backup "test\*") test -Recurse -Force
  Copy-Item (Join-Path $Backup "integration_test\*") integration_test -Recurse -Force
  Copy-Item (Join-Path $Backup "web\*") web -Recurse -Force
  Copy-Item (Join-Path $Backup "pubspec.yaml") . -Force
  Copy-Item (Join-Path $Backup "analysis_options.yaml") . -Force
  Remove-Item $Backup -Recurse -Force
}

$AndroidManifest = Join-Path $ProjectRoot "android/app/src/main/AndroidManifest.xml"
if (Test-Path $AndroidManifest) {
  (Get-Content $AndroidManifest -Raw).Replace('android:label="hydroq"', 'android:label="HydroQ"') | Set-Content $AndroidManifest -NoNewline
}

$WindowsRunner = Join-Path $ProjectRoot "windows/runner/main.cpp"
if (Test-Path $WindowsRunner) {
  (Get-Content $WindowsRunner -Raw).Replace('L"hydroq"', 'L"HydroQ"') | Set-Content $WindowsRunner -NoNewline
}

flutter pub get
flutter analyze
flutter test
flutter build web --release
Write-Host "`nHydroQ siap dan build Web release berhasil. Jalankan: flutter run -d web-server --web-port 8080" -ForegroundColor Green
Write-Host "Lalu buka URL yang muncul menggunakan Brave atau browser pilihanmu."
