---
name: drawing-qa
description: Use before issuing or submitting planning drawings, or when asked to check, audit or QA an AutoCAD drawing or drawing set — title block consistency, revisions, scales, layers, existing-vs-proposed consistency, missing information that gets planning applications invalidated.
---

# Drawing QA before issue

Run through this list and report as a table: item, sheet(s), status (OK / issue / couldn't check), detail. Only report issues you actually found; say plainly what you could not check.

If the AutoCAD MCP server is connected, check from the drawing itself (layouts, title block attributes via `TBTAGS`, layers, viewport scales, entities). Otherwise check PDFs or ask for screenshots.

## Title blocks
- [ ] Every layout has a title block with drawing number, title, revision, scale, date, status filled in — no placeholder text (`XXX`, `TBC`, `Title`).
- [ ] Drawing numbers unique across the set; no two layouts share one.
- [ ] Scale in the title block matches the viewport scale and states the paper size (`1:100 @ A3`).
- [ ] Revision letter matches the latest row in the revision table; date matches.
- [ ] Address and client identical on every sheet (catch typos by comparing all values).
- [ ] Status consistent across the set (all `PLANNING`, not one left as `PRELIMINARY`).

## Content
- [ ] North point on every plan; scale bar on every sheet.
- [ ] Location plan: red line reaches the public highway; blue line for other owned land; OS copyright/licence note.
- [ ] Existing and proposed plans and elevations match each other for everything not changing (overlay them: same outline, same window positions).
- [ ] Every elevation affected by the works is shown, existing and proposed.
- [ ] Ridge and eaves heights dimensioned on elevations/sections for extensions, dormers and outbuildings.
- [ ] Distances to boundaries shown where they matter (2 m rule, 7 m rear boundary rule).
- [ ] Materials annotated on proposed elevations.
- [ ] Demolished elements shown dashed; new work distinguishable in black-and-white print.

## Drawing hygiene
- [ ] `INSUNITS` = millimetres; geometry drawn 1:1.
- [ ] Nothing on layer `0` or `Defpoints` that should plot; viewport layer set to no-plot.
- [ ] Viewports locked.
- [ ] No broken xrefs or missing images; no proxy objects warnings.
- [ ] `AUDIT` reports no errors; `PURGE` run before issue.
- [ ] Text uses a consistent style and height per scale; no overlapping text or dimensions.

## Output
- [ ] One PDF per drawing, named `<DWG_NO>-<REV> <Title>.pdf` (`BATCHPDF` does this).
- [ ] PDFs open, are the right paper size, and are readable in monochrome.
- [ ] If the proposal relies on permitted development, the `permitted-development` check has been run against the final drawings.
