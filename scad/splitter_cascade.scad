// =============================================================================
// Micropaleontology dry-sediment splitter — Jones-type two-stage CASCADE
// =============================================================================
// Lab-style quartering via two sequential 2-way splits (more accurate than a
// single-stage 4-way bank):
//   funnel → stage-1 L/R riffle → two stage-2 F/B riffles → four ACTIVE pans
//
// Kit: cascade (see also splitter_2way.scad, splitter_4way.scad). STLs: stl/cascade/
// PART: cup | catch_tray | frame | riffle_upper | riffle_lower | funnel
//       | assembly | exploded | side_view
// Print: cup ×4, riffle_lower ×2, one each of the rest. Do not print assembly.
// Units: mm.

/* [Part] */
PART = "assembly"; // ["cup","catch_tray","frame","riffle_upper","riffle_lower","funnel","assembly","exploded","side_view"]
/* [Orbit preview] */
ORBIT_DEG = 0;

wall = 2.6;
clear = 0.6;
$fn = 48;

// Catch tray — 2×2 active pans
tray_w = 300;
tray_d = 300;
tray_h = 30;
tray_t = 2.8;
tray_floor = 3.0;

// Hi-back pans (print 4 — all active); same geometry as 2-way / 4-way kits
cup_w = 100;
cup_d = 72;
cup_h = 50;
cup_t = 2.0;
cup_floor = 2.2;
cup_back = 20;

// Shared chute sizing
chute_w = 7.0;
vane_t = 2.0;
end_w = 4.0;

// Stage 1 (upper) — classic L/R 2-way
n1 = 12;
bank1_d = 60;
bank1_h = 55;
hood1 = 40;

// Stage 2 (lower) — F/B 2-way; print ×2
n2 = 8;
bank2_d = 52;
bank2_h = 50;
hood2 = 36;

// Funnel (top of stage 1)
funnel_w = 230;
funnel_d = 170;
funnel_rim = 10;
funnel_t = 2.4;
funnel_collar = 32;
funnel_cone = 75;

leg = 10;

// derived — stage 1
inner1 = n1 * chute_w + (n1 - 1) * vane_t;
outer1_w = inner1 + 2 * end_w;
outer1_d = bank1_d + 2 * wall;
throat1_w = inner1 - 2;
throat1_d = bank1_d - 6;

// derived — stage 2
inner2 = n2 * chute_w + (n2 - 1) * vane_t;
outer2_w = inner2 + 2 * end_w;
outer2_d = bank2_d + 2 * wall;
throat2_w = inner2 - 2;
throat2_d = bank2_d - 6;

// Lateral offset of each lower bank (under stage-1 L/R outlets)
lower_x = outer1_w/2 + hood1*0.35;

riffle_z_lower = tray_floor + cup_h + 10;
// Drop gap between stage-1 outlets and stage-2 open tops
stage_gap = 28;
riffle_z_upper = riffle_z_lower + bank2_h + stage_gap + 18;

// Four ACTIVE cups under stage-2 F/B outlets
function nests() = [
    [-(cup_w/2 + 18), -(cup_d/2 + 30)],  // A1 FRONT-LEFT  ← lower-left front
    [ (cup_w/2 + 18), -(cup_d/2 + 30)],  // B1 FRONT-RIGHT ← lower-right front
    [-(cup_w/2 + 18),  (cup_d/2 + 38)],  // A2 REAR-LEFT   ← lower-left rear
    [ (cup_w/2 + 18),  (cup_d/2 + 38)]   // B2 REAR-RIGHT  ← lower-right rear
];

// -----------------------------------------------------------------------------
module cup() {
    back = cup_d + cup_back;
    difference() {
        translate([-cup_w/2, -cup_d/2, 0])
            cube([cup_w, back, cup_h]);
        translate([-(cup_w - 2*cup_t)/2, -(cup_d - 2*cup_t)/2, cup_floor])
            cube([cup_w - 2*cup_t, back - 2*cup_t, cup_h]);
    }
}

