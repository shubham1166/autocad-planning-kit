---
name: autolisp-tools
description: Use when writing, fixing or running AutoLISP (.lsp) routines for AutoCAD or AutoCAD LT, batch-editing title blocks or attributes, bumping revisions, creating standard layers, calculating areas in m², batch plotting layouts to PDF, or automating any repetitive AutoCAD task across one or many drawings.
---

# AutoLISP automation

`lisp/planning-tools.lsp` is a ready-made library. Tell the designer how to load it (`APPLOAD` → browse to the file → Load; add to the **Startup Suite** to load it every session). Commands:

| Command | What it does |
|---|---|
| `TBTAGS` | Lists every attribute tag and value of every attributed block in paper space. Run this first on a new drawing to learn its title block tags. |
| `TBSET` | Sets one field (e.g. `STATUS` → `PLANNING`) on the title block of every layout |
| `TBREV` | Bumps revision `-`→`A`→`B`… and sets today's date on every layout |
| `PLAYERS` | Creates the standard layer set from `planning-drawings/references/layers.md` |
| `AREAM2` | Areas of selected closed polylines/circles/regions in m², with a total (for GIA, curtilage, PD 50% checks) |
| `BATCHPDF` | Plots every layout to `<drawing folder>\PDF\<DWG_NO>-<REV> <DWG_TITLE>.pdf` using each layout's own page setup |

The tag names (`DWG_NO`, `REV`, `DATE`, `DWG_TITLE`) are set at the top of the file. If `TBTAGS` shows different tags, edit those four lines — don't rewrite the routines.

## Writing new routines

- **Stay LT-compatible**: AutoCAD LT 2024+ runs AutoLISP but **not** `vla-*`, `vlax-*`, `vlr-*` (ActiveX/reactors), and not ObjectARX/.NET. Use `entget`/`entmod`/`entnext`, `ssget`, `command`, `tblsearch`. `vl-` string/file functions are fine. Ask whether they have full AutoCAD or LT if you need ActiveX.
- Prefix internal helpers with a short namespace (`pt:`), declare locals after `/` in every `defun`.
- Save and restore any system variable you change (`CMDECHO`, `FILEDIA`, `OSMODE`, `CLAYER`), and restore them in a local `*error*` handler.
- Use underscore-prefixed English command names and options (`"_.-LAYER" "_M"`) so routines work on non-English installs.
- Use `-COMMAND` (dash) versions to avoid dialog boxes; set `FILEDIA` 0 while running.
- Finish every command with `(princ)` so it exits quietly.
- Before handing over code, check the brackets balance and walk through the command prompt sequence for the `command` calls — prompts differ between commands and versions, which is the most common bug.
- Batch over many drawings with a script (`.scr`) that opens each file, runs the command, saves and closes; or with the MCP server if connected. **Make sure there is a backup / the files are in version control before batch edits.**

## Running through the MCP server

If the AutoCAD MCP server is connected and AutoLISP execution is enabled, you can load the library and run commands directly, e.g. `(load "C:/autocad-planning-kit/plugins/uk-planning-cad/skills/autolisp-tools/lisp/planning-tools.lsp")` then `(c:TBTAGS)`. Show the designer what you are about to run before running anything that edits the drawing.
