// Tux M5Stamp S3 case — v4
// Multi-part: case (black) + belly insert (white) + beak & feet (yellow).
// The head/cap lifts off at the collar to install the M5Stamp S3 board.

/* [Render] */
part = "preview"; // [preview, exploded, case_top, case_bottom, belly, beak, foot_left, foot_right]

/* [Faceting — higher = smoother] */
poly_fn = 36;
$fn = poly_fn;

/* [Body — pear silhouette] */
body_bottom_d = 58;
body_mid_d    = 52;
body_top_d    = 38;
body_bottom_z = -22;
body_mid_z    = -6;
body_top_z    = 8;

/* [Head] */
head_d = 38;
head_z = 24;

/* [Beak] */
beak_w        = 14;
beak_h        = 5.5;
beak_l        = 10;
beak_droop    = 8;
beak_tenon_d  = 4;
beak_tenon_l  = 5;

/* [Feet] */
foot_w        = 22;
foot_l        = 28;
foot_h        = 8;
foot_spread   = 13;
foot_angle    = 10;
foot_tenon_d  = 4;
foot_tenon_l  = 7;

/* [Flippers] */
flipper_h     = 14;
flipper_thick = 4.5;
flipper_l     = 13;
flipper_z     = -4;
flipper_angle = 25;

/* [Belly + face insert (white)] */
belly_thick    = 1.6;   // insert thickness (also recess depth on body)
belly_oval_w   = 20;    // narrower than flippers so they aren't covered
belly_oval_h   = 22;
bridge_w       = 13;
bridge_h       = 32;
face_oval_w    = 22;
face_oval_h    = 16;
pupil_d        = 3.2;
pupil_spread   = 7.5;
pupil_z_offset = 2.0;

/* [M5Stamp S3] */
m5_w   = 18.4;
m5_l   = 24.4;
m5_h   = 9.6;
usb_w  = 10.0;
usb_h  = 4.2;
tol    = 0.3;

/* [Shell + assembly] */
wall      = 2.0;
lip_t     = 1.2;   // register-lip thickness (radial)
lip_h     = 3.0;   // lip height above the split
lip_clear = 0.3;   // clearance for the lip in its socket

// Derived
m5_pos_z = -10;
split_z  = 4;

beak_base_y = -head_d * 0.42;
beak_base_z = head_z - head_d * 0.05;

// =====================================================
// Silhouette (no beak, no feet — those are separate parts)
// =====================================================

module tux_body() {
    hull() {
        translate([0, 0, body_bottom_z]) sphere(d = body_bottom_d);
        translate([0, 0, body_mid_z])    sphere(d = body_mid_d);
        translate([0, 0, body_top_z])    sphere(d = body_top_d);
    }
}

module tux_head() {
    translate([0, 0, head_z])
    hull() {
        sphere(d = head_d);
        translate([0, -head_d * 0.06, -head_d * 0.04])
            scale([1, 0.9, 1])
                sphere(d = head_d * 0.95);
    }
}

module tux_neck() {
    hull() {
        translate([0, 0, body_top_z + 0.5])
            sphere(d = body_top_d * 0.88);
        translate([0, 0, head_z - head_d * 0.30])
            sphere(d = head_d * 0.80);
    }
}

module tux_flipper(side = 1) {
    translate([side * body_mid_d * 0.43, 0, flipper_z])
    rotate([0, side * flipper_angle, side * 10])
    hull() {
        translate([0, 0, flipper_h/2])
            scale([flipper_thick/8, 0.7, 1]) sphere(d = 6);
        translate([0, -2, -flipper_h/2])
            scale([flipper_thick/10, flipper_l/8, 1]) sphere(d = 7);
    }
}

module tux_main_outline() {
    union() {
        tux_body();
        tux_head();
        tux_neck();
        tux_flipper( 1);
        tux_flipper(-1);
    }
}

// =====================================================
// Beak (separate yellow part)
// =====================================================

