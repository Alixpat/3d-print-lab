// Universal pole mount system — two-piece modular bracket for Ø145 mm pole
//
// Part A (base): tapered arc clamped to the pole by two Ø141-165mm worm-drive
//                hose clamps (band width 12mm, e.g. Caianwin). Carries a
//                38×38mm interface platform with 4× M5 heat-set inserts.
//                Independent of the accessory carried by Part B.
//
// Part B (mount): accessory fixation. This file's variant: SO-239 / PL-259
//                 chassis mount for an antenna. Bolts onto Part A with 4× M5×20
//                 stainless socket-head screws.
//
// Other Part B variants: design a new Part B respecting the [Interface]
// constants below (back plate 38×38×8, 4× M5 holes on 24mm square PCD,
// Ø9.5 counterbore on the front face).

/* [Render] */
part = "preview"; // [preview, exploded, base, mount]

/* [Pole] */
pole_d            = 145;

/* [Bracket arc — Part A] */
bracket_arc_angle = 80;    // angular coverage (degrees)
bracket_thick_max = 10;    // radial thickness at center (locked: insert spec)
bracket_thick_min = 2;     // radial thickness at lateral edges
bracket_h         = 80;    // reduced from 90 — 2 clamps ~56mm apart give enough grip
taper_steps       = 48;

/* [Hose clamp grooves — Part A] */
groove_w          = 14;    // band 12mm + 2mm total clearance
groove_depth      = 2.5;
groove_z_offset   = 12;    // tighter spacing for shorter bracket

/* [Interface — Part A ↔ Part B] */
iface_size              = 38;    // reduced from 40
iface_thick             = 8;     // back-plate thickness; 4mm lip under bolt head
iface_inner_overlap     = 8;     // platform depth into bracket
iface_bolt_pcd          = 24;    // wall to platform edge 3.8mm (> 2.6 min)
iface_insert_d          = 6.4;   // HANGLIFE M5 OD 7 insert hole
iface_insert_h          = 12;    // insert 7mm + 5mm clearance so M5×20 fits exactly
iface_bolt_thru_d       = 5.5;
iface_bolt_cbore_d      = 9.5;
iface_bolt_cbore_h      = 4;

/* [Antenna arm — Part B] */
arm_length        = 70;
arm_width         = iface_size;  // aligned with back plate (no visible step)
arm_thick         = 10;          // SF 2.9 for whip in 100 km/h wind
transition_len    = 12;          // tapered blend from back plate (38 tall) to arm (10 tall)
gusset_size       = 12;          // kept as fallback param (unused with taper)

/* [SO-239 mount pad — Part B] */
so239_pad_size    = iface_size;  // same width as arm (continuous look)
so239_pad_extra   = 0;           // pad same thickness as arm (no Z step)
so239_hole_d      = 17;
so239_bolt_d      = 3.5;
so239_bolt_pcd    = 19;

/* [Edge chamfers — applied to outer edges only] */
chamfer_r         = 0.8;         // rounded chamfer radius on outer edges (mm)

$fn = 96;

// ---- Derived ----
pole_r        = pole_d / 2;
outer_r_max   = pole_r + bracket_thick_max;
outer_r_min   = pole_r + bracket_thick_min;
iface_outer_y = outer_r_max + iface_thick;
iface_inner_y = outer_r_max - iface_inner_overlap;
center_z      = bracket_h / 2;

// =====================================================
// PART A — pole base (tapered bracket + interface platform)
// =====================================================

function r_outer_at(theta) =
    pole_r + bracket_thick_min
           + (bracket_thick_max - bracket_thick_min)
             * sin(180 * (theta + bracket_arc_angle/2) / bracket_arc_angle);

function inner_pt(theta) = [-pole_r * sin(theta), pole_r * cos(theta)];
function outer_pt(theta) = [-r_outer_at(theta) * sin(theta), r_outer_at(theta) * cos(theta)];

module bracket_cross_section() {
    polygon(concat(
        [for (i = [0:taper_steps])
            outer_pt(-bracket_arc_angle/2 + bracket_arc_angle * i / taper_steps)],
        [for (i = [0:taper_steps])
            inner_pt( bracket_arc_angle/2 - bracket_arc_angle * i / taper_steps)]
    ));
}

module bracket_body() {
    linear_extrude(height = bracket_h)
        bracket_cross_section();
}

module groove(z_pos) {
    translate([0, 0, z_pos - groove_w/2])
        difference() {
            cylinder(h = groove_w, r = outer_r_max + 1);
            translate([0, 0, -1])
                cylinder(h = groove_w + 2, r = outer_r_max - groove_depth);
        }
}

module both_grooves() {
    groove(groove_z_offset);
    groove(bracket_h - groove_z_offset);
}

module iface_platform() {
    translate([-iface_size/2, iface_inner_y, center_z - iface_size/2])
        cube([iface_size, iface_outer_y - iface_inner_y, iface_size]);
}

module iface_insert_holes() {
    for (sx = [-1, 1])
        for (sz = [-1, 1])
            translate([sx * iface_bolt_pcd/2,
                       iface_outer_y + 0.1,
                       center_z + sz * iface_bolt_pcd/2])
                rotate([90, 0, 0])
                    cylinder(d = iface_insert_d, h = iface_insert_h + 0.5);
}

