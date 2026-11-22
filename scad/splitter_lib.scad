// =============================================================================
// Shared geometry for the compact brass-style Jones micro-splitter kits.
// Included by splitter_2way.scad, splitter_4way.scad, splitter_cascade.scad.
// Units: mm. Coordinates: z up from the bench, tray bottom at z = 0.
// Chute banks run along x and discharge to -y (side A) and +y (side B),
// unless a kit rotates them.
// =============================================================================

$fn = 40;

// ---- fits --------------------------------------------------------------------
clear  = 0.5;                 // mating clearance per side
pin_d  = 3.0;                 // locating pin
pin_h  = 2.4;
hole_d = pin_d + 2*clear;     // 4.0
hole_h = 3.0;

// ---- cup (scale reference: brass kit cup 45 x 39 x 24) ----------------------
cup_w = 45;                   // along the chute bank (x)
cup_d = 39;                   // across the bank (y)
cup_h = 24;
cup_t = 1.6;
cup_floor = 1.6;
cup_gap = 3.0;                // gap between the A and B cups (y)
cup_y = cup_d/2 + cup_gap/2;  // 21.0 : cup centre offset from the split line

// ---- tray / frame --------------------------------------------------------------
tray_floor = 2.0;
tray_wall  = 2.0;
tray_h     = 9.0;
slot_d     = 0.8;             // frame plate slots in the tray floor
plate_t    = 4.0;
tie_t      = 1.6;
tie_w      = 4.0;
rib_h      = 3.0;
// riffle base = frame top. Cups clear the frame ties by 0.5 mm.
z0 = tray_floor + cup_h + clear + tie_t;          // 28.1
plate_y = cup_d + cup_gap/2 + 0.1;                // plates run y = -plate_y..+plate_y (40.6)
tray_in_y = plate_y + clear;                      // 41.1

// ---- chutes --------------------------------------------------------------------
chute_w = 3.6;
vane_t  = 1.6;
body_w  = 2.4;                // horizontal wall on sloped faces (normal >= 1.6)
function span(n) = n*chute_w + (n-1)*vane_t;
function chute_x(n, i) = -span(n)/2 + chute_w/2 + i*(chute_w + vane_t);

// ---- funnel --------------------------------------------------------------------
fun_th    = 2.2;              // horizontal wall of the cone
fun_fl    = 2.0;              // flange thickness
fun_neck  = 3.0;              // straight throat above the flange (houses pin holes)
fun_collar = 2.0;

// =============================================================================
module cup() {
    difference() {
        translate([-cup_w/2, -cup_d/2, 0]) cube([cup_w, cup_d, cup_h]);
        translate([-cup_w/2 + cup_t, -cup_d/2 + cup_t, cup_floor])
            cube([cup_w - 2*cup_t, cup_d - 2*cup_t, cup_h]);
        // finger notch in the outer (-y) rim, for sliding the cup out
        translate([0, -cup_d/2, cup_h]) rotate([90, 0, 0])
            cylinder(r=6, h=4*cup_t, center=true);
    }
}

// Chute bank: n chutes along x, inlet slot y = -a..a at z = H,
// outlets shifted dy to -y (even i) or +y (odd i) at z = 0.
module stage_cavity(n, a, dy, H) {
    for (i = [0:n-1]) {
        x = chute_x(n, i);
        s = (i % 2 == 0) ? -1 : 1;
        hull() {
            translate([x - chute_w/2, -a - s*dy/H, H + 1]) cube([chute_w, 2*a, 0.01]);
            translate([x - chute_w/2, -a + s*dy*(1 + 1/H), -1]) cube([chute_w, 2*a, 0.01]);
        }
    }
}

// A-frame body around a chute bank, x from xl to xr.
module stage_body(a, dy, H, xl, xr) {
    hull() {
        translate([xl, -(a + body_w), H - 0.01]) cube([xr - xl, 2*(a + body_w), 0.01]);
        translate([xl, -(a + dy + body_w), 0])   cube([xr - xl, 2*(a + dy + body_w), 0.01]);
    }
}

module holes_at(pts, z, depth=hole_h) {
    for (p = pts) translate([p[0], p[1], z - 0.01]) cylinder(d=hole_d, h=depth + 0.01);
}
module pins_at(pts, z) {
    for (p = pts) translate([p[0], p[1], z - 0.01]) cylinder(d=pin_d, h=pin_h + 0.01);
}

