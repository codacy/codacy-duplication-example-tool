#!/usr/bin/env bash

#parse
codacyrc_file=$(jq -erM '.' < /.codacyrc)

# error on invalid json
if [ $? -ne 0 ]; then
  echo "Can't parse .codacyrc file"
  exit 1
fi

codacy_lang=$(jq -cer '.language' <<< "$codacyrc_file")
if [ "$(echo "$codacy_lang" | tr '[:upper:]' '[:lower:]')" != "shell" ]; then
  echo "Language is not supported (only 'Shell' available)"
  exit 1
fi

codacy_files=$(cd /src || exit; find . -type f -exec echo {} \; | cut -c3-)

function join_by {
  local d="$1"
  shift; echo -n "$1"; shift
  printf "%s" "${@/#/$d}"
}

function report_errors {
  local name="$1"
  local dup="$2"
  echo "{\"cloneLines\":\"$name\",\"nrTokens\":1,\"nrLines\":1,\"files\":[$dup]}"
}

function analyze_file {
  local file="$1"
  final_file="/src/$file"
  if [ -f "$final_file" ]; then
    output=$(tr -d '\n' < "$final_file")
    if [ "$output" != "" ]; then
      local entry="{\"filePath\":\"$file\",\"startLine\":1,\"endLine\":2}"
      if [ "$output" == "foo" ]; then
        g_final_foo_results+=( "$entry" )
      else
        g_final_bar_results+=( "$entry" )
      fi
    fi
  else
    echo "{\"filename\":\"$final_file\",\"message\":\"could not parse the file\"}"
  fi
}

g_final_foo_results=()
g_final_bar_results=()

while read -r file; do
  analyze_file "$file"
done <<< "$codacy_files"

if [ ${#g_final_foo_results[@]} -gt 1 ]; then
  report_errors "foo" "$(join_by ',' ${g_final_foo_results[@]})"
fi

if [ ${#g_final_bar_results[@]} -gt 1 ]; then
  report_errors "bar" "$(join_by ',' ${g_final_bar_results[@]})"
fi