// Outer geometry chamfered via minkowski with a small sphere, then the front
// (mating) face is re-flattened by clipping at Y = iface_outer_y.  Holes are
// subtracted AFTER chamfering so they keep their nominal size.
module part_A() {
    difference() {
        intersection() {
            minkowski() {
                union() {
                    bracket_body();
                    iface_platform();
                }
                sphere(r = chamfer_r, $fn = 12);
            }
            // Clip the front face (Y ≤ iface_outer_y) — keeps the mating
            // plane flat and sharp where it touches Part B.
            translate([-300, -300, -300])
                cube([600, iface_outer_y + 300, 600]);
        }
        both_grooves();
        iface_insert_holes();
    }
}

// =====================================================
// PART B — antenna mount (SO-239)
// Local coords: back face at Y=0, extends in +Y.
// When assembled: translate by (0, iface_outer_y, 0).
// =====================================================

module iface_back_plate() {
    translate([-iface_size/2, 0, center_z - iface_size/2])
        cube([iface_size, iface_thick, iface_size]);
}

module iface_thru_holes() {
    // Bolt inserted from the FRONT (antenna side) of Part B:
    //   - Ø5.5 through-hole spans the whole plate
    //   - Ø9.5 counterbore on the FRONT face for the M5 cap head, extending
    //     forward through any gusset/arm material so the head can be inserted.
    for (sx = [-1, 1])
        for (sz = [-1, 1]) {
            x = sx * iface_bolt_pcd/2;
            z = center_z + sz * iface_bolt_pcd/2;
            // Through-hole (full back-plate thickness)
            translate([x, -0.1, z])
                rotate([-90, 0, 0])
                    cylinder(d = iface_bolt_thru_d, h = iface_thick + 2);
            // Counterbore: 4mm into back plate + clearance forward through
            // any front-side material (e.g. the gusset for the bottom bolts).
            translate([x, iface_thick - iface_bolt_cbore_h, z])
                rotate([-90, 0, 0])
                    cylinder(d = iface_bolt_cbore_d,
                             h = iface_bolt_cbore_h + gusset_size + 2);
        }
}

// Symmetric taper from back plate (iface_size tall) to arm (arm_thick tall),
// followed by the constant-section arm and the SO-239 pad at the end.
module antenna_arm_B() {
    transition_start = iface_thick;            // front face of back plate
    transition_end   = iface_thick + transition_len;
    arm_y_end        = iface_thick + arm_length;
    pad_thick        = arm_thick + so239_pad_extra;

    // Tapered transition: full back-plate cross-section → arm cross-section
    hull() {
        translate([-iface_size/2, transition_start, center_z - iface_size/2])
            cube([iface_size, 0.1, iface_size]);
        translate([-arm_width/2, transition_end, center_z - arm_thick/2])
            cube([arm_width, 0.1, arm_thick]);
    }
    // Constant-section arm body up to the pad
    translate([-arm_width/2, transition_end - 0.1, center_z - arm_thick/2])
        cube([arm_width, arm_y_end - transition_end - so239_pad_size/2 + 1, arm_thick]);
    // SO-239 pad
    translate([-so239_pad_size/2, arm_y_end - so239_pad_size, center_z - pad_thick/2])
        cube([so239_pad_size, so239_pad_size, pad_thick]);
}

// (Gusset module no longer needed — the taper covers both top and bottom.)
module arm_gusset_B() { }

module so239_holes_B() {
    arm_y_end    = iface_thick + arm_length;
    pad_y_center = arm_y_end - so239_pad_size / 2;
    pad_thick    = arm_thick + so239_pad_extra;
    h_drill      = pad_thick + 6;
    translate([0, pad_y_center, center_z])
        cylinder(h = h_drill, d = so239_hole_d, center = true);
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx * so239_bolt_pcd/2,
                       pad_y_center + sy * so239_bolt_pcd/2,
                       center_z])
                cylinder(h = h_drill, d = so239_bolt_d, center = true);
}

// Outer geometry chamfered via minkowski; the back (mating) face is
// re-flattened by clipping at Y = 0.
module part_B() {
    difference() {
        intersection() {
            minkowski() {
                union() {
                    iface_back_plate();
                    antenna_arm_B();
                    arm_gusset_B();
                }
                sphere(r = chamfer_r, $fn = 12);
            }
            // Clip the back face (Y ≥ 0) — keeps the mating plane flat
            // where it touches Part A.
            translate([-300, 0, -300])
                cube([600, 600, 600]);
        }
        iface_thru_holes();
        so239_holes_B();
    }
}

// =====================================================
// Render
// =====================================================

if (part == "preview") {
    color("DimGray")  part_A();
    color("SteelBlue") translate([0, iface_outer_y, 0]) part_B();
    %translate([0, 0, -10]) cylinder(h = bracket_h + 20, d = pole_d);
}
else if (part == "exploded") {
    color("DimGray")  part_A();
    color("SteelBlue") translate([0, iface_outer_y + 30, 0]) part_B();
    %translate([0, 0, -10]) cylinder(h = bracket_h + 20, d = pole_d);
}
else if (part == "base")  part_A();
else if (part == "mount") part_B();
