#!/bin/sh

# $(evaluate '$test')
evaluate() {
  if eval "$1"; then
    echo 1
  else
    echo 0
  fi
}

# $(loop "$(ls)" '$index is $item!') # note the single quotes
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

usage() {
  echo "Usage: $0 in_pattern... out_directory out_extension"
  echo "Example:"
  echo "  $0 a.smd b.smd output/ md"
  echo "  $0     *.shtml output/ html"
  echo "  $0 /dir/*.stxt output/ txt"
}

main() {
  if [ "$#" -lt 3 ]; then
    usage
    exit 1
  fi

  output="${@: -2:1}" # get the second last argument (output directory)
  extension="${@: -1}" # get last argument (output extension)
  input_patterns="${@:1:$(($# - 1))}" # get all arguments except the last one (input_patterns)

  mkdir -p "$output"

  # process all input files
  for pattern in $input_patterns; do
    find . -type f -name "$(basename "$pattern")" | while read -r file; do
      if [ -f "$file" ]; then
        base_name="${file##*/}" # filename without extension
        output_file="${output}/${base_name%.*}.$extension" # replace .extension with .html

        relativeDir="$(dirname "$file")" # for use in template
        mkdir -p "$(dirname "$output_file")"
        template "$file" > "$output_file"
      fi
    done
  done

  exit 0
}

main "$@"
