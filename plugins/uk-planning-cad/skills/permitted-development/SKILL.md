---
name: permitted-development
description: Use when checking whether a householder proposal in England falls within permitted development (GPDO 2015 Schedule 2 Part 1 — Class A extensions, AA upward extensions, B and C roof works, D porches, E outbuildings, F hard surfaces), when preparing a lawful development certificate (LDC) or larger home extension prior approval, or when measuring a drawing against PD limits.
---

# Permitted development checks (England, householder)

The designer is the professional; this skill produces a **measured checklist** that helps them, it does not replace their judgement. Always state the result as "appears to comply / appears not to comply / needs checking", never as a guarantee.

## Before checking anything — stop conditions

Ask (or find on the drawing) and report these first. Any "yes" means Part 1 PD may not apply at all:

- Is it a **flat or maisonette**? (No Part 1 rights.)
- Is the building **listed**?
- Is the site on **article 2(3) land** — conservation area, National Park, National Landscape (AONB), the Broads, World Heritage Site? (Extra restrictions — see reference.)
- Has an **Article 4 direction** removed PD rights? Was there a **planning condition** removing PD rights on the original permission? (Tell the designer to check the LPA's planning history; you cannot know this.)
- Was the house created through a change of use under Part 3 (e.g. office to residential)? (No Part 1 rights.)
- Is the site in Wales, Scotland or Northern Ireland? (Different law — this skill does not apply.)

## How to measure

"Original" means the house as first built, or as it stood on 1 July 1948 if older. Ask which parts of the existing house are original — previous extensions count against the limits.

If the AutoCAD MCP server is connected, measure from the drawing rather than asking for numbers:

1. Confirm `INSUNITS` is millimetres.
2. Curtilage area: area of the closed boundary polyline on the site layer, minus the original house footprint.
3. Area covered by buildings: sum of footprints of every building in the curtilage other than the original house (existing outbuildings and extensions + proposed).
4. Depth: perpendicular distance from the original rear wall to the furthest point of the extension.
5. Heights: from natural ground level adjacent to the building (on sloping ground, the highest ground level adjacent — tell the designer this is an interpretation point).
6. Distance to boundary: shortest distance from the proposal to the boundary line.

Then put the numbers into `scripts/pd_check.py` (`python pd_check.py measurements.json`) to get a deterministic pass/fail table. See `scripts/example.json` for the input format. Do the arithmetic with the script, not in your head.

## Output format

A table per Class: limit, measured value, result, the GPDO paragraph reference. Then a short list of points that need the designer's judgement (materials similar in appearance, "so far as practicable", principal elevation identification, sloping ground). Finish with:

> Checked against the limits in `references/gpdo-part1.md`. Confirm against the current GPDO on legislation.gov.uk and the latest MHCLG householder technical guidance before submitting — the limits change from time to time.

If you have web access, fetch the current text of Schedule 2 Part 1 from legislation.gov.uk and flag any difference from the reference file to the designer, and offer to update the reference file.
