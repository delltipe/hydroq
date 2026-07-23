$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $ProjectRoot

Write-Host "[1/6] Static source and contract checks" -ForegroundColor Cyan
python scripts/verify_structure.py

Write-Host "[2/6] Mock backend JavaScript syntax" -ForegroundColor Cyan
node --check backend_mock/server.js
node --check backend_mock/contract_test.js

Write-Host "[3/6] Mock backend contract suite" -ForegroundColor Cyan
node backend_mock/contract_test.js

Write-Host "[4/6] Flutter dependencies and formatting" -ForegroundColor Cyan
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test

Write-Host "[5/6] Flutter analysis and tests" -ForegroundColor Cyan
flutter analyze
flutter test

Write-Host "[6/6] Flutter Web release build" -ForegroundColor Cyan
flutter build web --release

Write-Host "All HydroQ verification checks passed." -ForegroundColor Green