module catch_tray() {
    ns = nests();
    labels = ["A1 FL", "B1 FR", "A2 RL", "B2 RR"];
    difference() {
        translate([-tray_w/2, -tray_d/2, 0])
            cube([tray_w, tray_d, tray_h]);
        translate([-(tray_w - 2*tray_t)/2, -(tray_d - 2*tray_t)/2, tray_floor])
            cube([tray_w - 2*tray_t, tray_d - 2*tray_t, tray_h]);
        for (p = ns) {
            translate([p[0]-(cup_w+1.2)/2, p[1]-(cup_d+1.2)/2, tray_floor-1])
                cube([cup_w+1.2, cup_d+cup_back+1.2, 1.2]);
        }
        for (i = [0:3]) {
            translate([ns[i][0], ns[i][1], tray_floor-1.3])
                linear_extrude(1)
                    text(labels[i], size=7,halign="center", valign="center",
                         font="Liberation Sans:style=Bold");
        }
    }
    translate([-(tray_w - 2*tray_t - 8)/2, -1.6, tray_floor])
        cube([tray_w - 2*tray_t - 8, 3.2, 10]);
    translate([-1.6, -(tray_d - 2*tray_t - 8)/2, tray_floor])
        cube([3.2, tray_d - 2*tray_t - 8, 10]);
}

module cradle_rails(ow, od, z) {
    for (sx=[-1,1]) {
        translate([
            sx * (ow/2 + 3) - (sx>0?0:14),
            -od/2 - 6,
            z
        ])
            cube([14, od + 18, 8]);
    }
    translate([-ow/2 - 14, -od/2 - 10, z])
        cube([ow + 28, 8, 8]);
    translate([-ow/2 - 14, od/2 + 2, z])
        cube([ow + 28, 8, 8]);
}

module frame() {
    z_top = riffle_z_upper + 6;
    difference() {
        union() {
            translate([-tray_w/2 + 8, -tray_d/2 + 8, 0])
                cube([tray_w - 16, tray_d - 16, 6]);

            for (sx=[-1,1], sy=[-1,1]) {
                translate([
                    sx * (tray_w/2 - 18) - (sx>0?0:leg),
                    sy * (tray_d/2 - 18) - (sy>0?0:leg),
                    0
                ])
                    cube([leg, leg, z_top]);
            }

            // Lower cradles (left + right stage-2 banks)
            for (sx=[-1,1]) {
                translate([sx * lower_x, 0, 0])
                    cradle_rails(outer2_w, outer2_d, riffle_z_lower);
            }

            // Upper cradle (stage-1 bank, centered)
            cradle_rails(outer1_w, outer1_d, riffle_z_upper);

            // Braces: legs → lower cradles
            for (sx=[-1,1], sy=[-1,1]) {
                hull() {
                    translate([
                        sx*(tray_w/2-18)-(sx>0?0:leg)+leg/2-2,
                        sy*(tray_d/2-18)-(sy>0?0:leg)+leg/2-2,
                        6
                    ]) cube([4,4,4]);
                    translate([sx*lower_x + sx*(outer2_w/4)-2, sy*(outer2_d/4), riffle_z_lower])
                        cube([4,4,4]);
                }
            }
            // Braces: lower → upper cradle
            for (sx=[-1,1]) {
                hull() {
                    translate([sx*lower_x - 2, 0, riffle_z_lower + 4])
                        cube([4,4,4]);
                    translate([sx*(outer1_w/2)-2, 0, riffle_z_upper])
                        cube([4,4,4]);
                }
            }
        }
        translate([-tray_w/2 + 20, -tray_d/2 + 20, -1])
            cube([tray_w - 40, tray_d - 40, 10]);
    }
}

// ---- Stage-1 L/R cavities ---------------------------------------------------
module chute1(i) {
    x = -inner1/2 + chute_w/2 + i*(chute_w + vane_t);
    left = (i % 2 == 0);
    dir = left ? -1 : 1;
    hull() {
        translate([x - chute_w/2, -bank1_d/2, bank1_h - 1])
            cube([chute_w, bank1_d, 2]);
        translate([
            x - chute_w/2 + dir*(outer1_w/2 + hood1*0.55),
            -bank1_d/2 + 3,
            -12
        ])
            cube([chute_w + 3, bank1_d - 6, 2]);
    }
}

