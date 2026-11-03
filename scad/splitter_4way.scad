// =============================================================================
// Micropaleontology dry-sediment splitter — Jones-type 4-way riffle
// =============================================================================
// True simultaneous quartering (1:1:1:1):
//   large hopper → 16-chute vane bank (i%4) → four corner discharges
//   → four ACTIVE pans (A1/B1/A2/B2) in a spill tray + open stand.
//
// Kit: 4-way (see also splitter_2way.scad). STLs: stl/4way/
// PART: cup | catch_tray | frame | riffle | funnel | assembly | exploded
// Print cup ×4 (all active). Do not print assembly/exploded.
// Units: mm.

/* [Part] */
PART = "assembly"; // ["cup","catch_tray","frame","riffle","funnel","assembly","exploded","side_view"]
/* [Orbit preview] */
ORBIT_DEG = 0;

wall = 2.6;
clear = 0.6;
$fn = 48;

// Catch tray — square enough for 2×2 active pans
tray_w = 300;
tray_d = 300;
tray_h = 30;
tray_t = 2.8;
tray_floor = 3.0;

// Hi-back pans (print 4 — all active)
cup_w = 100;
cup_d = 72;
cup_h = 50;
cup_t = 2.0;
cup_floor = 2.2;
cup_back = 20;

// Jones 4-way riffle bank (multiple of 4 for equal quarters)
n_chutes = 16;
chute_w = 7.0;
vane_t = 2.0;
bank_d = 60;
bank_h = 55;
end_w = 4.0;
hood_reach = 42;     // corner discharge overhang

// Funnel
funnel_w = 230;
funnel_d = 170;
funnel_rim = 10;
funnel_t = 2.4;
funnel_collar = 32;
funnel_cone = 75;

// Frame
leg = 10;

// derived
inner_w = n_chutes * chute_w + (n_chutes - 1) * vane_t;
outer_w = inner_w + 2 * end_w;
outer_d = bank_d + 2 * wall;
throat_w = inner_w - 2;
throat_d = bank_d - 6;

riffle_z = tray_floor + cup_h + 10;

// Four ACTIVE cups under the four corner outlets (true 4-way).
function nests() = [
    [-(cup_w/2 + 18), -(cup_d/2 + 30)],  // A1 FRONT-LEFT
    [ (cup_w/2 + 18), -(cup_d/2 + 30)],  // B1 FRONT-RIGHT
    [-(cup_w/2 + 18),  (cup_d/2 + 38)],  // A2 REAR-LEFT
    [ (cup_w/2 + 18),  (cup_d/2 + 38)]   // B2 REAR-RIGHT
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
                    text(labels[i], size=7, halign="center", valign="center",
                         font="Liberation Sans:style=Bold");
        }
    }
    // Light cross guides between the four active wells (not a spare bay)
    translate([-(tray_w - 2*tray_t - 8)/2, -1.6, tray_floor])
        cube([tray_w - 2*tray_t - 8, 3.2, 10]);
    translate([-1.6, -(tray_d - 2*tray_t - 8)/2, tray_floor])
        cube([3.2, tray_d - 2*tray_t - 8, 10]);
}

module frame() {
    z_top = riffle_z + 6;
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

            // top cradle rails (L/R)
            for (sx=[-1,1]) {
                translate([
                    sx * (outer_w/2 + 3) - (sx>0?0:14),
                    -outer_d/2 - 6,
                    riffle_z
                ])
                    cube([14, outer_d + 18, 8]);
            }
            // front + rear crossbars
            translate([-outer_w/2 - 14, -outer_d/2 - 10, riffle_z])
                cube([outer_w + 28, 8, 8]);
            translate([-outer_w/2 - 14, outer_d/2 + 2, riffle_z])
                cube([outer_w + 28, 8, 8]);

            // braces from all four legs up toward cradle
            for (sx=[-1,1], sy=[-1,1]) {
                hull() {
                    translate([
                        sx*(tray_w/2-18)-(sx>0?0:leg)+leg/2-2,
                        sy*(tray_d/2-18)-(sy>0?0:leg)+leg/2-2,
                        6
                    ]) cube([4,4,4]);
                    translate([sx*(outer_w/2)-2, sy*(outer_d/4), riffle_z])
                        cube([4,4,4]);
                }
            }
        }
        translate([-tray_w/2 + 20, -tray_d/2 + 20, -1])
            cube([tray_w - 40, tray_d - 40, 10]);
    }
}

// Corner target for chute i%4: 0=FL, 1=FR, 2=RL, 3=RR
function chute_out_x(i, x) =
    let(d = i % 4)
    (d == 0 || d == 2)
        ? x - chute_w/2 - (outer_w/2 + hood_reach*0.55)
        : x - chute_w/2 + (outer_w/2 + hood_reach*0.55);

function chute_out_y(i) =
    let(d = i % 4)
    (d == 0 || d == 1)
        ? -bank_d/2 - hood_reach*0.45
        :  bank_d/2 + hood_reach*0.45;

module chute_cavity(i) {
    // Parallelepiped: top slot → lean out to one of four corner discharges
    x = -inner_w/2 + chute_w/2 + i*(chute_w + vane_t);
    hull() {
        translate([x - chute_w/2, -bank_d/2, bank_h - 1])
            cube([chute_w, bank_d, 2]);
        translate([
            chute_out_x(i, x),
            chute_out_y(i),
            -12
        ])
            cube([chute_w + 3, max(bank_d - 10, 18), 2]);
    }
}

