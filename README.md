# AutoCAD Planning Kit for Claude Code

Lets Claude work **inside AutoCAD** for UK planning and permitted-development drawings: fill and revise title blocks across every sheet, set up layers, measure areas, check proposals against permitted development limits, QA a drawing set before submission, and batch-plot PDFs named the way planning portals want them.

Two pieces work together:

| Piece | What it is | Where it comes from |
|---|---|---|
| **AutoCAD MCP server** | The "hands": lets Claude read and edit the drawing open in AutoCAD | [beiming183-cloud/AutoCAD-MCP](https://github.com/beiming183-cloud/AutoCAD-MCP) (MIT, works with full AutoCAD and AutoCAD LT 2024+) |
| **uk-planning-cad plugin** (this repo) | The "know-how": four skills that teach Claude UK planning drawing practice | This repo |

## Requirements

- Windows 10 version 1809 or newer, or Windows 11 (check with `winver`)
- AutoCAD (full) or **AutoCAD LT 2024 or newer**. Older LT versions can't run AutoLISP, so the connector won't work. The skills still help with advice and PD checks.
- A Claude Pro or Max subscription (or an Anthropic API key)

## Setup (about 10 minutes, once)

1. Open **PowerShell** from the Start menu. Don't run it as admin.
2. Install Git if you don't have it, then clone this repo:
   ```powershell
   winget install --id Git.Git -e
   ```
   Close and reopen PowerShell, then run:
   ```powershell
   git clone <THIS-REPO-URL> C:\autocad-planning-kit
   cd C:\autocad-planning-kit
   powershell -ExecutionPolicy Bypass -File setup\setup.ps1
   ```
3. Inside **AutoCAD**, type `APPLOAD` and load both of these files. Add both to the **Startup Suite** in the same dialog so they load every time.
   - `C:\autocad-mcp\lisp-code\mcp_dispatch.lsp`
   - `C:\autocad-planning-kit\plugins\uk-planning-cad\skills\autolisp-tools\lisp\planning-tools.lsp`
4. Open **Windows Terminal** from the Start menu, type `claude`, and log in when it asks.

To check it works, open a drawing in AutoCAD, then in Claude type:
> Check the AutoCAD connection and list the layouts and title block fields in the open drawing.

## The terminal: Windows Terminal

The setup installs **Windows Terminal**, Microsoft's free terminal. It comes with Windows 11 and is on the Microsoft Store for Windows 10. It supports copy and paste with Ctrl+C / Ctrl+V and tabs, and Claude Code displays properly in it, which the old blue PowerShell window and `cmd.exe` don't manage well.

Tips for someone new to terminals:
- **Start Claude:** open Windows Terminal, type `cd C:\Jobs\2417` (your job folder), then `claude`.
- **Paste a screenshot:** Win+Shift+S to snip, then Alt+V in Claude.
- **Stop Claude mid-task:** press Esc.
- **Exit:** type `/exit`, or close the tab.
- **Rather not use a terminal at all?** The **Claude desktop app** for Windows has a Code tab that runs the same Claude Code with these plugins and the AutoCAD connector, all point-and-click.

## What you can ask

- *"Set STATUS to PLANNING and today's date on every sheet."*
- *"Bump all sheets to the next revision, description 'Rear extension reduced to 3m per LPA comments'."*
- *"Check the proposed rear extension and the garden room against permitted development. It's a semi, not in a conservation area."*
- *"Measure the curtilage and all outbuildings and tell me if we're under 50%."*
- *"QA this drawing set before I submit it."*
- *"Plot every layout to PDF."*
- *"Write me a LISP routine that renumbers all the room tags on this floor plan."*

## Skills included

| Skill | Kicks in when you… |
|---|---|
| `planning-drawings` | create or edit plans, elevations, site and location plans, title blocks, layers |
| `permitted-development` | ask whether something is PD (Classes A, AA, B, C, D, E, F); it measures from the drawing and runs a tested calculator |
| `autolisp-tools` | want to automate anything; includes `TBTAGS`, `TBSET`, `TBREV`, `PLAYERS`, `AREAM2`, `BATCHPDF` |
| `drawing-qa` | are about to issue or submit drawings |

Claude picks the right skill on its own. You can also call one directly, for example `/uk-planning-cad:drawing-qa`.

## Making it yours

The skills are plain text files you can edit:
- **Your layer standard:** edit `plugins/uk-planning-cad/skills/planning-drawings/references/layers.md` and the `*pt-layers*` list at the top of `planning-tools.lsp`.
- **Your title block tags:** run `TBTAGS` in AutoCAD, then edit the four `*pt-...-tag*` lines at the top of `planning-tools.lsp`.
- **New habits:** tell Claude something like *"add to the planning-drawings skill that our drawing numbers always start with the job number"* and it will edit the file.

## Updating

```powershell
cd C:\autocad-planning-kit
powershell -ExecutionPolicy Bypass -File setup\update.ps1
```

Skill changes take effect the next time Claude starts. If you edit the skills on your own, bump `version` in `plugins/uk-planning-cad/.claude-plugin/plugin.json`.

## Important

- **Keep backups.** Before any batch edit across many drawings, copy the folder first or keep the drawings in version control.
- The permitted-development skill is a **checking aid, not legal advice**. It covers England only. Always confirm against the current GPDO on [legislation.gov.uk](https://www.legislation.gov.uk/uksi/2015/596/schedule/2) and the MHCLG householder technical guidance, and check for Article 4 directions and conditions on the planning history.
- `planning-tools.lsp` is new. Try each command on a copy of a drawing first.