module riffle_upper() {
    difference() {
        union() {
            translate([-outer1_w/2, -outer1_d/2, 0])
                cube([outer1_w, outer1_d, bank1_h]);
            for (sx=[-1,1]) {
                hull() {
                    translate([
                        sx*(outer1_w/2) - (sx>0?0:3),
                        -outer1_d/2,
                        bank1_h*0.4
                    ]) cube([3, outer1_d, 3]);
                    translate([
                        sx*(outer1_w/2 + hood1) - (sx>0?0:22),
                        -outer1_d/2 + 3,
                        -10
                    ]) cube([22, outer1_d - 6, 3]);
                }
            }
            translate([-(outer1_w + 28)/2, -outer1_d/2, 10])
                cube([outer1_w + 28, outer1_d, 6]);
            translate([-(throat1_w+10)/2, -(throat1_d+10)/2, bank1_h])
                cube([throat1_w+10, throat1_d+10, 7]);
        }
        translate([-inner1/2, -bank1_d/2, bank1_h - 8])
            cube([inner1, bank1_d, 20]);
        translate([-(throat1_w+clear)/2, -(throat1_d+clear)/2, bank1_h-1])
            cube([throat1_w+clear, throat1_d+clear, 12]);
        for (i=[0:n1-1]) chute1(i);
        translate([-outer1_w/2 - hood1 - 2, -bank1_d/2 + 4, -14])
            cube([outer1_w/2 + hood1 - 1, bank1_d - 8, 20]);
        translate([1, -bank1_d/2 + 4, -14])
            cube([outer1_w/2 + hood1 - 1, bank1_d - 8, 20]);
    }
}

// ---- Stage-2 F/B cavities ---------------------------------------------------
module chute2(i) {
    x = -inner2/2 + chute_w/2 + i*(chute_w + vane_t);
    front = (i % 2 == 0);
    dir = front ? -1 : 1;
    hull() {
        translate([x - chute_w/2, -bank2_d/2, bank2_h - 1])
            cube([chute_w, bank2_d, 2]);
        translate([
            x - chute_w/2 - 1.5,
            dir > 0 ? bank2_d/2 + hood2*0.35 : -bank2_d/2 - hood2*0.55,
            -12
        ])
            cube([chute_w + 3, max(bank2_d - 10, 16), 2]);
    }
}

module riffle_lower() {
    difference() {
        union() {
            translate([-outer2_w/2, -outer2_d/2, 0])
                cube([outer2_w, outer2_d, bank2_h]);
            // Front / rear hoods
            for (sy=[-1,1]) {
                hull() {
                    translate([
                        -outer2_w/2,
                        sy*(outer2_d/2) - (sy>0?0:3),
                        bank2_h*0.4
                    ]) cube([outer2_w, 3, 3]);
                    translate([
                        -outer2_w/2 + 4,
                        sy*(outer2_d/2 + hood2) - (sy>0?0:18),
                        -10
                    ]) cube([outer2_w - 8, 18, 3]);
                }
            }
            translate([-(outer2_w + 28)/2, -outer2_d/2, 10])
                cube([outer2_w + 28, outer2_d, 6]);
            // Open top socket receives stage-1 stream (no separate mid funnel)
            translate([-(throat2_w+10)/2, -(throat2_d+10)/2, bank2_h])
                cube([throat2_w+10, throat2_d+10, 10]);
        }
        translate([-inner2/2, -bank2_d/2, bank2_h - 8])
            cube([inner2, bank2_d, 24]);
        translate([-(throat2_w+clear)/2, -(throat2_d+clear)/2, bank2_h-1])
            cube([throat2_w+clear, throat2_d+clear, 16]);
        for (i=[0:n2-1]) chute2(i);
        // Underside open under F/B hoods
        translate([-outer2_w/2 + 2, -bank2_d/2 - hood2 - 2, -14])
            cube([outer2_w - 4, bank2_d/2 + hood2 - 1, 20]);
        translate([-outer2_w/2 + 2, 1, -14])
            cube([outer2_w - 4, bank2_d/2 + hood2 - 1, 20]);
    }
}

