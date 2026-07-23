#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "[1/7] Static source and contract checks"
python3 scripts/verify_structure.py

echo "[2/7] Shell syntax"
bash -n scripts/setup_unix.sh
bash -n scripts/start_unix.sh
bash -n scripts/run_all_checks.sh

echo "[3/7] Mock backend JavaScript syntax"
node --check backend_mock/server.js
node --check backend_mock/contract_test.js

echo "[4/7] Mock backend contract suite"
node backend_mock/contract_test.js

echo "[5/7] JSON, XML, HTML, and YAML parse checks"
python3 - <<'PY'
from pathlib import Path
from html.parser import HTMLParser
import json
import xml.etree.ElementTree as ET

root = Path('.')
for path in root.rglob('*.json'):
    json.loads(path.read_text(encoding='utf-8'))
for path in root.rglob('*.xml'):
    ET.parse(path)
class Parser(HTMLParser):
    pass
for path in root.rglob('*.html'):
    Parser().feed(path.read_text(encoding='utf-8'))
for path in list(root.rglob('*.yaml')) + list(root.rglob('*.yml')):
    text = path.read_text(encoding='utf-8')
    if '\t' in text:
        raise AssertionError(f'YAML file contains tab indentation: {path}')
    if not text.strip():
        raise AssertionError(f'YAML file is empty: {path}')
print('PASS: JSON, XML, HTML, and YAML smoke checks.')
PY

if command -v flutter >/dev/null 2>&1; then
  echo "[6/7] Flutter dependencies, formatting, analysis, and tests"
  flutter pub get
  dart format --output=none --set-exit-if-changed lib test integration_test
  flutter analyze
  flutter test

  echo "[7/7] Flutter Web release build"
  flutter build web --release
else
  echo "[6/7] SKIP: Flutter SDK is not available in PATH."
  echo "[7/7] SKIP: Flutter Web release build requires the Flutter SDK."
fi