module corner_hood(sx, sy) {
    // sx,sy in {-1,1}: hood pointing toward that corner
    hull() {
        translate([
            sx*(outer_w/2) - (sx>0?0:3),
            sy*(outer_d/2) - (sy>0?0:3),
            bank_h*0.4
        ]) cube([3, 3, 3]);
        translate([
            sx*(outer_w/2 + hood_reach) - (sx>0?0:22),
            sy*(outer_d/2 + hood_reach*0.55) - (sy>0?0:18),
            -10
        ]) cube([22, 18, 3]);
    }
}

module riffle() {
    difference() {
        union() {
            translate([-outer_w/2, -outer_d/2, 0])
                cube([outer_w, outer_d, bank_h]);

            // Four corner hoods (Jones-style, quartering)
            for (sx=[-1,1], sy=[-1,1])
                corner_hood(sx, sy);

            // flanges for frame rails
            translate([-(outer_w + 28)/2, -outer_d/2, 10])
                cube([outer_w + 28, outer_d, 6]);

            // funnel socket
            translate([-(throat_w+10)/2, -(throat_d+10)/2, bank_h])
                cube([throat_w+10, throat_d+10, 7]);
        }

        // open top feed pocket
        translate([-inner_w/2, -bank_d/2, bank_h - 8])
            cube([inner_w, bank_d, 20]);

        // funnel sleeve pocket
        translate([-(throat_w+clear)/2, -(throat_d+clear)/2, bank_h-1])
            cube([throat_w+clear, throat_d+clear, 12]);

        // four-way chute cavities
        for (i=[0:n_chutes-1]) chute_cavity(i);

        // open underside under each corner hood so pans receive freely
        for (sx=[-1,1], sy=[-1,1]) {
            translate([
                sx>0 ? 1 : -outer_w/2 - hood_reach - 2,
                sy>0 ? 1 : -bank_d/2 - hood_reach*0.55,
                -14
            ])
                cube([
                    outer_w/2 + hood_reach - 1,
                    bank_d/2 + hood_reach*0.55 - 1,
                    20
                ]);
        }
    }
}

module funnel() {
    difference() {
        union() {
            translate([-(funnel_w+2*funnel_rim)/2, -(funnel_d+2*funnel_rim)/2, funnel_cone])
                cube([funnel_w+2*funnel_rim, funnel_d+2*funnel_rim, funnel_collar]);
            hull() {
                translate([-(funnel_w+2*funnel_rim-6)/2, -(funnel_d+2*funnel_rim-6)/2, funnel_cone])
                    cube([funnel_w+2*funnel_rim-6, funnel_d+2*funnel_rim-6, 1]);
                translate([-(throat_w+2*funnel_t)/2, -(throat_d+2*funnel_t)/2, 0])
                    cube([throat_w+2*funnel_t, throat_d+2*funnel_t, 1]);
            }
            translate([-throat_w/2, -throat_d/2, -16])
                cube([throat_w, throat_d, 17]);
        }
        translate([-(funnel_w-2*funnel_t)/2, -(funnel_d-2*funnel_t)/2, funnel_cone-0.1])
            cube([funnel_w-2*funnel_t, funnel_d-2*funnel_t, funnel_collar+2]);
        hull() {
            translate([-(funnel_w-2*funnel_t-6)/2, -(funnel_d-2*funnel_t-6)/2, funnel_cone])
                cube([funnel_w-2*funnel_t-6, funnel_d-2*funnel_t-6, 1.2]);
            translate([-(throat_w-2*funnel_t)/2, -(throat_d-2*funnel_t)/2, 0])
                cube([throat_w-2*funnel_t, throat_d-2*funnel_t, 1.2]);
        }
        translate([-(throat_w-2*funnel_t)/2, -(throat_d-2*funnel_t)/2, -17])
            cube([throat_w-2*funnel_t, throat_d-2*funnel_t, 20]);
    }
}

module assembly() {
    ns = nests();
    color([0.42,0.45,0.50]) catch_tray();
    color([0.50,0.52,0.55]) translate([0,0,tray_floor]) frame();
    // All four pans active under corner outlets
    color([0.95,0.75,0.15]) translate([ns[0][0], ns[0][1], tray_floor+0.5]) cup(); // A1
    color([0.25,0.60,0.90]) translate([ns[1][0], ns[1][1], tray_floor+0.5]) cup(); // B1
    color([0.93,0.52,0.22]) translate([ns[2][0], ns[2][1], tray_floor+0.5]) cup(); // A2
    color([0.42,0.72,0.42]) translate([ns[3][0], ns[3][1], tray_floor+0.5]) cup(); // B2
    color([0.60,0.60,0.64])
        translate([0, 0, riffle_z+8]) riffle();
    color([0.38,0.52,0.78])
        translate([0, 0, riffle_z+8+bank_h+7]) funnel();
}

module exploded() {
    ns = nests();
    color([0.42,0.45,0.50]) catch_tray();
    color([0.50,0.52,0.55]) translate([0,0,30]) frame();
    cols=[[0.93,0.78,0.22],[0.30,0.62,0.82],[0.93,0.52,0.22],[0.42,0.72,0.42]];
    for (i=[0:3]) color(cols[i]) translate([ns[i][0], ns[i][1], 55]) cup();
    color([0.60,0.60,0.64]) translate([0,0,150]) riffle();
    color([0.38,0.52,0.78]) translate([0,0,250]) funnel();
}

module side_view() {
    rotate([0, 0, 90]) assembly();
}

if (PART=="cup") cup();
else if (PART=="catch_tray") catch_tray();
else if (PART=="frame") frame();
else if (PART=="riffle") riffle();
else if (PART=="funnel") funnel();
else if (PART=="exploded") exploded();
else if (PART=="side_view") side_view();
else rotate([0, 0, ORBIT_DEG]) assembly();
