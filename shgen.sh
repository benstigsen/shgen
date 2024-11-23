#!/bin/sh

# to store variables across command substitutions
# useful to define frontmatter
VARS_FILE="/tmp/template_vars_$$"
touch "$VARS_FILE"
trap 'rm -f $VARS_FILE' EXIT

# $(let x 5)
let() {
  local name="$1"
  local value="$2"
  echo "$name=\"$value\"" >> "$VARS_FILE"
}

# $(get x)
get() {
  local name="$1"
  . "$VARS_FILE" 2>/dev/null
  eval "echo \"\$$name\""
}

# $(evaluate '$test')
evaluate() {
  if eval "$1"; then
    echo 1
  else
    echo 0
  fi
}

# $(loop "$(ls)" '$index is $item!')
# note the single quotes for the second argument
loop() {
  items="$1"
  template="$2"

  export index=0
  for item in $items; do
    export item
    eval "echo \"$template\""
    index=$((index + 1))
  done
}

# $(template 'file.txt')
template() {
  while IFS= read -r line; do
    if echo "$line" | grep -q '\$'; then
      eval "echo \"$line\""
    else
      echo "$line"
    fi
  done
}

usage() {
  echo "usage: $0 [FILE]" >&2
  echo
  echo "options:"
  echo "  -h, --help    show this help message"
  echo
  echo "examples:"
  echo "  $0 template.txt      # process a file"
  echo "  cat file.txt | $0    # process from stdin"
}

main() {
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
  esac

  if [ $# -gt 1 ]; then
    echo "error: too many arguments" >&2
    usage
    exit 1
  fi

  if [ -n "$1" ]; then
    # Input is a file
    input_dir="$(cd "$(dirname "$1")" && pwd)"
    let "root_dir" "$input_dir"
    (
      cd "$input_dir" || exit 1
      template < "$(basename "$1")"
    )
  else
    # Input is from stdin
    let "root_dir" "$(pwd)"
    template
  fi
}

main "$@"
