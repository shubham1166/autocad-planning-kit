---
name: planning-drawings
description: Use when producing, editing or checking UK planning application drawings in AutoCAD — existing/proposed plans, elevations, sections, site and block plans, location plans, roof plans, title blocks, layers, scales and sheet sets for householder, full planning, lawful development certificate (LDC) or prior approval submissions.
---

# UK planning application drawings

You are helping a UK architectural designer who prepares planning and permitted-development drawings in AutoCAD. Be practical: they know the job, you are here to remove repetitive work and catch mistakes.

## How to work

1. **Ask for the job basics once**, then reuse them: site address, client, job number, application type (householder / full / LDC / prior approval / listed building), local planning authority (LPA), drawing status (`PLANNING`, `PRELIMINARY`, `LDC`, `BUILDING REGS`).
2. **Inspect before changing.** If the AutoCAD MCP server is connected, read the drawing first (layers, blocks, layouts, title block attributes) and summarise what is there before editing anything.
3. **Never change the original existing-drawings file in place.** Save proposed work as a new file or new layout. Existing and proposed must stay consistent with each other — same datum, same scale, same orientation.
4. **Draw in model space at 1:1 in millimetres.** Scale only in viewports. Check `INSUNITS` = 4 (mm) before doing any measurement or area work.
5. **Prefer AutoLISP** (see the `autolisp-tools` skill) for repeated edits across many drawings; prefer direct MCP calls for one-off edits.
6. After any change, run the `drawing-qa` checklist on the affected sheets.

## Standard drawing package

| Drawing | Usual scale (at A3 unless noted) | Must show |
|---|---|---|
| Location plan | 1:1250 or 1:2500 | Red line round the whole site incl. access to a road, blue line round other land owned by the applicant, north point, scale bar, OS licence/copyright note |
| Block / site plan | 1:500 or 1:200 | Site boundaries, all buildings, proposal shaded/hatched, distances to boundaries, neighbouring windows if relevant, north point |
| Existing floor plans | 1:100 or 1:50 | All floors, room names, dimensions, walls hatched consistently |
| Proposed floor plans | 1:100 or 1:50 | Same as existing plus new work clearly distinguished (colour or hatch), demolished walls dashed |
| Existing / proposed elevations | 1:100 or 1:50 | All elevations affected, materials annotated, ridge and eaves heights, ground level |
| Sections | 1:100 or 1:50 | Floor-to-ceiling, ridge/eaves, ground levels, relationship to neighbours where relevant |
| Roof plans | 1:100 | Pitches, ridge lines, rooflights, dormers, set-backs from eaves |

Every sheet: title block with drawing number, revision, scale at paper size (e.g. `1:100 @ A3`), date, status, a scale bar, and a north point on plans. Many LPAs reject drawings that say "do not scale" — use a scale bar instead.

See `references/layers.md` for a layer standard and `references/title-block.md` for title block attributes.

## Naming

Drawing numbers: `<JOB>-<TYPE>-<NNN>` e.g. `2417-PL-101`. Existing drawings in the 0xx/1xx range and proposed in the 2xx range is a common pattern — follow whatever the designer already uses; ask once if it is unclear.

Revisions: `-` for first issue, then `A`, `B`, `C`… Each revision gets a revision-table row: letter, date, description, initials. Cloud the change on the sheet.

## Things that get applications invalidated or delayed

- Red line missing the access to the public highway.
- Scale stated without paper size, or a scale bar that doesn't match the viewport scale.
- Existing and proposed plans not matching each other (wall moved between sets).
- Missing elevations of affected sides.
- Ridge and eaves heights missing on elevations for extensions and outbuildings.
- No north point on site/block plan.

## PDF output

Planning portals want one PDF per drawing, named with the drawing number and revision, e.g. `2417-PL-201-B Proposed Ground Floor.pdf`. Use the batch plot routine in `autolisp-tools` to produce them.
