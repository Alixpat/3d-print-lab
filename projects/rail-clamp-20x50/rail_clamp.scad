// Two-piece clamp for a horizontal rectangular railing (rambarde), section 50 x 20 mm.
//
// The clamp splits FRONT/BACK along the vertical plane Y=0 into two halves that
// sandwich the rail and bolt together through top & bottom flanges (4x M6).
// Tightening closes the seam gap and grips the rail. The FRONT half carries an
// accessory platform on its +Y face (4x M6 through-holes, 32 x 36 mm pattern).
// A clip-on weather capot (3rd part) covers the top.
//
// Frame: rail axis = X, cross-section in the YZ plane, centred on the origin.

/* [Render] */
part = "preview"; // [preview, exploded, assembly, front, back, capot, assembly_capot]

/* [Rail — external dimensions] */
rail_w    = 50;    // depth  (Y)
rail_h    = 20;    // height (Z)
fit_clear = 0.5;   // clearance around the rail, per face (0.5 for ASA shrinkage)

/* [Edges] */
round_r   = 1.5;   // outer-edge rounding (0 = sharp; minkowski if > 0)

/* [Clamp shell] */
wall      = 6;     // wall thickness (uniform)
clamp_len = 50;    // length along the rail axis (X) = overall width
seam_gap  = 1.2;   // parting-plane gap (closes when bolted -> grip)

/* [Closure flanges + bolts (top & bottom)] */
flange_ext   = 13;   // flange Z extension beyond the shell
flange_thick = 6;    // flange Y thickness (per half)
bolt_d       = 6.2;  // M6 clearance hole (thread 5.7 + 0.5) — closure & platform
n_bolt_x     = 2;    // bolts per flange along X
bolt_pitch_x = 32;   // bolt spacing along X (aligned with the platform holes)

/* [Accessory platform (front +Y face)] */
platform   = true;
plat_pcd_x = 32;     // hole pattern, X (centre-to-centre)
plat_pcd_z = 36;     // hole pattern, Z (centre-to-centre)
plat_w     = clamp_len;   // width (X), aligned with the collar
plat_h     = 6;      // pad thickness (+Y)
plat_nut_clear_d = 12;    // nut-clearance pocket size behind each hole
plat_nut_clear_h = 7;     // its depth into the wall

/* [Engraving] */
engrave        = true;        // "ANFSI" on the collar back face
engrave_text   = "ANFSI";
adc_text       = "ADC PATTE";
engrave_depth  = 1;
engrave_corner = 3;           // recess rounded-corner radius
engrave_bold   = 0.4;         // text thickening per side
engrave_rect_x = 42; engrave_rect_z = 15; engrave_size = 9;   // collar "ANFSI"
adc_rx   = 44; adc_ry   = 13; adc_sz   = 5;   // capot "ADC PATTE"
anfsi_rx = 44; anfsi_ry = 11; anfsi_sz = 7;   // capot "ANFSI"
cap_text_gap = 3;             // gap between the two capot labels

/* [Capot — clip-on weather cap] */
capot_t   = 2.5;     // shell wall thickness
capot_fit = 0.5;     // clearance over the clamp
clip_w    = 2;       // grip groove/tongue width (∩)
clip_d    = 2;       // grip groove/tongue depth (∩)
clip_len  = 13;      // side snap-detent length (Y)
det_eng   = 0.6;     // detent barb engagement past the face (= insertion flex)
det_rr    = 1.3;     // detent recess radius
det_rb    = 1.0;     // detent barb radius (≥ capot_fit + eng → stays solidly attached)
det_play  = 0.5;     // detent length play (Y)

$fn = 64;

// ---- Derived ----
inner_w   = rail_w + 2 * fit_clear;     // cavity depth  (Y)
inner_h   = rail_h + 2 * fit_clear;     // cavity height (Z)
half_in_w = inner_w / 2;
shell_y   = inner_w / 2 + wall;         // outer front/back wall (Y)
shell_z   = inner_h / 2 + wall;         // outer top/bottom wall (Z)
plat_face = shell_y + plat_h;           // platform front surface (Y)
plat_ht   = 2 * (shell_z + flange_ext); // platform height (Z) = flush with flanges
bolt_z    = shell_z + flange_ext / 2;   // bolt centre height
bolt_xs   = n_bolt_x == 1 ? [0]
            : [for (i = [0:n_bolt_x-1]) -bolt_pitch_x/2 + i*bolt_pitch_x/(n_bolt_x-1)];
