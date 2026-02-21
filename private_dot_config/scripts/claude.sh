#!/bin/bash
# Claude Code functions
# Dependencies: claude, nvm, gopass, kitty, fd, gum

claude_fn() {
  export CLD=1
  kitten @ set-user-vars CLD="$CLD"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use
  nvm use 20 --silent >/dev/null 2>&1
  export MCP_SERVERS_DIR="$HOME/mcp-servers"
  export TAVILY_API_KEY=$(gopass -o api/tavily)
  export VUETIFY_API_KEY=$(gopass -o api/vuetify)
  export DISCORD_EMAIL=$(gopass -o websites/Discord.com login)
  export DISCORD_PASSWORD=$(gopass -o websites/Discord.com)
  claude --mcp-config "$HOME/.config/.mcp.json" "$@"
  kitten @ set-user-vars CLD=""
  unset CLD
}

alias claude='claude_fn'

# Continue last claude session
cc() {
  claude_fn --continue "$@"
}

# Find and cd to a .claude directory
claude_log() {
  local dirs choice
  dirs=$(fd -H -t d '^\.claude$' ~ -x dirname {})
  choice=$(echo "$dirs" | gum choose) && cd "$choice"
}

clog() {
  case "$1" in
  sync)
    shift
    bun run /home/yuv/proj/sqlite.claude/scripts/index.ts "$@"
    ;;
  *) bun /home/yuv/proj/sqlite.claude/scripts/search.ts "$@" ;;
  esac
}
