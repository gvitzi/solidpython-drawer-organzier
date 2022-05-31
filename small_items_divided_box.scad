
base_unit = 25;

default_height=30;
x = 250;
y = 200;
z = default_height;

labels = true;
label_w = 20;

divider_spacing_y = 100;
divider_spacing_x = 50;
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
    if (labels == true) {
        label_size = 8;
        diagonal = sqrt(pow(label_size,2) / 2);
        difference() {
            translate([wall_thickness-diagonal,(x-label_w)/2,z-diagonal])rotate([0,45,0])cube([label_size,label_w,label_size]);
            translate([-label_size+0.1,(x-label_w)/2 - 1,z-label_size*2])rotate([0,0,0])cube([label_size,label_w + 2,label_size*2]);
        }  
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

module dividers(h) {
    for(div_y = [divider_spacing_y : divider_spacing_y : y-divider_spacing_y+1]) {
        translate([div_y,wall_thickness,0]) {
            divider_y();
        }
    }

    for(div_x = [divider_spacing_x : divider_spacing_x : x-divider_spacing_x+1]) {
        translate([wall_thickness,div_x,0])divider_x();
    }
}

module labels() {
    for(div_y = [divider_spacing_y : divider_spacing_y : y]) {
        for(div_x = [divider_spacing_x : divider_spacing_x : x]) {
            translate([-divider_spacing_y + div_y,-y + divider_spacing_x + div_x,0]) label();
        }
    }
}

module box() {
    // Floor
    linear_extrude(wall_thickness)hull()corners(x,y);

    // Walls
    linear_extrude(z)walls();

    labels();
    dividers();
}

module divider_y(len=10, h=z) {
    l = x-wall_thickness;
    translate([0,-wall_thickness/2,wall_thickness])cube([wall_thickness,l,h-wall_thickness]);
}

module divider_x(len=10, h=z) {
    l = y-wall_thickness;
    translate([-wall_thickness/2,0,wall_thickness])cube([l, wall_thickness,h-wall_thickness]);
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