module funnel() {
    // Sized to stage-1 throat
    tw = throat1_w;
    td = throat1_d;
    difference() {
        union() {
            translate([-(funnel_w+2*funnel_rim)/2, -(funnel_d+2*funnel_rim)/2, funnel_cone])
                cube([funnel_w+2*funnel_rim, funnel_d+2*funnel_rim, funnel_collar]);
            hull() {
                translate([-(funnel_w+2*funnel_rim-6)/2, -(funnel_d+2*funnel_rim-6)/2, funnel_cone])
                    cube([funnel_w+2*funnel_rim-6, funnel_d+2*funnel_rim-6, 1]);
                translate([-(tw+2*funnel_t)/2, -(td+2*funnel_t)/2, 0])
                    cube([tw+2*funnel_t, td+2*funnel_t, 1]);
            }
            translate([-tw/2, -td/2, -16])
                cube([tw, td, 17]);
        }
        translate([-(funnel_w-2*funnel_t)/2, -(funnel_d-2*funnel_t)/2, funnel_cone-0.1])
            cube([funnel_w-2*funnel_t, funnel_d-2*funnel_t, funnel_collar+2]);
        hull() {
            translate([-(funnel_w-2*funnel_t-6)/2, -(funnel_d-2*funnel_t-6)/2, funnel_cone])
                cube([funnel_w-2*funnel_t-6, funnel_d-2*funnel_t-6, 1.2]);
            translate([-(tw-2*funnel_t)/2, -(td-2*funnel_t)/2, 0])
                cube([tw-2*funnel_t, td-2*funnel_t, 1.2]);
        }
        translate([-(tw-2*funnel_t)/2, -(td-2*funnel_t)/2, -17])
            cube([tw-2*funnel_t, td-2*funnel_t, 20]);
    }
}

module assembly() {
    ns = nests();
    color([0.42,0.45,0.50]) catch_tray();
    color([0.50,0.52,0.55]) translate([0,0,tray_floor]) frame();
    color([0.95,0.75,0.15]) translate([ns[0][0], ns[0][1], tray_floor+0.5]) cup();
    color([0.25,0.60,0.90]) translate([ns[1][0], ns[1][1], tray_floor+0.5]) cup();
    color([0.93,0.52,0.22]) translate([ns[2][0], ns[2][1], tray_floor+0.5]) cup();
    color([0.42,0.72,0.42]) translate([ns[3][0], ns[3][1], tray_floor+0.5]) cup();
    // Stage-2 banks under L/R stage-1 streams
    color([0.55,0.58,0.62])
        translate([-lower_x, 0, riffle_z_lower+8]) riffle_lower();
    color([0.55,0.58,0.62])
        translate([ lower_x, 0, riffle_z_lower+8]) riffle_lower();
    // Stage-1
    color([0.60,0.60,0.64])
        translate([0, 0, riffle_z_upper+8]) riffle_upper();
    color([0.38,0.52,0.78])
        translate([0, 0, riffle_z_upper+8+bank1_h+7]) funnel();
}

module exploded() {
    ns = nests();
    color([0.42,0.45,0.50]) catch_tray();
    color([0.50,0.52,0.55]) translate([0,0,40]) frame();
    cols=[[0.93,0.78,0.22],[0.30,0.62,0.82],[0.93,0.52,0.22],[0.42,0.72,0.42]];
    for (i=[0:3]) color(cols[i]) translate([ns[i][0], ns[i][1], 70]) cup();
    color([0.55,0.58,0.62]) translate([-lower_x, 0, 160]) riffle_lower();
    color([0.55,0.58,0.62]) translate([ lower_x, 0, 160]) riffle_lower();
    color([0.60,0.60,0.64]) translate([0, 0, 260]) riffle_upper();
    color([0.38,0.52,0.78]) translate([0, 0, 360]) funnel();
}

module side_view() {
    rotate([0, 0, 90]) assembly();
}

if (PART=="cup") cup();
else if (PART=="catch_tray") catch_tray();
else if (PART=="frame") frame();
else if (PART=="riffle_upper") riffle_upper();
else if (PART=="riffle_lower") riffle_lower();
else if (PART=="funnel") funnel();
else if (PART=="exploded") exploded();
else if (PART=="side_view") side_view();
else rotate([0, 0, ORBIT_DEG]) assembly();
