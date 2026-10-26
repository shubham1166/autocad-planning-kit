"""Check householder measurements against GPDO 2015 Sch.2 Part 1 limits (England).

Usage: python pd_check.py measurements.json

All lengths in metres, areas in square metres, volumes in cubic metres.
Leave a field out if it does not apply; its checks are skipped.
"""
import json
import sys

PASS, FAIL, CHECK = "appears to comply", "APPEARS NOT TO COMPLY", "needs checking"


def check(rows, ref, limit, value, ok):
    if value is None:
        return
    rows.append((ref, limit, value, PASS if ok else FAIL))


def coverage(site, rows, ref):
    curtilage = site.get("curtilage_area")
    original = site.get("original_house_footprint")
    covered = site.get("other_buildings_footprint_total")
    if None in (curtilage, original, covered):
        return
    available = curtilage - original
    pct = 100 * covered / available
    check(rows, ref, "<= 50% of curtilage (excl. original house)", f"{pct:.1f}%", pct <= 50)


def class_a(d, site):
    rows = []
    detached = site.get("house_type") == "detached"
    a23 = site.get("article_2_3_land", False)
    coverage(site, rows, "A.1(b)")
    h, e = d.get("height"), d.get("eaves_height")
    ridge, eaves = site.get("existing_ridge_height"), site.get("existing_eaves_height")
    if ridge is not None:
        check(rows, "A.1(c)", "height <= existing ridge", h, h is not None and h <= ridge)
    if eaves is not None:
        check(rows, "A.1(d)", "eaves <= existing eaves", e, e is not None and e <= eaves)

    storeys = d.get("storeys", 1)
    depth = d.get("rear_depth")
    if depth is not None:
        if storeys == 1:
            if d.get("larger_home_extension"):
                lim = 8 if detached else 6
                check(rows, "A.1(g)", f"rear depth <= {lim} m (prior approval)", depth, depth <= lim)
            else:
                lim = 4 if detached else 3
                check(rows, "A.1(f)", f"rear depth <= {lim} m", depth, depth <= lim)
            check(rows, "A.1(f)", "height <= 4 m", d.get("height"),
                  d.get("height") is not None and d["height"] <= 4)
        else:
            if a23:
                rows.append(("A.2(c)", "no multi-storey rear extension on art. 2(3) land", storeys, FAIL))
            check(rows, "A.1(h)", "rear depth <= 3 m", depth, depth <= 3)
            rb = d.get("distance_to_rear_boundary")
            check(rows, "A.1(h)", ">= 7 m to rear boundary", rb, rb is not None and rb >= 7)

    dist = d.get("distance_to_boundary")
    if dist is not None and dist < 2 and d.get("eaves_height") is not None:
        check(rows, "A.1(i)", "eaves <= 3 m within 2 m of boundary", d["eaves_height"], d["eaves_height"] <= 3)

    if d.get("side_extension"):
        if a23:
            rows.append(("A.2(b)", "no side extension on art. 2(3) land", "side", FAIL))
        check(rows, "A.1(j)", "height <= 4 m", d.get("height"),
              d.get("height") is not None and d["height"] <= 4)
        check(rows, "A.1(j)", "single storey", storeys, storeys == 1)
        w, ow = d.get("side_width"), site.get("original_house_width")
        if w is not None and ow is not None:
            check(rows, "A.1(j)", f"width <= half original width ({ow / 2:.2f} m)", w, w <= ow / 2)

    for flag, label in [("forward_of_principal_elevation", "A.1(e)"),
                        ("balcony_or_raised_platform", "A.1(k)"),
                        ("roof_alterations", "A.1(k)")]:
        if d.get(flag):
            rows.append((label, f"no {flag.replace('_', ' ')}", "yes", FAIL))
    return rows


def class_b(d, site):
    rows = []
    if site.get("article_2_3_land"):
        rows.append(("B.1(f)", "not on art. 2(3) land", "yes", FAIL))
    lim = 40 if site.get("house_type") == "terraced" else 50
    vol = d.get("volume_total_incl_previous")
    check(rows, "B.1(d)", f"added volume <= {lim} m3", vol, vol is not None and vol <= lim)
    if d.get("higher_than_ridge") is not None:
        rows.append(("B.1(b)", "not higher than ridge", d["higher_than_ridge"],
                     FAIL if d["higher_than_ridge"] else PASS))
    if d.get("on_principal_elevation_fronting_highway"):
        rows.append(("B.1(c)", "not on principal roof slope fronting highway", "yes", FAIL))
    sb = d.get("eaves_setback")
    check(rows, "B.2(b)", ">= 0.2 m set back from eaves (so far as practicable)", sb, sb is not None and sb >= 0.2)
    return rows


def class_e(d, site):
    rows = []
    coverage(site, rows, "E.1(b)")
    h = d.get("height")
    if h is not None:
        if d.get("distance_to_boundary", 99) < 2:
            lim = 2.5
        elif d.get("dual_pitched_roof"):
            lim = 4
        else:
            lim = 3
        check(rows, "E.1(e)", f"height <= {lim} m", h, h <= lim)
    e = d.get("eaves_height")
    check(rows, "E.1(f)", "eaves <= 2.5 m", e, e is not None and e <= 2.5)
    check(rows, "E.1(d)", "single storey", d.get("storeys"), d.get("storeys", 1) == 1)
    if d.get("forward_of_principal_elevation"):
        rows.append(("E.1(c)", "not forward of principal elevation", "yes", FAIL))
    return rows


def main(path):
    with open(path) as f:
        data = json.load(f)
    site = data["site"]
    if site.get("flat_or_maisonette") or site.get("listed_building") or site.get("pd_rights_removed"):
        print(f"STOP: Part 1 PD rights may not apply ({CHECK}). Planning permission likely required.")
    checkers = {"A": class_a, "B": class_b, "E": class_e}
    for cls, fn in checkers.items():
        if cls not in data:
            continue
        print(f"\nClass {cls}")
        print(f"{'Ref':<8}{'Limit':<56}{'Measured':<12}Result")
        for ref, limit, value, result in fn(data[cls], site):
            print(f"{ref:<8}{limit:<56}{str(value):<12}{result}")
    print("\nConfirm against the current GPDO and MHCLG technical guidance before relying on this.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
