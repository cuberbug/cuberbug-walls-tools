#!/usr/bin/env bash

LAUNCHER_DEBUG=0
LAUNCHER_NO_COLOR=0


# =============================
# Разбор аргументов командной строки
# -----------------------------
# Читает переданные скрипту опции и переопределяет глобальные переменные конфигурации.
#
# Параметры:
#   $@ — все аргументы скрипта
# =============================
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      -N|--no-color) LAUNCHER_NO_COLOR=1; shift ;;
      -d|--debug) LAUNCHER_DEBUG=1; shift ;;
      -h|--help|help) show_help; exit 0 ;;
      -v|--version) printf 'v%s\n' "$LAUNCHER_VERSION"; exit 0 ;;
      -*)
        printf 'Неизвестная опция: %s. Используйте --help для справки.\n' "$1" >&2
        exit 1
        ;;
      *)
        printf 'Ошибка: Скрипт не принимает позиционные аргументы (%s).\n' "$1" >&2
        exit 1
        ;;
    esac
  done
}


# =============================
# Проверяет, включен ли режим отладки.
# -----------------------------
# Переменная LAUNCHER_DEBUG должна содержать:
#   0 — режим отладки выключен.
#   1 — режим отладки включен.
#
# Код возврата:
#   0 — если LAUNCHER_DEBUG=1.
#   1 — если LAUNCHER_DEBUG=0.
# =============================
is_debug() {
  [[ "$LAUNCHER_DEBUG" -eq 1 ]]
}


# =============================
# Проверяет, включен ли режим без цвета.
# -----------------------------
# Переменная LAUNCHER_NO_COLOR должна содержать:
#   0 — цветной вывод включен.
#   1 — цветной вывод отключен.
#
# Код возврата:
#   0 — если LAUNCHER_NO_COLOR=1.
#   1 — если LAUNCHER_NO_COLOR=0.
# =============================
is_no_color() {
  [[ "$LAUNCHER_NO_COLOR" -eq 1 ]]
}


# =============================
# Имя функции: init_env
# -----------------------------
# Инициализирует окружение после проверки системных зависимостей:
#   - Настраивает форматирование выводимого текста
#   - Устанавливает значения для важных переменных
#
# Возвращаемые значения:
#   0 — если все зависимости найдены
#   1 — если отсутствует хотя бы одна зависимость
# =============================
init_env() {
  p_debug 'Запуск инициализации окружения...'

  check_dependencies

  # REPO_TOOLS_ROOT определяется в главном файле `start`
  readonly APPS_DIR="${REPO_TOOLS_ROOT}/apps"

  readonly REQUIREMENTS_FILE="${APPS_DIR}/requirements.txt"
  readonly VENV_DIR="${APPS_DIR}/.venv"
  readonly VENV_PYTHON_FILE="${VENV_DIR}/bin/python"
  readonly VENV_PIP_FILE="${VENV_DIR}/bin/pip"

  readonly MENU_APP='apps.menu.menu'


  p_debug 'Переменные окружения подготовлены.'
  p_debug "Рабочая директория: $(f_bold "$REPO_TOOLS_ROOT")"
  p_debug "Директория Python-приложений: $(f_bold "$APPS_DIR")"

  p_debug "Зависимости: $(f_bold "$REQUIREMENTS_FILE")"
  p_debug "Директория для установки виртуального окружения: $(f_bold "$VENV_DIR")"
  p_debug "Путь к локальному интерпретатору Python: $(f_bold "$VENV_PYTHON_FILE")"
  p_debug "Путь к локальному менеджеру пакетов Pip: $(f_bold "$VENV_PIP_FILE")"

  p_debug "Используемый адрес Python-приложения для запуска меню: $(f_bold "$MENU_APP")"
}


# =============================
# Имя функции: check_dependencies
# -----------------------------
# Назначение:
#   Проверяет наличие системных зависимостей (Git и Python).
#
# Возвращаемые значения:
#   0 — если все зависимости найдены
#   1 — если отсутствует хотя бы одна зависимость
# =============================
check_dependencies() {
  p_info "Проверка системных зависимостей..."
  if ! command -v git &>/dev/null; then
    p_error 'Git не найден. Пожалуйста, установите Git.'
    return 1
  fi
  if ! command -v python3 &>/dev/null && ! command -v python &>/dev/null; then
    p_error 'Python не найден. Пожалуйста, установите Python.'
    return 1
  fi
  p_done 'Все системные зависимости найдены.'
  return 0
}
