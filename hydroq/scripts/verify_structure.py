#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import struct
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def strip_dart(source: str) -> str:
    out: list[str] = []
    i = 0
    state = 'code'
    quote = ''
    triple = False
    while i < len(source):
        ch = source[i]
        nxt = source[i + 1] if i + 1 < len(source) else ''
        if state == 'code':
            if ch == '/' and nxt == '/':
                state = 'line_comment'; out.extend('  '); i += 2; continue
            if ch == '/' and nxt == '*':
                state = 'block_comment'; out.extend('  '); i += 2; continue
            if ch in "'\"":
                quote = ch
                triple = source[i:i + 3] == ch * 3
                state = 'string'
                count = 3 if triple else 1
                out.extend(' ' * count); i += count; continue
            out.append(ch); i += 1; continue
        if state == 'line_comment':
            if ch == '\n': state = 'code'; out.append('\n')
            else: out.append(' ')
            i += 1; continue
        if state == 'block_comment':
            if ch == '*' and nxt == '/': state = 'code'; out.extend('  '); i += 2
            else: out.append('\n' if ch == '\n' else ' '); i += 1
            continue
        if state == 'string':
            if ch == '\\': out.extend('  '); i += 2; continue
            if triple and source[i:i + 3] == quote * 3:
                out.extend('   '); i += 3; state = 'code'; continue
            if not triple and ch == quote:
                out.append(' '); i += 1; state = 'code'; continue
            out.append('\n' if ch == '\n' else ' '); i += 1
    if state in {'string', 'block_comment'}:
        raise AssertionError(f'Unterminated Dart {state}')
    return ''.join(out)


def verify_dart(path: Path) -> None:
    source = path.read_text(encoding='utf-8')
    cleaned = strip_dart(source)
    stack: list[tuple[str, int]] = []
    pairs = {')': '(', ']': '[', '}': '{'}
    for index, ch in enumerate(cleaned):
        if ch in '([{': stack.append((ch, index))
        elif ch in ')]}':
            if not stack or stack[-1][0] != pairs[ch]:
                line = cleaned.count('\n', 0, index) + 1
                raise AssertionError(f'{path}: unmatched {ch} at line {line}')
            stack.pop()
    if stack:
        ch, index = stack[-1]
        line = cleaned.count('\n', 0, index) + 1
        raise AssertionError(f'{path}: unclosed {ch} from line {line}')

    for match in re.finditer(r"import\s+'([^']+)'", source):
        target = match.group(1)
        if target.startswith(('dart:', 'package:flutter', 'package:integration_test', 'package:hydroq')):
            continue
        resolved = (path.parent / target).resolve()
        if not resolved.exists():
            raise AssertionError(f'{path}: missing relative import {target}')


def require_keys(document: dict, keys: set[str], label: str) -> None:
    missing = keys.difference(document)
    if missing:
        raise AssertionError(f'{label} fixture missing keys: {sorted(missing)}')


def verify_fixtures() -> None:
    fixture_dir = ROOT / 'test' / 'fixtures'
    fixtures = {path.stem: json.loads(path.read_text(encoding='utf-8')) for path in fixture_dir.glob('*.json')}
    if set(fixtures) != {'snapshot', 'report', 'alert', 'plant', 'recipe'}:
        raise AssertionError(f'Unexpected contract fixtures: {sorted(fixtures)}')

    require_keys(fixtures['snapshot'], {'tankId', 'tankName', 'deviceConfigured', 'deviceOnline', 'updatedAt', 'overallState', 'readings'}, 'snapshot')
    require_keys(fixtures['snapshot']['readings'], {'ph', 'ec', 'volume'}, 'snapshot.readings')
    require_keys(fixtures['report']['summary'], {'average', 'minimum', 'maximum', 'sampleCount', 'warningCount', 'criticalCount', 'abnormalDurationMinutes'}, 'report.summary')
    require_keys(fixtures['alert'], {'id', 'state', 'metric', 'valueText', 'targetRange', 'createdAt', 'resolved'}, 'alert')
    require_keys(fixtures['plant'], {'id', 'name', 'aliases', 'phMin', 'phMax', 'ecMin', 'ecMax', 'waterTempMin', 'waterTempMax'}, 'plant')
    require_keys(fixtures['recipe'], {'id', 'name', 'phMin', 'phMax', 'ecMin', 'ecMax', 'minimumVolumeLiters', 'warningMarginPercent', 'persistenceMinutes'}, 'recipe')


