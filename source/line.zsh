#!/bin/zsh

# ——————————————————————————————————————————————————————————————————————————— #

line() {

  local end=$'\n'
  if [[ "$1" == '-n' ]] { end= ; shift; }

  # these are the defaults that'll be used if one of the args isn't valid
  local -i 10 line_len=$COLUMNS
  local line_chr='─'

  # if there are no non-flag inputs, print the defaults and get out of the way
  if [[ -z "$@" ]] { echo -n "${(pr:$line_len::$line_chr:)}$end"; return; }

  # if $1 is a number
  if [[ "$1" == <-> ]] {
    line_len=$1                 # set $1 as the line length,
    line_chr="${2:-$line_chr}"  # and $2 as the line char

  # if $2 is a number
  } elif [[ "$2" == <-> ]] {
    line_len=$2                 # set $2 as the line length,
    line_chr="${1:-$line_chr}"  # and $1 as the line char

  } elif [[ -n "$1" ]] { line_chr="$1" # if $1 has a value, set it as the char
  } elif [[ -n "$2" ]] { line_chr="$2" # if $2 has a value, set it as the char

  }  # if both are empty, use the defaults

  echo -n "${(pr:$line_len::$line_chr:)}$end"
}

# ——————————————————————————————————————————————————————————————————————————— #

create_title() {
  # Format:
  #  create_title [title] [line_char] [start_len] [min_end_len] [ellipses] [min_letters]
  #   1. title       : str  =  ''
  #   2. line_char   : str  =  '—'
  #   3. start_len   : int  =  3
  #   4. min_end_len : int  =  4
  #   5. ellipses    : str  =  "..."
  #   6. min_letters : int  =  1

  # Notes:
  #  - Inputs must be provided in order, so use ^ to indicate a default value
  #  - If no title is provided, a line will be drawn with len equal to the screen width

  # Examples:
  #  create_title 'Some Title' '~' 5 8 '•••' 2   ==>   create_title 'Some Title' 5 8 '•••' 2
  #  create_title 'Some Title' '~' 5 ^ '•••' ^   ==>   create_title 'Some Title' 5 8 '•••' 2
  #  create_title 'Some Title' '~' 5             ==>   create_title 'Some Title' 5 8 '•••' 2
  #  create_title 'Some Title' '~'               ==>   create_title 'Some Title' 5 8 '•••' 2
  #  create_title ^ '~'                          ==>   create_title 'Some Title' 5 8 '•••' 2
  #  create_title ^                              ==>   create_title 'Some Title' 5 8 '•••' 2
  #  create_title                                ==>   create_title 'Some Title' 5 8 '•••' 2


  # TODO_: implement input validation
  # TODO_: add proper flag logic


  ##title Control Constants (for internal use)

  # the character that indicates that a default value should be used
  local __DFT__='^'
  # the string that will be the sign to draw a line w/o a title
  local __LNE__='%__LNE__%'


  ##title Default Constants (can be overwritten by user)

  # what will show after the truncated title if
  #  there's not enough space to display the whole title
  local __DFT_ellipses='...'
  # the character used to draw the separator lines
  local __DFT_line_char='—'

  # the length of the line before the title
  local __DFT_start_len=3
  # the minimum length that the line after the title should be
  local __DFT_min_end_len=4

  # the minimum number of letters that should be shown before the
  #  function just gives up and draws a line with no title
  local __DFT_min_letters=1


  ##title Input Handling / User Overrides

  local   _title_str=$( [[ $1 == '' || $1 == $__DFT__ ]] && echo $__LNE__           || echo $1 )
  local   _line_char=$( [[ $2 == '' || $2 == $__DFT__ ]] && echo $__DFT_line_char   || echo $2 )
  local   _start_len=$( [[ $3 == '' || $3 == $__DFT__ ]] && echo $__DFT_start_len   || echo $3 )
  local _min_end_len=$( [[ $4 == '' || $4 == $__DFT__ ]] && echo $__DFT_min_end_len || echo $4 )
  local    _ellipses=$( [[ $5 == '' || $5 == $__DFT__ ]] && echo $__DFT_ellipses    || echo $5 )
  local _min_letters=$( [[ $6 == '' || $6 == $__DFT__ ]] && echo $__DFT_min_letters || echo $6 )


  ##title Calculated Constants

  # defining how long the ellipses is 
  local _ellipses_len=${#_ellipses}

  # the starting and ending line strings
  local _start_line=$(get_line $_start_len $_line_char)
  local _min_end_line=$(get_line $_min_end_len $_line_char)

  # this will be compared against the terminal width.
  #  if the term width is smaller than this, then a line with no title will be shown
  local _min_char_count=$(( $_start_len + $_min_end_len + $_ellipses_len + $_min_letters + 2 ))


  ##title Calculated Values

  local _input_length=${#_title_str}
  local _term_width=$(tput cols)

  local _do_draw_title=$(
    [[ $_term_width -lt $_min_char_count || $_title_str == $__LNE__ ]] && echo "false" || echo "true"
  )

  # subtracted 2 to account for the space
  #  after and before the start and end lines, respectively
  local _available_width=$(( $_term_width - ( $_start_len + $_min_end_len + 2 ) ))


  ##title Logic

  [[ $_do_draw_title == "false" ]] && get_line && return

  local _end_line_len=$(
    [[ $_do_draw_title == "false" ]]          && echo $_term_width  && return
    (( $_input_length >= $_available_width )) && echo $_min_end_len && return
    echo $(( $_term_width - ( $_input_length + $_start_len + 2 ) ))
  )

  local _end_line=$(get_line $_end_line_len $_line_char)

  local _trunc_idx=$(
    (( $_input_length > $_available_width )) && echo $(( $_available_width - $_ellipses_len )) || echo -1
  )

  echo -n $_start_line' '${_title_str[0, $_trunc_idx]}
  (( $_trunc_idx != -1 )) && echo -n $_ellipses
  echo ' '$_end_line
}


center_title_nocheck() {
  local -r _input_title=$1
  local -r _usable_width=$(( COLUMNS - $#_input_title - 2 ))
  local -r _half_width=$(( _usable_width / 2 ))

  line $_half_width
  echo -n " $_input_title "
  line $_half_width
  line $(( _usable_width % 2 ))
}
