// =============================================================================
// Shared two-stage quartering geometry (used by the 4-way and cascade kits).
// Stage 1 (upper) splits left / right (+-x). Each half falls through a short
// collecting hopper into a stage-2 (lower) bank that splits front / back
// (+-y) into a cup. Four cups in a 2 x 2 grid, all active.
// =============================================================================
include <splitter_lib.scad>

// ---- columns and frame plates ---------------------------------------------------
cpl = 2.0;                               // half width of the centre plate
cx  = cpl + clear + cup_w/2;             // 25.0 : cup column centre
po0 = cx + cup_w/2 + clear;              // 48.0 : outer plate inner face
po1 = po0 + plate_t;                     // 52.0
plates = [[-po1, -po0], [-cpl, cpl], [po0, po1]];
pmx = (po0 + po1)/2;                     // 50.0
frame_pins = [[-pmx, -12], [-pmx, 12], [pmx, -12], [pmx, 12]];

// ---- stage 2 (lower, print x2 in the cascade) -----------------------------------
n2 = 8; a2 = 6; dy2 = 10; H2 = 12;       // floor slope atan(12/10) = 50.2 deg
lxl = clear/2 + 0 - cx;                  // body x from 0.25 ...
lxr = po1 + 1.6 - cx;                    // ... to 53.6 (relative to the column)

// ---- stage 1 (upper) -------------------------------------------------------------
n1 = 8; a1 = 8; r1 = 21; H1 = 23.5;      // floor slope atan(23.5/21) = 48.2 deg
uend = span(n1)/2 + 6.5;                 // end blocks: y = +-26.5

// ---- hopper between the stages ---------------------------------------------------
hop = 14;                                // y converges 20 -> 6 over 14 mm = 45 deg
ap_x0 = r1 - a1; ap_x1 = r1 + a1;        // aperture x 13..29 (stage-1 outlet)
hop_pins = [[(ap_x0 + ap_x1)/2, -(span(n1)/2 + 3.5)], [(ap_x0 + ap_x1)/2, span(n1)/2 + 3.5]];
z_upper = z0 + H2 + hop;                 // stage-1 base height above the bench
top_pins = [[0, -24], [0, 24]];

// ---- funnel --------------------------------------------------------------------
f_tw = 2*a1; f_td = span(n1);            // throat 16 x 40
f_ch = 12;                               // cone run 10 over 12 = 50 deg
f_ow = f_tw + 20; f_od = f_td + 20;      // rim 36 x 60

nests = [[-cx, -cup_y], [cx, -cup_y], [-cx, cup_y], [cx, cup_y]];

// Lower part (stage 2 + hopper) for the +x column, in global x, base at z = 0.
// The -x copy is the same print rotated 180 deg about z.
module lower_part(with_fits=true) {
    difference() {
        hull() {
            translate([cx + lxl, -(a2 + dy2 + body_w), 0])
                cube([lxr - lxl, 2*(a2 + dy2 + body_w), 0.01]);
            // keep full width up to the stage-2 inlet so the hopper walls stay >= 2.4 mm
            translate([cx + lxl, -(a2 + body_w), H2])
                cube([lxr - lxl, 2*(a2 + body_w), 0.01]);
            translate([ap_x0 - 3, -uend, H2 + hop - 0.01])
                cube([ap_x1 - ap_x0 + 3 + body_w, 2*uend, 0.01]);
        }
        translate([cx, 0, 0]) stage_cavity(n2, a2, dy2, H2);
        hull() {
            translate([cx - span(n2)/2, -a2, H2]) cube([span(n2), 2*a2, 0.01]);
            translate([ap_x0, -span(n1)/2, H2 + hop]) cube([ap_x1 - ap_x0, span(n1), 0.01]);
            translate([ap_x0, -span(n1)/2, H2 + hop + 1]) cube([ap_x1 - ap_x0, span(n1), 0.01]);
        }
        if (with_fits) holes_at([for (p = frame_pins) if (p[0] > 0) p], 0);
    }
    if (with_fits) pins_at(hop_pins, H2 + hop);
}

// Upper part (stage 1), centred, base at z = 0. Chutes along y, outlets +-x.
function to_local(p) = [p[1], -p[0]];
module upper_part(with_fits=true) {
    rotate([0, 0, 90]) difference() {
        stage_body(a1, r1, H1, -uend, uend);
        stage_cavity(n1, a1, r1, H1);
        if (with_fits)
            holes_at([for (p = concat(hop_pins, [for (q = hop_pins) [-q[0], q[1]]])) to_local(p)], 0);
    }
    pins_at(top_pins, H1);
}

module funnel()     funnel_part(f_tw, f_td, f_ow, f_od, f_ch, a1 + body_w, uend, top_pins);
module frame()      frame_part(plates, frame_pins);
module catch_tray() tray_part(-po1 - clear, po1 + clear, plates,
                              [[-po0, -cpl], [cpl, po0]],
                              [[-po0 + clear, -cpl - clear], [cpl + clear, po0 - clear]], []);

module place_cup(p, z) translate([p[0], p[1], z]) rotate([0, 0, p[1] > 0 ? 180 : 0]) cup();

module base_assembly(gap=0) {
    color([0.42, 0.45, 0.50]) catch_tray();
    color([0.55, 0.57, 0.60]) translate([0, 0, tray_floor - slot_d + gap]) frame();
    cols = [[0.95, 0.75, 0.15], [0.25, 0.60, 0.90], [0.93, 0.52, 0.22], [0.42, 0.72, 0.42]];
    for (i = [0:3]) color(cols[i]) place_cup(nests[i], tray_floor + gap*0.5);
}
function total_height() = z_upper + H1 + funnel_height(f_ch);
