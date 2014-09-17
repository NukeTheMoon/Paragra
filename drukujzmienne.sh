#!/bin/bash

VARS="`set -o posix ; set `"
source test.sh
SCRIPT_VARS="`grep -vFe "$VARS" <<<"$(set -o posix ; set)" | grep -v ^VARS=`"
echo "$SCRIPT_VARS"
unset VARS
