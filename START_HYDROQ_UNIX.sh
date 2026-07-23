#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/hydroq"
bash scripts/setup_unix.sh
flutter run -d web-server --web-port 8080