def main() -> int:
    required = [
        ROOT / 'pubspec.yaml', ROOT / 'lib/main.dart', ROOT / 'web/index.html',
        ROOT / 'README.md', ROOT / 'API_CONTRACT.md', ROOT / 'backend_mock/server.js',
        ROOT / 'scripts/setup_windows.ps1', ROOT / 'scripts/setup_unix.sh',
    ]
    for path in required:
        if not path.exists(): raise AssertionError(f'Missing required file: {path}')

    pubspec_text = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    if not re.search(r'^name:\s*hydroq\s*$', pubspec_text, re.MULTILINE):
        raise AssertionError('pubspec package name must be hydroq')
    if "sdk: '>=3.4.0 <4.0.0'" not in pubspec_text:
        raise AssertionError('pubspec Dart SDK constraint changed unexpectedly')
    dependency_block = pubspec_text.split('dependencies:', 1)[1].split('dev_dependencies:', 1)[0]
    dependency_names = set(re.findall(r'^  ([a-zA-Z0-9_]+):', dependency_block, re.MULTILINE))
    if dependency_names != {'flutter', 'flutter_localizations'}:
        raise AssertionError(f'Unexpected runtime dependencies: {sorted(dependency_names)}')

    manifest = json.loads((ROOT / 'web/manifest.json').read_text(encoding='utf-8'))
    assert manifest['name'] == 'HydroQ'
    assert manifest['short_name'] == 'HydroQ'
    for icon in manifest['icons']:
        assert (ROOT / 'web' / icon['src']).exists(), icon['src']

    dart_files = sorted((ROOT / 'lib').rglob('*.dart')) + sorted((ROOT / 'test').rglob('*.dart')) + sorted((ROOT / 'integration_test').rglob('*.dart'))
    if len(dart_files) < 20: raise AssertionError('Unexpectedly small Dart source set')
    for path in dart_files: verify_dart(path)

    source_text = '\n'.join(path.read_text(encoding='utf-8') for path in dart_files)
    forbidden = ['TODO', 'TBD', 'Hydro Q', 'Hydroq', 'minimumVolumePercent', 'warningEnabled', 'criticalEnabled']
    for token in forbidden:
        if token in source_text: raise AssertionError(f'Forbidden placeholder/obsolete name found: {token}')
    for label in [
        'Beranda', 'Edukasi', 'Profil', 'Kondisi air saat ini', 'HydroQ',
        'Volume minimum aman', 'Margin warning', 'Persistensi alert',
        'Data tidak lengkap', 'Perangkat belum dikonfigurasi',
    ]:
        if label not in source_text: raise AssertionError(f'Missing key UI copy: {label}')

    verify_fixtures()

    if source_text.count('PlantProfile(') < 9:
        raise AssertionError('Expected at least eight built-in plant profiles plus test coverage')
    for required_symbol in [
        'classifyReading(', 'combineReadingStates(', 'setDemoStaleState(',
        'setSensorAvailability(', 'copyPlantAsRecipe(', 'activateRecipe(',
    ]:
        if required_symbol not in source_text:
            raise AssertionError(f'Missing required domain behavior: {required_symbol}')

    repository_files = list(ROOT.rglob('*'))
    forbidden_extensions = {'.ttf', '.otf', '.woff', '.woff2'}
    font_files = [path for path in repository_files if path.is_file() and path.suffix.lower() in forbidden_extensions]
    if font_files:
        raise AssertionError(f'Unexpected redistributed font binaries: {font_files}')

    secret_patterns = [
        r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
        r'AIza[0-9A-Za-z_-]{30,}',
        r'gh[pousr]_[0-9A-Za-z]{30,}',
        r'sk-[0-9A-Za-z]{32,}',
    ]
    text_files = [
        path for path in repository_files
        if path.is_file() and path.suffix.lower() in {'.dart', '.js', '.json', '.yaml', '.yml', '.md', '.html', '.sh', '.ps1', '.bat'}
    ]
    combined_text = '\n'.join(path.read_text(encoding='utf-8', errors='ignore') for path in text_files)
    for pattern in secret_patterns:
        if re.search(pattern, combined_text):
            raise AssertionError(f'Potential secret detected by pattern: {pattern}')

    screenshot_dir = ROOT / 'verification' / 'screenshots'
    expected_screenshots = {
        'dashboard-phone.png': (390, 1000),
        'dashboard-tablet.png': (700, 900),
        'dashboard-desktop.png': (1200, 800),
    }
    for name, minimum_size in expected_screenshots.items():
        image = screenshot_dir / name
        if not image.exists():
            raise AssertionError(f'Missing responsive visual snapshot: {image}')
        data = image.read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n':
            raise AssertionError(f'Invalid PNG signature: {image}')
        width, height = struct.unpack('>II', data[16:24])
        if width < minimum_size[0] or height < minimum_size[1]:
            raise AssertionError(f'Unexpectedly small visual snapshot {name}: {width}x{height}')

    print(f'PASS: {len(dart_files)} Dart files have balanced delimiters and resolved relative imports.')
    print('PASS: pubspec is SDK-only and web manifest assets resolve.')
    print('PASS: required HydroQ states, controls, and product copy are present.')
    print('PASS: 5 API contract fixtures contain all required fields.')
    print('PASS: domain behaviors, secret scan, font policy, and responsive PNG snapshots verified.')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        raise
