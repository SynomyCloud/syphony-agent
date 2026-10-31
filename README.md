# Syphony for your agent

Your Syphony notes, for the AI agent you already use: it can read, search and write your pages,
fill your databases, write LaTeX and HTML pages, and use your meeting transcripts — in the
Syphony app on your own computer. Nothing goes to a server: the agent talks to the app at
`http://127.0.0.1:51740`, and only while it runs.

The first time the agent uses Syphony, your browser opens at a page the app serves. You choose
how far it reaches (the whole project, one page and what is inside it, or meeting transcripts)
and what it may do (read; read and change; also delete), and press Allow. You can take it back
in Syphony's **Settings → API** at any time. While it works, you see it: its pointer moves in
your window to what it reads and changes, with its name and a sparkle that says it is an AI.

The step-by-step guide for every agent is at **https://syphony.net/agents**.

## The quickest way

**Claude Code**

```
/plugin marketplace add SynomyCloud/syphony-agent
/plugin install syphony@syphony
```

or, without the skill: `claude mcp add --transport http -s user syphony http://127.0.0.1:51740/mcp`.
Then `/mcp` → syphony → Authenticate.

**Codex**

```
codex mcp add syphony --url http://127.0.0.1:51740/mcp
codex mcp login syphony
```

and, for the skill, `codex plugin marketplace add SynomyCloud/syphony-agent`.

**Everything on this computer at once** (Claude Code, Codex, and the skill for the agents that
read `~/.agents/skills`):

```
curl -fsSL https://raw.githubusercontent.com/SynomyCloud/syphony-agent/main/install.sh | sh
```

## What is here

| Path | What it is |
|---|---|
| `plugins/syphony/` | The plugin: the server (`.mcp.json`) and the skill, for Claude Code (`.claude-plugin/`) and Codex (`.codex-plugin/`) |
| `plugins/syphony/skills/syphony/SKILL.md` | The skill: how Syphony's pages work and how to change them well. An [Agent Skills](https://agentskills.io) folder — copy it to `~/.agents/skills/` for Codex, Cursor, VS Code, OpenCode and Antigravity |
| `.claude-plugin/marketplace.json` | This repository as a Claude Code marketplace |
| `.agents/plugins/marketplace.json` | This repository as a Codex marketplace |
| `gemini-extension.json` | A Gemini CLI extension: `gemini extensions install https://github.com/SynomyCloud/syphony-agent` |
| `install.sh` | Adds the server to the agents it finds and puts the skill in place |

If you chose another port in Syphony's settings, set `SYPHONY_PORT` before starting your agent
(the plugin's server address reads it) or before running `install.sh`.
