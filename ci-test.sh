#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function citest_cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  set -o errexit -o pipefail
  trap 'echo T: "Failed at $BASH_SOURCE line $LINENO: $BASH_COMMAND" >&2' ERR
  exec 7>>"${GITHUB_STEP_SUMMARY:-/tmp.stepsum.txt}"

  local TODO=
  TODO+=' @joint/core@4.1.3'
  TODO+=' @types/ansicolors@0.0.29'
  TODO+=' ansible-bogus-linux-pwhash'
  TODO+=' is-string@1.0.7'
  TODO="${TODO# }"
  export TODO
  ./bundle.sh --env-todo

  cat -- "$GITHUB_ENV" >tmp.ci-test.actual.txt
  echo >>tmp.ci-test.actual.txt

  local FILES=()
  readarray -t FILES < <(find tmp.bundled/ -type f | sort -V)
  sha1sum --binary -- "${FILES[@]}" | sed -re 's~^(\S+) \*[^/]+/(.*$)~\2\
    = \1~' >>tmp.ci-test.actual.txt

  local DIFF_RV=0
  echo $'\n#### Compare with expectations:\n\n```diff' >&7
  diff -sU 2 -- \
    tmp.ci-test.actual.txt \
    ci-test.want.txt \
    >&7 || DIFF_RV="$?"
  echo '```' >&7

  return "$DIFF_RV"
}








citest_cli_main "$@"; exit $?