fl_top    = shell_z + flange_ext;            // flange top Z (= platform top Z)
fl_yc     = seam_gap/2 + flange_thick/2;     // flange thickness centre (per half)
plat_yc   = (shell_y + plat_face) / 2;       // platform thickness centre (Y)
clip_z    = (inner_h/2 + shell_z) / 2;       // detent centre (in the top-wall thickness)
clip_gy   = (seam_gap/2 + shell_y) / 2;      // detent Y on the side faces
eps       = 0.05;

// Engraved label: raised text in a rounded-corner recess (extruded in +Z; the
// caller positions/orients it). Shared by the collar and capot engravings.
module label(txt, w, h, sz) {
    linear_extrude(engrave_depth + eps)
        difference() {
            offset(r = engrave_corner) offset(r = -engrave_corner) square([w, h], center = true);
            offset(delta = engrave_bold) text(txt, size = sz, halign = "center", valign = "center");
        }
}

// =====================================================
// Clamp half (front orientation) — mirror across Y for the back half
// =====================================================
// Solid body (outer block + top/bottom flanges), undersized by round_r on the
// faces the minkowski will grow, so the rounded part keeps its nominal size. The
// front face is left at shell_y so it overlaps the platform and stays connected.
module half_shell_solid() {
    rr = round_r;
    translate([-clamp_len/2 + rr, seam_gap/2, -shell_z + rr])
        cube([clamp_len - 2*rr, shell_y - seam_gap/2, 2*shell_z - 2*rr]);
    for (sz = [-1, 1])
        translate([-clamp_len/2 + rr, seam_gap/2,
                   sz > 0 ? (shell_z - rr) : -(shell_z - rr) - flange_ext])
            cube([clamp_len - 2*rr, flange_thick - rr, flange_ext]);
}

// Cuts shared by both halves: rail cavity + horizontal closure bolt holes.
// (Lengths extended by round_r so they fully cut the minkowski-grown body.)
module half_shell_cuts() {
    translate([-clamp_len/2 - round_r - 2, seam_gap/2 - eps, -inner_h/2])
        cube([clamp_len + 2*round_r + 4, half_in_w - seam_gap/2 + eps, inner_h]);
    for (sz = [-1, 1]) for (bx = bolt_xs)
        translate([bx, seam_gap/2 - round_r - 2, sz * bolt_z])
            rotate([-90, 0, 0]) cylinder(d = bolt_d, h = flange_thick + 2*round_r + 4);
}

// Round the outer edges with a small sphere (minkowski), then re-flatten one face
// at Y = clip_y by clipping (the seam stays flat). Cuts are applied AFTER this.
module rounded_at(clip_y) {
    if (round_r > 0)
        intersection() {
            minkowski() { children(); sphere(r = round_r, $fn = 16); }
            translate([-500, clip_y, -500]) cube([1000, 1000, 1000]);
        }
    else children();
}

// =====================================================
// Platform (front half only)
// =====================================================
// Pad on the +Y face; its BACK face (shell_y) is kept flat for the nut.
module platform_pad() {
    rr = round_r;
    translate([-plat_w/2 + rr, shell_y, -plat_ht/2 + rr])
        cube([plat_w - 2*rr, (plat_face - rr) - shell_y, plat_ht - 2*rr]);
}

// M6 through-holes (accessory bolts from the front, nut at the back).
module platform_holes() {
    for (sx = [-1, 1]) for (sz = [-1, 1])
        translate([sx*plat_pcd_x/2, shell_y - round_r - 2, sz*plat_pcd_z/2])
            rotate([-90, 0, 0]) cylinder(d = bolt_d, h = plat_h + 2*round_r + 4);
}

