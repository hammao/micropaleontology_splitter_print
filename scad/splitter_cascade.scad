// =============================================================================
// Micropaleontology dry-sediment splitter: compact brass-style two-stage CASCADE
// =============================================================================
// Quartering by two sequential 2-way splits, each stage a separate print:
//   funnel -> stage-1 riffle (L/R) -> two stage-2 riffles with collecting
//   hoppers (F/B) -> four active cups A1 B1 A2 B2.
// Cups (45 x 39 x 24 mm) set the scale. Whole assembled stack <= 100 mm tall.
//
// Kit: cascade. STLs: stl/cascade/
// PART: cup | catch_tray | frame | riffle_upper | riffle_lower | funnel
//       | assembly | exploded | side_view
// Print: cup x4, riffle_lower x2, one each of the rest.
// Units: mm.

include <splitter_quarter_lib.scad>

/* [Part] */
PART = "assembly"; // ["cup","catch_tray","frame","riffle_upper","riffle_lower","funnel","assembly","exploded","side_view"]
ORBIT_DEG = 0;

module riffle_upper() upper_part(true);
// Print orientation: column centre moved to the origin.
module riffle_lower() translate([-cx, 0, 0]) lower_part(true);

module assembly(gap=0) {
    base_assembly(gap);
    color([0.78, 0.62, 0.30]) translate([0, 0, z0 + 2*gap]) lower_part(true);
    color([0.72, 0.58, 0.28]) translate([0, 0, z0 + 2*gap]) rotate([0, 0, 180]) lower_part(true);
    color([0.85, 0.70, 0.35]) translate([0, 0, z_upper + 3*gap]) riffle_upper();
    color([0.90, 0.78, 0.45]) translate([0, 0, z_upper + H1 + 4*gap]) funnel();
}

if      (PART == "cup")          cup();
else if (PART == "catch_tray")   catch_tray();
else if (PART == "frame")        frame();
else if (PART == "riffle_upper") riffle_upper();
else if (PART == "riffle_lower") riffle_lower();
else if (PART == "funnel")       funnel();
else if (PART == "exploded")     assembly(gap=25);
else if (PART == "side_view")    { assembly(); ruler100(po1 + 14, 0); }
else rotate([0, 0, ORBIT_DEG]) assembly();
