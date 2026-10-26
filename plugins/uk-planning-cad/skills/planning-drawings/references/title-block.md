# Title block attributes

The AutoLISP tools assume the title block is a block with these attribute tags. If the designer's block uses different tags, edit this table **and** the `*tb-tags*` list at the top of `autolisp-tools/lisp/planning-tools.lsp`.

| Tag | Example | Notes |
|---|---|---|
| `PROJECT` | Rear extension | |
| `ADDRESS` | 12 Acacia Avenue, London N1 1AA | |
| `CLIENT` | Mr & Mrs Smith | |
| `DWG_TITLE` | Proposed Ground Floor Plan | |
| `DWG_NO` | 2417-PL-201 | |
| `REV` | B | `-` for first issue |
| `SCALE` | 1:100 @ A3 | Always include paper size |
| `DATE` | 26/10/2026 | UK date format dd/mm/yyyy |
| `STATUS` | PLANNING | |
| `DRAWN` | AB | Initials |

To find out what a block actually uses, run `TBTAGS` (from `planning-tools.lsp`) in AutoCAD — it lists every attribute tag in every title block on the current layout.
