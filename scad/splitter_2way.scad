// =============================================================================
// Micropaleontology dry-sediment splitter — Jones-type 2-way riffle
// =============================================================================
// Classic lab silhouette:
//   large hopper → alternating /\/\/\ vane bank → L/R discharge
//   → removable pans in a spill tray, held by an open stand.
//
// Kit: 2-way (see also splitter_4way.scad). STLs: stl/2way/
// PART: cup | catch_tray | frame | riffle | funnel | assembly | exploded
// Print cup ×4. Do not print assembly/exploded.
// Units: mm.

/* [Part] */
PART = "assembly"; // ["cup","catch_tray","frame","riffle","funnel","assembly","exploded","side_view"]
/* [Orbit preview] */
ORBIT_DEG = 0; // used by walkthrough frame script

wall = 2.6;
clear = 0.6;
$fn = 48;

// Catch tray (close to original 260×210 base)
tray_w = 260;
tray_d = 210;
tray_h = 30;
tray_t = 2.8;
tray_floor = 3.0;

// Hi-back pans (print 4)
cup_w = 100;
cup_d = 72;
cup_h = 50;
cup_t = 2.0;
cup_floor = 2.2;
cup_back = 20;

// Jones riffle bank
n_chutes = 12;       // even
chute_w = 7.0;
vane_t = 2.0;
bank_d = 60;
bank_h = 55;
end_w = 4.0;
hood_reach = 36;     // side discharge overhang

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

// ONLY two cups sit under the L/R outlets (true 2-way).
// The other two park in a rear STORAGE bay — not under any chute.
function nests() = [
    [-(cup_w/2 + 10), -28],  // A1 ACTIVE left  ← receives LEFT stream
    [ (cup_w/2 + 10), -28],  // B1 ACTIVE right ← receives RIGHT stream
    [-(cup_w/2 + 10),  85],  // A2 SPARE (storage only)
    [ (cup_w/2 + 10),  85]   // B2 SPARE (storage only)
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
    difference() {
        translate([-tray_w/2, -tray_d/2, 0])
            cube([tray_w, tray_d, tray_h]);
        translate([-(tray_w - 2*tray_t)/2, -(tray_d - 2*tray_t)/2, tray_floor])
            cube([tray_w - 2*tray_t, tray_d - 2*tray_t, tray_h]);
        for (p = ns) {
            translate([p[0]-(cup_w+1.2)/2, p[1]-(cup_d+1.2)/2, tray_floor-1])
                cube([cup_w+1.2, cup_d+cup_back+1.2, 1.2]);
        }
        // Active labels under outlets
        translate([ns[0][0], ns[0][1], tray_floor-1.3])
            linear_extrude(1)
                text("A1 LEFT", size=7, halign="center", valign="center",
                     font="Liberation Sans:style=Bold");
        translate([ns[1][0], ns[1][1], tray_floor-1.3])
            linear_extrude(1)
                text("B1 RIGHT", size=7, halign="center", valign="center",
                     font="Liberation Sans:style=Bold");
        // Spare labels
        translate([ns[2][0], ns[2][1], tray_floor-1.3])
            linear_extrude(1)
                text("A2 SPARE", size=7, halign="center", valign="center",
                     font="Liberation Sans:style=Bold");
        translate([ns[3][0], ns[3][1], tray_floor-1.3])
            linear_extrude(1)
                text("B2 SPARE", size=7, halign="center", valign="center",
                     font="Liberation Sans:style=Bold");
    }
    // Divider wall: ACTIVE zone (front) vs STORAGE bay (rear)
    // Makes clear this is NOT a 4-way / 4-compartment splitter.
    translate([-(tray_w - 2*tray_t - 8)/2, 28, tray_floor])
        cube([tray_w - 2*tray_t - 8, 3.2, 18]);
    // Simple block labels (avoid glyph explosion / disconnected bodies)
    translate([-55, 40, tray_floor])
        cube([110, 8, 6]);   // spare-bay marker bar
    translate([-70, -82, tray_floor])
        cube([140, 8, 6]);   // active-bay marker bar
}


module frame() {
    // One connected stand: legs + skirt ties + top cradle
    z_top = riffle_z + 6;
    difference() {
        union() {
            // perimeter skirt tied to legs (keeps single body)
            translate([-tray_w/2 + 8, -tray_d/2 + 8, 0])
                cube([tray_w - 16, tray_d - 16, 6]);

            // corner legs
            for (sx=[-1,1], sy=[-1,1]) {
                translate([
                    sx * (tray_w/2 - 18) - (sx>0?0:leg),
                    sy * (tray_d/2 - 18) - (sy>0?0:leg),
                    0
                ])
                    cube([leg, leg, z_top]);
            }

            // top cradle rails (L/R) — riffle flanges sit here
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

            // braces from front legs up to cradle
            for (sx=[-1,1]) {
                hull() {
                    translate([
                        sx*(tray_w/2-18)-(sx>0?0:leg)+leg/2-2,
                        -(tray_d/2-18),
                        6
                    ]) cube([4,4,4]);
                    translate([sx*(outer_w/2)-2, -outer_d/2, riffle_z])
                        cube([4,4,4]);
                }
            }
        }
        // open the skirt interior so pans fit (only keep a rim)
        translate([-tray_w/2 + 20, -tray_d/2 + 20, -1])
            cube([tray_w - 40, tray_d - 40, 10]);
    }
}

