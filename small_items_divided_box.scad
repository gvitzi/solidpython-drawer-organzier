
base_unit = 25;

default_height=30;
x = 50;
y = 100;
z = default_height;

labels = true;
label_w = 20;

divider_spacing = 50;
divider_length = 25;
divider_height = -1;
divider_gap = 0.5;
corner_radius = 2;
wall_thickness = 1.0;

guide_w = 1;
guide_d = 1; // guide depth

$fn = 64;

module corners(x1,y1) {
    r = corner_radius;
    translate([r,r])circle(r=r);
    translate([r,x1-r])circle(r=r);
    translate([y1-r,x1-r])circle(r=r);
    translate([y1-r,r])circle(r=r);
}

module walls() {
    difference() {
        hull()corners(x,y);
        translate([wall_thickness,wall_thickness,0])hull()corners(x-wall_thickness*2, y-wall_thickness*2);
    }
}

module label() {
    label_size = 8;
    diagonal = sqrt(pow(label_size,2) / 2);
    difference() {
        translate([wall_thickness-diagonal,(x-label_w)/2,z-diagonal])rotate([0,45,0])cube([label_size,label_w,label_size]);
        translate([-label_size+0.1,(x-label_w)/2 - 1,z-label_size*2])rotate([0,0,0])cube([label_size,label_w + 2,label_size*2]);
    }
}

module divider_guide(size_arr) {
    guide_spacing = wall_thickness + divider_gap;

    w = size_arr[0];
    d = size_arr[1];
    z = size_arr[2];
    translate([guide_spacing/2,0,0])linear_extrude(z)polygon([
        [0,0],
        [0,d],
        [w,0]
    ]);
    
    translate([-guide_spacing/2,0,z])rotate([0,180,0])linear_extrude(z)polygon([
        [0,0],
        [0,d],
        [w,0]
    ]);
}

module divider_guides(h) {
    for(guide_y = [base_unit : base_unit : y-base_unit+1]) {
        translate([guide_y,wall_thickness,0])divider_guide([guide_w,guide_d,h]);
        translate([guide_y,x-wall_thickness,0])rotate([0,0,180])divider_guide([guide_w,guide_d,h]);
    }

    for(guide_x = [base_unit : base_unit : x-base_unit+1]) {
        translate([wall_thickness,guide_x,0])rotate([0,0,270])divider_guide([guide_w,guide_d,h-wall_thickness]);
        translate([y-wall_thickness,guide_x,0])rotate([0,0,90])divider_guide([guide_w,guide_d,h-wall_thickness]);
    }
}

module box() {
    // Floor
    linear_extrude(wall_thickness)hull()corners(x,y);

    // Walls
    linear_extrude(z)walls();

    if (labels == true) {
        label();
    }

    dividers();
}

module divider(h=z, labelled=false) {
    l = x-wall_thickness;
    if (divider_height == 0) {
        h = z;
    } else {
        h = divider_height;
    }

    translate([0,-wall_thickness/2,-wall_thickness])cube([wall_thickness,l,h-wall_thickness]);

    // if (labelled) {
    //     translate([0,0,-wall_thickness])label();
    // }

    // for(guide_x = [base_unit : base_unit : x-base_unit+1]) {
    //     translate([0,guide_x,0])rotate([0,0,90])divider_guide([guide_w,guide_d,h-wall_thickness]);
    //     translate([wall_thickness,guide_x,0])rotate([0,0,270])divider_guide([guide_w,guide_d,h-wall_thickness]);
    // }
}

module labelled_divider() {
    divider(labelled=true);
}

module label_clip() {
    spiel = 0.2;
    leg_lentgh = 5;
    leg_thickness = 0.8;
    label_size = 4;
    translate([0,label_w/2,0])rotate([90,90,0])linear_extrude(label_w) {
        translate([0,0])square([leg_lentgh,leg_thickness]);
        translate([0,wall_thickness + spiel+leg_thickness])square([leg_lentgh,leg_thickness]);
        translate([0,0])rotate([0,0,90])square([wall_thickness + spiel+leg_thickness*2,leg_thickness]);
        translate([-leg_thickness,wall_thickness + spiel+leg_thickness*2])polygon([[0,0],[label_size,0],[label_size,label_size]]);
    }
}

box();
translate([y/2 - wall_thickness/2,wall_thickness + 0.3,wall_thickness+1])divider();
//translate([y/2 - wall_thickness/2,wall_thickness + 0.3,wall_thickness])labelled_divider();

// translate([50-3,base_unit/2,z+1]){
//     label_clip();
// }