#!/usr/bin/env bash
# Собирает приложение Focusly и запускает его (предыдущий экземпляр закрывается).
#
#   ./scripts/run.sh
#
# Удобно, когда хочется посмотреть результат, не переключаясь в Xcode.
# Логи приложения (os.Logger) смотрите в Console.app с фильтром «Focusly»
# или командой: log stream --predicate 'subsystem == "Focusly"' --level debug

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_PROJECT="${FOCUSLY_PROJECT:-$ROOT/Focusly/Focusly.xcodeproj}"
APP_SCHEME="${FOCUSLY_SCHEME:-Focusly}"
DERIVED="$ROOT/.build/xcode-run"
LOG="$ROOT/.build/check-logs/run-build.log"
mkdir -p "$(dirname "$LOG")"

if [[ ! -d "$APP_PROJECT" ]]; then
    echo "Xcode-проект не найден: ${APP_PROJECT#"$ROOT/"} — создайте его в уроке 0."
    exit 1
fi

echo "Сборка…"
if ! xcodebuild -project "$APP_PROJECT" -scheme "$APP_SCHEME" -destination "platform=macOS" \
    -derivedDataPath "$DERIVED" build >"$LOG" 2>&1; then
    grep -E "error:" "$LOG" | sed -E "s|$ROOT/||g" | awk '!seen[$0]++' | head -30
    echo "Сборка не удалась, полный лог: ${LOG#"$ROOT/"}"
    exit 1
fi

APP="$(find "$DERIVED/Build/Products/Debug" -maxdepth 1 -name "*.app" | head -1)"
NAME="$(basename "$APP" .app)"
pkill -x "$NAME" 2>/dev/null && sleep 0.5 || true
echo "Запуск $NAME.app"
open "$APP"