// Behind each platform hole (rambarde side): a square pocket for the hex nut and a
// deep channel that swallows the full screw thread (a long M6 doesn't hit the flange).
module platform_nut_clearance() {
    w = plat_nut_clear_d;
    chan_depth = (shell_y + eps) - (seam_gap/2 + flange_thick);
    for (sx = [-1, 1]) for (sz = [-1, 1]) {
        translate([sx*plat_pcd_x/2 - w/2, shell_y - plat_nut_clear_h, sz*plat_pcd_z/2 - w/2])
            cube([w, plat_nut_clear_h + eps, w]);
        translate([sx*plat_pcd_x/2, shell_y + eps, sz*plat_pcd_z/2])
            rotate([90, 0, 0]) cylinder(d = bolt_d + 0.8, h = chan_depth);
    }
}

// =====================================================
// Capot grip — ∩ grooves (front platform + rear flange) and side snap detent
// =====================================================
// Top chant grooves (clip_w x clip_d slot, open upward) + side grooves down the
// two X-end faces, forming a ∩ the capot ribs drop into.
module flange_chant_groove()   // rear: top chant of the back flange
    translate([-clamp_len/2, -fl_yc - clip_w/2, fl_top - clip_d])
        cube([clamp_len, clip_w, clip_d + 2]);
module platform_chant_groove() // front: top chant of the platform
    translate([-plat_w/2, plat_yc - clip_w/2, fl_top - clip_d])
        cube([plat_w, clip_w, clip_d + 2]);
module flange_side_grooves()   // rear: X-end grooves, stop at the rail
    for (sx = [-1, 1])
        translate([sx > 0 ? clamp_len/2 - clip_d : -clamp_len/2, -fl_yc - clip_w/2, rail_h/2])
            cube([clip_d, clip_w, fl_top - rail_h/2]);
module platform_side_grooves() // front: X-end grooves, down to the platform bottom
    for (sx = [-1, 1])
        translate([sx > 0 ? plat_w/2 - clip_d : -plat_w/2, plat_yc - clip_w/2, -plat_ht/2 - 1])
            cube([clip_d, clip_w, fl_top + plat_ht/2 + 1]);

// Snap detent on the left & right side faces of the front half: a rounded (capsule)
// recess centred in the top-wall thickness. The capot carries the matching barb.
module side_clip_recess() {
    for (sx = [-1, 1])
        hull() for (sy = [-1, 1])
            translate([sx*clamp_len/2, clip_gy + sy*(clip_len/2 - det_rr), clip_z])
                sphere(r = det_rr, $fn = 28);
}

// "ANFSI" on the back face of the back half.
module engraving() {
    yf = -(shell_y + round_r);
    translate([0, yf + engrave_depth, 0]) rotate([90, 0, 0])
        label(engrave_text, engrave_rect_x, engrave_rect_z, engrave_size);
}

// =====================================================
// Final clamp halves
// =====================================================
module front_half() {
    difference() {
        union() {
            rounded_at(seam_gap/2) half_shell_solid();
            if (platform) rounded_at(shell_y) platform_pad();
        }
        half_shell_cuts();
        if (platform) {
            platform_holes();
            platform_nut_clearance();
            platform_chant_groove();    // capot front grip (top)
            platform_side_grooves();    // capot front grip (sides)
        }
        side_clip_recess();             // capot snap detent (left & right)
    }
}

module back_half() {
    difference() {
        mirror([0, 1, 0]) difference() {
            rounded_at(seam_gap/2) half_shell_solid();
            half_shell_cuts();
        }
        if (engrave) engraving();
        flange_chant_groove();          // capot rear grip (top)
        flange_side_grooves();          // capot rear grip (sides)
    }
}

