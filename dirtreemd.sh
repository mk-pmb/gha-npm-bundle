#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function dirtreemd_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  set -o errexit -o pipefail
  trap 'echo T: "Failed at $BASH_SOURCE line $LINENO: $BASH_COMMAND" >&2' ERR
  cd -- "${1:-.}"; shift || true
  ( dirtreemd_scan "${1:-}" )
}


function dirtreemd_scan {
  local BULLET="${BULLET:-* }"
  cd -- "$1"
  local TODO="$(ls -1 -v --almost-all --group-directories-first)"$'\n'
  local ITEM=
  local SYMS=() DIRS=() FILES=()
  while [ -n "$TODO" ]; do
    ITEM="${TODO%%$'\n'*}"
    TODO="${TODO#*$'\n'}"
    if [ -L "$ITEM" ]; then
      # Symlinks need to go first because they might also be a directory.
      # For now, we treat symlinks as just files:
      FILES+=( "$ITEM" )
    elif [ -d "$ITEM" ]; then
      DIRS+=( "$ITEM" )
    else
      FILES+=( "$ITEM" )
    fi
  done

  local N_FILES="${#FILES[@]}"
  local BADGES=' '
  [[ " ${FILES[*]} " == *'-lock.json'* ]] && BADGES+='🔒' || true
  local MAX_PREVIEW_FILES=3
  local BUF="${FILES[*]:0:$MAX_PREVIEW_FILES}"
  [ -z "$BUF" ] || BUF='`'"${BUF//' '/'`, `'}"'`'
  BUF="$BULLET\`$1\` ($N_FILES)${BADGES% }: $BUF"
  [ "$N_FILES" -le $MAX_PREVIEW_FILES ] || BUF+=', …'
  BUF="${BUF% }"
  BUF="${BUF%:}"
  BUF="${BUF/' (0)'/}"
  echo "$BUF"

  for ITEM in "${DIRS[@]}"; do
    ( BULLET="  $BULLET" "$FUNCNAME" "$ITEM" )
  done
}










dirtreemd_cli_init "$@"; exit $?
