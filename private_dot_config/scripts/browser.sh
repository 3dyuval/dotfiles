function bdg() {
  export BDG_CHROME_FLAGS="--ignore-certificate-errors --disable-web-security"
  command bdg --chrome-flags=""$BDG_CHROME_FLAGS"" "$@"
}

alias bdg-emulatedmedia-clear="bdg cdp Emulation.setEmulatedMedia --params '{\"media\": \"\"}'"
bdgmp() {
  bdg cdp Emulation.setEmulatedMedia --params '{"media": "print"}'
  bdg cdp Runtime.evaluate --params '{"expression":"document.body.style.setProperty(\"overflow\", \"scroll\", \"important\")"}'
}

bdgmn() {
  bdg cdp Emulation.setEmulatedMedia --params '{"media": ""}'
  bdg cdp Runtime.evaluate --params '{"expression":"document.body.style.removeProperty(\"overflow\")"}'
}

bdg-nav() {
  local url="${1:?}"
  [[ "$url" =~ ^https?:// ]] || url="https://$url"
  local params=$(jq -nc --arg u "$url" '{url: $u}')
  bdg cdp Page.navigate --params "$params"
}

bdg-list() {
  local domain="${1}"
  local target
  [[ "$target" == "domain" ]] && property="domain" || property="methods"
  if [[ -n $domain ]]; then
    #todo use jq smartly to handle Page.navigate
    bdg cdp "$domain" --list | jq "$target.[].name"
  else
    bdg cdp --list
  fi

}

bdg-bookmarks() {
  local boomkarks=$(jq '[.. | objects | select(.type == "url") | {name, url}]' \
    ~/.bdg/chrome-profile/Default/Bookmarks)
  if [[ -n $1 ]]; then
    local selected=$(echo $boomkarks | jq --argjson i "$1" '.[$i]')
    if [[ $selected != "null" ]]; then
      echo "Navigating to '$(jq -r '.name' <<<"$selected")'"
      bdg-nav "$(jq -r '.url' <<<"$selected")"
    fi
    return 1
  else
    echo $boomkarks
  fi
}

# Get nodeId for CSS selector (hydrates DOM first)
bdg-node() {
  local selector="${1:?selector required}"
  local root=$(bdg cdp DOM.getDocument --params '{"depth": 0}' 2>/dev/null | jq '.result.root.nodeId')
  bdg cdp DOM.querySelector --params "{\"nodeId\": $root, \"selector\": \"$selector\"}" 2>/dev/null | jq '.result.nodeId'
}

# Get computed styles for selector
# Usage: bdg-css ".element" 'select(.name == "display")'
bdg-css() {
  local selector="${1:?selector required}"
  local filter="${2:-.}"
  bdg cdp CSS.enable 2>/dev/null
  local node=$(bdg-node "$selector")
  bdg cdp CSS.getComputedStyleForNode --params "{\"nodeId\": $node}" 2>/dev/null | jq ".result.computedStyle[] | $filter"
}

#
# jq -n '{name: "foo"}'                          # {"name": "foo"}
#   jq -n --arg x "$var" '{name: $x}'              # safe variable injection
#   jq -n --argjson n 42 '{count: $n}'             # inject number/bool/null
#   jq -n '$ARGS.named' --arg a 1 --arg b 2        # {"a": "1", "b": "2"}
#
#   # ─── Parse ───
#   echo '{"a":1}' | jq '.a'                       # 1
#   echo '{"a":{"b":2}}' | jq '.a.b'               # 2
#   echo '[1,2,3]' | jq '.[0]'                     # 1
#   echo '[{"id":1},{"id":2}]' | jq '.[].id'       # 1 \n 2
#
#   # ─── Transform ───
#   echo '{"a":1}' | jq '.b = 2'                   # {"a":1,"b":2}
#   echo '{"a":1}' | jq 'del(.a)'                  # {}
#   echo '[1,2,3]' | jq 'map(. * 2)'               # [2,4,6]
#   echo '{"a":1,"b":2}' | jq 'to_entries'         # [{"key":"a","value":1},...]
#
#   # ─── Filter ───
#   echo '[{"x":1},{"x":5}]' | jq '.[] | select(.x > 2)'  # {"x":5}
#
#   # ─── Output ───
#   jq -c '.'              # compact (one line)
#   jq -r '.name'          # raw string (no quotes)
#   jq -e '.foo'           # exit 1 if null/false
#
#   Key flags:
#   - -n = null input (construct from scratch)
#   - -c = compact output
#   - -r = raw output (no quotes on strings)
#   - --arg k v = inject string
#   - --argjson k v = inject JSON value