// =====================================================
// CAPOT — clip-on weather cap (3rd part)
// Roof + two side walls; open at the front (platform) and just past the rear flange
// groove (does not cover the grey collar); stops at the rail. Held by ∩ tongues that
// drop into the chant grooves (front platform + rear flange) plus a rounded snap
// detent on the two side faces. "ADC PATTE" over "ANFSI" engraved on the roof.
// =====================================================
module capot_part() {
    cx  = clamp_len/2;
    cyf = shell_y + plat_h;             // platform front (open)
    zr  = rail_h/2;                     // walls stop at the rail
    yb  = -(seam_gap/2 + flange_thick); // rear edge: just past the back-flange groove
    ix  = cx + capot_fit;   ox  = ix + capot_t;
    izt = fl_top + capot_fit;  ozt = izt + capot_t;
    adc_y   = (yb + cyf)/2 - (cap_text_gap + anfsi_ry)/2;          // "ADC PATTE" (lower)
    anfsi_y = adc_y + adc_ry/2 + cap_text_gap + anfsi_ry/2;        // "ANFSI" (upper)
    rib_x = cx - clip_d + 0.3;
    difference() {
        union() {
            translate([-ox, yb, izt]) cube([2*ox, cyf - yb, capot_t]);          // roof
            for (sx = [-1, 1])                                                  // side walls
                translate([sx > 0 ? ix : -ox, yb, zr]) cube([capot_t, cyf - yb, ozt - zr]);
            for (yc = [-fl_yc, plat_yc])                                        // top ribs
                translate([-cx, yc - (clip_w - 0.4)/2, fl_top - clip_d + 0.3])
                    cube([clamp_len, clip_w - 0.4, izt - (fl_top - clip_d + 0.3)]);
            for (sx = [-1, 1]) for (yc = [-fl_yc, plat_yc])                     // side ribs (∩)
                translate([sx > 0 ? rib_x : -ix, yc - (clip_w - 0.4)/2, zr])
                    cube([ix - rib_x, clip_w - 0.4, fl_top - zr]);
            for (sx = [-1, 1])                                                  // snap barbs
                hull() for (sy = [-1, 1])
                    translate([sx*(cx - det_eng + det_rb),
                               clip_gy + sy*((clip_len - 2*det_play)/2 - det_rb), clip_z])
                        sphere(r = det_rb, $fn = 28);
        }
        // roof labels: "ADC PATTE" (lower) + "ANFSI" (upper)
        translate([0, adc_y,   ozt - engrave_depth]) label(adc_text, adc_rx, adc_ry, adc_sz);
        translate([0, anfsi_y, ozt - engrave_depth]) label(engrave_text, anfsi_rx, anfsi_ry, anfsi_sz);
    }
}

// =====================================================
// Hardware (visualisation only) — measured M6: thread 5.7 x 30, hex 9.8 AF
// =====================================================
scr_d = 5.7; scr_len = 30; scr_hd_af = 9.8; scr_hd_h = 4; scr_nu_af = 9.8; scr_nu_h = 4.8;
module m6_screw() color("Silver") {
    translate([0, 0, -scr_len]) cylinder(d = scr_d, h = scr_len, $fn = 20);
    cylinder(d = scr_hd_af / cos(30), h = scr_hd_h, $fn = 6);
}
module m6_nut() color("Gold") difference() {
    cylinder(d = scr_nu_af / cos(30), h = scr_nu_h, $fn = 6);
    translate([0, 0, -1]) cylinder(d = scr_d + 0.3, h = scr_nu_h + 2, $fn = 20);
}
module fasteners() {
    if (platform)
        for (sx = [-1, 1]) for (sz = [-1, 1]) {
            translate([sx*plat_pcd_x/2, plat_face, sz*plat_pcd_z/2]) rotate([-90,0,0]) m6_screw();
            translate([sx*plat_pcd_x/2, shell_y,  sz*plat_pcd_z/2]) rotate([ 90,0,0]) m6_nut();
        }
    for (sx = bolt_xs) for (sz = [-1, 1]) {
        translate([sx,  seam_gap/2 + flange_thick,  sz*bolt_z]) rotate([-90,0,0]) m6_screw();
        translate([sx, -(seam_gap/2 + flange_thick), sz*bolt_z]) rotate([ 90,0,0]) m6_nut();
    }
}

// =====================================================
// Render
// =====================================================
module rail_ghost()
    %translate([-clamp_len/2 - 15, -rail_w/2, -rail_h/2]) cube([clamp_len + 30, rail_w, rail_h]);

if (part == "front") front_half();
else if (part == "back") back_half();
else if (part == "capot") color("OliveDrab") capot_part();
else {
    yf = part == "exploded" ? 22 : 0;
    color("SteelBlue") translate([0,  yf, 0]) front_half();
    color("DimGray")   translate([0, -yf, 0]) back_half();
    if (part == "assembly") fasteners();
    if (part == "assembly_capot") color("OliveDrab") capot_part();
    rail_ghost();
}
