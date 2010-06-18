#!/bin/bash
#
# pbrisbin 2009
#
# cli interface to thepiratebay.org
#
# http://pbrisbin.com:8080/bin/piratesearch
#
###

message() {
  echo "usage: pirateseaerch [options] [search terms]"
  echo
  echo "  options:"
  echo "        -a, --audio      search audio torrents"
  echo "        -v, --video      search video torrents"
  echo "        -A, --apps       search application torrents"
  echo "        -g, --games      search games torrents"
  echo "        -o, --other      search other torrents"
  echo "        -h, --help       display this"
  echo
  echo "        none             search all torrents"
  echo
  exit 1
}

errorout() { echo "error: $*"; exit 1; }

# properly add an extension to the url
add_ext() { [[ -n "$ext" ]] && ext="$ext,$1" || ext="$1"; }

# get user input
parse_options() {
  while [[ -n "$1" ]]; do
    case "$1" in
      -h|--h*)  message       ;;
      -a|--au*) add_ext '100' ;;
      -v|--v*)  add_ext '200' ;;
      -A|--ap*) add_ext '300' ;;
      -g|--g*)  add_ext '400' ;;
      -o|--o*)  add_ext '500' ;;
      *)        break         ;;
    esac
    shift
  done

  # left is the search term
  term="$*"
}

# download the nth results page and add to the LINKS and INFO arrays one
# entry per torrent. INFO is "Date|Size" and LINKS is "ID|Name".
get_page() { 
  local IFS=$'\n' file='/tmp/piratesearch_results.txt'
  
  [[ -z "$term" ]] && errorout 'you must provide a search term'

  lynx -dump "http://thepiratebay.org/search/$term/$criteria" > "$file"

  # add entries to link array
  LINKS+=( $(sed -e '/^[^ ]* .*\/\([^\/]*\)\.\([0-9]*\)\.TPB.torrent$/!d;s//\2|\1/g' "$file") )

  # add entries to info array
  INFO+=( $(tr -d '\n' < "$file" |\
              sed -e 's/Uploaded/\n&/g' |\
              sed -e '/^Uploaded *\([^,]*\), *Size *\([^,]*\),.*/!d;s//\1|\2/g' |\
              cut -d 'i' -f 1) )

  rm "$file"

  [[ ${#LINKS[@]} -eq 0 ]] && errorout 'No results or search engine overloaded, feel free to try again in a few seconds.'

#  echo
#  echo links has length ${#LINKS[@]} and contents ${LINKS[@]}
#  echo
#  echo info has length ${#INFO[@]} and contents ${INFO[@]}
#  echo 
#  exit
}

# goes through 30 results at a time (as the user hits m), print the
# entries out of the INFO and LINKS arrays.
display_results() {
  local link info

  # starts empty, increments by 30 with each loop
  count="${count:-0}"

  echo -e "  Num\tUploaded    Size\tName"
  while [[ -n "${LINKS[count]}" ]]; do
    # get the nth entry from each array
    link="${LINKS[count]}"
    info="${INFO[count]}"

    # make them prettier
    link="$(echo "${link#*|}" | sed 's/\(_\|\.\)+*/ /g')"
    info="${info/\|/ }"

    count=$((count+1))
    echo -e "  $count\t$info\t$link"
  done
}

# prompts the user to download, show more, or quit
prompt_continue() {
  if [[ $((${#LINKS[@]}%30)) -eq 0 ]]; then
    read -p 'Enter the number(s) to download, [m]ore, or [q]uit: ' A
  else
    read -p 'Enter the number(s) to download or [q]uit: ' A

    while [[ "${A:-m}" = 'm' ]]; do
      read -p 'No more results, enter the number(s) to download or [q]uit: ' A
    done
  fi
  
  [[ "$A" = 'q' ]] && exit 1
}

# fetches each results page in turn, first and as the user hits m,
# displaying the results and prompting to download/continue
search() {
  while [[ "${A:-m}" = 'm' ]]; do
    criteria="${page:-0}/99/${ext:-0}" # start at page zero
    get_page                           # dl and parse the page
    display_results                    # print the results
    prompt_continue                    # prompt to continue
    page=$((page+1))                   # go to the next page
  done
}

# downloads out of the LINKS array based on the user-entered numbers
download() {
  local choice link url

  for choice in $A; do
    if [[ -n "${choice//[0-9]/}" ]]; then
      echo "Skipping invalid choice $choice..."
      continue
    fi

    link="${LINKS[choice-1]}"

    if [[ -z "$link" ]]; then
      echo "Skipping invalid choice $choice..."
      continue
    fi

    url="http://torrents.thepiratebay.org/${link%|*}/${link#*|}.${link%|*}.TPB.torrent"

    [[ -d "$downloads" ]] || errorout 'download directory not found'

    if (cd "$downloads" && wget -q "$url"); then
      echo "${link#*|} downloaded"
    else
      echo " -!- ${link#*|} failed to download"
    fi
  done
}

# to where do i download the torrents?
downloads="$HOME/torrents/torrentfiles"

parse_options "$@"
search
download