// Funnel: throat tw x td at z = 0 (sits on the riffle top), straight neck,
// cone to ow x od at the rim, short vertical collar. Flange fx x fy (half sizes).
module funnel_part(tw, td, ow, od, ch, fx, fy, holes) {
    zc = fun_neck;            // cone starts here
    difference() {
        union() {
            translate([-fx, -fy, 0]) cube([2*fx, 2*fy, fun_fl]);
            translate([-(tw/2 + fun_th), -(td/2 + fun_th), 0])
                cube([tw + 2*fun_th, td + 2*fun_th, zc]);
            hull() {
                translate([-(tw/2 + fun_th), -(td/2 + fun_th), zc]) cube([tw + 2*fun_th, td + 2*fun_th, 0.01]);
                translate([-(ow/2 + fun_th), -(od/2 + fun_th), zc + ch]) cube([ow + 2*fun_th, od + 2*fun_th, 0.01]);
            }
            translate([-(ow/2 + fun_th), -(od/2 + fun_th), zc + ch]) cube([ow + 2*fun_th, od + 2*fun_th, fun_collar]);
        }
        translate([-tw/2, -td/2, -1]) cube([tw, td, zc + 1.01]);
        hull() {
            translate([-tw/2, -td/2, zc]) cube([tw, td, 0.01]);
            translate([-ow/2, -od/2, zc + ch]) cube([ow, od, 0.01]);
        }
        translate([-ow/2, -od/2, zc + ch - 0.01]) cube([ow, od, fun_collar + 1]);
        holes_at(holes, 0);
    }
}
function funnel_height(ch) = fun_neck + ch + fun_collar;

// Frame: vertical plates [x0, x1] standing in tray slots, joined at both
// y ends by ties just under the riffle base. Placed with its bottom at
// z = tray_floor - slot_d. Pins on top of plates listed in pins.
module frame_part(plates, pins) {
    hp = z0 - (tray_floor - slot_d);
    xa = plates[0][0];
    xb = plates[len(plates) - 1][1];
    for (p = plates) translate([p[0], -plate_y, 0]) cube([p[1] - p[0], 2*plate_y, hp]);
    for (y = [-plate_y, plate_y - tie_w])
        translate([xa, y, hp - tie_t]) cube([xb - xa, tie_w, tie_t]);
    pins_at(pins, hp);
}

// Catch tray. inner box x0..x1, y = -tray_in_y..tray_in_y.
// slots: plate x ranges. notches: x ranges opened in the front and back
// walls so the active cups slide out. ribs: x ranges for the centre stop.
// pockets: [x, y] of parked spare cups (0.8 mm recess).
module tray_part(x0, x1, slots, notches, ribs, pockets) {
    difference() {
        translate([x0 - tray_wall, -tray_in_y - tray_wall, 0])
            cube([x1 - x0 + 2*tray_wall, 2*(tray_in_y + tray_wall), tray_h]);
        translate([x0, -tray_in_y, tray_floor]) cube([x1 - x0, 2*tray_in_y, tray_h]);
        for (s = slots)
            translate([s[0] - clear, -plate_y - clear, tray_floor - slot_d])
                cube([s[1] - s[0] + 2*clear, 2*(plate_y + clear), slot_d + 0.01]);
        for (n = notches)
            translate([n[0], -tray_in_y - tray_wall - 1, tray_floor])
                cube([n[1] - n[0], 2*(tray_in_y + tray_wall + 1), tray_h]);
        for (p = pockets)
            translate([p[0] - cup_w/2 - clear, p[1] - cup_d/2 - clear, tray_floor - slot_d])
                cube([cup_w + 2*clear, cup_d + 2*clear, slot_d + 0.01]);
    }
    for (r = ribs)
        translate([r[0], -(cup_gap/2 - clear), tray_floor - 0.01])
            cube([r[1] - r[0], cup_gap - 2*clear, rib_h]);
}

// 100 mm reference post for side renders.
module ruler100(x, y) {
    color([0.85, 0.15, 0.15]) translate([x, y, 0]) {
        cylinder(d=1.2, h=100);
        for (z = [0:10:100]) translate([0, 0, z]) cube([(z % 50 == 0) ? 8 : 4, 0.8, 0.6], center=true);
        translate([0, 0, 100]) cube([16, 0.8, 0.8], center=true);
    }
}
