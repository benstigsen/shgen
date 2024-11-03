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

  index=0
  for item in $items; do
    eval "echo \"$template\""
    index=$((index + 1))
  done
}

# $(ternary "condition" 'true' 'false')
ternary() {
  if eval "$1"; then
    eval "echo \"$2\""
  else
    eval "echo \"$3\""
  fi
}

# $(template 'file.txt')
template() {
  while IFS= read -r line; do
    eval "echo \"$line\""
  done < "$1"
}

process_file() {
  file="$1"
  input_dir="$(cd "$(dirname "$file")" && pwd)"
  let "root_dir" "$input_dir"

  # allows for relative paths in templates
  (
    cd "$input_dir" || exit 1
    template "$(basename "$file")"
  )
}

usage() {
  echo "usage: $0 [OPTIONS] file..."
  echo
  echo "options:"
  echo "  -o, --output    <dir>  output directory (optional)"
  echo "  -e, --extension <ext>  output extension (required with -o)"
  echo "  -h, --help             show this help message"
  echo
  echo "examples:"
  echo "  $0 file.shtxt                           # write to stdout"
  echo "  $0 *.shtxt -e txt -o output/            # process multiple files to directory"
  echo "  $0 a.shtxt b.shtxt -e txt -o output/    # process specific files"
}

main() {
  extension=""
  output_dir=""
  files=""

  # command line options
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -e|--extension)
        shift
        if [ $# -eq 0 ]; then
          echo "error: -e requires an extension argument" >&2
          usage
          exit 1
        fi
        extension="$1"
        ;;
      -o|--output)
        shift
        if [ $# -eq 0 ]; then
          echo "error: -o requires a directory argument" >&2
          usage
          exit 1
        fi
        output_dir="$1"
        ;;
      -*)
        echo "error: unknown option: $1" >&2
        usage
        exit 1
        ;;
      *)
        if [ -z "$files" ]; then
          files="$1"
        else
          files="$files $1"
        fi
        ;;
    esac
    shift
  done

  if [ -z "$files" ]; then
    echo "error: no input files specified" >&2
    usage
    exit 1
  fi

  # require extension if output is specified
  if [ -n "$output_dir" ] && [ -z "$extension" ]; then
    echo "error: output extension (-e) is required when using -o" >&2
    usage
    exit 1
  fi


  for file in $files; do
    if [ ! -f "$file" ]; then
      echo "warning: file not found: $file" >&2
      continue
    fi

    if [ -n "$output_dir" ]; then
      mkdir -p "$output_dir"
      base_name="$(basename "$file")"
      output_file="$output_dir/${base_name%.*}.$extension"
      mkdir -p "$(dirname "$output_file")"
      process_file "$file" > "$output_file"
    else
      process_file "$file"
    fi
  done
}

main "$@"
