#!/usr/bin/env zsh

line() {
  setopt local_options warn_create_global

  local end=$'\n'
  if [[ "$1" == '-n' ]] { end= ; shift; }

  # these are the defaults that'll be used if one of the args isn't valid
  local -i 10 line_len=$COLUMNS
  local line_chr='─'

  # if there are no non-flag inputs, print the defaults and exit
  if ! (( $# )) {
    echo -nE "${(pr:line_len::$line_chr:)}$end"
    return
  }

  # if `$1` is a number
  if [[ "$1" == (<->(.(<->|)|)|.<->) ]] {  # (\d+(.\d*)?|.\d+)
    line_len=$1                 # set `$1` as the line length,
    line_chr="${2:-$line_chr}"  # and `$2` as the line char

  # if `$2` is a number
  } elif [[ "$2" == (<->(.(<->|)|)|.<->) ]] {
    line_len=$2                 # set `$2` as the line length,
    line_chr="${1:-$line_chr}"  # and `$1` as the line char

  } elif [[ "$1" ]] { line_chr="$1" # if `$1` has a value, set it as the char
  } elif [[ "$2" ]] { line_chr="$2" # if `$2` has a value, set it as the char

  }  # if both are empty, use the defaults

  echo -nE "${(pr:line_len::$line_chr:)}$end"
}
