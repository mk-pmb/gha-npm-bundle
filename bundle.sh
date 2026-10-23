#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function bundle_cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  set -o errexit -o pipefail
  local OUT_DIR='tmp.bundled'
  mkdir --parents -- "$OUT_DIR"

  local TODO="$*"
  echo "TODO: '$TODO'"

  echo "$EPOCHSECONDS" >"$OUT_DIR"/bundle_uts.txt
}








bundle_cli_main "$@"; exit $?
