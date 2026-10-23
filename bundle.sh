#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function bundle_cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  set -o errexit -o pipefail
  trap 'echo T: "Failed at $BASH_SOURCE line $LINENO: $BASH_COMMAND" >&2' ERR
  exec 7>>"${GITHUB_STEP_SUMMARY:-/tmp.stepsum.txt}"

  local TODO="$TODO"
  [ "$#:$1" == 1:--env-todo ] || TODO="$*"
  TODO="${TODO//$'\n'/ }"
  echo $'\n'"Original todo list: \`$TODO\`">&7
  TODO+=' '
  local VAL=
  while [ -n "$TODO" ]; do
    VAL="${TODO%% *}"
    TODO="${TODO#* }"
    [ -z "$VAL" ] || bundle_one_package "$VAL"
  done
}


function bundle_one_package () {
  local PKG="$1"
  local VER=
  local ORG=
  case "$PKG" in
    @/* ) echo E: 'Empty org name in package name!' >&2; return 4;;
    @*/* ) ORG="${PKG%%/*}"; ORG="${ORG#@}"; PKG="${PKG#*/}";;
  esac
  case "$PKG" in
    *@* ) VER="${PKG##*@}"; PKG="${PKG%@*}";;
  esac

  local KEY= VAL= BAD=
  for KEY in ORG PKG VER; do
    eval 'VAL="$'"$KEY"'"'
    BAD="${VAL//[0-9a-z_.-]/}"
    [ -z "$BAD" ] || return 4$(
      echo E: "Unsupported characters in input slot $KEY: $BAD" >&2)
    case "$VAL" in
      '' ) ;;
      [a-z0-9]* ) ;;
      * )
        echo E: "Input slot $KEY must start with a letter or digit!" >&2
        return 4;;
    esac
  done
  [ -n "$PKG" ] || return 4$(echo E: 'Package name is mandatory!' >&2)
  [ -n "$VER" ] || VER='latest'

  local OUT_DIR='tmp.bundled'
  mkdir --parents -- "$OUT_DIR"

  local SUB="$PKG"
  [ -z "$ORG" ] || SUB="@$ORG/$SUB"
  echo D: "Gonna bundle $SUB@$VER:"
  echo $'\n'"#### Bundle: \`$SUB@$VER\`" >&7
  npm install "$SUB@$VER"
  git checkout HEAD package.json

  VER="$(jq --raw-output .version <"node_modules/$SUB/package.json")"
  case "$VER" in
    [0-9]*.[0-9]*.[0-9]* ) ;;
    * )
      echo E: "Failed to detect effective version of $SUB: Got '$VER'" >&2
      return 4;;
  esac

  [ -z "$ORG" ] || mkdir --parents -- "$OUT_DIR/@$ORG"
  bundle_rm_trash node_modules/
  mv --no-target-directory -- {node_modules,"$OUT_DIR"}/"$SUB"
  [ -z "$ORG" ] || rmdir -- "node_modules/@$ORG" 2>/dev/null || true
  mv --target-directory="$OUT_DIR/$SUB" -- node_modules
  rmdir -- "$OUT_DIR/$SUB/node_modules" 2>/dev/null || true

  # ( echo ; ./dirtreemd.sh "$OUT_DIR" "$SUB" ) >&7

  VAL="${SUB//'/'/.}@$VER"
  echo "ARTIFACT_NAME=$VAL" >>"$GITHUB_ENV"
  echo $'\n'"Artifact name will be \`$VAL\`">&7
  echo >&7
}


function bundle_rm_trash () {
  local SUB="$1"
  [ -d "$SUB" ] || return 4$(echo E: $FUNCNAME: "Not a directory: $SUB" >&2)
  local ITEM= VAL=
  for ITEM in "$SUB"/{.,}*; do
    ! [ -L "$ITEM" ] || continue
    VAL="$(basename -- "$ITEM")"
    ! [ -d "$ITEM" ] || VAL+=/
    VAL="${VAL,,}"
    VAL="${VAL/%.yml/.yaml}"
    case "$VAL" in
      .git/ | \
      .github/ | \
      '' ) rm --recursive -- "$ITEM";;

      */ ) "$FUNCNAME" "$ITEM";;

      .package-lock.json | \
      funding.yaml | \
      package-lock.json | \
      '' ) rm -- "$ITEM";;
    esac
  done
  rmdir -- "$SUB" 2>/dev/null || true
}









bundle_cli_main "$@"; exit $?