module beak_shape() {
    tip_y = beak_base_y - beak_l;
    tip_z = beak_base_z - beak_h * 0.6;
    hull() {
        translate([0, beak_base_y, beak_base_z])
            scale([beak_w/8, 0.5, beak_h/8])
                sphere(d = 8);
        translate([0, tip_y, tip_z])
            scale([(beak_w*0.18)/4, 0.5, (beak_h*0.3)/4])
                sphere(d = 4);
    }
}

// Tenon goes IN the head (+Y direction from base)
module beak_tenon() {
    translate([0, beak_base_y + 0.5, beak_base_z])
    rotate([-90, 0, 0])
        cylinder(d = beak_tenon_d, h = beak_tenon_l, $fn = 24);
}

module beak_socket() {
    translate([0, beak_base_y + 0.5 - 0.1, beak_base_z])
    rotate([-90, 0, 0])
        cylinder(d = beak_tenon_d + 2*tol, h = beak_tenon_l + 0.5, $fn = 24);
}

module beak_part() {
    union() {
        beak_shape();
        beak_tenon();
    }
}

// =====================================================
// Feet (separate yellow parts, ±1 mirrored)
// =====================================================

function foot_pos(side) = [
    side * foot_spread,
    -foot_l * 0.20,
    body_bottom_z - body_bottom_d * 0.30 + foot_h * 0.4
];

module foot_shape(side = 1) {
    pos = foot_pos(side);
    translate(pos)
    rotate([0, 0, side * foot_angle])
    hull() {
        scale([1, 1, foot_h / foot_w])
            sphere(d = foot_w);
        translate([0, -foot_l * 0.55, 0])
            scale([0.7, 1, foot_h * 0.75 / foot_w])
                sphere(d = foot_w);
    }
}

module foot_tenon(side = 1) {
    pos = foot_pos(side);
    translate([pos[0], pos[1], pos[2] + foot_h * 0.35])
        cylinder(d = foot_tenon_d, h = foot_tenon_l, $fn = 24);
}

module foot_socket(side = 1) {
    pos = foot_pos(side);
    translate([pos[0], pos[1], pos[2] + foot_h * 0.35 - 0.1])
        cylinder(d = foot_tenon_d + 2*tol, h = foot_tenon_l + 0.5, $fn = 24);
}

module foot_part(side = 1) {
    union() {
        foot_shape(side);
        foot_tenon(side);
    }
}

// =====================================================
// Belly + face insert (white)
// =====================================================

// Hourglass zone: cylinders along Y, elliptical XZ cross-section.
// Intersected with front_thin_shell, gives the curved belly+face patch.
module _belly_cyl(w, h, z) {
    translate([0, 0, z])
        rotate([90, 0, 0])
            scale([w/2, h/2, 1])
                cylinder(h = 200, d = 2, center = true, $fn = 32);
}

module belly_zone() {
    union() {
        _belly_cyl(belly_oval_w, belly_oval_h, body_mid_z + 2);            // belly
        _belly_cyl(bridge_w,     bridge_h,     (body_mid_z + 2 + head_z + head_d * 0.08) / 2);  // chest
        _belly_cyl(face_oval_w,  face_oval_h,  head_z + head_d * 0.08);    // face
    }
}

module pupil_hole(side = 1) {
    // axis along +Y so the cylinder drills from outside-the-face into the head
    translate([side * pupil_spread, -head_d * 0.55, head_z + pupil_z_offset])
    rotate([-90, 0, 0])
        cylinder(d = pupil_d, h = 10, $fn = 20);
}

module front_thin_shell() {
    difference() {
        tux_main_outline();
        translate([0, belly_thick, 0]) tux_main_outline();
    }
}

module belly_insert_volume() {
    intersection() {
        front_thin_shell();
        belly_zone();
    }
}

module belly_insert() {
    difference() {
        belly_insert_volume();
        pupil_hole( 1);
        pupil_hole(-1);
    }
}

// =====================================================
// Internal features
// =====================================================

module inner_body() {   // body part of the cavity (drives the split-region wall)
    hull() {
        translate([0, 0, body_bottom_z + 2]) scale([0.84, 0.84, 0.88]) sphere(d = body_bottom_d);
        translate([0, 0, body_mid_z])        scale([0.84, 0.84, 0.88]) sphere(d = body_mid_d);
        translate([0, 0, body_top_z])        scale([0.84, 0.84, 0.88]) sphere(d = body_top_d);
    }
}

