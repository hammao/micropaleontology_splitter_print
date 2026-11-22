// =============================================================================
// Micropaleontology dry-sediment splitter: compact brass-style Jones 2-way riffle
// =============================================================================
// Modelled on the classic brass micro-splitter: small hopper sitting directly
// on a short A-frame chute block, cups sliding under each side. Cups
// (45 x 39 x 24 mm) set the scale. Whole assembled device <= 100 mm tall.
//
//   funnel -> 8 alternating chutes (4 to side A, 4 to side B) -> cups A1 / B1
//   spare cups A2 / B2 park in the same tray.
//
// Kit: 2-way. STLs: stl/2way/
// PART: cup | catch_tray | frame | riffle | funnel | assembly | exploded | side_view
// Print cup x4, one each of the rest. Do not print assembly / exploded / side_view.
// Units: mm.

include <splitter_lib.scad>

/* [Part] */
PART = "assembly"; // ["cup","catch_tray","frame","riffle","funnel","assembly","exploded","side_view"]
ORBIT_DEG = 0;

// ---- riffle ------------------------------------------------------------------
n_chutes = 8;          // even; 4 per side
a   = 8;               // half inlet depth (inlet slot 40.0 x 16 mm)
dy  = 14;              // outlet shift: outlets y = 6..22 mm, centred over the cups
H   = 24;              // chute floor slope atan(24/14) = 59.7 deg

// ---- frame plates straddle the active cups ------------------------------------
px0 = cup_w/2 + clear;           // 23.0
px1 = px0 + plate_t;             // 27.0
rx  = px1 + 1.7;                 // riffle body half width 28.7
frame_pins = [[-(px0+px1)/2, -12], [-(px0+px1)/2, 12], [(px0+px1)/2, -12], [(px0+px1)/2, 12]];
top_pins   = [[-26, 0], [26, 0]];

// ---- funnel ------------------------------------------------------------------
f_ow = 80; f_od = 56;            // rim opening (wider than the brass hopper)
f_ch = 35;                       // cone: (80-40)/2 = 20 run over 35 = 60 deg

// ---- tray ---------------------------------------------------------------------
spare_x = px1 + 1.5 + cup_w/2 + clear;   // 51.5
tray_x0 = -(px1 + clear);
tray_x1 = spare_x + cup_w/2 + 2*clear;
nests = [[0, -cup_y], [0, cup_y], [spare_x, -cup_y], [spare_x, cup_y]];

module riffle() {
    difference() {
        stage_body(a, dy, H, -rx, rx);
        stage_cavity(n_chutes, a, dy, H);
        holes_at(frame_pins, 0);
    }
    pins_at(top_pins, H);
}
module funnel()     funnel_part(span(n_chutes), 2*a, f_ow, f_od, f_ch, rx, a + body_w, top_pins);
module frame()      frame_part([[-px1, -px0], [px0, px1]], frame_pins);
module catch_tray() tray_part(tray_x0, tray_x1, [[-px1, -px0], [px0, px1]],
                              [[-px0, px0]], [[-px0 + clear, px0 - clear]],
                              [[spare_x, -cup_y], [spare_x, cup_y]]);

module place_cup(p, z) translate([p[0], p[1], z]) rotate([0, 0, p[1] > 0 ? 180 : 0]) cup();

module assembly(gap=0) {
    color([0.42, 0.45, 0.50]) catch_tray();
    color([0.55, 0.57, 0.60]) translate([0, 0, tray_floor - slot_d + gap]) frame();
    color([0.95, 0.75, 0.15]) place_cup(nests[0], tray_floor + gap*0.5);
    color([0.25, 0.60, 0.90]) place_cup(nests[1], tray_floor + gap*0.5);
    color([0.80, 0.74, 0.55]) place_cup(nests[2], tray_floor - slot_d + gap*0.5);
    color([0.70, 0.74, 0.70]) place_cup(nests[3], tray_floor - slot_d + gap*0.5);
    color([0.78, 0.62, 0.30]) translate([0, 0, z0 + 2*gap]) riffle();
    color([0.85, 0.70, 0.35]) translate([0, 0, z0 + H + 3*gap]) funnel();
}

if      (PART == "cup")        cup();
else if (PART == "catch_tray") catch_tray();
else if (PART == "frame")      frame();
else if (PART == "riffle")     riffle();
else if (PART == "funnel")     funnel();
else if (PART == "exploded")   assembly(gap=30);
else if (PART == "side_view")  { assembly(); ruler100(tray_x1 + 12, 0); }
else rotate([0, 0, ORBIT_DEG]) assembly();
