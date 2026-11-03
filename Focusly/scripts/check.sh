#!/usr/bin/env bash
# Проверка проекта Focusly одной командой.
#
#   ./scripts/check.sh          всё: стиль + ядро (сборка и тесты) + приложение
#   ./scripts/check.sh core     только пакет FocuslyCore: swift build + swift test
#   ./scripts/check.sh app      только сборка приложения через xcodebuild
#   ./scripts/check.sh lint     только проверка стиля (swift format lint)
#   ./scripts/check.sh test Foo только тесты, в имени которых есть Foo
#
# Полные логи лежат в .build/check-logs/. На экран выводятся только ошибки,
# предупреждения и итог, чтобы их было легко читать и тебе, и агенту.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE="$ROOT/FocuslyCore"
APP_PROJECT="${FOCUSLY_PROJECT:-$ROOT/Focusly/Focusly.xcodeproj}"
APP_SCHEME="${FOCUSLY_SCHEME:-Focusly}"
LOGS="$ROOT/.build/check-logs"
mkdir -p "$LOGS"

if [[ -t 1 ]]; then
    GREEN=$'\e[32m'; RED=$'\e[31m'; YELLOW=$'\e[33m'; BOLD=$'\e[1m'; RESET=$'\e[0m'
else
    GREEN=""; RED=""; YELLOW=""; BOLD=""; RESET=""
fi

declare -a SUMMARY=()
FAILED=0

record() { # record <имя шага> <ok|fail|skip> [комментарий]
    local name="$1" status="$2" note="${3:-}"
    case "$status" in
        ok)   SUMMARY+=("${GREEN}✔${RESET} $name $note") ;;
        fail) SUMMARY+=("${RED}✘${RESET} $name $note"); FAILED=1 ;;
        skip) SUMMARY+=("${YELLOW}–${RESET} $name $note") ;;
    esac
}

header() { echo; echo "${BOLD}== $1 ==${RESET}"; }

# Показывает из лога только то, что важно: ошибки, предупреждения, упавшие тесты.
important_lines() {
    sed -E $'s/\x1b\\[[0-9;]*m//g' "$1" \
        | grep -E "error:|warning:|✘|Fatal|fatal error|Test run with" \
        | grep -vE "^[[:space:]]*$|^[[:space:]]*\||Command line:|failed with a nonzero exit code" \
        | sed -E "s|$ROOT/||g" \
        | awk '!seen[$0]++' \
        | head -60
}

swift_files() {
    local dirs=("$CORE/Sources" "$CORE/Tests")
    [[ -d "$ROOT/Focusly/Focusly" ]] && dirs+=("$ROOT/Focusly/Focusly")
    [[ -d "$ROOT/Focusly/FocuslyTests" ]] && dirs+=("$ROOT/Focusly/FocuslyTests")
    find "${dirs[@]}" -name "*.swift" -not -path "*/.build/*" 2>/dev/null
}

step_lint() {
    header "Стиль (swift format lint)"
    local log="$LOGS/lint.log"
    local files
    files=$(swift_files)
    if [[ -z "$files" ]]; then
        record "Стиль" skip "(нет .swift файлов)"
        return
    fi
    # shellcheck disable=SC2086
    swift format lint --configuration "$ROOT/.swift-format" $files >"$log" 2>&1
    local count
    count=$(grep -c "warning:\|error:" "$log" || true)
    if [[ "$count" -eq 0 ]]; then
        echo "замечаний нет"
        record "Стиль" ok
    else
        sed -E "s|$ROOT/||g" "$log" | head -40
        # Стиль не валит проверку: это подсказки, а не ошибки.
        record "Стиль" ok "(${YELLOW}замечаний: $count${RESET}, исправить: swift format -i <файл>)"
    fi
}

core_exists() {
    if [[ -f "$CORE/Package.swift" ]]; then
        return 0
    fi
    echo "Пакет не найден: FocuslyCore/Package.swift"
    echo "Его нужно создать в уроке 0 (Xcode → File → New → Package → Library)."
    return 1
}

step_core_build() {
    header "Ядро: сборка (swift build)"
    if ! core_exists; then
        record "Ядро" skip "(пакет ещё не создан)"
        return 1
    fi
    local log="$LOGS/core-build.log"
    if (cd "$CORE" && swift build --build-tests) >"$log" 2>&1; then
        important_lines "$log"
        record "Ядро: сборка" ok
        return 0
    else
        important_lines "$log"
        record "Ядро: сборка" fail "(лог: .build/check-logs/core-build.log)"
        return 1
    fi
}

step_core_test() {
    local filter="${1:-}"
    header "Ядро: тесты (swift test${filter:+ --filter $filter})"
    if ! core_exists; then
        record "Ядро: тесты" skip "(пакет ещё не создан)"
        return
    fi
    local log="$LOGS/core-test.log"
    local args=()
    [[ -n "$filter" ]] && args+=(--filter "$filter")
    if (cd "$CORE" && swift test ${args[@]+"${args[@]}"}) >"$log" 2>&1; then
        grep -E "✘|Test run with|warning:" "$log" | sed -E "s|$ROOT/||g" | awk '!seen[$0]++' | tail -5
        record "Ядро: тесты" ok
    else
        important_lines "$log"
        record "Ядро: тесты" fail "(лог: .build/check-logs/core-test.log)"
    fi
}

step_app() {
    header "Приложение: сборка (xcodebuild)"
    if [[ ! -d "$APP_PROJECT" ]]; then
        echo "Xcode-проект не найден: ${APP_PROJECT#"$ROOT/"}"
        echo "Его нужно создать в уроке 0 (Xcode → File → New → Project → macOS App)."
        record "Приложение" skip "(проект ещё не создан)"
        return
    fi
    local log="$LOGS/app-build.log"
    if xcodebuild \
        -project "$APP_PROJECT" \
        -scheme "$APP_SCHEME" \
        -destination "platform=macOS" \
        -derivedDataPath "$ROOT/.build/xcode" \
        CODE_SIGNING_ALLOWED=NO \
        build >"$log" 2>&1; then
        important_lines "$log" | grep -v "Test run" || true
        record "Приложение" ok
    else
        important_lines "$log"
        record "Приложение" fail "(лог: .build/check-logs/app-build.log)"
    fi
}

print_summary() {
    header "Итог"
    printf '%s\n' "${SUMMARY[@]}"
    exit "$FAILED"
}

case "${1:-all}" in
    lint) step_lint ;;
    core) step_core_build && step_core_test ;;
    test) step_core_test "${2:-}" ;;
    app)  step_app ;;
    all)
        step_lint
        step_core_build && step_core_test
        step_app
        ;;
    -h|--help|help)
        sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
    *)
        echo "Неизвестная команда: $1 (см. ./scripts/check.sh --help)"
        exit 2
        ;;
esac
print_summary
