// Side-by-side: the first 2-way print (256 mm plate version, left) and the
// compact brass-style 2-way (right), same scale, with a 100 mm post.
// Needs the compact STLs in stl/2way/ (run scripts/build_stls.sh first).
use <legacy/splitter_2way_256mm.scad>
use <splitter_lib.scad>

z0 = 28.1;
module new2way() {
    color([0.42, 0.45, 0.50]) import("../stl/2way/catch_tray.stl");
    color([0.55, 0.57, 0.60]) translate([0, 0, 1.2]) import("../stl/2way/frame.stl");
    color([0.95, 0.75, 0.15]) translate([0, -21, 2]) import("../stl/2way/cup.stl");
    color([0.25, 0.60, 0.90]) translate([0, 21, 2]) rotate([0, 0, 180]) import("../stl/2way/cup.stl");
    color([0.80, 0.74, 0.55]) translate([51.5, -21, 1.2]) import("../stl/2way/cup.stl");
    color([0.70, 0.74, 0.70]) translate([51.5, 21, 1.2]) rotate([0, 0, 180]) import("../stl/2way/cup.stl");
    color([0.78, 0.62, 0.30]) translate([0, 0, z0]) import("../stl/2way/riffle.stl");
    color([0.85, 0.70, 0.35]) translate([0, 0, z0 + 24]) import("../stl/2way/funnel.stl");
}
translate([-140, 0, 0]) assembly();
translate([150, 0, 0]) new2way();
ruler100(225, 0);
ruler100(-280, 0);
