---
name: syphony
description: Work in the person's Syphony notes — read, search, write and organise pages, fill databases, write LaTeX and HTML pages, and use meeting transcripts — through the Syphony app running on this computer. Use when the person mentions Syphony, their notes, a page or project in Syphony, a meeting transcript, or asks you to write something into their notes.
compatibility: Needs the Syphony app running on this computer (macOS or Windows), with its local API at http://127.0.0.1:51740.
metadata:
  version: "1.0.0"
  homepage: https://syphony.net/agents
---

# Syphony

Syphony is a notes app that keeps the person's notes on their own computer. It runs a server
for programs on this computer only, at `http://127.0.0.1:51740`, and you reach it through its
MCP tools (the server is called `syphony`). Everything you do there happens in the person's own
notes, and they see it: in their window your pointer moves to what you read and change, with
your name on it and a sparkle that says you are an AI.

## Connecting

If no Syphony tools are available, the server is not connected yet. Tell the person, and give
them the one line for this agent:

- Claude Code: `claude mcp add --transport http -s user syphony http://127.0.0.1:51740/mcp`,
  then `/mcp` → syphony → Authenticate.
- Codex: `codex mcp add syphony --url http://127.0.0.1:51740/mcp`, then
  `codex mcp login syphony`.
- Anything else: https://syphony.net/agents

Signing in opens the browser at a page Syphony serves. The person chooses how far you reach
(the whole project, one page and what is inside it, or meeting transcripts) and what you may do
(read; read and change; also delete), and presses Allow. If a tool answers that the project is
not open, ask the person to open that project in Syphony: a connection belongs to the project
that was open when they allowed it.

## Find your way first

1. `about` — who you are here, how far you reach, what you may do, what is in the project and
   which kinds of page this computer can make. Call it once at the start.
2. `search_pages` for words; `list_pages` for the tree (`kind` and `under` narrow it).
3. `read_page` before you change a page.

Wherever a tool asks for a page you can give its id (a UUID), its path (`Clients/Acme`), or its
title when no other page in reach has the same one.

## Changing pages

- **Prefer `edit_page`.** Quote words that are in the page, exactly as `read_page` gave them,
  and say what replaces them. Only the blocks those words are in are written again; the rest
  of the page — columns, colours, cards the person made in the app — stays as it is. If the
  words are there more than once, quote more around them, or set `replace_all`.
- `update_page` with `markdown` replaces the whole page and drops what markdown cannot hold.
  Use it for pages you made yourself. `append` adds to the end.
- `create_page` makes a page, at the top or inside another (`parent_id`).
- A subpage appears in its parent's text as a link to `synomy-page:<id>`. Leave those links
  where they are; a subpage whose link you leave out keeps its card anyway.
- Pictures: `add_picture` with a file on this computer or base64 bytes. It goes at the end and
  answers the markdown line; move that line with `edit_page`.
- Before you change anything, say what you are about to change. Do several small edits rather
  than one rewrite: the person watches them happen.

## Kinds of page

| `kind` | What it is | How to work with it |
|---|---|---|
| none | a page of text | `read_page`, `edit_page`, `append` |
| `transcription` | a meeting transcript, one speaker turn per line: `**Speaker 1 (0:04)** …` | read it; add a summary or action items at the end with `append` |
| `pdf` | a PDF | read only |
| `database` | a table: its rows are the pages inside it, each with a value per column | `read_database`, `add_database_row`, `update_page` with `values`, `change_columns` |
| `kept:latex/latex` | a LaTeX document | `list_files`, `read_file`, `write_file` (`main.tex` and the rest) |
| `kept:latex/html` | an HTML page or site | `list_files`, `read_file`, `write_file` (`index.html`, CSS, JS) |

### Databases

Values go in by column name, as a person would say them: text, a number, `true`/`false`, a
choice's name (a select makes a choice it does not have; a status refuses one), a list of names
for tags or people, a date as `"2026-10-12"` or `"2026-10-12T14:30"` (or `{"start","end"}`),
and for a relation the ids or titles of the related rows. Created, edited, created by, formula
and rollup columns are worked out by Syphony and read only.

`change_columns` adds columns (`{"op":"add","name":"Due","type":"date"}`; types text, number,
select, tags, status, date, person, checkbox, url, email, phone, created, edited, creator),
renames them, adds choices (`{"op":"options","column":"Stage","add":["Blocked"]}`), and — with
a key that may delete — removes them. Relation, rollup and formula columns are set up in the app.

### LaTeX and HTML pages

Make one with `create_page` and `kind` (`"kept:latex/latex"` or `"kept:latex/html"`) and,
if you like, a `template` (`about` lists them: article, report, beamer, blank; page, site,
slides, blank). Its text is only a sentence saying what it is; what it holds is its files.
`list_files` shows them, `read_file` reads one, `write_file` writes a whole file (made if it is
not there; folders with `/`). Syphony compiles a LaTeX page while the person has it open, so
after writing, `show_page` it and ask them to look. Files and folders starting with a dot are
the extension's own and cannot be reached.

## Safety nets

- `delete_page` sends a page to the project's trash for thirty days: `list_trash`,
  `restore_from_trash` (it comes back with a new id).
- Every page keeps its history: `page_history`, `read_version`, `restore_version`.
- `recent_changes` with `after` follows what happens, including what the person does.
- If a tool says the key may not do something, say so; the person can connect again with more
  access in Syphony's Settings → API.

## Without MCP

A script can use the same API over plain HTTP with a key from Settings → API
(`Authorization: Bearer synomy_…`). The full guide, with every route, is served by the app at
http://127.0.0.1:51740/ while it runs.

```
curl http://127.0.0.1:51740/v1/search?q=budget -H "Authorization: Bearer $SYPHONY_KEY"
curl -X PATCH http://127.0.0.1:51740/v1/pages/<id> -H "Authorization: Bearer $SYPHONY_KEY" \
  -H "Content-Type: application/json" -d '{"edits":[{"old":"Monday","new":"Tuesday"}]}'
```
