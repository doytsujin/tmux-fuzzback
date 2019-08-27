#!/usr/bin/env bash

_fzf_cmd() {
    fzf-tmux --delimiter=":" --ansi --with-nth="2.." --no-preview --print-query
}

_enter_mode() {
	tmux copy-mode
}

# "manually" go up in the scrollback for a number of lines
# https://github.com/tmux-plugins/tmux-copycat/blob/e95528ebaeb6300d8620c8748a686b786056f374/scripts/copycat_jump.sh#L121
_manually_go_up() {
	local line_number
  line_number="$1"
  tmux send-keys -X -N "$line_number" cursor-up
	tmux send-keys -X start-of-line
}

main() {
  local content match line_number corrected window_height query max_lines
  content="$(tmux capture-pane -e -J -p -S -)"
  match=$(echo "$content" | tac | nl -b 'a' -s ':' | _fzf_cmd)
  query=$(echo "$match" | cut -d$'\n' -f1)
  rest=$(echo "$match" | cut -d$'\n' -f2)
  line_number=$(echo "$rest" | cut -d':' -f1 | tr -d '[:space:]')
  corrected=$((line_number - 1))
	window_height="$(tmux display-message -p '#{pane_height}')"
  max_lines=$(echo "$content" | wc -l)

  _enter_mode
  if [ "$corrected" -lt "$window_height" ]; then
    _manually_go_up "$corrected"
  else
    tmux send-keys -X goto-line "$line_number"
  fi
}

main
