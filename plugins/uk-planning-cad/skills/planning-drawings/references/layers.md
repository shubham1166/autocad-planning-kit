# Layer standard

A simple standard for planning drawings. If the designer already has a layer standard, **use theirs** and edit this file to match it so Claude follows it in future.

| Layer | Colour | Linetype | Lineweight | Use |
|---|---|---|---|---|
| `A-WALL-EXST` | 8 | Continuous | 0.35 | Existing walls |
| `A-WALL-NEWW` | 1 | Continuous | 0.50 | New walls |
| `A-WALL-DEMO` | 9 | DASHED | 0.25 | Walls to be demolished |
| `A-WALL-HATCH` | 253 | Continuous | 0.05 | Wall hatching |
| `A-DOOR` | 4 | Continuous | 0.25 | Doors and swings |
| `A-GLAZ` | 4 | Continuous | 0.25 | Windows |
| `A-ROOF` | 3 | Continuous | 0.25 | Roof outlines, ridges |
| `A-STAIR` | 6 | Continuous | 0.18 | Stairs |
| `A-FURN` | 8 | Continuous | 0.13 | Furniture, sanitaryware |
| `A-ANNO-TEXT` | 7 | Continuous | 0.18 | Room names, notes |
| `A-ANNO-DIMS` | 7 | Continuous | 0.18 | Dimensions |
| `A-ANNO-LEVL` | 7 | Continuous | 0.18 | Levels, ridge/eaves heights |
| `A-ANNO-REVS` | 1 | Continuous | 0.25 | Revision clouds and tags |
| `A-SITE-BNDY` | 7 | DASHED2 | 0.35 | Site boundaries |
| `A-SITE-REDL` | 1 | Continuous | 0.70 | Red line (location plan) |
| `A-SITE-BLUL` | 5 | Continuous | 0.70 | Blue line (other land owned) |
| `A-SITE-NBRS` | 8 | Continuous | 0.18 | Neighbouring buildings |
| `A-SITE-LAND` | 3 | Continuous | 0.13 | Trees, planting, hard landscaping |
| `A-TTLB` | 7 | Continuous | 0.25 | Title block (paper space) |
| `A-VPRT` | 8 | Continuous | 0.00 | Viewports, set to no-plot |
| `X-REF` | 8 | Continuous | Default | External references (OS maps, surveys) |

Rules:
- Nothing on layer `0` except block-internal geometry.
- `A-VPRT` is always set to no-plot.
- Existing vs new must be distinguishable in monochrome PDF (lineweight or hatch), not by colour alone.
