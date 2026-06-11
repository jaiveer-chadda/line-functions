#!/usr/bin/env zsh

line() {

  # —— Setup & Constants ————————————————————————————————————————————————————— #

  setopt local_options warn_create_global

  if [[ "$1" == 'rainbow' ]] { eval line\ -{d,r,y,g,c,b,m,B}\; ; return; }

  local -rA colours=(
    [-B]=$'\e[1m'  [bld]=$'\e[1m'   [bold]=$'\e[1m'
    [-d]=$'\e[2m'  [dim]=$'\e[2m'     [-D]=$'\e[2m'
    [-r]=$'\e[31m' [red]=$'\e[31m'
    [-y]=$'\e[33m' [yel]=$'\e[33m'  [yellow]=$'\e[33m'
    [-g]=$'\e[32m' [grn]=$'\e[32m'   [green]=$'\e[32m'
    [-c]=$'\e[36m' [cyn]=$'\e[36m'    [cyan]=$'\e[36m'
    [-b]=$'\e[34m' [blu]=$'\e[34m'    [blue]=$'\e[34m'
    [-m]=$'\e[35m' [mag]=$'\e[35m' [magenta]=$'\e[35m'
  )

  # —— Options Parsing —————————————————————————————————————————————————————— #

  local colour rst
  if [[ ${(@k)colours[(Ie)$1]}     ]] { colour="$colours[$1]"    ; shift    ; }
  if [[ ${(@k)colours[(Ie)$@[-1]]} ]] { colour="$colours[$@[-1]]"; shift -p ; }

  if [[ "$colour" ]] rst=$'\e[m'

  local end=$'\n'
  if [[ "$1"     == '-n' ]] { end= ; shift   ; }
  if [[ "$@[-1]" == '-n' ]] { end= ; shift -p; }

  # —— Set Defaults ————————————————————————————————————————————————————————— #

  # these are the defaults that'll be used if one of the args isn't valid
  local line_len=$COLUMNS
  local line_chr='─'

  # —— Parse Len & Char ————————————————————————————————————————————————————— #

  # if `$1` is a number  # (\d+([.,]\d*)?|[.,]\d+)%?
  if [[ "${1// }" == (<->([.,](<->|)|)|[.,]<->)(%|) ]] {
    line_len=${1// }                 # set `$1` as the line length,
    line_chr="${2:-$line_chr}"  # and `$2` as the line char

  # if `$2` is a number
  } elif [[ "${2// }" == (<->([.,](<->|)|)|[.,]<->)(%|) ]] {
    line_len=${2// }                 # set `$2` as the line length,
    line_chr="${1:-$line_chr}"  # and `$1` as the line char

  } elif [[ "$1" ]] { line_chr="$1" # if `$1` has a value, set it as the char
  } elif [[ "$2" ]] { line_chr="$2" # if `$2` has a value, set it as the char

  }  # if both are empty, use the defaults

  # —— Normalise Len ———————————————————————————————————————————————————————— #

  if [[ "$line_len" == *% ]] {
    local -F 10 line_len="${line_len%\%}"
    (( line_len /= 100 ))
  }

  local -F 10 line_len=$(( line_len <= 1 ? line_len * COLUMNS : line_len ))

  local -ri 10 no_dec=${line_len%.*}
  line_len=$(( ${${line_len#*.}[1]} >= 5 ? no_dec + 1 : no_dec ))

  # —— Print Output ————————————————————————————————————————————————————————— #

  echo -nE "$colour${(pr:line_len::$line_chr:)}$rst$end"
}