module chute_cavity(i) {
    // Parallelepiped channel: top slot → lean out L or R to discharge
    x = -inner_w/2 + chute_w/2 + i*(chute_w + vane_t);
    left = (i % 2 == 0);
    dir = left ? -1 : 1;
    hull() {
        // inlet at top of bank
        translate([x - chute_w/2, -bank_d/2, bank_h - 1])
            cube([chute_w, bank_d, 2]);
        // outlet toward one side, below bank floor
        translate([
            x - chute_w/2 + dir*(outer_w/2 + hood_reach*0.55),
            -bank_d/2 + 3,
            -12
        ])
            cube([chute_w + 3, bank_d - 6, 2]);
    }
}

module riffle() {
    // Single body: solid housing + hoods, cavities cut as alternating channels
    difference() {
        union() {
            // main bank block
            translate([-outer_w/2, -outer_d/2, 0])
                cube([outer_w, outer_d, bank_h]);

            // A-frame side hoods (iconic Jones side profile)
            for (sx=[-1,1]) {
                hull() {
                    translate([
                        sx*(outer_w/2) - (sx>0?0:3),
                        -outer_d/2,
                        bank_h*0.4
                    ]) cube([3, outer_d, 3]);
                    translate([
                        sx*(outer_w/2 + hood_reach) - (sx>0?0:22),
                        -outer_d/2 + 3,
                        -10
                    ]) cube([22, outer_d - 6, 3]);
                }
            }

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

        // alternating chute cavities (= the vanes are the solid left between cuts)
        for (i=[0:n_chutes-1]) chute_cavity(i);

        // open underside L/R under hoods so pans receive freely
        translate([-outer_w/2 - hood_reach - 2, -bank_d/2 + 4, -14])
            cube([outer_w/2 + hood_reach - 1, bank_d - 8, 20]);
        translate([1, -bank_d/2 + 4, -14])
            cube([outer_w/2 + hood_reach - 1, bank_d - 8, 20]);
    }
}

module funnel() {
    // Single connected shell: collar thickened outward (no floating lip)
    difference() {
        union() {
            // thick-walled collar (outer includes rim)
            translate([-(funnel_w+2*funnel_rim)/2, -(funnel_d+2*funnel_rim)/2, funnel_cone])
                cube([funnel_w+2*funnel_rim, funnel_d+2*funnel_rim, funnel_collar]);
            // cone
            hull() {
                translate([-(funnel_w+2*funnel_rim-6)/2, -(funnel_d+2*funnel_rim-6)/2, funnel_cone])
                    cube([funnel_w+2*funnel_rim-6, funnel_d+2*funnel_rim-6, 1]);
                translate([-(throat_w+2*funnel_t)/2, -(throat_d+2*funnel_t)/2, 0])
                    cube([throat_w+2*funnel_t, throat_d+2*funnel_t, 1]);
            }
            // sleeve
            translate([-throat_w/2, -throat_d/2, -16])
                cube([throat_w, throat_d, 17]);
        }
        // hollow collar
        translate([-(funnel_w-2*funnel_t)/2, -(funnel_d-2*funnel_t)/2, funnel_cone-0.1])
            cube([funnel_w-2*funnel_t, funnel_d-2*funnel_t, funnel_collar+2]);
        // hollow cone
        hull() {
            translate([-(funnel_w-2*funnel_t-6)/2, -(funnel_d-2*funnel_t-6)/2, funnel_cone])
                cube([funnel_w-2*funnel_t-6, funnel_d-2*funnel_t-6, 1.2]);
            translate([-(throat_w-2*funnel_t)/2, -(throat_d-2*funnel_t)/2, 0])
                cube([throat_w-2*funnel_t, throat_d-2*funnel_t, 1.2]);
        }
        // sleeve bore
        translate([-(throat_w-2*funnel_t)/2, -(throat_d-2*funnel_t)/2, -17])
            cube([throat_w-2*funnel_t, throat_d-2*funnel_t, 20]);
    }
}

module assembly() {
    ns = nests();
    color([0.42,0.45,0.50]) catch_tray();
    color([0.50,0.52,0.55]) translate([0,0,tray_floor]) frame();
    // Active pans under L/R outlets (bright)
    color([0.95,0.75,0.15]) translate([ns[0][0], ns[0][1], tray_floor+0.5]) cup(); // A1
    color([0.25,0.60,0.90]) translate([ns[1][0], ns[1][1], tray_floor+0.5]) cup(); // B1
    // Spare pans in rear storage (muted — not in the split path)
    color([0.75,0.70,0.55]) translate([ns[2][0], ns[2][1], tray_floor+0.5]) cup(); // A2
    color([0.70,0.72,0.68]) translate([ns[3][0], ns[3][1], tray_floor+0.5]) cup(); // B2
    color([0.60,0.60,0.64])
        translate([0, -28, riffle_z+8]) riffle();
    color([0.38,0.52,0.78])
        translate([0, -28, riffle_z+8+bank_h+7]) funnel();
}

module exploded() {
    ns = nests();
    color([0.42,0.45,0.50]) catch_tray();
    color([0.50,0.52,0.55]) translate([0,0,30]) frame();
    cols=[[0.93,0.78,0.22],[0.30,0.62,0.82],[0.93,0.52,0.22],[0.42,0.72,0.42]];
    for (i=[0:3]) color(cols[i]) translate([ns[i][0], ns[i][1], 55]) cup();
    color([0.60,0.60,0.64]) translate([0,-22,150]) riffle();
    color([0.38,0.52,0.78]) translate([0,-22,250]) funnel();
}

module side_view() {
    // Rotate so OpenSCAD default camera shows the classic A-frame profile
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
