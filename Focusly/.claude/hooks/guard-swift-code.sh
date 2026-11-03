#!/usr/bin/env bash
# Хук PreToolUse: режим ментора.
# Не даёт агенту создавать и менять .swift-файлы проекта (код пишет человек).
# Исключение: Package.swift (это конфигурация, а не код урока).
#
# Временно выключить: touch .claude/mentor-off   (включить обратно: rm .claude/mentor-off)

set -euo pipefail

INPUT="$(cat)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

[[ -f "$PROJECT_DIR/.claude/mentor-off" ]] && exit 0

TOOL="$(jq -r '.tool_name // ""' <<<"$INPUT")"

deny() {
    cat >&2 <<EOF
Режим ментора: $1
Код в этом проекте пишет пользователь. Вместо правки:
  • укажи файл и строку, объясни, что не так и почему;
  • дай подсказку нужного уровня (см. /hint) или маленький пример НЕ из проекта;
  • предложи, как проверить: ./scripts/check.sh
Если пользователь сам просит написать код за него — попроси его выполнить
\`touch .claude/mentor-off\` (и \`rm .claude/mentor-off\` после).
EOF
    exit 2
}

is_guarded_path() {
    local path="$1"
    [[ "$path" == *.swift ]] || return 1
    [[ "$(basename "$path")" == "Package.swift" ]] && return 1
    # Только файлы внутри проекта; черновики в /tmp и scratchpad разрешены.
    case "$path" in
        /*) [[ "$path" == "$PROJECT_DIR"/* ]] || return 1 ;;
    esac
    return 0
}

case "$TOOL" in
    Write | Edit | MultiEdit | NotebookEdit)
        FILE="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' <<<"$INPUT")"
        if is_guarded_path "$FILE"; then
            deny "запись в ${FILE#"$PROJECT_DIR/"} заблокирована."
        fi
        ;;
    Bash)
        CMD="$(jq -r '.tool_input.command // ""' <<<"$INPUT")"
        # Ловим попытки записать .swift через shell: >, >>, tee, sed -i, cp/mv в .swift, swift format -i.
        if grep -Eq '(>|tee |sed -i|perl -[a-z]*i|(^|[ ;&|])(cp|mv|touch) )[^|;&]*\.swift([^a-zA-Z]|$)' <<<"$CMD" \
            && ! grep -Eq 'Package\.swift' <<<"$CMD"; then
            deny "команда похожа на запись в .swift-файл."
        fi
        if grep -Eq 'swift[- ]format[^|;&]*( -i| --in-place)' <<<"$CMD"; then
            deny "автоформатирование меняет код — пусть пользователь запустит его сам."
        fi
        ;;
esac

exit 0