module tux_inner() {
    union() {
        inner_body();
        translate([0, 0, head_z]) scale([0.78, 0.80, 0.80]) sphere(d = head_d);
        hull() {
            translate([0, 0, body_top_z + 0.5])        scale([0.78, 0.78, 1]) sphere(d = body_top_d * 0.75);
            translate([0, 0, head_z - head_d * 0.30])  scale([0.78, 0.78, 1]) sphere(d = head_d * 0.68);
        }
    }
}

module m5_cavity() {
    translate([0, 0, m5_pos_z])
        cube([m5_w + 4*tol, m5_l + 4*tol, m5_h + 4*tol], center = true);
}

module usb_cutout() {
    translate([0, body_mid_d * 0.55, m5_pos_z])
    rotate([90, 0, 0])
        hull() {
            translate([ (usb_w-usb_h)/2, 0, 0]) cylinder(d = usb_h, h = 30, $fn = 24);
            translate([-(usb_w-usb_h)/2, 0, 0]) cylinder(d = usb_h, h = 30, $fn = 24);
        }
}

// =====================================================
// Main case + collar split
// =====================================================

module case_solid() {
    difference() {
        tux_main_outline();
        tux_inner();
        m5_cavity();
        usb_cutout();
        beak_socket();
        foot_socket( 1);
        foot_socket(-1);
        belly_insert_volume();
    }
}

// Register lip (replaces the old free pegs): the inner part of the wall, raised
// above the split, so the two halves self-centre. It IS the wall extended (and
// reaches below the split to merge solidly). The top half gets the matching relief.
module register_lip() {
    intersection() {
        difference() {
            minkowski() { inner_body(); sphere(r = lip_t, $fn = 12); }
            inner_body();
        }
        translate([0, 0, split_z - 1.5]) cylinder(d = 400, h = lip_h + 1.5, $fn = 8);
    }
}

module register_socket() {   // relief in the top half so the lip nests (with clearance)
    intersection() {
        difference() {
            minkowski() { inner_body(); sphere(r = lip_t + lip_clear, $fn = 12); }
            inner_body();
        }
        translate([0, 0, split_z - 0.01]) cylinder(d = 400, h = lip_h + 1.5, $fn = 8);
    }
}

module case_half_bottom() {
    union() {
        difference() {
            case_solid();
            translate([0, 0, split_z + 100]) cube([300, 300, 200], center = true);
        }
        register_lip();
    }
}

module case_half_top() {
    intersection() {
        difference() {
            case_solid();
            translate([0, 0, split_z - 100]) cube([300, 300, 200], center = true);
            register_socket();
        }
        // keep only the main body -> drops tiny flipper slivers that poke above the split
        union() { tux_body(); tux_head(); tux_neck(); }
    }
}

// =====================================================
// Render
// =====================================================

if (part == "preview") {
    color("Black")  case_half_top();
    color("Black")  case_half_bottom();
    color("White")  belly_insert();
    color("Gold")   beak_part();
    color("Gold")   foot_part( 1);
    color("Gold")   foot_part(-1);
    %translate([0, 0, m5_pos_z]) cube([m5_w, m5_l, m5_h], center = true);
}
else if (part == "exploded") {
    color("Black")  translate([0, 0, 35])  case_half_top();
    color("Black")  case_half_bottom();
    color("White")  translate([0, -35, 5]) belly_insert();
    color("Gold")   translate([0, -25, 25]) beak_part();
    color("Gold")   translate([-22, 0, -15]) foot_part( 1);
    color("Gold")   translate([ 22, 0, -15]) foot_part(-1);
    color("Red")    %translate([0, 0, m5_pos_z + 18]) cube([m5_w, m5_l, m5_h], center = true);
}
else if (part == "case_top")    rotate([180, 0, 0]) case_half_top();
else if (part == "case_bottom") case_half_bottom();
else if (part == "belly")       belly_insert();
else if (part == "beak")        beak_part();
else if (part == "foot_left")   foot_part( 1);
else if (part == "foot_right")  foot_part(-1);
