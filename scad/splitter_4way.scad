// =============================================================================
// Micropaleontology dry-sediment splitter: compact brass-style 4-way riffle
// =============================================================================
// One pour, four equal parts. The quartering riffle is ONE print holding both
// split stages: stage 1 splits L/R, each half drops through an internal
// collecting hopper into a stage-2 bank that splits F/B into a cup.
// (A single straight-chute bank cannot feed a 2 x 2 cup grid with
// interleaved chutes: the chutes would have to cross. Two stages in one
// body gives true 1:1:1:1 with no crossing.)
// Same tray, frame, funnel and cups as the cascade kit.
// Cups (45 x 39 x 24 mm) set the scale. Whole assembled device <= 100 mm tall.
//
// Kit: 4-way. STLs: stl/4way/
// PART: cup | catch_tray | frame | riffle | funnel | assembly | exploded | side_view
// Print cup x4, one each of the rest.
// Units: mm.

include <splitter_quarter_lib.scad>

/* [Part] */
PART = "assembly"; // ["cup","catch_tray","frame","riffle","funnel","assembly","exploded","side_view"]
ORBIT_DEG = 0;

module riffle() {
    difference() {
        union() {
            lower_part(false);
            rotate([0, 0, 180]) lower_part(false);
            translate([0, 0, H2 + hop]) upper_part(false);
        }
        holes_at(frame_pins, 0);
    }
    translate([0, 0, H2 + hop]) pins_at(top_pins, H1);
}

module assembly(gap=0) {
    base_assembly(gap);
    color([0.78, 0.62, 0.30]) translate([0, 0, z0 + 2*gap]) riffle();
    color([0.90, 0.78, 0.45]) translate([0, 0, z_upper + H1 + 3*gap]) funnel();
}

if      (PART == "cup")        cup();
else if (PART == "catch_tray") catch_tray();
else if (PART == "frame")      frame();
else if (PART == "riffle")     riffle();
else if (PART == "funnel")     funnel();
else if (PART == "exploded")   assembly(gap=25);
else if (PART == "side_view")  { assembly(); ruler100(po1 + 14, 0); }
else rotate([0, 0, ORBIT_DEG]) assembly();
