#!/bin/sh
# Gives the AI agents on this computer your Syphony notes (https://syphony.net/agents).
#
# For each agent it finds — Claude Code, Codex — it adds Syphony's server, and it puts
# the Syphony skill where agents read skills (~/.claude/skills, ~/.agents/skills). It
# changes nothing else, and asks for nothing: the first time an agent uses Syphony, your
# browser opens at a page Syphony serves, and you choose what it may do there.
#
#   curl -fsSL https://raw.githubusercontent.com/SynomyCloud/syphony-agent/main/install.sh | sh
#
# SYPHONY_PORT picks another port, when you chose one in Syphony's Settings → API.
set -eu

PORT="${SYPHONY_PORT:-51740}"
URL="http://127.0.0.1:${PORT}/mcp"
RAW="https://raw.githubusercontent.com/SynomyCloud/syphony-agent/main"
HERE="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"

say() { printf '%s\n' "$*"; }

skill() {
  if [ -n "$HERE" ] && [ -f "$HERE/plugins/syphony/skills/syphony/SKILL.md" ]; then
    cat "$HERE/plugins/syphony/skills/syphony/SKILL.md"
  else
    curl -fsSL "$RAW/plugins/syphony/skills/syphony/SKILL.md"
  fi
}

put_skill() {
  mkdir -p "$1/syphony"
  skill > "$1/syphony/SKILL.md"
  say "  the skill: $1/syphony/SKILL.md"
}

found=0
if command -v claude >/dev/null 2>&1; then
  found=1
  say "Claude Code:"
  if claude mcp get syphony >/dev/null 2>&1; then
    say "  already has a server called syphony; left as it is"
  else
    if claude mcp add --transport http --scope user syphony "$URL" >/dev/null 2>&1; then
      say "  the server: syphony at $URL"
    else
      say "  could not add the server; run: claude mcp add --transport http -s user syphony $URL"
    fi
  fi
  put_skill "$HOME/.claude/skills"
  say "  then, in Claude Code: /mcp → syphony → Authenticate"
fi
if command -v codex >/dev/null 2>&1; then
  found=1
  say "Codex:"
  if codex mcp get syphony >/dev/null 2>&1; then
    say "  already has a server called syphony; left as it is"
  else
    if codex mcp add syphony --url "$URL" >/dev/null 2>&1; then
      say "  the server: syphony at $URL"
    else
      say "  could not add the server; run: codex mcp add syphony --url $URL"
    fi
  fi
  say "  then: codex mcp login syphony"
fi
# Read by Codex, Cursor, VS Code, OpenCode and Antigravity.
say "Other agents:"
put_skill "$HOME/.agents/skills"

if [ "$found" = 0 ]; then
  say ""
  say "No Claude Code or Codex here. For your agent's own steps: https://syphony.net/agents"
fi
if ! curl -fsS -o /dev/null "http://127.0.0.1:${PORT}/" 2>/dev/null; then
  say ""
  say "Syphony is not answering at http://127.0.0.1:${PORT}. Open it before your agent uses it."
fi
