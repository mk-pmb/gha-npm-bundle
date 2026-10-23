#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function citest_cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  set -o errexit -o pipefail

  local TODO=
  ./bundle.sh "$TODO"

  find tmp.bundled/ | sort -V
}








citest_cli_main "$@"; exit $?
